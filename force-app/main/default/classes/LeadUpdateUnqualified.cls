/**
 * @description       : Controller class for automation to change lead status to unqualified
 * @author            : Ishardan
 * @createdDate       : 10/10/2025
 * @lastModifiedBy    : Ishardan
 * @lastModifiedDate  : 17/10/2025
 * @groupDescription  : Controller for button in leads for change status.
 */
public with sharing class LeadUpdateUnqualified {

    @TestVisible
    private static Boolean simulateNoAccess = false;

    /**
     * @description  Changes the Lead status to 'Unqualified' after validating field-level access.
     * @param leadId  The ID of the Lead record whose Status should be updated to 'Unqualified'.
     * @param simulateRestricted  A test flag used to simulate permission restriction in test methods.
     * @throws AuraHandledException  If the user does not have permission to update the Status field.
     */
    @AuraEnabled
    public static void markUnqualified(Id leadId, Boolean simulateRestricted) {

        // Simulate no access (for unit testing)
        if (simulateRestricted == true) {
            throw new AuraHandledException('You do not have permission to update the Status field.');
        }

        // Check Field-Level Security (real condition)
        if (!Schema.sObjectType.Lead.fields.Status.isUpdateable()) {
            throw new AuraHandledException('You do not have permission to update the Status field.');
        }

        // Query Lead record securely
        Lead l = [SELECT Id, Status FROM Lead WHERE Id = :leadId WITH SECURITY_ENFORCED LIMIT 1];

        // Update Lead Status
        l.Status = 'Unqualified';
        update l;
    }
}