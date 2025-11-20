/** @description
 * Test class to verify the functionality of the CaseTotalSLAMilestoneTimeCalculator class.
 */
@isTest
private class CaseTotalSLAMilestoneTimeCalculatorTest {
    
    /** @description
     * Test method to verify the calculateMilestoneTriggerTime() function.
     */
    @isTest
    static void testCalculateMilestoneTriggerTime() {
        // Test data setup
        Case testCase = new Case(
            Priority = 'High',
             SCC_Assigned_Date__c = Date.today().addDays(-1), // Assigned date 1 day ago
            SCC_Case_Type_assigned_time__c = Datetime.now().addMinutes(-30),
                         SCC_Next_Escalation_Level__c = 'SCC_Level1_Escalation_team__c', // Replace with your specific SCC_Next_Escalation_Level__c
            SCC_Case_Category__c = 'Request',
            SCC_Product_L1__c ='Loans',
            SCC_Product_L2__c='KTA - Digital',
            SCC_Segment__c = 'Individu Umum',
            Description='xyz'// Case type assigned time 30 minutes ago
            // Add any other required fields for the Case record
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

        // Test the calculateMilestoneTriggerTime method
        Test.startTest();
        CaseTotalSLAMilestoneTimeCalculator calculator = new CaseTotalSLAMilestoneTimeCalculator();
        Integer result = calculator.calculateMilestoneTriggerTime(testCase.Id, callType.Id);
        Test.stopTest();

        // Verify the result
        Integer expectedTimeValue = 1; // Convert hours to days
        System.assertEquals(expectedTimeValue, result, 'Milestone trigger time calculation is incorrect');
    }
}