/**
 * @description caseRelatedAccountInfoController
 */
public without sharing class CaseRelatedAccountInfoController {
    /**
     * @description Method getCaseAssociatedAccount
     * @param recordId of type Id
     * @return Case Object Record
     */
    @AuraEnabled(cacheable=true)
    public static Case getCaseAssociatedAccount(Id recordId) {
        Case caseRecord = [SELECT Id, AccountId, Account.Name, Account.RecordType.Name, Account.SCC_TanggalLahir__c
                           FROM Case 
                           WHERE Id = :recordId AND AccountId != null WITH SECURITY_ENFORCED];
        return caseRecord;
    }
}