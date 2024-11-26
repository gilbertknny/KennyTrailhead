public without sharing class SCC_BatchApprove implements Database.Batchable<sObject> {
    public List<Id>CaseId;
    public SCC_BatchApprove(List <Id>CaseId) {
        this.CaseId = CaseId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, CaseNumber, SCC_Call_Type__r.Name, SCC_Call_Type_Feature__c, SCC_Card_Number__c, CreatedDate, SCC_Amount__c, Approval_Status__c, Count_Nota__c, SCC_Call_Type_Feature__r.Name From Case Where id IN:this.CaseId]);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Id> caseIds = new List<Id>();
        for (Case c : scope) {
            caseIds.add(c.Id);
        }
        
        Id userId = UserInfo.getUserId();
        SCC_ApexApproval_Signer.approveTickets(caseIds, userId);
    }

    public void finish(Database.BatchableContext bc) {
    }
}