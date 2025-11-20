/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(SeeAllData=true)
public class SurveyInvitationTriggerTest {

    @isTest
    static void testSurveyInvitationUpdate() {

        // Retrieve existing records
        List<Survey> existingSurveys = [SELECT Id FROM Survey WHERE DeveloperName LIKE '%customer_feedback_survey%' LIMIT 1];

        SurveyInvitation invitation = [SELECT Id, OptionsAllowGuestUserResponse 
                                       FROM SurveyInvitation 
                                       LIMIT 1];
        
        Test.startTest();
        
        SurveyInvitation oldInvitation = new SurveyInvitation(
            Id = invitation.Id,
            OptionsAllowGuestUserResponse = true
        );
        update oldInvitation;
        //oldInvitation.put('ResponseStatus', 'Started');
        
        SurveyInvitation newInvitation = new SurveyInvitation(
            Id = invitation.Id,
            OptionsAllowGuestUserResponse = true
        );
        //newInvitation.put('ResponseStatus', 'Completed');
        
        // SurveyInvitationTriggerHandler.triggerOldMap = new Map<Id, SurveyInvitation>{
        //     oldInvitation.Id => oldInvitation
        // };
            
        // SurveyInvitationTriggerHandler.triggerNew = new List<SurveyInvitation>{
        //     newInvitation
        // };
        
        //SurveyInvitationTriggerHandler.handleBeforeUpdate();
        
        Test.stopTest();
        
        //System.assertEquals(false, newInvitation.OptionsAllowGuestUserResponse, 'Guest response should be disabled when status is Completed');
    }
}