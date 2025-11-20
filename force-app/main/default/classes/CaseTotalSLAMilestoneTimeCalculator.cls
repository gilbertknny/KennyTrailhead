global without sharing class CaseTotalSLAMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    global  Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Integer timeValue = 1;
        Integer iHour = Integer.ValueOf(Label.HourInBusinessHour);
        //if(!FeatureManagement.checkPermission('By_Pass_Validation_for_Migration')){
        Case c = [SELECT Priority, SCC_Call_Type__c, CreatedDate FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        List<SSC_Call_Type__c> calls = [SELECT Id, SCC_Total_SLA__c FROM SSC_Call_Type__c WHERE Id = :c.SCC_Call_Type__c WITH SECURITY_ENFORCED];
        if (!calls.isEmpty()) timeValue = Integer.valueOf(calls[0].SCC_Total_SLA__c * 60 * iHour);
        if(timeValue <= 0) timeValue = 1;
        //}
        return timeValue;
    }   
}