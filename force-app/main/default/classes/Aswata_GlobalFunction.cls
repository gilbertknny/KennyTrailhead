/**
 * @description       : Global Function
 * @author            : Fikri Hailal
 * @last modified on  : 11-26-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_GlobalFunction {
    /**
     * @description create Insurance Policy
     * @param oppId = opportunity Id
     * @return String Id Insurance Policy
     */
    public static String createInsurancePolicy(String oppId) {
        if (!Schema.sObjectType.InsurancePolicy.isCreateable()) {
            throw new System.NoAccessException();
        }
        if (String.isBlank(oppId)) {
            return null;
        }

        // Get Opportunity
        Opportunity oppObj = [
            SELECT Id, Name, AccountId
            FROM Opportunity
            WHERE Id = :oppId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        // === NEW LOGIC: Check existing InsurancePolicy for this Opportunity ===
        List<InsurancePolicy> existingPolicy = [
            SELECT Id
            FROM InsurancePolicy
            WHERE SourceOpportunityId = :oppId with security_enforced
            LIMIT 1
        ];

        // If exists, return existing Id — no insert
        if (!existingPolicy.isEmpty()) {
            return existingPolicy[0].Id;
        }

        // === Create NEW Insurance Policy ===
        InsurancePolicy insPolicy = new InsurancePolicy();
        insPolicy.Name = 'Insurance Policy - ' + oppObj.Name;
        insPolicy.SourceOpportunityId = oppObj.Id;
        insPolicy.NameInsuredId = oppObj.AccountId;
        insert insPolicy;
        return insPolicy.Id;
    }
}