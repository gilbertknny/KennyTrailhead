@isTest
public with sharing class SCC_EmployeeFeedbackControllerTest {
    @TestSetup
    static void setupTestData() {

        String surveyId = System.Label.employee_feedback_id;
        
        Employee_Survey__c empSurvey = new Employee_Survey__c(
            Survey__c = surveyId,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(5),
            Active__c = true,
            Title__c = 'Test Title',
            Subtitle__c = 'Test Subtitle',
            Content__c = 'Test Content'
        );

        insert empSurvey;

    }


    @isTest
    static void testGetCurrentUserId() {
        Test.startTest();
        SCC_EmployeeFeedbackController.userInfoWrapper result =  SCC_EmployeeFeedbackController.getCurrentUserId();
        Test.stopTest();
        
        Assert.isNotNull(result, 'User info should not be null');
        Assert.areEqual(UserInfo.getUserId(), result.userId, 'User ID should match current user');
        Assert.areEqual(UserInfo.getUserName(), result.userName, 'Username should match current user');
    }

    @isTest
    static void testCheckSurveyDateActive() {
        Test.startTest();
        SCC_EmployeeFeedbackController.surveyDataWrapper result =  SCC_EmployeeFeedbackController.checkSurveyDateActive();
        Test.stopTest();
        
        Assert.isNotNull(result, 'Survey data should not be null');
        Assert.isTrue(result.isOpen, 'Survey should be open based on dates');
        Assert.areEqual('Test Title', result.title, 'Title should match');
        Assert.areEqual('Test Subtitle', result.subtitle, 'Subtitle should match');
        Assert.areEqual('Test Content', result.content, 'Content should match');
    }

    @isTest
    static void testNoInvitation() {
        List<User> testUser = [SELECT username, Profile.Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String surveyId = System.Label.employee_feedback_id;
        String userId = testUser[0].Id;

        
        Test.startTest();
        SCC_EmployeeFeedbackController.surveyInvitationDataWrapper result = SCC_EmployeeFeedbackController.checkSurveyInvitation(userId , surveyId);
        Test.stopTest();

        Assert.areEqual('', result.surveyInvitationID);
        Assert.areEqual(false, result.invitationIsCompleted);
    }

    @isTest
    static void testNotStartedInvitation() {
        List<User> testUser = [SELECT username, Profile.Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String surveyId = System.Label.employee_feedback_id;
        String userId = testUser[0].Id;
        
        SurveyInvitation invitation = new SurveyInvitation(
            Name = 'Test-Inv-001',
            Responden__c = userId,
            SurveyId = surveyId
        );
        insert invitation;
        
        Test.startTest();
        SCC_EmployeeFeedbackController.surveyInvitationDataWrapper result = SCC_EmployeeFeedbackController.checkSurveyInvitation(userId, surveyId);
        Test.stopTest();
        
        Assert.areEqual(invitation.Id, result.surveyInvitationID);
        Assert.areEqual(false, result.invitationIsCompleted);
    }

    @isTest
    static void testNoExistingInvitation() {
        List<User> testUser = [SELECT username, Profile.Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String surveyId = System.Label.employee_feedback_id;
        String userId = testUser[0].Id;
        
        Test.startTest();
        SCC_EmployeeFeedbackController.SurveyInvitationDataWrapper result = SCC_EmployeeFeedbackController.createSurveyInvitation(userId, surveyId);
        Test.stopTest();

        Assert.areEqual('', result.surveyInvitationID);
        Assert.areEqual(false, result.invitationIsCompleted);
        Assert.areEqual('', result.invitationLink);
    }

    @isTest
    static void testExistingInvitation() {
        List<User> testUser = [SELECT username, Profile.Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String surveyId = System.Label.employee_feedback_id;
        String userId = testUser[0].Id;
        
        SurveyInvitation invitation = new SurveyInvitation(
            Name = 'Test-Inv-001',
            Responden__c = userId,
            SurveyId = surveyId
        );
        insert invitation;
        
        Test.startTest();
        SCC_EmployeeFeedbackController.SurveyInvitationDataWrapper result = SCC_EmployeeFeedbackController.createSurveyInvitation(userId,surveyId);
        Test.stopTest();
        
    }

    @isTest
    static void testSuccessfulInvitationCreation() {
        List<User> testUser = [SELECT username, Profile.Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String surveyId = System.Label.employee_feedback_id;
        String userId = testUser[0].Id;
        String username = testUser[0].username;
        
        Test.startTest();
        SCC_EmployeeFeedbackController.SurveyInvitationDataWrapper result = SCC_EmployeeFeedbackController.createNewSurveyInvitation(
            userId, 
            surveyId, 
            username
        );
        Test.stopTest();
        
        SurveyInvitation createdInvitation = [
            SELECT Id, Name, SurveyId, CommunityId, OptionsAllowGuestUserResponse, Responden__c, InvitationLink 
            FROM SurveyInvitation 
            WHERE Id = :result.surveyInvitationID
        ];
        
        Assert.areNotEqual(null, result.surveyInvitationID);
        Assert.areEqual(false, result.invitationIsCompleted);
        Assert.areNotEqual(null, result.invitationLink);
        Assert.areEqual(System.Label.CommunityId, createdInvitation.CommunityId);
        Assert.areEqual(true, createdInvitation.OptionsAllowGuestUserResponse);
        Assert.areEqual(userId, createdInvitation.Responden__c);
    }

}