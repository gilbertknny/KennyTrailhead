public with sharing class EmailMessageTriggerHandler {

    public static void beforeInsert(List<EmailMessage> newList) {
        Set<Id> relatedIds = new Set<Id>();

        for (EmailMessage em : newList) {
            if (em.RelatedToId != null) {

                relatedIds.add(em.RelatedToId);
                em.Thread_ID__c = String.valueOf(em.RelatedToId).substring(0, 15);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, EmailThreadKey__c FROM Account WHERE Id IN :relatedIds]
        );
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, EmailThreadKey__c FROM Opportunity WHERE Id IN :relatedIds]
        );
        Map<Id, InsurancePolicy> polMap = new Map<Id, InsurancePolicy>(
            [SELECT Id, EmailThreadKey__c FROM InsurancePolicy WHERE Id IN :relatedIds]
        );

        for (EmailMessage em : newList) {
            if (String.isNotBlank(em.Thread_ID__c)) {
                if (accMap.containsKey(em.RelatedToId)) {
                
                    accMap.get(em.RelatedToId).EmailThreadKey__c = em.Thread_ID__c;
                } else if (oppMap.containsKey(em.RelatedToId)) {
                    oppMap.get(em.RelatedToId).EmailThreadKey__c = em.Thread_ID__c;
                } else if (polMap.containsKey(em.RelatedToId)) {
                    polMap.get(em.RelatedToId).EmailThreadKey__c = em.Thread_ID__c;
                }
            }
        }

        if (!accMap.isEmpty()) {
            update accMap.values();
        }
        if (!oppMap.isEmpty()) {
            update oppMap.values();
        }
        if (!polMap.isEmpty()) {
            update polMap.values();
        }
    }

    public static void afterInsert(List<EmailMessage> newList) {
        Set<Id> emailIds = new Set<Id>();

        for (EmailMessage em : newList) {
            if (String.isNotBlank(em.Thread_ID__c)) {
                emailIds.add(em.Id);
            }
        }

        if (emailIds.isEmpty()) {
            return;
        }

        List<EmailMessage> updates = [
            SELECT Id, TextBody, HtmlBody, Thread_ID__c, Incoming
            FROM EmailMessage
            WHERE Id IN :emailIds
        ];

        for (EmailMessage em : updates) {
            if (em.Incoming && String.isNotBlank(em.Thread_ID__c)) {
                String footerText = '\n\n[ThreadID:' + em.Thread_ID__c + ']';
                String footerHtml = '<br/><br/>[ThreadID:' + em.Thread_ID__c + ']';
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}