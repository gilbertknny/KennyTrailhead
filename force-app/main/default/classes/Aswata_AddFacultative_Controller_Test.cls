@isTest(seeAllData=false)
public with sharing class Aswata_AddFacultative_Controller_Test {
    
    @TestSetup
    static void setupData() {
        Transaction_Data__c facFolder = Aswata_TestDataFactory.createTransactionData('Facultative Folder', 'Folder Test');
        facFolder.Folder_Status__c = 'In Progress';
        update facFolder;

        Account acc = Aswata_TestDataFactory.createAccount('Coverage Account');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Coverage Opportunity');
        opp.Opportunity_Type__c = 'NB';
        update opp;
        InsurancePolicy policy = Aswata_TestDataFactory.createInsurancePolicy(acc, opp);
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Risk Test');
        risk.Facultative_Folder__c = facFolder.Id;
        risk.Has_Facultative__c = true;
        update risk;
        Quote quo = Aswata_TestDataFactory.createQuote(opp, 'Test Quote');


        // add opportunity Facultative
        Opportunity outwardOpp = Aswata_TestDataFactory.createOpportunity(acc, 'Outward Facultative Opportunity');
        outwardOpp.Opportunity_Type__c = 'Facultative Outward';
        outwardOpp.Facultative_Folder__c = facFolder.Id;
        update outwardOpp;

        Asset riskFacul = Aswata_TestDataFactory.createRisk(outwardOpp, 'Risk Test');
        riskFacul.Origin_Risk__c = risk.Id;
        update riskFacul;

        Account accReas = Aswata_TestDataFactory.createAccount('Reinsurer A'); 
        accReas.Type = 'REINSURANCE';
        accReas.Insurance_ID__c = 'R001';
        update accReas;

    }

    

    // === Test getFolderAndRiskDetail ===
    @IsTest
    static void test_getFolderAndRiskDetail() {

        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        Map<String, Object> result = Aswata_AddFacultative_Controller.getFolderAndRiskDetail(testQuote.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('folderOptions'), 'Result should contain folderOptions');
    }
    
    // === Test getListOpportunityFolder ===
    @IsTest
    static void test_getListOpportunityFolder() {
        Transaction_Data__c folder = [SELECT Id FROM Transaction_Data__c WHERE RecordType.Name = 'Facultative Folder' LIMIT 1];
        Test.startTest();
        Map<String, Object> result = Aswata_AddFacultative_Controller.getListOpportunityFolder(folder.id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('folderOpportunities'), 'Result should contain folderOpportunities');
    }

    // === Test getRiskDetail ===
    @IsTest
    static void test_getRiskDetail() {
        Asset riskFacul = [SELECT Id FROM Asset WHERE RecordType.Name = 'Risk' and Origin_Risk__c != null LIMIT 1];
        // Add a Treaty JSON to Quote for parsing
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        q.Treaty_Distribution_Response__c = 
            '[{"busreq_id":"BR001","riskNo":"RISK001","totalSumInsuredShare":1000000,"accumulatedSumInsuredShare":500000,"treaty":400000,"exhaustedUtilized":100000,"remaining":300000,"excess":50000}]';
        update q;

        Test.startTest();
        Map<String, Object> result = Aswata_AddFacultative_Controller.getRiskDetail(riskFacul.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Risk detail should not be null');
        System.assert(result.containsKey('Name'), 'Risk detail should include Name');
    }
    // === Test searchAccounts ===
    @IsTest
    static void test_searchAccounts() {
        // Create a Reinsurance type account

        Test.startTest();
        List<Account> results = Aswata_AddFacultative_Controller.searchAccounts('Reinsurer');
        Test.stopTest();

        System.assert(results.size() > 0, 'Should return at least one matching account');
    }

    // === Test updateFacultativeStatus ===
    @IsTest
    static void test_updateFacultativeStatus() {
        Opportunity opp = [SELECT Id FROM Opportunity Where Opportunity_Type__c = 'Facultative Outward' LIMIT 1];
        String newStatus = 'Approved';

        Test.startTest();
        Aswata_AddFacultative_Controller.updateFacultativeStatus(opp.Id, newStatus);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Offering_status__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(newStatus, updatedOpp.Offering_status__c, 'Status should be updated correctly');
    }
        
}