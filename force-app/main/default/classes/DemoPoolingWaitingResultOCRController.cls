public with sharing class DemoPoolingWaitingResultOCRController {
    @AuraEnabled
    public static String getOCRStatus(Id caseId) {
        Case c = [SELECT Demo_Status_Match__c FROM Case Where Id =: caseId LIMIT 1];

        return c.Demo_Status_Match__c;
    }
}