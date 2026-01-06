public with sharing class Aswata_ApproveOffering_Controller {

    /* =====================================================
       GET SHARES (READ ONLY)
    ===================================================== */
    @AuraEnabled(cacheable=false)
    public static List<Facultative_Share__c> getShares(String quoteId) {
        if (String.isBlank(quoteId)) {
            return new List<Facultative_Share__c>();
        }

        Quote q = [
            SELECT Id, OpportunityId
            FROM Quote
            WHERE Id = :quoteId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return [
            SELECT Id,
                   Name,
                   Origin_Risk__r.Name,
                   Co_Insurer_Name__r.Name,
                   Share_Offered__c,
                   Share_Accepted_Approved__c,
                   Rate__c,
                   Commission__c,
                   Subjectivity_Clauses__c
            FROM Facultative_Share__c
            WHERE Facultative_Opportunity__c = :q.OpportunityId
            WITH SECURITY_ENFORCED
        ];
    }

    /* =====================================================
       APPROVE OFFERING (SAVE DRAFT + APPROVE)
    ===================================================== */
    @AuraEnabled
    public static void approveOffering(
        String quoteId,
        List<Map<String,Object>> draftShares
    ) {
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Quote Id is required');
        }
        System.debug('Quote ID: ' + quoteId +' , draftShares: '+ draftShares);

        /* ---------- Update Facultative Shares ---------- */
        List<Facultative_Share__c> sharesToUpdate = new List<Facultative_Share__c>();

        if (draftShares != null && !draftShares.isEmpty()) {
            for (Map<String,Object> d : draftShares) {
                sharesToUpdate.add(new Facultative_Share__c(
                     Id = (Id)d.get('Id'),
                    Share_Accepted_Approved__c = d.containsKey('Share_Accepted_Approved__c') ? (Decimal)d.get('Share_Accepted_Approved__c') : null,
                    Rate__c = d.containsKey('Rate__c') ? (Decimal)d.get('Rate__c') : null,
                    Commission__c = d.containsKey('Commission__c') ? (Decimal)d.get('Commission__c') : null,
                    Subjectivity_Clauses__c = (String)d.get('Subjectivity_Clauses__c')
                ));
            }

            // 🔐 Enforce FLS
            sharesToUpdate =
                (List<Facultative_Share__c>) Security.stripInaccessible(
                    AccessType.UPDATABLE,
                    sharesToUpdate
                ).getRecords();

            if (!sharesToUpdate.isEmpty()) {
                update sharesToUpdate;
            }
        }

        /* ---------- Update Quote + Opportunity ---------- */
        Quote q = [
            SELECT Id, OpportunityId, Status
            FROM Quote
            WHERE Id = :quoteId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Opportunity opp = new Opportunity(
            Id = q.OpportunityId,
            Offering_status__c = 'Accepted'
        );

        q.Status = 'Approved';

        List<SObject> recordsToUpdate = new List<SObject>{ opp, q };

        // 🔐 Enforce FLS
        recordsToUpdate =
            (List<SObject>) Security.stripInaccessible(
                AccessType.UPDATABLE,
                recordsToUpdate
            ).getRecords();

        update recordsToUpdate;
    }
}