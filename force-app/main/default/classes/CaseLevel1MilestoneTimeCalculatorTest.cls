/**  @description
 * Test class for the CaseLevel1MilestoneTimeCalculator class.
 * Verifies the behavior of the calculateMilestoneTriggerTime method.
 */
@isTest
private class CaseLevel1MilestoneTimeCalculatorTest {
    /** @description
     * Test method to verify the calculation of milestone trigger time.
     * 
     * Test Scenario:
     * - Create a Case record with a high priority.
     * - Create an SSC_Call_Type__c record with a specified SCC_Level1_OLA__c value.
     * - Call the calculateMilestoneTriggerTime method with the Case Id and SSC_Call_Type__c Id.
     * - Verify that the calculated time value matches the expected value.
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
            Description='xyz'
            // Add any other required fields for the Case record
        );
        insert testCase;

        // Create an SSC_Call_Type__c record with a specified SCC_Level1_OLA__c value
        SSC_Call_Type__c callType = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Level1_OLA__c = 1,
            SSC_Case_Description__c	 = 'xyz',
            External_Id__c = '8812',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request',// Adjusted to a valid value
            Active__c = true
            // Add any other required fields for the SSC Call Type record
        );
        insert callType;

        testCase.SCC_Call_Type__c = callType.id;
        update testCase;

        // Test the calculateMilestoneTriggerTime method
        Test.startTest();
        CaseLevel1MilestoneTimeCalculator calculator = new CaseLevel1MilestoneTimeCalculator();
        Integer result = calculator.calculateMilestoneTriggerTime(testCase.Id, callType.Id);
        Test.stopTest();

        // Verify the result
        Integer expectedTimeValue = 480; // Convert hours to days
        System.assertEquals(expectedTimeValue, result, 'Milestone trigger time calculation is incorrect');
    }
}