global without sharing class CaseWaitingMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Case c = [SELECT Priority, SCC_Call_Type__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        Integer timeValue = Integer.ValueOf(Label.HourInWaitingDocument);  
        return timeValue;
    }   
}