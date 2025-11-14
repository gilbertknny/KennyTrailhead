@IsTest (seeAllData=false)
public with sharing class Aswata_Lead_Distribution_Queueable_Test {
    @IsTest
    static void testCreateNewLead() {
        // Step 1: Setup test data
        Aswata_TestDataFactory.createLocationHierarchy();
        Master_Data__c masterBranch = Aswata_TestDataFactory.createMasterData('Jakarta', 'Master Branch');
        masterBranch.BRANCH_ID__c = '1';
        update masterBranch;

        Master_Data__c roundRobinMember1 = Aswata_TestDataFactory.createMasterData('Round Robin Member 1', 'Round Robin Member');
        roundRobinMember1.Salesman_branch__c = masterBranch.Id;
        roundRobinMember1.Round_Robin_Counter_Branch__c = 1;
        roundRobinMember1.Round_Robin_Counter_Account__c = 1;
        update roundRobinMember1;
        // Fetch test locations
        Schema.Location zipCode = [SELECT Id FROM Location WHERE RecordType.Name = 'Zip Code' LIMIT 1];
        zipCode.Branch_ID__c = '1';
        update zipCode;
        
        Schema.Location address = [SELECT Id FROM Location WHERE RecordType.Name = 'Address' LIMIT 1];

        // Step 2: Create Lead
        Lead lead = Aswata_TestDataFactory.createLeadCustom('Alice', 'Smith', 'Test Corp');
        lead.Zip__c = zipCode.Id;
        lead.Address__c = address.Id;
        lead.branch__c = '1';

        Test.startTest();
        insert lead;
        Test.stopTest();

        // Step 3: Verify Lead updates
        Lead insertedLead = [SELECT Id, Zip__c, Address__c, Branch__c, Description, Original_Lead_ID__c, Address_Selected__c 
                             FROM Lead WHERE Id = :lead.Id LIMIT 1];

        // Assert that the Zip__c and Address__c still match master data
        System.assertEquals(zipCode.Id, insertedLead.Zip__c, 'Zip__c should match the master Location Id');
        System.assertEquals(address.Id, insertedLead.Address__c, 'Address__c should match the master Location Id');

        // Assert that trigger logic ran
       //System.assertEquals(lead.Id, insertedLead.Original_Lead_ID__c, 'Original_Lead_ID__c should be set');
       //System.assertEquals(true, insertedLead.Address_Selected__c, 'Address_Selected__c should be true');
    }
}