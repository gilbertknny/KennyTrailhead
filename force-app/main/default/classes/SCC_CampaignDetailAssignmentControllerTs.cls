/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 21-02-2025
 * @last modified by  : Ardyta Yudianto
**/
@isTest
private class SCC_CampaignDetailAssignmentControllerTs {
    private static User testUser1;
    private static User testUser2;
    
    @TestSetup
    static void setupTestData() {
        // Create test users (Setup objects)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@test.com',
            Username = 'testuser1@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser1;

        testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser2;

        // Assign Permission Set to testUser1 (Setup object)
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_Telesales_Maker' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser1.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
    }

    static void createTestRecords() {
        User u1 = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Username LIKE 'testuser2@test.com%' LIMIT 1];
        
        // Create test Campaign__c
        Campaign__c testCampaign = new Campaign__c(
            Name = 'Test Campaign'
        );
        insert testCampaign;

        // Create test Campaign Details
        List<Campaign_Detail__c> campaignDetails = new List<Campaign_Detail__c>();
        
        // Campaign Detail owned by user with Permission Set
        Campaign_Detail__c cd1 = new Campaign_Detail__c(
            Campaign__c = testCampaign.Id,
            OwnerId = u1.Id,
            Customer_Name__c = 'Test Customer 1',
            Dial_Phone_No__c = '1234567890'
        );
        campaignDetails.add(cd1);

        // Campaign Detail owned by user without Permission Set
        Campaign_Detail__c cd2 = new Campaign_Detail__c(
            Campaign__c = testCampaign.Id,
            OwnerId = u2.Id,
            Customer_Name__c = 'Test Customer 2',
            Dial_Phone_No__c = '0987654321'
        );
        campaignDetails.add(cd2);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert campaignDetails;
        }
    }

    @isTest
    static void testGetAllCampaignDetails() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        
        System.runAs(testUser) {
            createTestRecords();
            
            Test.startTest();
            Map<String, Object> result = SCC_CampaignDetailAssignmentController.getAllCampaignDetails();
            Test.stopTest();

            List<Campaign_Detail__c> filteredDetails = (List<Campaign_Detail__c>)result.get('campaignDetails');
            System.assertNotEquals(null, filteredDetails, 'Campaign details should not be null');
            System.assertEquals(1, filteredDetails.size(), 'Should only return campaign details owned by users without the permission set');
            
            Campaign_Detail__c detail = filteredDetails[0];
            System.assertEquals('Test Customer 2', detail.Customer_Name__c, 'Should return the correct campaign detail');
        }
    }

    @isTest
    static void testGetCampaignDetailsWithDate() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        
        System.runAs(testUser) {
            createTestRecords();
            Date testDate = Date.today();
            
            Test.startTest();
            Map<String, Object> result = SCC_CampaignDetailAssignmentController.getCampaignDetails(testDate);
            Test.stopTest();

            List<Campaign_Detail__c> filteredDetails = (List<Campaign_Detail__c>)result.get('campaignDetails');
            System.assertNotEquals(null, filteredDetails, 'Campaign details should not be null');
            System.assertEquals(1, filteredDetails.size(), 'Should only return campaign details owned by users without the permission set');
        }
    }

    @isTest
    static void testGetCampaignDetailsWithNullDate() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        
        System.runAs(testUser) {
            createTestRecords();
            
            Test.startTest();
            Map<String, Object> result = SCC_CampaignDetailAssignmentController.getCampaignDetails(null);
            Test.stopTest();

            List<Campaign_Detail__c> filteredDetails = (List<Campaign_Detail__c>)result.get('campaignDetails');
            System.assertNotEquals(null, filteredDetails, 'Campaign details should not be null');
            System.assertEquals(1, filteredDetails.size(), 'Should return all campaign details owned by users without the permission set');
        }
    }

    @isTest
    static void testGetTelesalesMakers() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        
        System.runAs(testUser) {
            createTestRecords();
            
            Test.startTest();
            List<User> telesalesMakers = SCC_CampaignDetailAssignmentController.getTelesalesMakers();
            Test.stopTest();

            System.assertNotEquals(null, telesalesMakers, 'Telesales makers list should not be null');
            // System.assertEquals(1, telesalesMakers.size(), 'Should return one telesales maker');
            // System.assertEquals('Test User1', telesalesMakers[0].Name, 'Should return the correct user');
        }
    }

    @isTest
    static void testAssignCampaignDetails() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        
        System.runAs(testUser) {
            createTestRecords();
            
            // Get test data
            User telesalesMaker = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
            Campaign_Detail__c campaignDetail = [SELECT Id FROM Campaign_Detail__c WHERE Customer_Name__c = 'Test Customer 2' LIMIT 1];
            
            // Prepare assignments
            Map<Id, List<Id>> assignments = new Map<Id, List<Id>>{
                telesalesMaker.Id => new List<Id>{campaignDetail.Id}
            };

            Test.startTest();
            SCC_CampaignDetailAssignmentController.assignCampaignDetails(assignments);
            Test.stopTest();

            // Verify assignment
            Campaign_Detail__c updatedDetail = [SELECT Id, OwnerId FROM Campaign_Detail__c WHERE Id = :campaignDetail.Id];
            System.assertEquals(telesalesMaker.Id, updatedDetail.OwnerId, 'Campaign detail should be assigned to the telesales maker');
        }
    }

    // @isTest
    // static void testAssignCampaignDetailsError() {
    //     User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser1@test.com%' LIMIT 1];
        
    //     System.runAs(testUser) {
    //         createTestRecords();
            
    //         // Prepare invalid assignments
    //         Map<Id, List<Id>> assignments = new Map<Id, List<Id>>{
    //             '005000000000000' => new List<Id>{'a0A000000000000'}
    //         };

    //         Test.startTest();
    //         try {
    //             SCC_CampaignDetailAssignmentController.assignCampaignDetails(assignments);
    //             System.assert(false, 'Should throw an exception for invalid assignments');
    //         } catch (AuraHandledException e) {
    //             System.assert(true, 'Exception should be thrown for invalid assignments');
    //         }
    //         Test.stopTest();
    //     }
    // }
}