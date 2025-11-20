/**
 * @description       : Test Class untuk SCC_CampaignDetailCalculator
 * @author           : Ardyta Yudianto
 * @group            : 
 * @last modified on : 21-02-2025
 * @last modified by : Ardyta Yudianto
**/
@IsTest
private class SCC_CampaignDetailCalculatorTest {
    private static User testUser1;
    private static User testUser2;
    
    @TestSetup
    static void setupTestData() {
        // Create test users first
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        testUser1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@test.com',
            Username = 'testuser1@test.com' + System.currentTimeMillis(),
            Alias = 'tuser1',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id
        );
        insert testUser1;

        testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com' + System.currentTimeMillis(),
            Alias = 'tuser2',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id
        );
        insert testUser2;

        // Assign Permission Set in a separate transaction
        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_Telesales_Maker' LIMIT 1];
            insert new PermissionSetAssignment(
                AssigneeId = testUser1.Id,
                PermissionSetId = ps.Id
            );
        }
    }

    @IsTest
    static void testCalculateTotals() {
        User testUser1 = [SELECT Id FROM User WHERE Email = 'testuser1@test.com' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Email = 'testuser2@test.com' LIMIT 1];
        
        // Create test data in a separate method
        Campaign__c campaign = createTestCampaignWithDetails(testUser1.Id, testUser2.Id);
        
        Test.startTest();
        SCC_CampaignDetailCalculator.calculateTotals(new List<Id>{campaign.Id});
        Test.stopTest();

        // Verify results
        Campaign__c updatedCampaign = [
            SELECT Id, Total_Agent__c, Total_Customer__c, Total_Call__c 
            FROM Campaign__c 
            WHERE Id = :campaign.Id
        ];

        // Assert results
        System.assertEquals(1, updatedCampaign.Total_Agent__c, 
            'Should only count agents with SCC_Telesales_Maker permission set');
        System.assertEquals(2, updatedCampaign.Total_Customer__c, 
            'Should count all unique customers');
        System.assertEquals(25, updatedCampaign.Total_Call__c, 
            'Should sum all call durations');
    }

    private static Campaign__c createTestCampaignWithDetails(Id user1Id, Id user2Id) {
        // Create test Campaign
        Campaign__c campaign = new Campaign__c(
            Name = 'Test Campaign'
        );
        insert campaign;

        // Create Campaign Details
        List<Campaign_Detail__c> details = new List<Campaign_Detail__c>();
        
        // Details owned by user with permission set
        Campaign_Detail__c detail1 = new Campaign_Detail__c(
            Campaign__c = campaign.Id,
            OwnerId = user1Id,
            Customer_Name__c = 'Customer 1',
            Duration__c = 10
        );
        details.add(detail1);

        // Details owned by user without permission set
        Campaign_Detail__c detail2 = new Campaign_Detail__c(
            Campaign__c = campaign.Id,
            OwnerId = user2Id,
            Customer_Name__c = 'Customer 2',
            Duration__c = 15
        );
        details.add(detail2);

        insert details;
        
        return campaign;
    }

    @IsTest
    static void testCalculateTotalsWithNullValues() {
        // Create campaign with null values
        Campaign__c campaign = new Campaign__c(
            Name = 'Test Campaign Null'
        );
        insert campaign;

        User testUser1 = [SELECT Id FROM User WHERE Email = 'testuser1@test.com' LIMIT 1];

        Campaign_Detail__c detailNull = new Campaign_Detail__c(
            Campaign__c = campaign.Id,
            OwnerId = testUser1.Id,
            Customer_Name__c = null,
            Duration__c = null
        );
        insert detailNull;

        Test.startTest();
        SCC_CampaignDetailCalculator.calculateTotals(new List<Id>{campaign.Id});
        Test.stopTest();

        // Verify results
        Campaign__c updatedCampaign = [
            SELECT Id, Total_Agent__c, Total_Customer__c, Total_Call__c 
            FROM Campaign__c 
            WHERE Id = :campaign.Id
        ];

        // Assert results
        // System.assertEquals(0, updatedCampaign.Total_Agent__c, 
        //     'Should handle null OwnerId');
        System.assertEquals(0, updatedCampaign.Total_Customer__c, 
            'Should handle null Customer_Name__c');
        System.assertEquals(0, updatedCampaign.Total_Call__c, 
            'Should handle null Duration__c');
    }

    @IsTest
    static void testCalculateTotalsWithEmptyCampaign() {
        // Create empty campaign
        Campaign__c emptyCampaign = new Campaign__c(
            Name = 'Empty Campaign'
        );
        insert emptyCampaign;

        Test.startTest();
        SCC_CampaignDetailCalculator.calculateTotals(new List<Id>{emptyCampaign.Id});
        Test.stopTest();

        // Verify results
        Campaign__c updatedCampaign = [
            SELECT Id, Total_Agent__c, Total_Customer__c, Total_Call__c 
            FROM Campaign__c 
            WHERE Id = :emptyCampaign.Id
        ];

        // Assert results
        System.assertEquals(0, updatedCampaign.Total_Agent__c, 
            'Should handle campaign with no details');
        System.assertEquals(0, updatedCampaign.Total_Customer__c, 
            'Should handle campaign with no details');
        System.assertEquals(0, updatedCampaign.Total_Call__c, 
            'Should handle campaign with no details');
    }
}