public with sharing class TaskApproval {
    public static String test(){
        return 'test';
    }
    /*
    @AuraEnabled(cacheable=true)
    public static List<ProcessInstanceWorkitem> getTaskApprovalTmp() {
        return [
            SELECT Id, CreatedById, OriginalActorId, OriginalActor.Name, ActorId, ProcessInstanceId
            FROM ProcessInstanceWorkitem
            WHERE IsDeleted = false
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<ProcessInstanceWorkitem> getTaskApproval() {
        return [
            SELECT Id, CreatedBy.Name, OriginalActor.Name, Actor.Name,
                    ProcessInstance.Status, 
                    ProcessInstance.TargetObject.Name 
            FROM ProcessInstanceWorkitem
            WHERE IsDeleted = false
            ORDER BY CreatedDate DESC
        ];
    }

    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [
            SELECT Id, Name, Industry, NPWP_Number__c
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Name
            LIMIT 10
        ];
    }

    public static void test(){
        for (ProcessInstanceWorkitem t : getTaskApproval()) {
           	System.debug('t = ' + t.CreatedBy.Name + '|' + t.OriginalActor.Name + '|' + t.Actor.Name );
        }
    }
    */
}