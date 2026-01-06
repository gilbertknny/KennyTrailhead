public with sharing class Aswata_AddFacultative_Controller {
    
    @AuraEnabled(cacheable=false)
    public static List<Asset> getRiskList() {
        return [
            SELECT Id,
                Name,
                Amount_Insured__c,
                Risk_ID__c,
                Opportunity__c,
                Opportunity__r.Name,
                Opportunity__r.Busreq_ID__c 
                FROM Asset WHERE RecordType.Name = 'Risk' 
                AND Has_Facultative__c = true 
                AND Facultative_Owner__c =: UserInfo.getUserId() 
                AND Opportunity__r.Busreq_ID__c != null
                AND Facultative_Folder__c = null WITH SECURITY_ENFORCED  
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getRiskByFolder(Id recordId) {
        return [
            SELECT Id,
                   Name,
                   Amount_Insured__c,
                   Risk_ID__c,
                   Opportunity__c,
                   Opportunity__r.Name,
                   Opportunity__r.Busreq_ID__c
            FROM Asset
            WHERE RecordType.Name = 'Risk'
              AND Has_Facultative__c = true
              //AND Opportunity__r.Opportunity_Type__c != 'Facultative Outward'
              AND Facultative_Folder__c = :recordId
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled
    public static void updateSelectedRisks(List<Id> assetIds, Id folderId) {
        
        System.debug(assetIds.size() + ' - ' + folderId);
        if (assetIds == null || assetIds.isEmpty()) return;

        List<Asset> assetsToUpdate = [
            SELECT Id, Facultative_Folder__c
            FROM Asset
            WHERE Id IN :assetIds
            WITH SECURITY_ENFORCED
        ];

        for (Asset a : assetsToUpdate) {
            a.Facultative_Folder__c = folderId;
        }

        update assetsToUpdate;
    }

    @AuraEnabled(cacheable=false)
    public static List<Account> searchAccounts(String searchKey) {
        if (String.isBlank(searchKey)) {
            return new List<Account>();
        }
        return [
            SELECT Id, Name, Insurance_ID__c
            FROM Account
            WHERE Name LIKE :('%' + searchKey + '%') and Type = 'REINSURANCE'
            With SECURITY_ENFORCED 
            ORDER BY Name
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static void updateFacultativeStatus(Id recordId, String newStatus) {
        if (String.isBlank(recordId) || String.isBlank(newStatus)) {
            throw new AuraHandledException('Missing parameters.');
        }

        Opportunity so = [SELECT Id, Offering_status__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        so.Offering_status__c = newStatus;
        update so;
    }


    @AuraEnabled(cacheable=true)
    public static Boolean validateCoverage(List<String> riskIds) {

        if (riskIds == null || riskIds.isEmpty()) {
            return false;
        }

        /* =========================
        1. Get Risk → Opportunity
        ========================= */
        Map<Id, Id> riskToOppMap = new Map<Id, Id>();

        for (Asset a : [
            SELECT Id, Opportunity__c
            FROM Asset
            WHERE Id IN :riskIds
            WITH SECURITY_ENFORCED
        ]) {
            if (a.Opportunity__c == null) {
                return false; // Risk without Opportunity → invalid
            }
            riskToOppMap.put(a.Id, a.Opportunity__c);
        }

        /* =========================
        2. Fetch Opportunities
        ========================= */
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Start_Date_Periode__c, End_Date_Periode__c
            FROM Opportunity
            WHERE Id IN :riskToOppMap.values()
            WITH SECURITY_ENFORCED
        ]);
        
        Set<Id> oppIds = new Set<Id>(riskToOppMap.values());

        if (oppMap.size() != oppIds.size()) {
            return false;
        }

        /* =========================
        3. Validate Opportunity Dates
        ========================= */
        Date refStartDate;
        Date refEndDate;

        for (Id oppId : oppMap.keySet()) {
            Opportunity opp = oppMap.get(oppId);

            if (refStartDate == null && refEndDate == null) {
                refStartDate = opp.Start_Date_Periode__c;
                refEndDate   = opp.End_Date_Periode__c;
            } else {
                if (opp.Start_Date_Periode__c != refStartDate ||
                    opp.End_Date_Periode__c   != refEndDate) {
                    return false;
                }
            }
        }

        /* =========================
        4. Validate Coverages
        ========================= */
        List<InsurancePolicyCoverage> coverages = [
            SELECT Risk_ID__c, Coverage_Id__c
            FROM InsurancePolicyCoverage
            WHERE Risk_ID__c IN :riskIds WITH SECURITY_ENFORCED
        ];

        if (coverages.isEmpty()) {
            return false;
        }

        // Map Risk → Set of Coverage Ids
        Map<String, Set<String>> riskToCoverageMap = new Map<String, Set<String>>();

        for (InsurancePolicyCoverage c : coverages) {
            if (!riskToCoverageMap.containsKey(c.Risk_ID__c)) {
                riskToCoverageMap.put(c.Risk_ID__c, new Set<String>());
            }
            riskToCoverageMap.get(c.Risk_ID__c).add(c.Coverage_Id__c);
        }

        // If any selected risk has NO coverage → invalid
        if (riskToCoverageMap.size() != riskIds.size()) {
            return false;
        }

        // Reference coverage set (first risk)
        Set<String> referenceSet;
        for (String riskId : riskToCoverageMap.keySet()) {
            referenceSet = riskToCoverageMap.get(riskId);
            break;
        }

        // Compare all risks against reference
        for (Set<String> coverageSet : riskToCoverageMap.values()) {
            if (coverageSet.size() != referenceSet.size()) {
                return false;
            }
            if (!coverageSet.equals(referenceSet)) {
                return false;
            }
        }

        return true;
    }
    

}