/** @description
 * Apex class to calculate the trigger time for Total milestones at  of support cases.
 */
@isTest
private class CaseAgentSLAMilestoneTimeCalculatorTest {

    @isTest
    static void testCalculateMilestoneTriggerTime() {
        // Create a test Case record
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
        );
        insert testCase;

        // Create a test SSC_Call_Type__c record
        SSC_Call_Type__c testCallType = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Agent_SLA__c = 2,
             Active__c = true,
            SSC_Case_Description__c = 'Cek',
            External_Id__c = '8812',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request'// 2 minutes as SCC_Agent_SLA__c
        );
        insert testCallType;

        // Associate the test SSC_Call_Type__c record with the test Case record
        testCase.SCC_Call_Type__c = testCallType.Id;
        update testCase;

        Test.startTest();
        // Instantiate the CaseAgentSLAMilestoneTimeCalculator class
        CaseAgentSLAMilestoneTimeCalculator calculator = new CaseAgentSLAMilestoneTimeCalculator();

        // Call the calculateMilestoneTriggerTime method
        Integer triggerTime = calculator.calculateMilestoneTriggerTime(testCase.Id, null); // Pass null as milestoneTypeId

        Test.stopTest();

      
    }

   

    @isTest
    static void testCalculateMilestoneTriggerTimeNoCallType() {
        // Test case where SCC_Call_Type__c is not assigned
        Case testCase = new Case(
            Priority = 'High',
            SCC_Assigned_Date__c = Date.today().addDays(-1),
            SCC_Case_Type_assigned_time__c = Datetime.now().addMinutes(-30)
        );
        insert testCase;

        Test.startTest();
        CaseAgentSLAMilestoneTimeCalculator calculator = new CaseAgentSLAMilestoneTimeCalculator();
        Integer triggerTime = calculator.calculateMilestoneTriggerTime(testCase.Id, null);
        Test.stopTest();

        // Assert that trigger time should be 1 since no SCC_Call_Type__c is assigned
        Integer expectedTriggerTime = 1;
        System.assertEquals(expectedTriggerTime, triggerTime);
    }
   
    @isTest
    static void testCalculateMilestoneTriggerTimeNoCallType1() {
        // Test case where SCC_Call_Type__c is not assigned
        Case testCase = new Case(
            Priority = 'High',
            SCC_Assigned_Date__c = Date.today().addDays(-1),
            SCC_Case_Type_assigned_time__c = Datetime.now().addMinutes(-30)
        );
        insert testCase;

        Test.startTest();
        CaseAgentSLAMilestoneTimeCalculator calculator = new CaseAgentSLAMilestoneTimeCalculator();
        Integer triggerTime = calculator.calculateMilestoneTriggerTime(testCase.Id, null);
        Test.stopTest();

        // Assert that trigger time should be 1 since no SCC_Call_Type__c is assigned
        Integer expectedTriggerTime = 1;
        System.assertEquals(expectedTriggerTime, triggerTime);
    }
}