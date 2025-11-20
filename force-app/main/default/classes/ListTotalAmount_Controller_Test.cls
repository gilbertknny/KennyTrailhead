@isTest
public with sharing class ListTotalAmount_Controller_Test {
    @TestSetup
    static void setupTestData() {
        Map<String, SObject> standardData = Aswata_TestDataFactory.createStandardDataSet();
        Opportunity opp = (Opportunity) standardData.get('Opportunity');
        
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk 1');
        
        Master_Data__c section1 = Aswata_TestDataFactory.createMasterData('Section A', 'Asset Section');
        Master_Data__c section2 = Aswata_TestDataFactory.createMasterData('Section B', 'Asset Section');
        
        Master_Data__c currencyUSD = Aswata_TestDataFactory.createExchangeRate('USD', 15000);
        Master_Data__c currencyEUR = Aswata_TestDataFactory.createExchangeRate('EUR', 16000);
        Master_Data__c currencyIDR = Aswata_TestDataFactory.createExchangeRate('IDR', 1);
        
        RecordType assetRT = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Asset' AND Name = 'Asset' 
            LIMIT 1
        ];
        
        List<Asset> assetsToInsert = new List<Asset>();
        
        assetsToInsert.add(new Asset(
            Name = 'Asset 1',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            Section__c = section1.Id,
            Currency__c = currencyUSD.Id,
            Amount__c = 1000,
            Amount_IDR__c = 15000000,
            RecordTypeId = assetRT.Id
        ));
        
        assetsToInsert.add(new Asset(
            Name = 'Asset 2',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            Section__c = section1.Id,
            Currency__c = currencyUSD.Id,
            Amount__c = 2000,
            Amount_IDR__c = 30000000,
            RecordTypeId = assetRT.Id
        ));
        
        assetsToInsert.add(new Asset(
            Name = 'Asset 3',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            Section__c = section2.Id,
            Currency__c = currencyEUR.Id,
            Amount__c = 500,
            Amount_IDR__c = 8000000,
            RecordTypeId = assetRT.Id
        ));
        
        assetsToInsert.add(new Asset(
            Name = 'Asset 4',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            Section__c = section1.Id,
            Currency__c = currencyIDR.Id,
            Amount__c = 5000000,
            Amount_IDR__c = 5000000,
            RecordTypeId = assetRT.Id
        ));
        
        assetsToInsert.add(new Asset(
            Name = 'Asset 5',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            Section__c = section2.Id,
            Currency__c = currencyUSD.Id,
            Amount__c = 1500,
            Amount_IDR__c = 22500000,
            RecordTypeId = assetRT.Id
        ));
        
        insert assetsToInsert;
    }
    
    /**
     * Test the main functionality with multiple sections and currencies
     */
    @IsTest
    static void testGetAssetSummary_MultipleGroupings() {
        Asset risk = [SELECT Id FROM Asset WHERE RecordType.Name = 'Risk' LIMIT 1];
        
        Test.startTest();
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(risk.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(4, results.size(), 'Should have 4 grouped combinations (Section A+USD, Section A+IDR, Section B+EUR, Section B+USD)');
        
        for (ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper wrapper : results) {
            System.assertNotEquals(null, wrapper.sectionId, 'Section ID should be populated');
            System.assertNotEquals(null, wrapper.sectionName, 'Section name should be populated');
            System.assertNotEquals(null, wrapper.currencyId, 'Currency ID should be populated');
            System.assertNotEquals(null, wrapper.currencyName, 'Currency name should be populated');
            System.assertNotEquals(null, wrapper.totalAmount, 'Total amount should be populated');
            System.assertNotEquals(null, wrapper.totalAmountIDR, 'Total amount IDR should be populated');
        }
    }
    
    /**
     * Test that amounts are correctly aggregated for same section+currency combination
     */
    @IsTest
    static void testGetAssetSummary_VerifyAggregation() {
        Asset risk = [SELECT Id FROM Asset WHERE RecordType.Name = 'Risk' LIMIT 1];
        
        Test.startTest();
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(risk.Id);
        Test.stopTest();
        
        // Find Section A + USD combination (should aggregate Asset 1 and Asset 2)
        ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper sectionA_USD = null;
        for (ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper wrapper : results) {
            if (wrapper.sectionName == 'Section A' && wrapper.currencyName == 'USD') {
                sectionA_USD = wrapper;
                break;
            }
        }
        
        System.assertNotEquals(null, sectionA_USD, 'Should find Section A + USD combination');
        System.assertEquals(3000, sectionA_USD.totalAmount, 'Total amount should be 3000 (1000 + 2000)');
        System.assertEquals(45000000, sectionA_USD.totalAmountIDR, 'Total amount IDR should be 45000000 (15M + 30M)');
    }
    
    /**
     * Test grand total calculation across all groups
     */
    @IsTest
    static void testGetAssetSummary_GrandTotal() {
        Asset risk = [SELECT Id FROM Asset WHERE RecordType.Name = 'Risk' LIMIT 1];
        
        Test.startTest();
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(risk.Id);
        Test.stopTest();
        
        Decimal grandTotalIDR = 0;
        for (ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper wrapper : results) {
            grandTotalIDR += wrapper.totalAmountIDR;
        }
        
        System.assertEquals(80500000, grandTotalIDR, 'Grand total IDR should be 80,500,000');
    }
    
    /**
     * Test with Risk that has no child Assets
     */
    @IsTest
    static void testGetAssetSummary_NoAssets() {
        // Create a new Risk with no child Assets
        Map<String, SObject> standardData = Aswata_TestDataFactory.createStandardDataSet();
        Opportunity opp = (Opportunity) standardData.get('Opportunity');
        Asset emptyRisk = Aswata_TestDataFactory.createRisk(opp, 'Empty Risk');
        
        Test.startTest();
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(emptyRisk.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should return empty list when no child assets exist');
    }
    
    /**
     * Test that each currency total is correct
     */
    @IsTest
    static void testGetAssetSummary_CurrencyTotals() {
        Asset risk = [SELECT Id FROM Asset WHERE RecordType.Name = 'Risk' LIMIT 1];
        
        Test.startTest();
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(risk.Id);
        Test.stopTest();
        
        Map<String, Decimal> currencyTotals = new Map<String, Decimal>();
        
        for (ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper wrapper : results) {
            if (!currencyTotals.containsKey(wrapper.currencyName)) {
                currencyTotals.put(wrapper.currencyName, 0);
            }
            currencyTotals.put(wrapper.currencyName, 
                currencyTotals.get(wrapper.currencyName) + wrapper.totalAmount);
        }
        
        System.assertEquals(4500, currencyTotals.get('USD'), 'Total USD should be 4500');
        System.assertEquals(500, currencyTotals.get('EUR'), 'Total EUR should be 500');
        System.assertEquals(5000000, currencyTotals.get('IDR'), 'Total IDR should be 5000000');
    }
    
    /**
     * Test wrapper class constructor
     */
    @IsTest
    static void testAssetSummaryWrapper_Constructor() {
        Master_Data__c testSection = Aswata_TestDataFactory.createMasterData('Test Section', 'Asset Section');
        Master_Data__c testCurrency = Aswata_TestDataFactory.createExchangeRate('JPY', 100);
        
        Test.startTest();
        ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper wrapper = 
            new ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper(
                testSection.Id,
                'Test Section',
                testCurrency.Id,
                'JPY',
                1000.50,
                100050.00
            );
        Test.stopTest();
        
        System.assertEquals(testSection.Id, wrapper.sectionId);
        System.assertEquals('Test Section', wrapper.sectionName);
        System.assertEquals(testCurrency.Id, wrapper.currencyId);
        System.assertEquals('JPY', wrapper.currencyName);
        System.assertEquals(1000.50, wrapper.totalAmount);
        System.assertEquals(100050.00, wrapper.totalAmountIDR);
    }
    
    /**
     * Test cacheable behavior - verify method can be called multiple times
     */
    @IsTest
    static void testGetAssetSummary_Cacheable() {
        Asset risk = [SELECT Id FROM Asset WHERE RecordType.Name = 'Risk' LIMIT 1];
        
        Test.startTest();
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results1 = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(risk.Id);
        List<ListTotalAmountPerCurrency_Controller.AssetSummaryWrapper> results2 = 
            ListTotalAmountPerCurrency_Controller.getAssetSummary(risk.Id);
        Test.stopTest();
        
        System.assertEquals(results1.size(), results2.size(), 'Multiple calls should return same size');
        System.assertEquals(4, results1.size(), 'Should return 4 groupings');
    }
}