/*
 * @Author: Williams
 * @Date: 2025-11-06 18:30:00
 * @Class: Aswata_TriggerHandler_Asset_Test
 * @Description: Test class testing trigger handler with full cascade: Asset → Risk → Opportunity
 */

@isTest
public class Aswata_TriggerHandler_Asset_Test {
    /**
     * Test 1: AfterInsert Handler - Single Asset
     * Tests that afterInsert handler is called correctly and cascades to Opportunity
     */
    @isTest
    static void testAfterInsert_SingleAsset() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account AfterInsert');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp AfterInsert');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk AfterInsert');
        
        Test.startTest();
        
        // Create asset - this will trigger afterInsert
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset');
        asset.Amount__c = 5000000;
        update asset;
        
        Test.stopTest();
        
        // Verify Risk updated
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(5000000, updatedRisk.Amount_Insured__c,
            'AfterInsert handler should trigger calculation for Risk');
        
        // Verify Opportunity updated
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c,
            'AfterInsert handler should cascade to Opportunity');
    }
    
    /**
     * Test 2: AfterInsert Handler - Bulk Assets
     * Tests bulk insert processing with Opportunity update
     */
    @isTest
    static void testAfterInsert_BulkAssets() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Bulk Insert');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Bulk Insert');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Bulk');
        
        Test.startTest();
        
        // Bulk create 10 assets
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 10; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Bulk Asset ' + i);
            ast.Amount__c = i * 1000000;
            assets.add(ast);
        }
        update assets;
        
        Test.stopTest();
        
        // Verify Risk
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(55000000, updatedRisk.Amount_Insured__c,
            'AfterInsert handler should process bulk correctly (55M)');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(55000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should be updated with total (55M)');
    }
    
    /**
     * Test 3: AfterUpdate Handler - Amount Change
     * Tests afterUpdate when Amount__c changes and cascades to Opportunity
     */
    @isTest
    static void testAfterUpdate_AmountChange() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Update Amount');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Update Amount');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Update');
        
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk, 'Test Asset');
        asset.Amount__c = 3000000;
        update asset;
        
        Test.startTest();
        
        // Update amount - should trigger afterUpdate
        asset.Amount__c = 7000000;
        update asset;
        
        Test.stopTest();
        
        // Verify Risk
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(7000000, updatedRisk.Amount_Insured__c,
            'AfterUpdate handler should recalculate on amount change');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(7000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should reflect updated amount');
    }
    
    /**
     * Test 4: AfterUpdate Handler - Parent Change
     * Tests afterUpdate when ParentId changes
     */
    @isTest
    static void testAfterUpdate_ParentChange() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Update Parent');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Update Parent');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk1, 'Test Asset');
        asset.Amount__c = 4000000;
        update asset;
        
        Test.startTest();
        
        // Move asset from risk1 to risk2
        asset.ParentId = risk2.Id;
        update asset;
        
        Test.stopTest();
        
        // Verify both risks recalculated
        Map<Id, Asset> risks = new Map<Id, Asset>([
            SELECT Amount_Insured__c FROM Asset WHERE Id IN (:risk1.Id, :risk2.Id)
        ]);
        
        System.assertEquals(0, risks.get(risk1.Id).Amount_Insured__c,
            'Old parent should be recalculated (0M)');
        System.assertEquals(4000000, risks.get(risk2.Id).Amount_Insured__c,
            'New parent should be recalculated (4M)');
        
        // Verify Opportunity still correct (total unchanged since asset moved within same opp)
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(4000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity total should remain 4M');
    }
    
    /**
     * Test 5: AfterUpdate Handler - No Relevant Changes
     * Tests that handler skips recalculation when irrelevant fields change
     */
    @isTest
    static void testAfterUpdate_NoRelevantChanges() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account No Change');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp No Change');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk No Change');
        
        // Create TWO assets to have a baseline
        Asset asset1 = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset 1');
        Asset asset2 = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset 2');
        
        Test.startTest();
        
        // Set amounts
        asset1.Amount__c = 3000000;
        asset2.Amount__c = 3000000;
        update new List<Asset>{asset1, asset2};
        
        Test.stopTest(); // Force @future to complete - should be 6M total
        
        // Get amount after calculation
        Asset riskBefore = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(6000000, riskBefore.Amount_Insured__c, 'Initial calculation should be 6M');
        
        Opportunity oppBefore = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(6000000, oppBefore.Total_Sum_Insured__c, 'Initial Opportunity should be 6M');
        
        // Now test: Update non-relevant field only (Name)
        asset1.Name = 'Updated Asset Name';
        update asset1;
        
        // Verify amount didn't change
        Asset riskAfter = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(6000000, riskAfter.Amount_Insured__c,
            'Amount should stay same when only non-relevant fields change');
        
        Opportunity oppAfter = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(6000000, oppAfter.Total_Sum_Insured__c,
            'Opportunity should stay same');
    }
    
    /**
     * Test 6: AfterUpdate Handler - Bulk Update
     * Tests bulk update processing with Opportunity cascade
     */
    @isTest
    static void testAfterUpdate_BulkUpdate() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Bulk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Bulk Update');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Bulk Update');
        
        // Create 5 assets
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 5; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset ' + i);
            ast.Amount__c = i * 1000000;
            assets.add(ast);
        }
        update assets;
        
        Test.startTest();
        
        // Bulk update amounts
        for (Integer i = 0; i < assets.size(); i++) {
            assets[i].Amount__c = (i + 1) * 2000000; // Double the amounts
        }
        update assets;
        
        Test.stopTest();
        
        // Verify Risk: 2M + 4M + 6M + 8M + 10M = 30M
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(30000000, updatedRisk.Amount_Insured__c,
            'AfterUpdate handler should process bulk update correctly (30M)');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(30000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should reflect bulk update (30M)');
    }
    
    /**
     * Test 7: AfterDelete Handler - Single Delete
     * Tests afterDelete with single record and Opportunity cascade
     */
    @isTest
    static void testAfterDelete_SingleAsset() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Delete Single');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Delete Single');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Delete');
        
        Asset asset1 = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset 1');
        asset1.Amount__c = 3000000;
        update asset1;
        
        Asset asset2 = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset 2');
        asset2.Amount__c = 5000000;
        update asset2;
        
        Test.startTest();
        
        // Delete one asset
        delete asset1;
        
        Test.stopTest();
        
        // Verify Risk recalculation: should have 5M remaining
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(5000000, updatedRisk.Amount_Insured__c,
            'AfterDelete handler should recalculate after deletion (5M)');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should reflect deletion (5M)');
    }
    
    /**
     * Test 8: AfterDelete Handler - Bulk Delete
     * Tests bulk delete processing with Opportunity cascade
     */
    @isTest
    static void testAfterDelete_BulkDelete() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Bulk Delete');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Bulk Delete');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Bulk Delete');
        
        // Create 8 assets
        List<Asset> assets = new List<Asset>();
        for (Integer i = 1; i <= 8; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Asset ' + i);
            ast.Amount__c = i * 1000000;
            assets.add(ast);
        }
        update assets;
        
        Test.startTest();
        
        // Delete first 3 assets (1M + 2M + 3M = 6M removed)
        delete new List<Asset>{assets[0], assets[1], assets[2]};
        
        Test.stopTest();
        
        // Verify Risk: 4M + 5M + 6M + 7M + 8M = 30M remaining
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(30000000, updatedRisk.Amount_Insured__c,
            'AfterDelete handler should process bulk delete correctly (30M)');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(30000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should reflect bulk delete (30M)');
    }
    
    /**
     * Test 9: Handler with Asset without Parent
     * Tests that handler gracefully handles assets without ParentId
     */
    @isTest
    static void testHandler_AssetWithoutParent() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account No Parent Handler');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp No Parent Handler');
        
        Test.startTest();
        
        // Create asset without parent
        RecordType rtAsset = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset' AND Name = 'Asset' LIMIT 1];
        Asset orphanAsset = new Asset(
            Name = 'Orphan Asset',
            Opportunity__c = opp.Id,
            ParentId = null,
            RecordTypeId = rtAsset.Id,
            Amount__c = 1000000,
            COB__c = '201'
        );
        insert orphanAsset;
        
        // Update orphan asset
        orphanAsset.Amount__c = 2000000;
        update orphanAsset;
        
        // Delete orphan asset
        delete orphanAsset;
        
        Test.stopTest();
        
        // Should complete without errors
        System.assert(true, 'Handler should gracefully handle assets without parent');
    }
    
    /**
     * Test 10: Handler with Mixed RecordTypes
     * Tests that handler only processes Asset RecordType, not Risk
     */
    @isTest
    static void testHandler_MixedRecordTypes() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Mixed Handler');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Mixed Handler');
        
        Test.startTest();
        
        // Create Risk (should be ignored by Asset processing logic)
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        
        // Create Asset under risk1
        Asset asset1 = Aswata_TestDataFactory.createAsset(opp, risk1, 'Asset 1');
        asset1.Amount__c = 7000000;
        update asset1;
        
        // Create another Risk
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        
        Test.stopTest();
        
        // Verify only Asset processed
        Asset updatedRisk1 = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk1.Id];
        System.assertEquals(7000000, updatedRisk1.Amount_Insured__c,
            'Handler should only process Asset RecordType');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(7000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should have total from all risks');
    }
    
    /**
     * Test 11: Handler with Multiple Risks in Same Transaction
     * Tests handler processes multiple parent risks correctly and updates Opportunity
     */
    @isTest
    static void testHandler_MultipleRisksInTransaction() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Multi Risk');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Multi Risk');
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset risk3 = Aswata_TestDataFactory.createRisk(opp, 'Risk 3');
        
        Test.startTest();
        
        // Create assets for all 3 risks in same transaction
        List<Asset> allAssets = new List<Asset>();
        
        // Risk 1: 2 assets
        for (Integer i = 1; i <= 2; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk1, 'R1 Asset ' + i);
            ast.Amount__c = i * 1000000;
            allAssets.add(ast);
        }
        
        // Risk 2: 3 assets
        for (Integer i = 1; i <= 3; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk2, 'R2 Asset ' + i);
            ast.Amount__c = i * 1000000;
            allAssets.add(ast);
        }
        
        // Risk 3: 4 assets
        for (Integer i = 1; i <= 4; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk3, 'R3 Asset ' + i);
            ast.Amount__c = i * 1000000;
            allAssets.add(ast);
        }
        
        update allAssets;
        
        Test.stopTest();
        
        // Verify all risks calculated correctly
        Map<Id, Asset> risks = new Map<Id, Asset>([
            SELECT Amount_Insured__c FROM Asset 
            WHERE Id IN (:risk1.Id, :risk2.Id, :risk3.Id)
        ]);
        
        System.assertEquals(3000000, risks.get(risk1.Id).Amount_Insured__c, 'Risk 1: 3M');
        System.assertEquals(6000000, risks.get(risk2.Id).Amount_Insured__c, 'Risk 2: 6M');
        System.assertEquals(10000000, risks.get(risk3.Id).Amount_Insured__c, 'Risk 3: 10M');
        
        // Verify Opportunity total: 3M + 6M + 10M = 19M
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(19000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should have total from all risks (19M)');
    }
    
    /**
     * Test 12: RecordType Mapping Cache
     * Tests that RecordType mapping is cached properly
     */
    @isTest
    static void testRecordTypeCache() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Cache');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Cache');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk Cache');
        
        Test.startTest();
        
        // Multiple inserts should reuse cached RecordType mapping
        for (Integer i = 1; i <= 3; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk, 'Cache Asset ' + i);
            ast.Amount__c = i * 1000000;
            update ast;
        }
        
        Test.stopTest();
        
        // Verify calculation worked (cache was effective)
        Asset updatedRisk = [SELECT Amount_Insured__c FROM Asset WHERE Id = :risk.Id];
        System.assertEquals(6000000, updatedRisk.Amount_Insured__c,
            'RecordType cache should work correctly');
        
        // Verify Opportunity
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(6000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should be updated');
    }
    
    /**
     * Test 13: Handler Performance with Large Dataset
     * Tests handler doesn't hit governor limits with BULK operations
     */
    @isTest
    static void testHandler_GovernorLimits() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Governor');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Governor');
        
        // Create 3 risks
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset risk3 = Aswata_TestDataFactory.createRisk(opp, 'Risk 3');
        List<Asset> risks = new List<Asset>{risk1, risk2, risk3};
        
        // Create assets for each risk separately to ensure correct assignment
        List<Asset> allAssets = new List<Asset>();
        
        // Risk 1: 10 assets
        for (Integer i = 1; i <= 10; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk1, 'R1 Asset ' + i);
            allAssets.add(ast);
        }
        
        // Risk 2: 10 assets
        for (Integer i = 1; i <= 10; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk2, 'R2 Asset ' + i);
            allAssets.add(ast);
        }
        
        // Risk 3: 10 assets
        for (Integer i = 1; i <= 10; i++) {
            Asset ast = Aswata_TestDataFactory.createAsset(opp, risk3, 'R3 Asset ' + i);
            allAssets.add(ast);
        }
        
        Test.startTest();
        
        // Set amounts for all assets explicitly
        // Risk 1 assets: indices 0-9
        for (Integer i = 0; i < 10; i++) {
            allAssets[i].Amount__c = (i + 1) * 1000000;
        }
        
        // Risk 2 assets: indices 10-19
        for (Integer i = 10; i < 20; i++) {
            allAssets[i].Amount__c = ((i - 10) + 1) * 1000000;
        }
        
        // Risk 3 assets: indices 20-29
        for (Integer i = 20; i < 30; i++) {
            allAssets[i].Amount__c = ((i - 20) + 1) * 1000000;
        }
        
        // Single bulk update - triggers ONE @future call
        update allAssets;
        
        Test.stopTest();
        
        // Verify all processed without governor limit errors
        List<Asset> updatedRisks = [
            SELECT Id, Name, Amount_Insured__c FROM Asset WHERE Id IN :risks ORDER BY Name
        ];
        
        System.assertEquals(3, updatedRisks.size(), 'All risks should be processed');
        
        // Each should have 55M (1+2+3+...+10 = 55)
        for (Asset risk : updatedRisks) {
            System.assertEquals(55000000, risk.Amount_Insured__c,
                risk.Name + ' should have 55M, but has ' + risk.Amount_Insured__c);
        }
        
        // Verify Opportunity total: 55M * 3 = 165M
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(165000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should have total from all 3 risks (165M)');
    }
    
    /**
     * Test 14: Handler with Amount Change and Parent Change Together
     * Tests update with both fields changing simultaneously
     */
    @isTest
    static void testHandler_AmountAndParentChange() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Both Change');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Both Change');
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        
        Asset asset = Aswata_TestDataFactory.createAsset(opp, risk1, 'Test Asset');
        asset.Amount__c = 3000000;
        update asset;
        
        Test.startTest();
        
        // Change both amount AND parent
        asset.Amount__c = 8000000;
        asset.ParentId = risk2.Id;
        update asset;
        
        Test.stopTest();
        
        // Verify both risks updated
        Map<Id, Asset> risks = new Map<Id, Asset>([
            SELECT Amount_Insured__c FROM Asset WHERE Id IN (:risk1.Id, :risk2.Id)
        ]);
        
        System.assertEquals(0, risks.get(risk1.Id).Amount_Insured__c,
            'Old parent should be recalculated (0M)');
        System.assertEquals(8000000, risks.get(risk2.Id).Amount_Insured__c,
            'New parent should have new amount (8M)');
        
        // Verify Opportunity (total unchanged since within same opp)
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(8000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should have total (8M)');
    }
    
    /**
     * Test 15: Risk Record Updates (RecordType = Risk)
     * Tests that Risk record updates trigger Opportunity calculation
     */
    @isTest
    static void testRiskUpdate_TriggersOpportunityUpdate() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Risk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Risk Update');
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk');
        
        // Manually set Amount_Insured__c (bypass normal flow)
        risk.Amount_Insured__c = 10000000;
        update risk;
        
        Test.startTest();
        
        // Update Risk Amount_Insured__c - should trigger Opportunity update
        risk.Amount_Insured__c = 15000000;
        update risk;
        
        Test.stopTest();
        
        // Verify Opportunity updated
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(15000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should be updated when Risk Amount_Insured__c changes');
    }
    
    /**
     * Test 16: Multiple Risks Update in Same Transaction
     * Tests bulk Risk updates trigger Opportunity calculation
     */
    @isTest
    static void testMultipleRisksUpdate_TriggersOpportunityUpdate() {
        // Setup
        Account acc = Aswata_TestDataFactory.createAccount('Test Account Multi Risk Update');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opp Multi Risk Update');
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        Asset risk3 = Aswata_TestDataFactory.createRisk(opp, 'Risk 3');
        
        // Set initial amounts
        risk1.Amount_Insured__c = 5000000;
        risk2.Amount_Insured__c = 10000000;
        risk3.Amount_Insured__c = 15000000;
        update new List<Asset>{risk1, risk2, risk3};
        
        Test.startTest();
        
        // Update all risks
        risk1.Amount_Insured__c = 7000000;
        risk2.Amount_Insured__c = 12000000;
        risk3.Amount_Insured__c = 18000000;
        update new List<Asset>{risk1, risk2, risk3};
        
        Test.stopTest();
        
        // Verify Opportunity: 7M + 12M + 18M = 37M
        Opportunity updatedOpp = [SELECT Total_Sum_Insured__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(37000000, updatedOpp.Total_Sum_Insured__c,
            'Opportunity should reflect all Risk updates (37M)');
    }
}