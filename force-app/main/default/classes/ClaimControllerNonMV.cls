public with sharing class ClaimControllerNonMV {

    // Wrapper 1: Untuk data awal Claim (Non-MV)
    public class ClaimDetailsWrapper {
        @AuraEnabled public String policyNo { get; set; }
        @AuraEnabled public Date policyDate { get; set; }
        @AuraEnabled public String classOfBusiness { get; set; }
        @AuraEnabled public Decimal sumInsured { get; set; }
        @AuraEnabled public String cur { get; set; }
        @AuraEnabled public String busreqId { get; set; }
        @AuraEnabled public Id opportunityId { get; set; }
        // Placeholder
        @AuraEnabled public Decimal valueAtRisk { get; set; }
        @AuraEnabled public Decimal lossEstimation { get; set; }
    }

    // Wrapper 2: Untuk paginasi Asset/Risk (Non-MV)
    public class PaginatedAssetWrapper {
        @AuraEnabled public List<Asset> assetList { get; set; }
        @AuraEnabled public Integer totalItemCount { get; set; }
    }

    // Wrapper 3: Untuk data Coverage + Total Deductible (Non-MV)
    public class CoverageWrapper {
        @AuraEnabled public List<InsurancePolicyCoverage> coverages { get; set; }
        @AuraEnabled public Decimal totalDeductible { get; set; }
    }

    // Method getClaimDetails (Non-MV)
    @AuraEnabled(cacheable=true)
    public static ClaimDetailsWrapper getClaimDetails(Id recordId) {
        Claim clm = [
            SELECT
                PolicyNumber.Name, PolicyNumber.EffectiveToDate, COB__c,
                Opportunity__c, Opportunity__r.Sum_Insured__c, Opportunity__r.Cur__c, Opportunity__r.Busreq_ID__c
                // , Value_At_Risk_Field__c, Loss_Estimation_Field__c // <-- Tambahkan field Anda di sini jika sudah ada
            FROM Claim WHERE Id = :recordId LIMIT 1
        ];

        ClaimDetailsWrapper wrapper = new ClaimDetailsWrapper();
        if (clm.PolicyNumber != null) {
            wrapper.policyNo = clm.PolicyNumber.Name;
            if(clm.PolicyNumber.EffectiveToDate != null) {
                wrapper.policyDate = clm.PolicyNumber.EffectiveToDate;
            }
        }
        wrapper.opportunityId = clm.Opportunity__c;
        if (clm.Opportunity__r != null) {
            wrapper.sumInsured = clm.Opportunity__r.Sum_Insured__c;
            wrapper.cur = clm.Opportunity__r.Cur__c;
            wrapper.busreqId = clm.Opportunity__r.Busreq_ID__c;
        } else {
             wrapper.sumInsured = 0;
             wrapper.cur = 'IDR'; // Default currency
             wrapper.busreqId = null;
        }
        wrapper.classOfBusiness = clm.COB__c;

        // Placeholder - uncomment and map when fields exist
        // wrapper.valueAtRisk = clm.Value_At_Risk_Field__c;
        // wrapper.lossEstimation = clm.Loss_Estimation_Field__c; // or clm.EstimatedAmount
        wrapper.valueAtRisk = null;
        wrapper.lossEstimation = null;

        return wrapper;
    }

    // Method searchRisksNonMV (Non-MV)
    @AuraEnabled
    public static PaginatedAssetWrapper searchRisksNonMV(String riskName, String riskDetail, Integer pageSize, Integer pageNumber) {
        PaginatedAssetWrapper wrapper = new PaginatedAssetWrapper();
        String queryBase = 'FROM Asset';
        List<String> whereClauses = new List<String>();
        String nameParam = '%' + riskName + '%';
        String detailParam = '%' + riskDetail + '%';

        if (String.isNotBlank(riskName)) whereClauses.add('Name LIKE :nameParam');
        // Assuming Risk Detail maps to Address_Description__c based on earlier mapping
        if (String.isNotBlank(riskDetail)) whereClauses.add('Address_Description__c LIKE :detailParam');

        String whereClause = '';
        if (!whereClauses.isEmpty()) {
            whereClause = ' WHERE ' + String.join(whereClauses, ' AND ');
        }

        try {
            String countQuery = 'SELECT COUNT() ' + queryBase + whereClause;
            wrapper.totalItemCount = Database.countQuery(countQuery);
            Integer offset = (pageNumber - 1) * pageSize;

            // Query fields relevant for Non-MV display
            String dataQuery = 'SELECT Id, Name, Address_Description__c ' +
                               queryBase + whereClause +
                               ' ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset';

            wrapper.assetList = Database.query(dataQuery);
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Error searching risks: ' + e.getMessage());
        }
    }

    // Method getCoveragesForAsset (Non-MV)
    @AuraEnabled(cacheable=true)
    public static CoverageWrapper getCoveragesForAsset(Id assetId) {
         CoverageWrapper wrapper = new CoverageWrapper();
         String lookupFieldToAsset = 'Risk_ID__c'; // Lookup from InsurancePolicyCoverage to Asset

         try {
             wrapper.coverages = [
                 SELECT Id, CoverageName, Deductible_PCT__c, Deductible_Type__c,
                        Deductible_Currency__r.Name, Minimum_Amount__c,
                        DeductibleAmount // Field to SUM
                 FROM InsurancePolicyCoverage
                 WHERE Risk_ID__c = :assetId
             ];

             // Calculate total deductible
             Decimal total = 0;
             for (InsurancePolicyCoverage cov : wrapper.coverages) {
                 if (cov.DeductibleAmount != null) {
                     total += cov.DeductibleAmount;
                 }
             }
             wrapper.totalDeductible = total;
             return wrapper;
         } catch (Exception e) {
             throw new AuraHandledException('Error fetching coverages: ' + e.getMessage());
         }
    }

    // Method getAssetsForOpportunity (Non-MV)
    @AuraEnabled(cacheable=true)
    public static PaginatedAssetWrapper getAssetsForOpportunity(Id opportunityId, Integer pageSize, Integer pageNumber) {
        PaginatedAssetWrapper wrapper = new PaginatedAssetWrapper();
        if (opportunityId == null) {
            wrapper.assetList = new List<Asset>();
            wrapper.totalItemCount = 0;
            return wrapper;
        }
        try {
            String whereClause = 'WHERE Opportunity__c = :opportunityId'; // Lookup from Asset to Opportunity
            String countQuery = 'SELECT COUNT() FROM Asset ' + whereClause;
            wrapper.totalItemCount = Database.countQuery(countQuery);
            Integer offset = (pageNumber - 1) * pageSize;

            // Query fields relevant for Non-MV display
            String dataQuery = 'SELECT Id, Name, Address_Description__c ' +
                               'FROM Asset ' + whereClause +
                               ' ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset';

            wrapper.assetList = Database.query(dataQuery);
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching assets for opportunity: ' + e.getMessage());
        }
    }
}