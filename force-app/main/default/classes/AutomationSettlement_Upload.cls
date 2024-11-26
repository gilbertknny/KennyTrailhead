public with sharing class AutomationSettlement_Upload {
    @AuraEnabled
    public static void updateCaseAfterUpload(String recordId) {
        try {
            // Query the case based on the provided record ID
            Case caseRecord = [SELECT Id, Attachment_Settlement__c FROM Case WHERE Id = :recordId LIMIT 1];

            if (caseRecord.Attachment_Settlement__c == false) {
               // Set the flag field to true
                caseRecord.Attachment_Settlement__c = true;
            }
            
            // Update the case record
            update caseRecord;
        } catch (Exception e) {
            // Handle the exception if there's an issue
            throw new AuraHandledException('Error updating case: ' + e.getMessage());
        }
    }
}