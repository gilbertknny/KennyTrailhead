@isTest
public class CaseOLAUkerMilestoneTimeCalculatorTest {
	@isTest
    static void testCalculateMilestoneTriggerTime() {
        Case testCase = new Case(
            Priority = 'High',
             SCC_Assigned_Date__c = Date.today().addDays(-1), // Assigned date 1 day ago
            SCC_Case_Type_assigned_time__c = Datetime.now().addMinutes(-30),
                         SCC_Next_Escalation_Level__c = 'SCC_Level1_Escalation_team__c', // Replace with your specific SCC_Next_Escalation_Level__c
            SCC_Case_Category__c = 'Request',
            SCC_Product_L1__c ='Loans',
            SCC_Product_L2__c='KTA - Digital',
            SCC_Segment__c = 'Individu Umum',
            Description='xyz'
        );
        insert testCase;

        SSC_Call_Type__c callType = new SSC_Call_Type__c(
              Name = 'Test Call Type',
            SCC_Agent_SLA__c = 1, // Adjusted to a valid value
           // SCC_Level1_OLA__c = 1,
            SSC_Case_Description__c	 = 'xyz',
            External_Id__c = '8812',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request'// 2 minutes as SCC_Agent_SLA__c
            // Add any other required fields for the SSC Call Type record
        );
        insert callType;
        
        Test.startTest();
        CaseOLAUkerMilestoneTimeCalculator calculator = new CaseOLAUkerMilestoneTimeCalculator();
        Integer result = calculator.calculateMilestoneTriggerTime(testCase.Id, callType.Id);
        Test.stopTest();
    }
}