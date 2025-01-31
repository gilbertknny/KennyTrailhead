global without sharing class CaseOLAUkerMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        //Case c = [SELECT Priority, SCC_Call_Type__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        Integer iTotal = 0;
        List<AggregateResult> listar = [SELECT SUM(ElapsedTimeInMins) Total FROM CaseMilestone 
                                        WHERE CaseId =:caseId 
                                        AND IsCompleted = TRUE 
                                        AND MilestoneTypeId =:milestoneTypeId
                                        GROUP BY MilestoneTypeId LIMIT 1]; 
        if(listar.size()>0) iTotal = Integer.ValueOf(listar[0].get('Total'));                    
        Integer timeValue = Integer.ValueOf(Label.HourInOLAUker) - iTotal; 
        if(timeValue <= 0) timeValue = 1;
        return timeValue;
    }   
}