/**
 * @description       : Global Function
 * @author            : Fikri Hailal
 * @last modified on  : 11-26-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_GlobalFunction {
    /**
     * @description create Insurance Policy
     * @param oppId = opportunity Id
     * @return String Id Insurance Policy
     */
    public static String createInsurancePolicy(String oppId) {
        /*if (!Schema.sObjectType.InsurancePolicy.isCreateable()) {
            throw new System.NoAccessException();
        }*/
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
        System.debug(
            'SourceOpportunityId readable = ' +
            Schema.sObjectType.InsurancePolicy
                .fields.SourceOpportunityId
                .isAccessible()
        );
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

    private static Map<String, String> matrixCache = new Map<String, String>();

    public static String matrixUserFacultativeCached(
        String branchId,
        String cobId,
        Decimal amount
    ) {
        if (branchId == null || cobId == null || amount == null) return null;

        String key = branchId + '-' + cobId + '-' + amount;
        if (matrixCache.containsKey(key)) {
            return matrixCache.get(key);
        }

        List<Master_Data__c> mdList = [
            SELECT USER_ID__c, LIMIT_AMOUNT__c
            FROM Master_Data__c
            WHERE Branch__r.BRANCH_ID__c = :branchId
            AND BSN_ID__c = :cobId
            AND LIMIT_AMOUNT__c >= :amount
            AND RecordType.DeveloperName = 'Limit_Reas'
            ORDER BY LIMIT_AMOUNT__c ASC
            LIMIT 1
        ];

        String userId = mdList.isEmpty() ? null : mdList[0].USER_ID__c;
        matrixCache.put(key, userId);

        return userId;
    }

    /* ================= OPPORTUNITY TEAM (BULK) ================= */

    public static void addUsersToOpportunityTeamBulk(
        Map<Id, Set<Id>> oppToUserIds,
        String teamRole,
        String accessType
    ) {
        if (oppToUserIds == null || oppToUserIds.isEmpty()) return;

        String accessLevel = accessType == 'Edit' ? 'Edit' : 'Read';

        // Existing members
        Map<String, OpportunityTeamMember> existingMap = new Map<String, OpportunityTeamMember>();

        for (OpportunityTeamMember otm : [
            SELECT OpportunityId, UserId
            FROM OpportunityTeamMember
            WHERE OpportunityId IN :oppToUserIds.keySet()
        ]) {
            existingMap.put(otm.OpportunityId + '-' + otm.UserId, otm);
        }

        List<OpportunityTeamMember> toInsert = new List<OpportunityTeamMember>();

        for (Id oppId : oppToUserIds.keySet()) {
            for (Id userId : oppToUserIds.get(oppId)) {

                String key = oppId + '-' + userId;
                if (existingMap.containsKey(key)) continue;

                toInsert.add(new OpportunityTeamMember(
                    OpportunityId = oppId,
                    UserId = userId,
                    TeamMemberRole = teamRole,
                    OpportunityAccessLevel = accessLevel
                ));
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
}