public with sharing class accumulationController {

    @AuraEnabled(cacheable=true)
    public static String getUserBranchName() {
        User u = [
            SELECT toLabel(Branch__c)
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return (u.Branch__c != null) ? u.Branch__c : null;
    }

    public class AssetSearchResult {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String requestNum { get; set; }
        @AuraEnabled public String policyNum { get; set; }
        @AuraEnabled public String address { get; set; }
        @AuraEnabled public String zipCode { get; set; }
        @AuraEnabled public String riskId { get; set; }
        @AuraEnabled public Decimal sumInsured { get; set; }
        @AuraEnabled public String nkr { get; set; }
        @AuraEnabled public String cur { get; set; } 
        @AuraEnabled public String opportunityId { get; set; } 

        public AssetSearchResult(Asset a) {
            this.id = a.Id;
            this.requestNum = (a.Opportunity__r != null) ? a.Opportunity__r.Busreq_ID__c : null;
            this.policyNum = a.Insurance_Policy__r.Name;
            this.riskId = a.Risk_ID__c;            
            this.sumInsured = a.Amount_IDR__c;
            this.address = a.Address_Description__c;
            this.zipCode = (a.Zip_Code__r != null) ? a.Zip_Code__r.Name : '';
            this.nkr = (a.N_K_R__r != null) ? a.N_K_R__r.Name : '';
            this.cur = (a.Currency__r != null) ? a.Currency__r.Name : 'IDR'; 
            this.opportunityId = a.Opportunity__c; 
        }
    }

    public class InitialData {
        @AuraEnabled public String businessRequestId { get; set; }
        @AuraEnabled public AssetSearchResult assetRow { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static InitialData getInitialAssetData(String assetId) {
        if (String.isBlank(assetId)) {
            return null;
        }

        Asset a = [
            SELECT Id, Risk_ID__c, Insurance_Policy__r.Name, 
                   Address_Description__c, Amount_IDR__c, Zip_Code__r.Name,
                   Opportunity__c, 
                   Opportunity__r.Busreq_ID__c, 
                   Zip_Code__r.Branch_Name__r.BRANCH_ID__c,
                   N_K_R__r.Name, Currency__r.Name 
            FROM Asset
            WHERE Id = :assetId
            LIMIT 1
        ];

        if (a != null) {
            InitialData data = new InitialData();
            data.businessRequestId = (a.Opportunity__r != null) ? a.Opportunity__r.Busreq_ID__c : null;
            data.assetRow = new AssetSearchResult(a);
            return data;
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<AssetSearchResult> searchAssets(String addressQuery, String policyQuery, String zipCodeQuery, String nkrQuery) {
        List<AssetSearchResult> results = new List<AssetSearchResult>();
        
        String soql = 'SELECT Id, Risk_ID__c, ' +
                        'Insurance_Policy__r.Name, Address_Description__c, Amount_IDR__c, ' +
                        'Zip_Code__r.Name, Zip_Code__r.Branch_Name__r.BRANCH_ID__c, ' +
                        'Opportunity__c, ' + 
                        'Opportunity__r.Busreq_ID__c, ' +
                        'N_K_R__r.Name, Currency__r.Name ' +
                        'FROM Asset';

        List<String> whereClauses = new List<String>();
        
        if (String.isNotBlank(addressQuery)) { 
            String likeAddress = '%' + String.escapeSingleQuotes(addressQuery) + '%';
            whereClauses.add('Address_Description__c LIKE :likeAddress'); 
        }
        
        if (String.isNotBlank(policyQuery)) {
            String likePolicy = '%' + String.escapeSingleQuotes(policyQuery) + '%';
            whereClauses.add('Insurance_Policy__r.Name LIKE :likePolicy');
        }

        if (String.isNotBlank(zipCodeQuery)) {
            String likeZip = '%' + String.escapeSingleQuotes(zipCodeQuery) + '%';
            whereClauses.add('Zip_Code__r.Name LIKE :likeZip');
        }

        if (String.isNotBlank(nkrQuery)) {
            String likeNKR = '%' + String.escapeSingleQuotes(nkrQuery) + '%';
            whereClauses.add('N_K_R__r.Name LIKE :likeNKR');
        }

        if (!whereClauses.isEmpty()) {
            soql += ' WHERE ' + String.join(whereClauses, ' AND ');
        } else {
            return results;
        }

        soql += ' LIMIT 50'; 

        try {
            for (Asset a : Database.query(soql)) {
                results.add(new AssetSearchResult(a));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return results;
    }

    public class AccumulationInput {
        @AuraEnabled public String businessRequestId { get; set; }
        @AuraEnabled public String address { get; set; }
        @AuraEnabled public String zipCode { get; set; }
        @AuraEnabled public Decimal totalTSI { get; set; } 
        @AuraEnabled public String versionStr { get; set; }
        @AuraEnabled public String oppId { get; set; } 
        @AuraEnabled public String policyNum { get; set; } 
    }

    @AuraEnabled
    public static String createAccumulationRecord(AccumulationInput data) { 
        try {
            Accumulation__c newAcc = new Accumulation__c();
            
            newAcc.Request_Number__c = data.businessRequestId; 
            newAcc.Address__c = data.address;
            newAcc.Zip_Code__c = data.zipCode;
            newAcc.Version__c = data.versionStr;
            newAcc.Policy_Number__c = data.policyNum; 
            // newAcc.Total_TSI__c = data.totalTSI; 
            
            insert newAcc;
            
            
            if (String.isNotBlank(data.oppId)) {
                try {
                    Map<String, Object> flowParams = new Map<String, Object>();
                    flowParams.put('recordId', data.oppId); 

                    Flow.Interview myFlow = Flow.Interview.createInterview(
                        'Quote_Autolaunched_Survey_Underwriting', 
                        flowParams
                    );
                    myFlow.start();
                    
                } catch (Exception e_flow) {
                    throw new AuraHandledException('Flow "Quote_Autolaunched_Survey_Underwriting" gagal: ' + e_flow.getMessage());
                }
            }
            
            return newAcc.Name; 

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}