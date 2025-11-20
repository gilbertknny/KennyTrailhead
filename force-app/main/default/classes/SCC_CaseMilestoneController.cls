/**
 * @description SCC_CaseMilestoneController Class for custom SLA & OLA tracker
 */
public without sharing class SCC_CaseMilestoneController {
    /**
     * @description getCaseMilestones
     * @param caseId
     * @return List<CaseMilestone>
     */
    @AuraEnabled(cacheable=true)
    public static List<CaseMilestone> getCaseMilestones(Id caseId) {
        return [
            SELECT 
            CaseId, 
            StartDate, 
            TargetDate, 
            MilestoneType.Name, 
            TargetResponseInMins, 
            CompletionDate , 
            IsViolated, 
            IsCompleted, 
            TimeSinceTargetInMins,
            TimeRemainingInMins
            FROM CaseMilestone 
            WHERE CaseId = :caseId
            LIMIT 50000
        ];
    }
}