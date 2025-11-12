@IsTest (seeAllData=false)
public with sharing class Aswata_TriggerHandler_Lead_Test {
    @IsTest
    static void testCreateNewLead() {
        // Step 1: Setup test data
        Aswata_TestDataFactory.createLocationHierarchy();
        
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

    @IsTest
    static void testCreateUpdateLead() {
        // Step 1: Setup test data
        Aswata_TestDataFactory.createLocationHierarchy();
        
        // Fetch test locations
        Schema.Location zipCode = [SELECT Id FROM Location WHERE RecordType.Name = 'Zip Code' LIMIT 1];
        Schema.Location address = [SELECT Id FROM Location WHERE RecordType.Name = 'Address' LIMIT 1];

        // Step 2: Create Lead
        Lead lead = Aswata_TestDataFactory.createLeadCustom('Alice', 'Smith', 'Test Corp');
        lead.Zip__c = zipCode.Id;
        lead.Address__c = address.Id;
        insert lead;

        Schema.Location newZipCode = Aswata_TestDataFactory.createZipCode();
        insert newZipCode;
        Schema.Location newAddress = Aswata_TestDataFactory.createAddress();
        newAddress.address_Name__c = 'Jl. Thamrin No. 20';
        insert newAddress;

        Test.startTest();
       
        lead.zip__c = newZipCode.Id;
        lead.address__c = newAddress.Id;
        update lead;

        Test.stopTest();

        // Step 3: Verify Lead updates
        Lead insertedLead = [SELECT Id, Zip__c, Address__c, Branch__c, Description, Original_Lead_ID__c, Address_Selected__c 
                             FROM Lead WHERE Id = :lead.Id LIMIT 1];

        // Assert that the Zip__c and Address__c still match master data
        System.assertEquals(newZipCode.Id, insertedLead.Zip__c, 'Zip__c should match new master Location Id');
        System.assertEquals(newAddress.Id, insertedLead.Address__c, 'Address__c should match new master Location Id');

        // Assert that trigger logic ran
       //System.assertEquals(lead.Id, insertedLead.Original_Lead_ID__c, 'Original_Lead_ID__c should be set');
       //System.assertEquals(true, insertedLead.Address_Selected__c, 'Address_Selected__c should be true');
    }

}