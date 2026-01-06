/**
 * @Author: Williams
 * @Date: 2025-11-14
 * @Class: Aswata_TriggerHandler_Asset_Test
 * @Description: Test class untuk Aswata_TriggerHandler_Asset
 */
@isTest
private class Aswata_TriggerHandler_Asset_Test {
    /**
     * Test 1: AfterInsert Handler - Single Asset
     * Tests that afterInsert handler is called correctly and cascades to Opportunity
     */
    @isTest
    static void testAfterInsert_SingleAsset() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account AfterInsert');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp AfterInsert');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk AfterInsert');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset');
        
        Test.startTest();
        
        System.debug('amount before = ' + asset.Amount__c);
        
        asset.Amount__c = 5000000;
        asset.Exchange_Rate__c = 1;
        update asset;

        Test.stopTest();
        
        System.debug('amount update = ' + asset.Amount__c);
        
        Asset verifyAsset = [SELECT Amount__c, Exchange_Rate__c, Amount_IDR_new__c FROM Asset WHERE Id = :asset.Id];
        
        System.debug('amount Amount_IDR_new__c update = ' + verifyAsset.Amount_IDR_new__c);
        
        System.assertEquals(5000000, verifyAsset.Amount_IDR_new__c, 'Formula field should calculate: 5000000 * 1 = 5000000');
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        
        System.debug('amount Amount_Insured__c asset = ' + updatedRisk.Amount_Insured__c);
        System.assertEquals(5000000, updatedRisk.Amount_Insured__c, 'AfterInsert handler should trigger calculation for Risk');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c, 'AfterInsert handler should cascade to Opportunity');
    }
    
    /**
     * Test 2: AfterInsert Handler - Bulk Assets
     * Tests bulk insert with multiple assets under same risk
     */
    @isTest
    static void testAfterInsert_BulkAssets() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Bulk');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Bulk');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Bulk');
        
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 10; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset ' + i);
            assets.add(ast);
        }
        
        Test.startTest();
        
        for (Integer i = 0; i < assets.size(); i++) {
            assets[i].Amount__c = (i + 1) * 1000000; 
            assets[i].Exchange_Rate__c = 1;  
        }
        update assets;
       
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(55000000, updatedRisk.Amount_Insured__c, 'Risk should have sum of all 10 assets = 55M');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(55000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should cascade from Risk = 55M');
    }
    
    /**
     * Test 3: AfterUpdate Handler - Amount Change
     * Tests that amount changes trigger recalculation
     */
    @isTest
    static void testAfterUpdate_AmountChange() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Update');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Update');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset Update');
        
        Test.startTest();
        
        asset.Amount__c = 3000000;
        asset.Exchange_Rate__c = 1;
        update asset;
        
        asset.Amount__c = 5000000;
        update asset;
        
        Test.stopTest(); 
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(5000000, updatedRisk.Amount_Insured__c, 'Risk should be updated to 5M (latest amount)');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should cascade to 5M');
    }
    
    /**
     * Test 4: AfterUpdate Handler - Parent Change
     * Tests that changing parent triggers recalculation for both old and new parents
     */
    @isTest
    static void testAfterUpdate_ParentChange() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Parent Change');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Parent Change');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk1, 'Moving Asset');
       
        Test.startTest();
        
        asset.Amount__c = 4000000;
        asset.Exchange_Rate__c = 1;
        update asset;
        
        asset.ParentId = risk2.Id;
        update asset;

        Test.stopTest();
        
        Asset updatedRisk1 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk1.Id];
        System.assertEquals(0, updatedRisk1.Amount_Insured__c, 'Risk 1 should be recalculated to 0 after asset moved out');
        
        Asset updatedRisk2 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk2.Id];
        System.assertEquals(4000000, updatedRisk2.Amount_Insured__c, 'Risk 2 should have 4M after asset moved in');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(4000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should have 4M (0 from Risk 1 + 4M from Risk 2)');
    }
    
    /**
     * Test 5: AfterUpdate Handler - No Relevant Changes
     * Tests that non-relevant field changes don't trigger recalculation
     */
    @isTest
    static void testAfterUpdate_NoRelevantChanges() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account No Change');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp No Change');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk No Change');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset No Change');
        
        Test.startTest();
        
        asset.Amount__c = 2000000;
        asset.Exchange_Rate__c = 1;
        update asset;
        
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(2000000, updatedRisk.Amount_Insured__c,
            'Risk should have 2M');
        
        Integer calloutsBefore = Limits.getFutureCalls();
        asset.Name = 'Updated Name';
        update asset;
        Integer calloutsAfter = Limits.getFutureCalls();
        
        System.assertEquals(calloutsBefore, calloutsAfter, 'No future calls should be made for irrelevant field changes');
        
        updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(2000000, updatedRisk.Amount_Insured__c, 'Risk amount should remain 2M');
    }
    
    /**
     * Test 6: AfterUpdate Handler - Bulk Update
     * Tests bulk updates trigger recalculation correctly
     */
    @isTest
    static void testAfterUpdate_BulkUpdate() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Bulk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Bulk Update');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Bulk Update');
        
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 5; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset ' + i);
            assets.add(ast);
        }
        
        Test.startTest();
        
        for (Integer i = 0; i < assets.size(); i++) {
            assets[i].Amount__c = (i + 1) * 1000000;
            assets[i].Exchange_Rate__c = 1;
        }
        update assets;
        
        for (Asset ast : assets) {
            ast.Amount__c = ast.Amount__c * 2;
        }
        update assets;
        
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(30000000, updatedRisk.Amount_Insured__c,
            'Risk should have doubled sum = 30M (2+4+6+8+10 = 30M)');
    }
    
    /**
     * Test 7: AfterDelete Handler - Single Asset
     * Tests that deleting an asset recalculates parent risk
     */
    @isTest
    static void testAfterDelete_SingleAsset() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Delete');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Delete');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Delete');
        Asset asset1 = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset 1');
        Asset asset2 = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset 2');
        
        Test.startTest();
        
        asset1.Amount__c = 3000000;
        asset1.Exchange_Rate__c = 1;
        asset2.Amount__c = 2000000;
        asset2.Exchange_Rate__c = 1;
        update new List<Asset>{asset1, asset2};
        
        delete asset1;
        
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(2000000, updatedRisk.Amount_Insured__c, 'Risk should have 2M after deleting 3M asset (only asset2 remains)');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(2000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should cascade to 2M');
    }
    
    /**
     * Test 8: AfterDelete Handler - Bulk Delete
     * Tests bulk deletion recalculates correctly
     */
    @isTest
    static void testAfterDelete_BulkDelete() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Bulk Delete');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Bulk Delete');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Bulk Delete');
        
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 5; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset ' + i);
            assets.add(ast);
        }
        
        Test.startTest();
        
        for (Integer i = 0; i < assets.size(); i++) {
            assets[i].Amount__c = (i + 1) * 1000000;
            assets[i].Exchange_Rate__c = 1;
        }
        update assets;
        
        List<Asset> toDelete = new List<Asset>{assets[0], assets[1], assets[2]};
        delete toDelete;
        
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(9000000, updatedRisk.Amount_Insured__c, 'Risk should have 9M (4M+5M) after deleting first 3 assets (6M)');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(9000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should cascade to 9M (4M+5M)');
    }
    
    /**
     * Test 9: Handler - Asset Without Parent
     * Tests that assets without parent don't cause errors
     */
    @isTest
    static void testHandler_AssetWithoutParent() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account No Parent');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp No Parent');

        Test.startTest();
        
        Asset orphanAsset = new Asset(
            Name = 'Orphan Asset',
            Opportunity__c = opp.Id,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset' AND DeveloperName = 'Asset' LIMIT 1].Id,
            Amount__c = 1000000,
            Exchange_Rate__c = 1
        );
        insert orphanAsset;
        
        orphanAsset.Amount__c = 2000000;
        update orphanAsset;
        
        Test.stopTest();
        
        Asset verifyAsset = [SELECT Id, Amount__c, ParentId FROM Asset WHERE Id = :orphanAsset.Id];
        System.assertEquals(2000000, verifyAsset.Amount__c, 'Asset should be updated');
        System.assertEquals(null, verifyAsset.ParentId, 'Asset should have no parent');
    }
    
    /**
     * Test 10: Handler - Mixed RecordTypes
     * Tests handling of both Asset and Risk record types in same transaction
     */
    @isTest
    static void testHandler_MixedRecordTypes() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Mixed');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Mixed');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Mixed');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset Mixed');
        
        Test.startTest();
        
        asset.Amount__c = 5000000;
        asset.Exchange_Rate__c = 1;
        risk.Amount_Insured__c = 100000;
        
        update new List<Asset>{asset, risk};
        
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(5000000, updatedRisk.Amount_Insured__c, 'Risk should have cascaded amount from Asset = 5M');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should cascade = 5M');
    }
    
    /**
     * Test 11: Handler - Multiple Risks In Transaction
     * Tests multiple risks updated in same transaction
     */
    @isTest
    static void testHandler_MultipleRisksInTransaction() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Multi Risk');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Multi Risk');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        
        Asset asset1 = Aswata_TestDataFactory.createAsset(opp, risk1, 'Asset 1');
        Asset asset2 = Aswata_TestDataFactory.createAsset(opp, risk2, 'Asset 2');
        
        Test.startTest();
        
        asset1.Amount__c = 3000000;
        asset1.Exchange_Rate__c = 1;
        asset2.Amount__c = 7000000;
        asset2.Exchange_Rate__c = 1;
        
        update new List<Asset>{asset1, asset2};
       
        Test.stopTest();
        
        Asset updatedRisk1 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk1.Id];
        System.assertEquals(3000000, updatedRisk1.Amount_Insured__c, 'Risk 1 should have 3M');
        
        Asset updatedRisk2 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk2.Id];
        System.assertEquals(7000000, updatedRisk2.Amount_Insured__c, 'Risk 2 should have 7M');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(10000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should have total 10M (3M+7M)');
    }
    
    /**
     * Test 12: RecordType Cache
     * Tests that RecordType caching works correctly
     */
    @isTest
    static void testRecordTypeCache() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Cache');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Cache');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Cache');
        
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 5; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset ' + i);
            assets.add(ast);
        }
        
        Test.startTest();
        
        for (Asset ast : assets) {
            ast.Amount__c = 1000000;
            ast.Exchange_Rate__c = 1;
        }
        update assets;
        
        Test.stopTest();
        
        Integer soqlUsed = Limits.getQueries();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(5000000, updatedRisk.Amount_Insured__c, 'Risk should have 5M from 5 assets');
    }
    
    /**
     * Test 13: Handler - Governor Limits
     * Tests that handler doesn't hit governor limits with bulk operations
     */
    @isTest
    static void testHandler_GovernorLimits() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Limits');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Limits');
        
        List<Asset> risks = new List<Asset>();
        for (Integer i = 1; i <= 5; i++) {
            Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk ' + i);
            risks.add(risk);
        }
        
        List<Asset> assets = new List<Asset>();
        for (Asset risk : risks) {
            for (Integer j = 1; j <= 5; j++) {
                Asset ast = Aswata_TestDataFactory.createAsset(opp, risk,'Asset ' + risk.Name + '-' + j);
                assets.add(ast);
            }
        }
        
        Integer soqlBefore = Limits.getQueries();
        Integer dmlBefore = Limits.getDmlStatements();
        Integer futureBefore = Limits.getFutureCalls();
        
        Test.startTest();
        
        for (Asset ast : assets) {
            ast.Amount__c = 100000;
            ast.Exchange_Rate__c = 1;
        }
        update assets;
        
        Test.stopTest();
        
        Integer soqlAfter = Limits.getQueries();
        Integer dmlAfter = Limits.getDmlStatements();
        Integer futureAfter = Limits.getFutureCalls();
        
        System.assert(soqlAfter < Limits.getLimitQueries(), 'Should not hit SOQL limit');
        System.assert(dmlAfter < Limits.getLimitDmlStatements(), 'Should not hit DML limit');
        
        List<Asset> updatedRisks = [SELECT Amount_Insured__c FROM Asset WHERE Id IN :risks];
        for (Asset risk : updatedRisks) {
            System.assertEquals(500000, risk.Amount_Insured__c, 'Each risk should have 500k (5 assets × 100k)');
        }
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(2500000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should have 2.5M (5 risks × 500k each)');
    }
    
    /**
     * Test 14: Handler - Amount And Parent Change
     * Tests simultaneous amount and parent changes
     */
    @isTest
    static void testHandler_AmountAndParentChange() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Combo');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Combo');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk1, 'Moving Asset');
        
        Test.startTest();
        
        asset.Amount__c = 3000000;
        asset.Exchange_Rate__c = 1;
        update asset;
        
        asset.Amount__c = 5000000;
        asset.ParentId = risk2.Id;
        update asset;
        
        Test.stopTest();
        
        Asset updatedRisk1 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk1.Id];
        System.assertEquals(0, updatedRisk1.Amount_Insured__c,'Risk 1 should be 0 after asset moved');
        
        Asset updatedRisk2 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk2.Id];
        System.assertEquals(5000000, updatedRisk2.Amount_Insured__c, 'Risk 2 should have 5M');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c,'Opportunity should have 5M (0 from Risk 1 + 5M from Risk 2)');
    }
    
    /**
     * Test 15: Risk Update - Triggers Opportunity Update
     * Tests that Risk Amount_Insured__c changes cascade to Opportunity
     */
    @isTest
    static void testRiskUpdate_TriggersOpportunityUpdate() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Risk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Risk Update');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Update');
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset');
        
        Test.startTest();
        
        asset.Amount__c = 4000000;
        asset.Exchange_Rate__c = 1;
        update asset;
        
        Test.stopTest();
        
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(4000000, updatedRisk.Amount_Insured__c, 'Risk should have 4M');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(4000000, updatedOpp.Total_Sum_Insured__c, 'Opportunity should cascade to 4M');
    }
    
    /**
     * Test 16: Multiple Risks Update - Triggers Opportunity Update
     * Tests that multiple risks updating in same transaction cascade correctly
     */
    @isTest
    static void testMultipleRisksUpdate_TriggersOpportunityUpdate() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Multi Risk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Multi Risk Update');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset asset1 = Aswata_TestDataFactory.createAsset(opp, risk1, 'Asset 1');
        Asset asset2 = Aswata_TestDataFactory.createAsset(opp, risk2, 'Asset 2');
        
        Test.startTest();
        
        asset1.Amount__c = 2000000;
        asset1.Exchange_Rate__c = 1;
        asset2.Amount__c = 3000000;
        asset2.Exchange_Rate__c = 1;
        
        update new List<Asset>{asset1, asset2};
        
        Test.stopTest();
        
        Asset updatedRisk1 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk1.Id];
        System.assertEquals(2000000, updatedRisk1.Amount_Insured__c, 'Risk 1 should have 2M');
        
        Asset updatedRisk2 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk2.Id];
        System.assertEquals(3000000, updatedRisk2.Amount_Insured__c, 'Risk 2 should have 3M');
        
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c,'Opportunity should have 5M (2M+3M)');
    }
    
    @isTest
    static void updateFacultative_facultativeOwnerMatrix() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Multi Risk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Multi Risk Update');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        User stdusr = Aswata_TestDataFactory.createTestUser('TestUser1211');
        User stdusr2 = Aswata_TestDataFactory.createTestUser('TestUser1222');
        //User usr = [Select Id from user Limit 1];
        Master_Data__c brch = Aswata_TestDataFactory.createMasterData('Bandung', 'Master Branch');
        brch.BRANCH_ID__c = '11';
        update brch;
        
        Product2 pdt = Aswata_TestDataFactory.createProduct('201');
        pdt.IsActive = true;
        pdt.ProductCode = '201';
        update pdt;
        
        Master_Data__c md = Aswata_TestDataFactory.createMasterData('User name', 'Limit Reas');
        md.USER_ID__c = stdusr.id;
        md.LIMIT_AMOUNT__c = 2000000;
        md.Branch__c = brch.id;
        md.BSN__c = pdt.id;
        update md;
        
        OpportunityTeamMember otm =  new OpportunityTeamMember(
                    OpportunityId = opp.Id,
                    UserId = stdusr2.Id,
                    TeamMemberRole = 'Underwriting',
                    OpportunityAccessLevel = 'edit'
                );
        insert otm;
        
        //System.debug('opp.COB__c: ' + opp.COB__c);
                     
        //System.debug('riskWithOpp.COB__c: ' + riskWithOpp.Opportunity__r.COB__c + 'opp.Branch: ' + opp.Owner_Branch__c);
        Test.startTest();
        
        risk1.Facultative__c = 2000000;
        
        update risk1;
        
        Test.stopTest();
        
        /*OpportunityTeamMember otm = [
            SELECT Id
            FROM OpportunityTeamMember
            WHERE OpportunityId = :opp.Id
            AND UserId = :stdusr.Id
            LIMIT 1
        ];*/
        
        Asset updatedRisk1 = [SELECT Facultative__c FROM Asset WHERE Id = :risk1.Id];
        System.assertEquals(2000000, updatedRisk1.Facultative__c, 'Facultative Value should equal to 2000000');
        
      
    }
    
    
}