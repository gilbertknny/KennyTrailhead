/** @description
 * Apex class to calculate the trigger time for a milestone based on the agent SLA (Service Level Agreement) of a support case.
 * Implements the Support.MilestoneTriggerTimeCalculator interface.
 */
global without sharing class CaseAgentSLAMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
/** @description
     * Calculates the trigger time for a milestone based on the agent SLA of a support case.
     * 
     * @param caseId The ID of the support case.
     * @param milestoneTypeId The ID of the milestone type for which trigger time is calculated.
     * @return The calculated trigger time in minutes.
     * @throws SecurityException If the current user does not have sufficient permissions to access required objects or fields.
     */
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Integer timeValue = 1;
        
        
        // Retrieve case information
        Case c = [SELECT Priority, SCC_Call_Type__c, SCC_Assigned_Date__c, SCC_Case_Type_assigned_time__c 
                  FROM Case 
                 WHERE Id = :caseId WITH SECURITY_ENFORCED];
        
        // Retrieve relevant SSC_Call_Type__c records
        List<SSC_Call_Type__c> calls = [SELECT Id, SCC_Agent_SLA__c 
                                          FROM SSC_Call_Type__c 
                                         WHERE Id = :c.SCC_Call_Type__c WITH SECURITY_ENFORCED];

        if (!calls.isEmpty()) {
            timeValue = Integer.valueOf(calls[0].SCC_Agent_SLA__c * 60 * 24);

            // Calculate the difference between SCC_Assigned_Date__c and SCC_Case_Type_assigned_time__c
            if (c.SCC_Assigned_Date__c != null && c.SCC_Case_Type_assigned_time__c != null) {
                Long timeDifferenceInMinutes = (c.SCC_Case_Type_assigned_time__c.getTime() - c.SCC_Assigned_Date__c.getTime()) / (1000 * 60);
                timeValue -= timeDifferenceInMinutes.intValue();
                if(timeValue<0)
                timeValue=1;
            }
        }

        return Math.max(1, timeValue);
    }
}