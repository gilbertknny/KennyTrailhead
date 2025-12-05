/*
 * @Author: Williams
 * @Date: 2025-11-12
 * @Class: Aswata_Async_Asset_Test
 * @Description: Optimized test class for Aswata_Async_Asset
 * @Last Modified: 2025-11-14 18:30:00
 */

@isTest
public class Aswata_Async_Asset_Test {
    private static void verify(Id recordId, Decimal expected, String msg, Boolean isOpportunity) {
        if (isOpportunity) {
            Opportunity opp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :recordId];
            System.assertEquals(expected, opp.Total_Sum_Insured__c, msg);
        } else {
            Asset risk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :recordId];
            System.assertEquals(expected, risk.Amount_Insured__c, msg);
        }
    }
    
    private static List<Asset> buildAssets(Opportunity opp, Asset risk, Integer count, Decimal baseAmount, Decimal rate) {
        RecordType rtAsset = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset' AND Name = 'Asset' LIMIT 1];
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= count; i++) {
            assets.add(new Asset(
                Name = 'Asset-' + i,
                Opportunity__c = opp.Id,
                ParentId = risk.Id,
                //COB__c = '201',
                RecordTypeId = rtAsset.Id,
                Amount__c = baseAmount * i,
                Exchange_Rate__c = rate
            ));
        }
        return assets;
    }

    /**
     * Test 1: Insert Assets
     */
    @isTest
    static void test_BasicOperations() {
        Account acc = Aswata_TestDataFactory.createAccount('Basic Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Basic Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        Test.startTest();
        
        List<Asset> assets = buildAssets(opp, risk, 3, 1000000, 1);
        insert assets;
        
        Test.stopTest();
        
        verify(risk.Id, 6000000, 'Insert: 6M', false);
        verify(opp.Id, 6000000, 'Opp: 6M', true);
    }
    
    /**
     * Test 2: Update Amount
     */
    @isTest
    static void test_UpdateOperations() {
        Account acc = Aswata_TestDataFactory.createAccount('Update Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Update Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        List<Asset> assets = buildAssets(opp, risk, 3, 1000000, 1);
        insert assets;
        
        Test.startTest();
        
        assets[0].Amount__c = 5000000;
        update assets[0];
        
        Test.stopTest();
        
        verify(risk.Id, 10000000, 'Update Amount: 10M', false);
        verify(opp.Id, 10000000, 'Opp: 10M', true);
    }
    
    /**
     * Test 3: Update Exchange Rate
     */
    @isTest
    static void test_UpdateExchangeRate() {
        Account acc = Aswata_TestDataFactory.createAccount('Rate Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Rate Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        List<Asset> assets = buildAssets(opp, risk, 1, 1000, 15000);
        insert assets;
        
        Test.startTest();
        
        assets[0].Exchange_Rate__c = 16000;
        update assets[0];
        
        Test.stopTest();
        
        verify(risk.Id, 16000000, 'Update Rate: 16M', false);
        verify(opp.Id, 16000000, 'Opp: 16M', true);
    }
    
    /**
     * Test 4: Multi-Currency
     */
    @isTest
    static void test_CurrencyOperations() {
        Account acc = Aswata_TestDataFactory.createAccount('Currency Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Currency Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        Test.startTest();
        
        List<Asset> assets = new List<Asset>();
        assets.addAll(buildAssets(opp, risk, 1, 1000, 12826));  
        assets.addAll(buildAssets(opp, risk, 1, 100, 16630));   
        assets.addAll(buildAssets(opp, risk, 1, 10000000, 1)); 
        insert assets;
        
        Test.stopTest();
        
        verify(risk.Id, 24489000, 'Multi-currency: 24.489M', false);
        verify(opp.Id, 24489000, 'Opp: 24.489M', true);
    }
    
    /**
     * Test 5: Both Amount and Exchange Rate Change
     */
    @isTest
    static void test_BothFieldsChange() {
        Account acc = Aswata_TestDataFactory.createAccount('Both Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Both Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        List<Asset> assets = buildAssets(opp, risk, 1, 1000, 12826);
        insert assets;
        
        Test.startTest();
        
        assets[0].Amount__c = 2000;
        assets[0].Exchange_Rate__c = 16000;
        update assets[0];
        
        Test.stopTest();
        
        verify(risk.Id, 32000000, 'Both changed: 32M', false);
        verify(opp.Id, 32000000, 'Opp: 32M', true);
    }
    
    /**
     * Test 6: Delete Asset
     */
    @isTest
    static void test_DeleteAsset() {
        Account acc = Aswata_TestDataFactory.createAccount('Delete Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Delete Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        List<Asset> assets = buildAssets(opp, risk, 3, 1000000, 1);
        insert assets;
        
        Test.startTest();

        delete assets[0];
        
        Test.stopTest();
        
        verify(risk.Id, 5000000, 'After delete: 5M', false);
        verify(opp.Id, 5000000, 'Opp: 5M', true);
    }
    
    /**
     * Test 7: Parent Change - Move Asset Between Risks
     */
    @isTest
    static void test_ParentChange() {
        Account acc = Aswata_TestDataFactory.createAccount('Move Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Move Opp');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        
        List<Asset> assets = buildAssets(opp, risk1, 3, 1000000, 1);
        insert assets;
        
        Test.startTest();
   
        assets[1].ParentId = risk2.Id;
        update assets[1];
        
        Test.stopTest();
        
        verify(risk1.Id, 4000000, 'Risk1: 4M', false);
        verify(risk2.Id, 2000000, 'Risk2: 2M', false);
        verify(opp.Id, 6000000, 'Opp: 6M', true);
    }
    
    /**
     * Test 8: Bulk Operations with Multiple Risks
     */
    @isTest
    static void test_BulkMultipleRisks() {
        Account acc = Aswata_TestDataFactory.createAccount('Bulk Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Bulk Opp');
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset risk3 = Aswata_TestDataFactory.createRisk(opp, 'Risk 3');
        
        Test.startTest();
        
        List<Asset> allAssets = new List<Asset>();
        allAssets.addAll(buildAssets(opp, risk1, 10, 1000000, 1)); // 55M
        allAssets.addAll(buildAssets(opp, risk2, 10, 1000000, 1)); // 55M
        allAssets.addAll(buildAssets(opp, risk3, 10, 1000000, 1)); // 55M
        insert allAssets;
        
        Test.stopTest();
        
        verify(risk1.Id, 55000000, 'Risk1: 55M', false);
        verify(risk2.Id, 55000000, 'Risk2: 55M', false);
        verify(risk3.Id, 55000000, 'Risk3: 55M', false);
        verify(opp.Id, 165000000, 'Opp: 165M', true);
        
        System.assert(Limits.getQueries() < Limits.getLimitQueries(), 'SOQL OK');
        System.assert(Limits.getDmlStatements() < Limits.getLimitDmlStatements(), 'DML OK');
    }
    
    /**
     * Test 9: Helper Methods & Edge Cases
     */
    @isTest
    static void test_HelpersAndEdgeCases() {
        Account acc = Aswata_TestDataFactory.createAccount('Helper Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Helper Opp');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        List<Asset> assets = buildAssets(opp, risk, 2, 1000000, 1);
        insert assets;
        
        Test.startTest();

        Set<Id> assetIds = new Set<Id>();
        for (Asset a : assets) assetIds.add(a.Id);
        
        Set<Id> parentIds = Aswata_Async_Asset.getParentAssetIds(assetIds);
        System.assertEquals(1, parentIds.size(), '1 parent');
        System.assert(parentIds.contains(risk.Id), 'Contains risk');
        
        Set<Id> oppIds = Aswata_Async_Asset.getOpportunityIds(assetIds);
        System.assertEquals(1, oppIds.size(), '1 opp');
        
        System.assertEquals(0, Aswata_Async_Asset.getParentAssetIds(null).size(), 'Null OK');
        System.assertEquals(0, Aswata_Async_Asset.getParentAssetIds(new Set<Id>()).size(), 'Empty OK');
        
        Asset nullAsset = Aswata_TestDataFactory.createAsset(opp, risk, 'Null Asset');
        nullAsset.Exchange_Rate__c = 1;
        update nullAsset;
        
        RecordType rtAsset = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset' AND Name = 'Asset' LIMIT 1];
        insert new Asset(
            Name = 'Orphan',
            Opportunity__c = opp.Id,
            RecordTypeId = rtAsset.Id,
            Amount__c = 1000000,
            Exchange_Rate__c = 1//,
            //COB__c = '201'
        );
        
        Aswata_Async_Asset.calculateParentAssetAmount(new Set<Id>());
        
        Test.stopTest();
        
        verify(risk.Id, 3000000, 'Only non-null: 3M', false);
        verify(opp.Id, 3000000, 'Opp: 3M', true);
    }
    
    /**
     * Test 10: Recalculation by Risk ID
     */
    @isTest
    static void test_RecalculationMethods() {
        Account acc = Aswata_TestDataFactory.createAccount('Recalc Test');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Recalc Opp');
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        
        insert buildAssets(opp, risk1, 2, 1000000, 1); // 3M
        insert buildAssets(opp, risk2, 3, 1000000, 1); // 6M
        
        risk1.Amount_Insured__c = 0;
        update risk1;
        opp.Total_Sum_Insured__c = 0;
        update opp;
        
        Test.startTest();
        
        Aswata_Async_Asset.calculateParentAssetAmount(new Set<Id>{risk1.Id});
        
        Test.stopTest();
        
        verify(risk1.Id, 3000000, 'Risk recalc: 3M', false);
    }
    
    /**
     * Test 11: Multiple Opportunities & RecordType Validation
     */
    @isTest
    static void test_OpportunityIsolation() {
        Account acc = Aswata_TestDataFactory.createAccount('Multi Opp Test');
        
        Opportunity opp1 = Aswata_TestDataFactory.createOpportunity(acc, 'Opp 1');
        Opportunity opp2 = Aswata_TestDataFactory.createOpportunity(acc, 'Opp 2');
        
        Opportunity check = [SELECT RecordType.Name FROM Opportunity WHERE Id = :opp1.Id];
        System.assertEquals('General', check.RecordType.Name, 'RecordType OK');
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp1, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp2, 'Risk 2');
        
        Test.startTest();
        
        insert buildAssets(opp1, risk1, 2, 1000000, 1); 
        insert buildAssets(opp2, risk2, 3, 1000000, 1); 
        
        Test.stopTest();
        
        verify(opp1.Id, 3000000, 'Opp1: 3M', true);
        verify(opp2.Id, 6000000, 'Opp2: 6M', true);
    }
}