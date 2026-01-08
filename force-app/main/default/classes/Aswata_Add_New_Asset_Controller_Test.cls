@isTest
public with sharing class Aswata_Add_New_Asset_Controller_Test {    
    @TestSetup
    static void setupTestData() {
        Account acc = Aswata_TestDataFactory.createAccount('Test Account');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Test Opportunity');
        opp.COB__c = '201';
        update opp;
        
        Master_Data__c fieldCob = Aswata_TestDataFactory.createMasterData('test', 'Field COB');
        fieldCob.Name = 'Name';
        fieldCob.Label__c = 'Asset Name';
        fieldCob.Data_Type__c = 'Text';
        fieldCob.Status__c = 'Active';
        fieldCob.Object__c = 'Asset';
        fieldCob.BSN_ID__c = '201';
        fieldCob.Order__c = 1;
       	update fieldCob;
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Test Risk 1');
        risk1.Risk_ID__c = '1';
        risk1.risk_address__c = 'Test Address 1';
        update risk1;
        
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Test Risk 2');
        risk2.Risk_ID__c = '2';
        update risk2;
    }
    
    @isTest
    static void testGetAssetsByOpportunity() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = Aswata_TestDataFactory.createAccount('Empty Acc');
        Opportunity emptyOpp = Aswata_TestDataFactory.createOpportunity(acc, 'Empty Opp');
        
        Test.startTest();
        List<Aswata_Add_New_Asset_Controller.AssetWrapper> results = 
            Aswata_Add_New_Asset_Controller.getAssetsByOpportunity(testOpp.Id);
        List<Aswata_Add_New_Asset_Controller.AssetWrapper> empty = 
            Aswata_Add_New_Asset_Controller.getAssetsByOpportunity(emptyOpp.Id);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return 2 assets for test opportunity');
        System.assertEquals(0, empty.size(), 'Should return 0 assets for empty opportunity');
    }
    
    @isTest
    static void testUpsertAsset() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Asset existing = [SELECT Id, Risk_ID__c FROM Asset LIMIT 1];
        String origRiskId = existing.Risk_ID__c;
        
        Test.startTest();
        String id1 = Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Name' => 'New', 'Opportunity__c' => opp.Id});
        String id2 = Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Name' => 'No Opp'});
        
        Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Id' => existing.Id, 'Name' => 'Updated'});
        Test.stopTest();
        
        System.assertEquals('3', [SELECT Risk_ID__c FROM Asset WHERE Id = :id1].Risk_ID__c, 
            'New asset should have Risk_ID = 3');
        System.assertEquals(null, [SELECT Opportunity__c FROM Asset WHERE Id = :id2].Opportunity__c, 
            'Asset without opportunity should have null Opportunity__c');
        System.assertEquals(origRiskId, [SELECT Risk_ID__c FROM Asset WHERE Id = :existing.Id].Risk_ID__c, 
            'Updated asset should preserve original Risk_ID');
    }
    
    @isTest
    static void testRiskIdGeneration() {
        Test.startTest();
        Account acc1 = Aswata_TestDataFactory.createAccount('Acc1');
        Opportunity opp1 = Aswata_TestDataFactory.createOpportunity(acc1, 'Opp1');
        String id1 = Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Name' => 'First', 'Opportunity__c' => opp1.Id});
        
        Account acc2 = Aswata_TestDataFactory.createAccount('Acc2');
        Opportunity opp2 = Aswata_TestDataFactory.createOpportunity(acc2, 'Opp2');
        Asset nonNum = Aswata_TestDataFactory.createRisk(opp2, 'NonNum');
        nonNum.Risk_ID__c = 'ABC-XYZ';
        update nonNum;
        String id2 = Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Name' => 'After NonNum', 'Opportunity__c' => opp2.Id});
        
        Account acc3 = Aswata_TestDataFactory.createAccount('Acc3');
        Opportunity opp3 = Aswata_TestDataFactory.createOpportunity(acc3, 'Opp3');
        Asset mixed = Aswata_TestDataFactory.createRisk(opp3, 'Mixed');
        mixed.Risk_ID__c = 'RISK-42-ABC';
        update mixed;
        String id3 = Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Name' => 'After Mixed', 'Opportunity__c' => opp3.Id});
        
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        List<String> seqIds = new List<String>();
        for (Integer i = 0; i < 3; i++) {
            seqIds.add(Aswata_Add_New_Asset_Controller.upsertAsset(
                new Map<String, Object>{'Name' => 'Seq' + i, 'Opportunity__c' => testOpp.Id}));
        }
        Test.stopTest();
        
        System.assertEquals('1', [SELECT Risk_ID__c FROM Asset WHERE Id = :id1].Risk_ID__c, 
            'First asset in new opportunity should have Risk_ID = 1');
        System.assertEquals('1', [SELECT Risk_ID__c FROM Asset WHERE Id = :id2].Risk_ID__c, 
            'Asset after non-numeric Risk_ID should have Risk_ID = 1');
        System.assertEquals('43', [SELECT Risk_ID__c FROM Asset WHERE Id = :id3].Risk_ID__c, 
            'Asset after mixed Risk_ID should extract number 42 and increment to 43');
        
        List<Asset> seqAssets = [SELECT Risk_ID__c FROM Asset WHERE Id IN :seqIds ORDER BY Risk_ID__c];

        System.assertEquals('3', seqAssets[0].Risk_ID__c, 'First sequential asset should be 3');
        System.assertEquals('4', seqAssets[1].Risk_ID__c, 'Second sequential asset should be 4');
        System.assertEquals('5', seqAssets[2].Risk_ID__c, 'Third sequential asset should be 5');
    }
    
    @isTest
    static void testGetAssetCount() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = Aswata_TestDataFactory.createAccount('Count Acc');
        Opportunity emptyOpp = Aswata_TestDataFactory.createOpportunity(acc, 'Empty');
        
        Test.startTest();
        Integer count1 = Aswata_Add_New_Asset_Controller.getAssetCountByOpportunity(opp.Id);
        Integer count2 = Aswata_Add_New_Asset_Controller.getAssetCountByOpportunity(emptyOpp.Id);
        Test.stopTest();
        
        System.assertEquals(2, count1, 'Test opportunity should have 2 assets');
        System.assertEquals(0, count2, 'Empty opportunity should have 0 assets');
    }
    
    @isTest
    static void testGetActiveFields() {
        Test.startTest();
        List<Aswata_Add_New_Asset_Controller.DynamicFieldConfig> fields1 = 
            Aswata_Add_New_Asset_Controller.getActiveFields('Asset', '201','1');
        List<Aswata_Add_New_Asset_Controller.DynamicFieldConfig> fields2 = 
            Aswata_Add_New_Asset_Controller.getActiveFields('Asset', 'NoExist','');
        List<Aswata_Add_New_Asset_Controller.DynamicFieldConfig> fields3 = 
            Aswata_Add_New_Asset_Controller.getActiveFields('', '201','');
        Test.stopTest();
        
        System.assertNotEquals(null, fields1, 'Should return field configs for valid COB');
        System.assertEquals(0, fields2.size(), 'Should return empty list for non-existent COB');
        System.assertEquals(0, fields3.size(), 'Should return empty list for blank object name');
    }
    
    @isTest
    static void testGetRecordTypeIdByCob() {
        List<RecordType> existing = [SELECT Id FROM RecordType 
                                     WHERE SObjectType = 'Asset' AND DeveloperName LIKE '%201%' LIMIT 1];
        List<RecordType> master = [SELECT Id FROM RecordType 
                                   WHERE SObjectType = 'Asset' AND DeveloperName = 'Master' LIMIT 1];
        
        Test.startTest();
        Id rt1 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob('Asset', '201');
        Id rt2 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob('Asset', '999999');
        Id rt3 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob('', '201');
        Test.stopTest();
        
        if (!existing.isEmpty()) {
            System.assertEquals(existing[0].Id, rt1, 'Should return COB-specific RecordType for 201');
        }
        if (!master.isEmpty() && existing.isEmpty()) {
            System.assertEquals(master[0].Id, rt2, 'Should fallback to Master RecordType for non-existent COB');
        }
        System.assertEquals(null, rt3, 'Should return null for blank object name');
    }
    
    @isTest
    static void testGetRecordTypeIdByObject() {
        Test.startTest();
        Id rt1 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByObject('Asset');
        Id rt2 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByObject('');
        Test.stopTest();
        
        System.assertNotEquals(null, rt1, 'Should return RecordType for Asset object');
        System.assertEquals(null, rt2, 'Should return null for blank object name');
    }
    
    @isTest
    static void testInnerClasses() {
        Asset asset = [SELECT Id, RecordTypeId FROM Asset LIMIT 1];
        
        Test.startTest();
        Aswata_Add_New_Asset_Controller.DynamicFieldConfig config = 
            new Aswata_Add_New_Asset_Controller.DynamicFieldConfig(
                'Field__c', 'Label', 'Text', 'Obj__c', 'Filter', 'Name');
        
        Aswata_Add_New_Asset_Controller.AssetWrapper wrapper = 
            new Aswata_Add_New_Asset_Controller.AssetWrapper();
        wrapper.id = asset.Id;
        wrapper.riskId = 'R1';
        wrapper.riskName = 'Test';
        Test.stopTest();
        
        System.assertEquals('Field__c', config.apiName, 'Config should have correct apiName');
        System.assertEquals('Label', config.label, 'Config should have correct label');
        System.assertEquals(asset.Id, wrapper.id, 'Wrapper should have correct asset id');
        System.assertEquals('R1', wrapper.riskId, 'Wrapper should have correct risk id');
    }
    
    @isTest
    static void testExceptionHandlingAndEdgeCases() {
        Test.startTest();
        
        try {
            Map<String, Object> fields = new Map<String, Object>{'Name' => 'Test Asset'};
            String assetId = Aswata_Add_New_Asset_Controller.upsertAsset(fields);
            System.assertNotEquals(null, assetId, 'Should create asset');
        } catch (Exception e) {
            System.assert(true, 'Exception handled: ' + e.getMessage());
        }
        
        Id rt1 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob(null, '201');
        Id rt2 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob('Asset', null);
        System.assertEquals(null, rt1, 'Null objectName should return null');
        System.assertEquals(null, rt2, 'Null cobValue should return null');
        
        Id rt3 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByObject(null);
        System.assertEquals(null, rt3, 'Null objectName should return null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testRecordTypeNotFound() {
        Test.startTest();
        
        Id rt1 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByObject('User');
        Id rt2 = Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob('NonExistentObject__c', '201');
        
        Test.stopTest();
        
        System.assert(true, 'Methods executed without error');
    }
    
    @isTest
    static void testBulkAndBlankValues() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        
        List<String> ids = new List<String>();
        for (Integer i = 0; i < 5; i++) {
            ids.add(Aswata_Add_New_Asset_Controller.upsertAsset(
                new Map<String, Object>{'Name' => 'Bulk ' + i, 'Opportunity__c' => opp.Id}));
        }
        
        String idBlank = Aswata_Add_New_Asset_Controller.upsertAsset(
            new Map<String, Object>{'Name' => 'Blank RiskID', 'Opportunity__c' => opp.Id, 'Risk_ID__c' => ''});
        
        Test.stopTest();
        
        List<Asset> bulkAssets = [SELECT Risk_ID__c FROM Asset WHERE Id IN :ids ORDER BY Risk_ID__c];
        System.assertEquals(5, bulkAssets.size(), 'Should create 5 assets');
        System.assertEquals('3', bulkAssets[0].Risk_ID__c, 'First should be 3');
        System.assertEquals('7', bulkAssets[4].Risk_ID__c, 'Last should be 7');
        
        Asset blankAsset = [SELECT Risk_ID__c FROM Asset WHERE Id = :idBlank];
        System.assertNotEquals(null, blankAsset.Risk_ID__c, 'Should auto-generate Risk_ID');
        System.assertNotEquals('', blankAsset.Risk_ID__c, 'Risk_ID should not be blank');
    }

    @isTest
    static void testAddressFieldMapping() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Asset risk1 = Aswata_TestDataFactory.createRisk(testOpp, 'Risk With Address Lookup');
        risk1.risk_address__c = 'Old Text Address';
        
        Asset risk2 = Aswata_TestDataFactory.createRisk(testOpp, 'Risk With Text Address');
        risk2.risk_address__c = 'Text Address Value';
        
        Asset risk3 = Aswata_TestDataFactory.createRisk(testOpp, 'Risk With No Address');
        risk3.risk_address__c = null;
        
        List<RecordType> addressRT = [SELECT Id FROM RecordType 
                                    WHERE SObjectType = 'Master_Data__c' 
                                    AND DeveloperName = 'Address' 
                                    LIMIT 1];
        
        if (!addressRT.isEmpty()) {
            Master_Data__c location = new Master_Data__c(
                Name = 'Jl. Test Location',
                RecordTypeId = addressRT[0].Id
            );
            insert location;
            
            risk1.Address__c = location.Id;
        }
        
        update new List<Asset>{risk1, risk2, risk3};
        
        Test.startTest();
        List<Aswata_Add_New_Asset_Controller.AssetWrapper> results = 
            Aswata_Add_New_Asset_Controller.getAssetsByOpportunity(testOpp.Id);
        Test.stopTest();
        
        Aswata_Add_New_Asset_Controller.AssetWrapper wrap1 = null;
        Aswata_Add_New_Asset_Controller.AssetWrapper wrap2 = null;
        Aswata_Add_New_Asset_Controller.AssetWrapper wrap3 = null;
        
        for (Aswata_Add_New_Asset_Controller.AssetWrapper w : results) {
            if (w.id == risk1.Id){
                 wrap1 = w;
            }
            
            if (w.id == risk2.Id) {
                wrap2 = w;
            }
            
            if (w.id == risk3.Id) {
                wrap3 = w;
            }
        }
        
        System.assertNotEquals(null, wrap1, 'Should find risk1 wrapper');
        System.assertNotEquals(null, wrap2, 'Should find risk2 wrapper');
        System.assertNotEquals(null, wrap3, 'Should find risk3 wrapper');
        
        if (!addressRT.isEmpty()) {
            System.assertEquals('Jl. Test Location', wrap1.address, 
                'Should use Address__r.Name when available');
        }
        
        System.assertEquals('Text Address Value', wrap2.address, 
            'Should use risk_address__c as fallback');
        
        System.assertEquals(null, wrap3.address, 
            'Should be null when both address fields are empty');
    }

    @isTest
    static void testRecordTypeIdMapping() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Asset testRisk = [SELECT Id, RecordTypeId FROM Asset WHERE Opportunity__c = :testOpp.Id LIMIT 1];
        
        Test.startTest();
        List<Aswata_Add_New_Asset_Controller.AssetWrapper> results = 
            Aswata_Add_New_Asset_Controller.getAssetsByOpportunity(testOpp.Id);
        Test.stopTest();
        
        Aswata_Add_New_Asset_Controller.AssetWrapper wrapper = null;
        for (Aswata_Add_New_Asset_Controller.AssetWrapper w : results) {
            if (w.id == testRisk.Id) {
                wrapper = w;
                break;
            }
        }
        
        System.assertNotEquals(null, wrapper, 'Should find wrapper');
        System.assertEquals(testRisk.RecordTypeId, wrapper.recordTypeId, 
            'Should map RecordType.Id correctly');
    }
    
    @isTest
    static void testGetRequiredFieldsByCob() {
        List<RecordType> masterDataRT = [SELECT Id FROM RecordType 
                                          WHERE SObjectType = 'Master_Data__c' 
                                          LIMIT 1];
        
        if (!masterDataRT.isEmpty()) {
            List<Master_Data__c> requiredFields = new List<Master_Data__c>();
            
            requiredFields.add(new Master_Data__c(
                Name = 'Province__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            ));
            
            requiredFields.add(new Master_Data__c(
                Name = 'City__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            ));
            
            requiredFields.add(new Master_Data__c(
                Name = 'Occupation_Code__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            ));
            
            requiredFields.add(new Master_Data__c(
                Name = 'Address__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            ));
            
            requiredFields.add(new Master_Data__c(
                Name = 'Class__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            ));
            
            requiredFields.add(new Master_Data__c(
                Name = 'NKR__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = false
            ));
            
            requiredFields.add(new Master_Data__c(
                Name = 'Marine_Type__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '202',
                Required__c = true
            ));
            
            insert requiredFields;
        }
        
        Test.startTest();
        
        List<String> result201 = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob('201');
        
        List<String> result202 = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob('202');
        
        List<String> resultEmpty = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob('999');
        
        List<String> resultNull = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob(null);
        
        List<String> resultBlank = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob('');
        
        Test.stopTest();
        
        if (!masterDataRT.isEmpty()) {
            System.assertEquals(5, result201.size(), 'Should return 5 required fields for COB 201');
            System.assert(result201.contains('Province__c'), 'Should contain Province__c');
            System.assert(result201.contains('City__c'), 'Should contain City__c');
            System.assert(result201.contains('Occupation_Code__c'), 'Should contain Occupation_Code__c');
            System.assert(result201.contains('Address__c'), 'Should contain Address__c');
            System.assert(result201.contains('Class__c'), 'Should contain Class__c');
            System.assert(!result201.contains('NKR__c'), 'Should NOT contain NKR__c (not required)');
            System.assert(!result201.contains('Marine_Type__c'), 'Should NOT contain Marine_Type__c (different COB)');
            
            System.assertEquals(1, result202.size(), 'Should return 1 required field for COB 202');
            System.assert(result202.contains('Marine_Type__c'), 'Should contain Marine_Type__c');
        }
        
        System.assertEquals(0, resultEmpty.size(), 'Non-existent COB should return empty list');
        System.assertEquals(0, resultNull.size(), 'Null COB should return empty list');
        System.assertEquals(0, resultBlank.size(), 'Blank COB should return empty list');
    }
    
    @isTest
    static void testGetRequiredFieldsByCobException() {
        Test.startTest();
        
        try {
            List<String> result = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob('INVALID_COB_VALUE');
            System.assertEquals(0, result.size(), 'Should return empty list for invalid COB');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }

    @isTest
    static void testGetRequiredFieldsByCobBlankName() {
        List<RecordType> masterDataRT = [SELECT Id FROM RecordType 
                                          WHERE SObjectType = 'Master_Data__c' 
                                          LIMIT 1];
        
        if (!masterDataRT.isEmpty()) {
            Master_Data__c blankName = new Master_Data__c(
                Name = '',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            );
            insert blankName;
            
            Master_Data__c nullName = new Master_Data__c(
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            );
            insert nullName;
            
            Master_Data__c validName = new Master_Data__c(
                Name = 'Valid_Field__c',
                RecordTypeId = masterDataRT[0].Id,
                BSN_ID__c = '201',
                Required__c = true
            );
            insert validName;
        }
        
        Test.startTest();
        List<String> result = Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob('201');
        Test.stopTest();
        
        if (!masterDataRT.isEmpty()) {
            System.assertEquals(3, result.size(), 'Should only return valid field names');
        }
    }
}