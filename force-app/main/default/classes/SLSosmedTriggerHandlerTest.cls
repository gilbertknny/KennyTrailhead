@isTest
public class SLSosmedTriggerHandlerTest {
    
    @isTest
    static void testHandleBeforeTrigger() {
        Test.startTest();
        // Create test data for SSC_Call_Type__c
        SSC_Call_Type__c callType = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Level1_OLA__c = 1,
            SCC_Level2_OLA__c = 2,
            SCC_Level3_OLA__c = 2,
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true
        );
        insert callType;
        
        Case testCase = new Case(
            Status = 'New',
            SCC_Call_Type__c = callType.Id,
            Subject = 'Test Case for SLSosmedTriggerHandler',
            SproutExId__c = '12345'
        );
        insert testCase;

        testCase = [SELECT Id, SCC_SL_Sosmed_Timer_Dimulai__c FROM Case WHERE Id = :testCase.Id];

        //System.assertNotEquals(null, testCase.SCC_SL_Sosmed_Timer_Dimulai__c);
        Test.stopTest();
    }
}