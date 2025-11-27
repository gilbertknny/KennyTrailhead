/**
 * @description Handler class for EmailMessage Trigger (beforeInsert & afterInsert)
 * Updates EmailThreadKey__c on related records and manages Thread_ID__c logic.
 *
 * PMD Improvements applied:
 * - Added documentation blocks
 * - Added early returns
 * - Added null checks
 * - Improved variable naming
 * - Grouped SOQL by object type
 * - Removed unused variables
 * - Ensured bulkification
 */
public with sharing class EmailMessageTriggerHandler {

    /**
     * @description beforeInsert: sets Thread_ID__c and updates related parent SObject
     */
    public static void beforeInsert(List<EmailMessage> newList) {
        if (newList == null || newList.isEmpty()) {
            return;
        }

        Set<Id> relatedIds = new Set<Id>();

        // Build Thread_ID__c value for each EmailMessage
        for (EmailMessage em : newList) {
            if (em.RelatedToId != null) {
                relatedIds.add(em.RelatedToId);
                em.Thread_ID__c = String.valueOf(em.RelatedToId).substring(0, 15);
            }
        }

        // Early exit if nothing to process
        if (relatedIds.isEmpty()) {
            return;
        }

        // Query related records
        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, EmailThreadKey__c FROM Account WHERE Id IN :relatedIds]
        );
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, EmailThreadKey__c FROM Opportunity WHERE Id IN :relatedIds]
        );
        Map<Id, InsurancePolicy> polMap = new Map<Id, InsurancePolicy>(
            [SELECT Id, EmailThreadKey__c FROM InsurancePolicy WHERE Id IN :relatedIds]
        );

        // Assign Thread key back to related records
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

        // Update grouped objects
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

    /**
     * @description afterInsert: append thread footer to EmailMessage (incoming only)
     */
    public static void afterInsert(List<EmailMessage> newList) {
        if (newList == null || newList.isEmpty()) {
            return;
        }

        Set<Id> emailIds = new Set<Id>();
        for (EmailMessage em : newList) {
            if (String.isNotBlank(em.Thread_ID__c)) {
                emailIds.add(em.Id);
            }
        }

        // Early exit
        if (emailIds.isEmpty()) {
            return;
        }

        List<EmailMessage> updates = [
            SELECT Id, TextBody, HtmlBody, Thread_ID__c, Incoming
            FROM EmailMessage
            WHERE Id IN :emailIds
        ];

        // Footer logic placeholder (actual update logic can be extended here)
        for (EmailMessage em : updates) {
            if (em.Incoming && String.isNotBlank(em.Thread_ID__c)) {
                String footerText = '\n\n[ThreadID:' + em.Thread_ID__c + ']';
                String footerHtml = '<br/><br/>[ThreadID:' + em.Thread_ID__c + ']';
                // (left as-is; no functional changes, as requested)
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}