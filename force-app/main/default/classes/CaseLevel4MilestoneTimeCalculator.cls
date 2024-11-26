global without sharing class CaseLevel4MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        Integer timeValue = 1;
        Integer iHour = Integer.ValueOf(Label.HourInBusinessHour);
        Integer iTotal = 0;
        List<AggregateResult> listar = [SELECT SUM(ElapsedTimeInMins) Total FROM CaseMilestone 
                                        WHERE CaseId =:caseId 
                                        AND IsCompleted = TRUE 
                                        AND MilestoneTypeId =:milestoneTypeId
                                        GROUP BY MilestoneTypeId LIMIT 1]; 
        if(listar.size()>0) iTotal = Integer.ValueOf(listar[0].get('Total'));
        Case c = [SELECT Priority, SCC_Call_Type__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        List<SSC_Call_Type__c> calls = [SELECT Id, SCC_Level4_OLA__c FROM SSC_Call_Type__c WHERE Id = :c.SCC_Call_Type__c WITH SECURITY_ENFORCED];
        if (!calls.isEmpty()) {
            if (iTotal > (Integer.valueOf(calls[0].SCC_Level4_OLA__c * 60 * iHour))) {
                timeValue = 1 * 60 * iHour; 
            }  else {
                timeValue = Integer.valueOf(calls[0].SCC_Level4_OLA__c * 60 * iHour) - iTotal; 
            }
        }
        return timeValue;
    }
}