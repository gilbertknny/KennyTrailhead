@isTest
public class SLSosmedTriggerHandlerTest {
    
    @isTest
    static void testHandleBeforeTrigger() {
        Case testCase = new Case(
            Status = 'New',
            Subject = 'Test Case for SLSosmedTriggerHandler',
            SproutExId__c = '12345'
        );
        insert testCase;

        testCase = [SELECT Id, SCC_SL_Sosmed_Timer_Dimulai__c FROM Case WHERE Id = :testCase.Id];

        System.assertNotEquals(null, testCase.SCC_SL_Sosmed_Timer_Dimulai__c);
    }
}