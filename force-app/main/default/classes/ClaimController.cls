public with sharing class ClaimController {

    // Wrapper ClaimDetailsWrapper (Tidak berubah)
    public class ClaimDetailsWrapper {
        @AuraEnabled public String policyNo { get; set; }
        @AuraEnabled public Date policyDate { get; set; }
        @AuraEnabled public String classOfBusiness { get; set; }
        @AuraEnabled public String registerNo { get; set; }
        @AuraEnabled public Decimal sumInsured { get; set; }
        @AuraEnabled public String cur { get; set; }
        @AuraEnabled public String busreqId { get; set; }
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Boolean isCasco { get; set; }
        @AuraEnabled public Boolean isLifeInsurance { get; set; }
        @AuraEnabled public Boolean isPaPassenger { get; set; }
        @AuraEnabled public Boolean isTpl { get; set; }
        @AuraEnabled public Boolean isPaDriver { get; set; }
        @AuraEnabled public Boolean isPll { get; set; }
    }

    // --- WRAPPER BARU UNTUK PAGINASI ---
    public class PaginatedAssetWrapper {
        @AuraEnabled public List<Asset> assetList { get; set; }
        @AuraEnabled public Integer totalItemCount { get; set; }
    }

    // Method getClaimDetails (Tidak berubah)
    @AuraEnabled(cacheable=true)
    public static ClaimDetailsWrapper getClaimDetails(Id recordId) {
        
        Claim clm = [
            SELECT 
                PolicyNumber.Name, 
                PolicyNumber.EffectiveToDate, 
                COB__c, 
                Register_No__c, 
                Casco__c, 
                LIFE_INSURANCE__c, 
                PA_Passanger__c, 
                TPL__c, 
                PA_Driver__c, 
                PLL__c,
                Opportunity__c,
                Opportunity__r.Sum_Insured__c,
                Opportunity__r.Cur__c,
                Opportunity__r.Busreq_ID__c
            FROM Claim 
            WHERE Id = :recordId
            LIMIT 1
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
             wrapper.cur = 'IDR';
             wrapper.busreqId = null;
        }

        wrapper.classOfBusiness = clm.COB__c;
        wrapper.registerNo = clm.Register_No__c;
        wrapper.isCasco = clm.Casco__c;
        wrapper.isLifeInsurance = clm.LIFE_INSURANCE__c;
        wrapper.isPaPassenger = clm.PA_Passanger__c;
        wrapper.isTpl = clm.TPL__c;
        wrapper.isPaDriver = clm.PA_Driver__c;
        wrapper.isPll = clm.PLL__c;

        return wrapper;
    }

    
    // --- METHOD DIPERBARUI UNTUK PAGINASI ---
    // Sekarang tidak cacheable karena parameter dinamis di query
    @AuraEnabled
    public static PaginatedAssetWrapper searchRisks(String model, String chasisNo, String engineNo, Integer pageSize, Integer pageNumber) {
        
        PaginatedAssetWrapper wrapper = new PaginatedAssetWrapper();
        String queryBase = 'FROM Asset';
        List<String> whereClauses = new List<String>();

        // Siapkan parameter bind (wajib untuk query dinamis yang aman)
        String modelParam = '%' + model + '%';
        String chasisParam = '%' + chasisNo + '%';
        String engineParam = '%' + engineNo + '%';
        
        if (String.isNotBlank(model)) {
            whereClauses.add('Model__r.Name LIKE :modelParam');
        }
        if (String.isNotBlank(chasisNo)) {
            whereClauses.add('Chasis_No__c LIKE :chasisParam');
        }
        if (String.isNotBlank(engineNo)) {
            whereClauses.add('Engine_No__c LIKE :engineParam');
        }
        
        String whereClause = '';
        if (!whereClauses.isEmpty()) {
            whereClause = ' WHERE ' + String.join(whereClauses, ' AND ');
        }
        
        try {
            // 1. Query untuk menghitung total
            String countQuery = 'SELECT COUNT() ' + queryBase + whereClause;
            wrapper.totalItemCount = Database.countQuery(countQuery);
            
            Integer offset = (pageNumber - 1) * pageSize;
            
            // 2. Query untuk mengambil data halaman ini
            String dataQuery = 'SELECT Id, Model__r.Name, Chasis_No__c, Engine_No__c, Register_No__c ' +
                               queryBase + whereClause +
                               ' ORDER BY CreatedDate DESC ' + // ORDER BY wajib untuk OFFSET
                               ' LIMIT :pageSize OFFSET :offset';
            
            wrapper.assetList = Database.query(dataQuery);
            return wrapper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Method 'getCoveragesForAsset' (Tidak berubah)
    @AuraEnabled(cacheable=true)
    public static List<InsurancePolicyCoverage> getCoveragesForAsset(Id assetId) {
        String lookupFieldToAsset = 'Risk_ID__c'; 
        String query = 'SELECT Id, CoverageName, Deductible_PCT__c, Deductible_Type__c, ' +
                       'Deductible_Currency__r.Name, Minimum_Amount__c ' +
                       'FROM InsurancePolicyCoverage ' +
                       'WHERE ' + lookupFieldToAsset + ' = :assetId';
        try {
            return (List<InsurancePolicyCoverage>)Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // --- METHOD DIPERBARUI UNTUK PAGINASI ---
    @AuraEnabled(cacheable=true)
    public static PaginatedAssetWrapper getAssetsForOpportunity(Id opportunityId, Integer pageSize, Integer pageNumber) {
        
        PaginatedAssetWrapper wrapper = new PaginatedAssetWrapper();
        if (opportunityId == null) {
            wrapper.assetList = new List<Asset>();
            wrapper.totalItemCount = 0;
            return wrapper;
        }
        
        try {
            String whereClause = 'WHERE Opportunity__c = :opportunityId';
            
            // 1. Query untuk menghitung total
            String countQuery = 'SELECT COUNT() FROM Asset ' + whereClause;
            wrapper.totalItemCount = Database.countQuery(countQuery);
            
            Integer offset = (pageNumber - 1) * pageSize;
            
            // 2. Query untuk mengambil data halaman ini
            String dataQuery = 'SELECT Id, Model__r.Name, Chasis_No__c, Engine_No__c, Register_No__c ' +
                               'FROM Asset ' + whereClause +
                               ' ORDER BY CreatedDate DESC ' + // ORDER BY wajib untuk OFFSET
                               ' LIMIT :pageSize OFFSET :offset';
            
            wrapper.assetList = Database.query(dataQuery);
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}