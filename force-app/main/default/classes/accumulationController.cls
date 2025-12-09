/**
 * @description       : Controller for Accumulation Logic handling Assets, Risks, and Integration Procedures.
 * Used by LWC to search assets, manage accumulation groups, and call Vlocity IPs.
 * @author            : Peppp
 * @group             : Controller
 * @last modified on  : 05-12-2025
 * @last modified by  : Peppp
 **/
public with sharing class AccumulationController {
    
    // Constants
    private static final String DEFAULT_CURRENCY = 'IDR';
    private static final Decimal DEFAULT_EXCHANGE_RATE = 1.0;
    private static final Integer SEARCH_LIMIT = 50;
    private static final String IP_NAME = 'SFAWT27_SendAccumulation';
    private static final String RECORD_TYPE_RISK = 'Risk';
    private static final String STATUS_SUCCESS = '00';
    private static final Integer FISCAL_MONTH_CUTOFF = 7;

    // ==========================================
    // WRAPPER CLASSES
    // ==========================================
    
    public class QuoteData {
        @AuraEnabled public String riskId { get; set; }
        @AuraEnabled public String zipCode { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String address { get; set; }
        @AuraEnabled public String nkr { get; set; }
        @AuraEnabled public String accumulationId { get; set; }
        @AuraEnabled public String accumulationName { get; set; }
        @AuraEnabled public String opportunityId { get; set; }
        @AuraEnabled public DateTime inceptionDate { get; set; }
        @AuraEnabled public Date startDatePeriode { get; set; }
        @AuraEnabled public Date endDatePeriode { get; set; }
        
        public QuoteData(Quote q) {
            this.riskId = q.Risk_Name__c;
            this.zipCode = q.Risk_Name__r?.Zip_Code__r?.Name;
            this.city = q.Risk_Name__r?.City__r?.Name;
            this.address = q.Risk_Name__r?.Address_Description__c;
            this.nkr = q.Risk_Name__r?.N_K_R__r?.Name;
            this.accumulationId = q.Risk_Name__r?.Accumulation__c;
            this.accumulationName = q.Risk_Name__r?.Accumulation__r?.Name;
            this.opportunityId = q.OpportunityId;
            this.inceptionDate = q.Risk_Name__r?.Accumulation__r?.As_Per_Inception_Date__c;
            this.startDatePeriode = q.Opportunity?.Start_Date_Periode__c;
            this.endDatePeriode = q.Opportunity?.End_Date_Periode__c;
        }
    }

    public class AccumulationData {
        @AuraEnabled public String accumulationId { get; set; }
        @AuraEnabled public String accumulationName { get; set; }
        @AuraEnabled public String version { get; set; }
        @AuraEnabled public String groupId { get; set; }
        @AuraEnabled public DateTime inceptionDate { get; set; }
        @AuraEnabled public List<AssetSearchResult> assets { get; set; }
        
        public AccumulationData(Accumulation__c acc, List<Asset> assetList) {
            this.accumulationId = acc.Id;
            this.accumulationName = acc.Name;
            this.version = acc.Version__c;
            this.groupId = acc.Group_ID__c;
            this.inceptionDate = acc.As_Per_Inception_Date__c;
            this.assets = new List<AssetSearchResult>();
            for (Asset a : assetList) {
                this.assets.add(new AssetSearchResult(a));
            }
        }
    }

    public class AssetSearchResult {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String requestNum { get; set; }
        @AuraEnabled public String policyNum { get; set; }
        @AuraEnabled public String address { get; set; }
        @AuraEnabled public String zipCode { get; set; }
        @AuraEnabled public String riskId { get; set; }
        @AuraEnabled public String riskName { get; set; }
        @AuraEnabled public String insuredName { get; set; }
        @AuraEnabled public Decimal sumInsured { get; set; }
        @AuraEnabled public Decimal sumInsuredIDR { get; set; }
        @AuraEnabled public String nkr { get; set; }
        @AuraEnabled public String cur { get; set; }
        @AuraEnabled public String opportunityId { get; set; }
        @AuraEnabled public Decimal exchangeRate { get; set; }
        @AuraEnabled public String groupId { get; set; }
        @AuraEnabled public String accumulationId { get; set; }
        @AuraEnabled public String riskObjectId { get; set; }
        @AuraEnabled public String vesselName { get; set; }
        @AuraEnabled public String voyageNumber { get; set; }
        @AuraEnabled public Date startDatePeriode { get; set; }
        @AuraEnabled public Date endDatePeriode { get; set; }
        @AuraEnabled public String accumId { get; set; } 

        public AssetSearchResult() {}

        public AssetSearchResult(Asset a) {
            this.id = a.Id;
            this.requestNum = a.Opportunity__r?.Busreq_ID__c;
            this.policyNum = a.Insurance_Policy__r?.Name;
            this.riskId = a.Risk_ID__c;
            this.riskName = a.Name;
            this.insuredName = a.Insurance_Policy__r?.NameInsured__c;
            this.sumInsured = a.Amount_Insured__c;
            this.sumInsuredIDR = a.Amount_Insured__c;
            this.address = a.Address_Description__c;
            this.zipCode = a.Zip_Code__r?.Name;
            this.nkr = a.N_K_R__r?.Name;
            this.cur = a.Currency__r?.Name != null ? a.Currency__r.Name : DEFAULT_CURRENCY;
            this.opportunityId = a.Opportunity__c;
            this.exchangeRate = DEFAULT_EXCHANGE_RATE;
            this.groupId = a.Accumulation__r?.Group_ID__c;
            this.accumulationId = a.Accumulation__c;
            this.riskObjectId = null;
            this.vesselName = a.Vessel_Name__r?.Name;
            this.voyageNumber = a.Voyage_Number__c;
            this.startDatePeriode = a.Opportunity__r?.Start_Date_Periode__c;
            this.endDatePeriode = a.Opportunity__r?.End_Date_Periode__c;
            try { 
                this.accumId = (String) a.get('Accumulation_ID__c'); 
            } catch(Exception e) { 
                this.accumId = ''; 
                System.debug(LoggingLevel.WARN, 'Failed to retrieve Accumulation_ID__c: ' + e.getMessage());
            }
        }
    }

    public class AccumulationInput {
        @AuraEnabled public String accumulationId { get; set; }
        @AuraEnabled public String businessRequestId { get; set; }
        @AuraEnabled public String address { get; set; }
        @AuraEnabled public String zipCode { get; set; }
        @AuraEnabled public Decimal totalTSI { get; set; }
        @AuraEnabled public String versionStr { get; set; }
        @AuraEnabled public String oppId { get; set; }
        @AuraEnabled public String policyNum { get; set; }
        @AuraEnabled public String riskId { get; set; }
        @AuraEnabled public String groupId { get; set; }
        @AuraEnabled public List<String> allAssetIds { get; set; }
        @AuraEnabled public DateTime inceptionDate { get; set; }
        
        @AuraEnabled public List<AssetSearchResult> assetDetails { get; set; }
        @AuraEnabled public List<AssetSearchResult> deletedAssetDetails { get; set; }
    }

    public class InitialData {
        @AuraEnabled public String businessRequestId { get; set; }
        @AuraEnabled public AssetSearchResult assetRow { get; set; }
    }
    
    // ==========================================
    // PUBLIC METHODS
    // ==========================================

    @AuraEnabled(cacheable=true)
    public static String getBsnIdFromOpportunity(String opportunityId) {
        if (String.isBlank(opportunityId)) {
            return null;
        }
        try { 
            return [SELECT COB__c FROM Opportunity WHERE Id = :opportunityId WITH SECURITY_ENFORCED LIMIT 1]?.COB__c; 
        } catch (Exception e) { 
            System.debug(LoggingLevel.ERROR, 'Error in getBsnIdFromOpportunity: ' + e.getMessage());
            return null; 
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getExchangeRate(String currencyCode, String year) {
        if (String.isBlank(currencyCode) || currencyCode == DEFAULT_CURRENCY) {
            return DEFAULT_EXCHANGE_RATE;
        }
        try {
            List<Master_Data__c> rates = [
                SELECT Exchange_Rate__c 
                FROM Master_Data__c 
                WHERE CURRENCY_CODE__c = :currencyCode 
                AND RI_PARAM_YEAR__c = :year 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            return (rates.isEmpty() || rates[0].Exchange_Rate__c == null) ? DEFAULT_EXCHANGE_RATE : rates[0].Exchange_Rate__c;
        } catch (Exception e) { 
            throw new AuraHandledException('Error fetching exchange rate: ' + e.getMessage()); 
        }
    }

    @AuraEnabled(cacheable=true)
    public static QuoteData getQuoteData(String quoteId) {
         if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Quote ID required');
         }
         try { 
            Quote q = [
                SELECT Id, Risk_Name__c, Risk_Name__r.Zip_Code__r.Name, Risk_Name__r.City__r.Name, 
                       Risk_Name__r.Address_Description__c, Risk_Name__r.N_K_R__r.Name, 
                       Risk_Name__r.Accumulation__c, Risk_Name__r.Accumulation__r.Name, 
                       Risk_Name__r.Accumulation__r.As_Per_Inception_Date__c, OpportunityId, 
                       Opportunity.Start_Date_Periode__c, Opportunity.End_Date_Periode__c 
                FROM Quote 
                WHERE Id = :quoteId 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            return new QuoteData(q); 
        } catch (Exception e) { 
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    @AuraEnabled(cacheable=true)
    public static AccumulationData getAccumulationData(String accumulationId) {
        if (String.isBlank(accumulationId)) {
            throw new AuraHandledException('Accumulation ID required');
        }
        try {
            Accumulation__c acc = [
                SELECT Id, Name, Version__c, Group_ID__c, As_Per_Inception_Date__c 
                FROM Accumulation__c 
                WHERE Id = :accumulationId 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            List<Asset> assets = [
                SELECT Id, Name, Risk_ID__c, Insurance_Policy__r.Name, Insurance_Policy__r.NameInsured__c, 
                       Address_Description__c, Amount_Insured__c, Zip_Code__r.Name, 
                       Zip_Code__r.Branch_Name__r.BRANCH_ID__c, Opportunity__c, Opportunity__r.Busreq_ID__c, 
                       Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c, N_K_R__r.Name, 
                       Currency__r.Name, Accumulation__c, Accumulation__r.Group_ID__c, Risk__c, Busreq_ID__c, 
                       Vessel_Name__c, Vessel_Name__r.Name, Voyage_Number__c, Accumulation_ID__c 
                FROM Asset 
                WHERE Accumulation__c = :accumulationId 
                AND RecordType.DeveloperName = :RECORD_TYPE_RISK
                WITH SECURITY_ENFORCED
            ];
            return new AccumulationData(acc, assets);
        } catch (Exception e) { 
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    @AuraEnabled(cacheable=true)
    public static InitialData getInitialAssetData(String assetId) {
        if (String.isBlank(assetId)) {
            return null;
        }
        try {
            Asset a = [
                SELECT Id, Name, Risk_ID__c, Insurance_Policy__r.Name, Insurance_Policy__r.NameInsured__c, 
                       Address_Description__c, Amount_Insured__c, Zip_Code__r.Name, Opportunity__c, 
                       Opportunity__r.Busreq_ID__c, Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c, 
                       Zip_Code__r.Branch_Name__r.BRANCH_ID__c, N_K_R__r.Name, Currency__r.Name, Accumulation__c, 
                       Accumulation__r.Group_ID__c, Risk__c, Vessel_Name__c, Vessel_Name__r.Name, Voyage_Number__c, Accumulation_ID__c 
                FROM Asset 
                WHERE Id = :assetId 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            InitialData data = new InitialData(); 
            data.businessRequestId = a.Opportunity__r?.Busreq_ID__c; 
            data.assetRow = new AssetSearchResult(a); 
            return data;
        } catch (Exception e) { 
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    @AuraEnabled
    public static Map<String, Object> getRisksByOpportunityBusReq(String opportunityId) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('data', new List<AssetSearchResult>());
        result.put('message', '');
        
        if (String.isBlank(opportunityId)) {
            return result;
        }

        try {
            List<Opportunity> oppList = [
                SELECT Busreq_ID__c, Start_Date_Periode__c 
                FROM Opportunity 
                WHERE Id = :opportunityId 
                WITH SECURITY_ENFORCED 
                LIMIT 1
            ];
            
            if (oppList.isEmpty()) {
                return result;
            }
            
            Opportunity currentOpp = oppList[0];
            String reqNum = currentOpp.Busreq_ID__c;
            Date refDate = currentOpp.Start_Date_Periode__c;

            if (String.isBlank(reqNum)) {
                result.put('message', 'This Opportunity does not have a Busreq ID.');
                return result;
            }

            Map<String, Date> dateRange = calculateFiscalYearRange(refDate);
            Date filterStart = dateRange.get('start');
            Date filterEnd = dateRange.get('end');

            String soql = 'SELECT Id, Name, Risk_ID__c, Insurance_Policy__r.Name, Insurance_Policy__r.NameInsured__c, ' +
                          'Address_Description__c, Amount_Insured__c, Zip_Code__r.Name, Zip_Code__r.Branch_Name__r.BRANCH_ID__c, ' +
                          'Opportunity__c, Opportunity__r.Busreq_ID__c, Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c, ' +
                          'N_K_R__r.Name, Currency__r.Name, Accumulation__c, Accumulation__r.Group_ID__c, Risk__c, Busreq_ID__c, ' +
                          'Vessel_Name__c, Vessel_Name__r.Name, Voyage_Number__c, Accumulation_ID__c ' +
                          'FROM Asset ' +
                          'WHERE Busreq_ID__c = :reqNum ' +
                          'AND RecordType.DeveloperName = :RECORD_TYPE_RISK ' +
                          'AND Accumulation__c = null ' +
                          'AND Opportunity__r.End_Date_Periode__c >= TODAY ';

            if (filterStart != null && filterEnd != null) {
                soql += 'AND Opportunity__r.Start_Date_Periode__c >= :filterStart ' +
                        'AND Opportunity__r.Start_Date_Periode__c <= :filterEnd ';
            }
            soql += 'ORDER BY Name ASC';

            List<Asset> assets = Database.query(String.escapeSingleQuotes(soql)); 
            List<AssetSearchResult> assetResults = new List<AssetSearchResult>();
            for (Asset a : assets) {
                assetResults.add(new AssetSearchResult(a));
            }
            
            result.put('data', assetResults);
            
            if (assetResults.isEmpty()) {
                result.put('message', 'No active Risk found (Range: ' + filterStart + ' to ' + filterEnd + ') with Busreq ID: ' + reqNum);
            } else {
                result.put('message', 'Found ' + assetResults.size() + ' risk(s).');
            }
            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching auto-suggested risks: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<AssetSearchResult> searchAssets(String addressQuery, String policyQuery, String zipCodeQuery, String nkrQuery, String riskNameQuery, String vesselNameQuery, String voyageNumberQuery, Date startDatePeriodeQuery, Date endDatePeriodeQuery, String contextOpportunityId) {
        List<String> whereClauses = new List<String>();
        
        if (String.isNotBlank(addressQuery)) {
            whereClauses.add('Address_Description__c LIKE \'%' + String.escapeSingleQuotes(addressQuery) + '%\'');
        }
        if (String.isNotBlank(policyQuery)) {
            whereClauses.add('Insurance_Policy__r.Name LIKE \'%' + String.escapeSingleQuotes(policyQuery) + '%\'');
        }
        if (String.isNotBlank(zipCodeQuery)) {
            whereClauses.add('Zip_Code__r.Name LIKE \'%' + String.escapeSingleQuotes(zipCodeQuery) + '%\'');
        }
        if (String.isNotBlank(nkrQuery)) {
            whereClauses.add('N_K_R__r.Name LIKE \'%' + String.escapeSingleQuotes(nkrQuery) + '%\'');
        }
        if (String.isNotBlank(riskNameQuery)) {
            whereClauses.add('Name LIKE \'%' + String.escapeSingleQuotes(riskNameQuery) + '%\'');
        }
        
        whereClauses.add('RecordType.DeveloperName = :RECORD_TYPE_RISK'); 
        whereClauses.add('Busreq_ID__c != null');
        whereClauses.add('Opportunity__r.End_Date_Periode__c >= TODAY'); 

        Date filterStart;
        Date filterEnd;

        if (String.isNotBlank(contextOpportunityId)) {
            List<Opportunity> opps = [SELECT Start_Date_Periode__c FROM Opportunity WHERE Id = :contextOpportunityId WITH SECURITY_ENFORCED LIMIT 1];
            if (!opps.isEmpty() && opps[0].Start_Date_Periode__c != null) {
                Map<String, Date> dateRange = calculateFiscalYearRange(opps[0].Start_Date_Periode__c);
                filterStart = dateRange.get('start');
                filterEnd = dateRange.get('end');
                
                if (filterStart != null && filterEnd != null) {
                    whereClauses.add('Opportunity__r.Start_Date_Periode__c >= :filterStart');
                    whereClauses.add('Opportunity__r.Start_Date_Periode__c <= :filterEnd');
                }
            }
        }

        if (whereClauses.isEmpty()) {
            return new List<AssetSearchResult>();
        } 
        
        String soql = 'SELECT Id, Name, Risk_ID__c, Insurance_Policy__r.Name, Insurance_Policy__r.NameInsured__c, ' +
                      'Address_Description__c, Amount_Insured__c, Zip_Code__r.Name, Zip_Code__r.Branch_Name__r.BRANCH_ID__c, ' +
                      'Opportunity__c, Opportunity__r.Busreq_ID__c, Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c, ' +
                      'N_K_R__r.Name, Currency__r.Name, Accumulation__c, Accumulation__r.Group_ID__c, Risk__c, Busreq_ID__c, ' +
                      'Vessel_Name__c, Vessel_Name__r.Name, Voyage_Number__c, Accumulation_ID__c ' +
                      'FROM Asset WHERE ' + String.join(whereClauses, ' AND ') + 
                      ' ORDER BY Name ASC NULLS LAST LIMIT :SEARCH_LIMIT';
        
        List<AssetSearchResult> results = new List<AssetSearchResult>();
        try {
            for (Asset a : Database.query(soql)) {
                results.add(new AssetSearchResult(a));
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error searching assets: ' + e.getMessage());
        }
        return results;
    }

    @AuraEnabled
    public static List<AssetSearchResult> getAssetsByGroupId(String groupId) {
        if (String.isBlank(groupId)) {
            return new List<AssetSearchResult>();
        }
        try {
            List<Asset> assets = [
                SELECT Id, Name, Risk_ID__c, Insurance_Policy__r.Name, Insurance_Policy__r.NameInsured__c, 
                       Address_Description__c, Amount_Insured__c, Zip_Code__r.Name, Zip_Code__r.Branch_Name__r.BRANCH_ID__c, 
                       Opportunity__c, Opportunity__r.Busreq_ID__c, Opportunity__r.Start_Date_Periode__c, 
                       Opportunity__r.End_Date_Periode__c, N_K_R__r.Name, Currency__r.Name, Accumulation__c, 
                       Accumulation__r.Group_ID__c, Risk__c, Busreq_ID__c, Vessel_Name__c, Vessel_Name__r.Name, 
                       Voyage_Number__c, Accumulation_ID__c 
                FROM Asset 
                WHERE Accumulation__r.Group_ID__c = :groupId 
                AND Busreq_ID__c != null 
                AND RecordType.DeveloperName = :RECORD_TYPE_RISK 
                AND Opportunity__r.End_Date_Periode__c >= TODAY
                WITH SECURITY_ENFORCED
            ];
            List<AssetSearchResult> results = new List<AssetSearchResult>();
            for (Asset a : assets) {
                results.add(new AssetSearchResult(a));
            }
            return results;
        } catch (Exception e) { 
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> checkMultipleAssetOwnership(List<String> assetIds) {
        Map<String, Boolean> ownershipMap = new Map<String, Boolean>();
        if (assetIds == null || assetIds.isEmpty()) {
            return ownershipMap;
        }
        try {
            List<Asset> assets = [
                SELECT Id, Opportunity__r.Assigned_Underwriting__c 
                FROM Asset 
                WHERE Id IN :assetIds
                WITH SECURITY_ENFORCED
            ];
            
            Id currentUserId = UserInfo.getUserId();
            
            for (Asset asset : assets) {
                if (asset.Opportunity__r != null && asset.Opportunity__r.Assigned_Underwriting__c != null) {
                    ownershipMap.put(asset.Id, asset.Opportunity__r.Assigned_Underwriting__c == currentUserId);
                } else {
                    ownershipMap.put(asset.Id, false);
                }
            }
            
            for (String assetId : assetIds) {
                if (!ownershipMap.containsKey(assetId)) {
                    ownershipMap.put(assetId, false);
                }
            }
            return ownershipMap;
        } catch (Exception e) {
             System.debug(LoggingLevel.ERROR, 'Error checking ownership: ' + e.getMessage());
             return ownershipMap; 
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> createAccumulationRecord(AccumulationInput data) { 
        validateAccumulationInput(data);
        Map<String, Object> result = new Map<String, Object>();
        try {
            Map<String, Object> ipResult = callIntegrationProcedure(data);
            String jsonResponse = (String) ipResult.get('jsonResponse');
            if (validateIpResponseStatus(jsonResponse)) {
                result.put('success', true);
                result.put('message', 'Integration Successful');
                result.put('data', jsonResponse);
            } else {
                result.put('success', false);
                result.put('message', 'Integration Failed: ' + jsonResponse);
            }
            return result;
        } catch (Exception e) { 
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    @AuraEnabled
    public static Map<String, Object> updateAccumulationRecord(AccumulationInput data) {
        validateAccumulationInput(data);
        Map<String, Object> result = new Map<String, Object>();
        if (String.isBlank(data.accumulationId)) {
            throw new AuraHandledException('Accumulation ID is required for update');
        }
        try {
            Map<String, Object> ipResult = callIntegrationProcedure(data);
            String jsonResponse = (String) ipResult.get('jsonResponse');
            if (validateIpResponseStatus(jsonResponse)) {
                result.put('success', true);
                result.put('message', 'Integration Successful');
                result.put('data', jsonResponse);
            } else {
                result.put('success', false);
                result.put('message', 'Integration Failed: ' + jsonResponse);
            }
            return result;
        } catch (Exception e) { 
            throw new AuraHandledException('Error: ' + e.getMessage()); 
        }
    }

    // ==========================================
    // PRIVATE / HELPER METHODS
    // ==========================================

    private static Map<String, Date> calculateFiscalYearRange(Date refDate) {
        Map<String, Date> rangeMap = new Map<String, Date>{'start' => null, 'end' => null};
        if (refDate == null) {
            return rangeMap;
        }

        Integer year = refDate.year();
        Integer month = refDate.month();
        Date filterStart;
        Date filterEnd;

        if (month >= FISCAL_MONTH_CUTOFF) {
            filterStart = Date.newInstance(year, 7, 1);
            filterEnd = Date.newInstance(year + 1, 6, 30);
        } else {
            filterStart = Date.newInstance(year - 1, 7, 1);
            filterEnd = Date.newInstance(year, 6, 30);
        }
        rangeMap.put('start', filterStart);
        rangeMap.put('end', filterEnd);
        return rangeMap;
    }

    private static Map<String, Object> callIntegrationProcedure(AccumulationInput data) {
        Map<String, Object> ipInput = new Map<String, Object>();
        List<Object> accumulationsList = new List<Object>();
        List<Object> deletedAccumulationsList = new List<Object>();
        
        Boolean isDeleteOperation = (data.deletedAssetDetails != null && !data.deletedAssetDetails.isEmpty());

        if (isDeleteOperation) {
            for (AssetSearchResult asset : data.deletedAssetDetails) {
                Map<String,Object> ucil = new Map<String,Object>();
                ucil.put('risk_id', asset.riskId);
                ucil.put('group_id', asset.groupId);
                ucil.put('busreq_id', asset.requestNum);
                ucil.put('accum_id', '');
                deletedAccumulationsList.add(ucil);
            }
        } else {
            if (data.assetDetails != null) {
                for (AssetSearchResult asset : data.assetDetails) {
                    Map<String,Object> ucil = new Map<String,Object>();
                    ucil.put('risk_id', asset.riskId);
                    ucil.put('group_id', asset.groupId);
                    ucil.put('busreq_id', asset.requestNum);
                    ucil.put('accum_id', asset.accumId);
                    accumulationsList.add(ucil);
                }
            }
        }
        
        ipInput.put('accumulations', accumulationsList);
        ipInput.put('deleted_accumulations', deletedAccumulationsList); 
        
        Map<String, Object> result = new Map<String, Object>();
        String extractedGroupId = '';
        String jsonResponseStr = '';

        try {
            String jsonInputString = JSON.serialize(ipInput);
            // Assuming VlocityMapping is a recognized class in your org
            Map<String, Object> ipOutput = VlocityMapping.callIP(IP_NAME, jsonInputString);
            jsonResponseStr = ipOutput != null ? JSON.serialize(ipOutput) : '';
            
            if (ipOutput != null && ipOutput.containsKey('data')) {
                Object dataObj = ipOutput.get('data');
                if (dataObj != null && dataObj instanceof Map<String, Object>) {
                     Map<String, Object> dataMap = (Map<String, Object>) dataObj;
                     if (dataMap.containsKey('accumulation-list')) {
                         Object listObj = dataMap.get('accumulation-list');
                         if (listObj instanceof List<Object>) {
                             List<Object> accList = (List<Object>) listObj;
                             if (!accList.isEmpty()) {
                                 Map<String, Object> firstItem = (Map<String, Object>) accList.get(0);
                                 if (firstItem != null && firstItem.containsKey('group_id')) {
                                     extractedGroupId = String.valueOf(firstItem.get('group_id'));
                                 }
                             }
                         }
                     }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error calling Integration Procedure: ' + e.getMessage());
        }

        result.put('groupId', extractedGroupId);
        result.put('jsonResponse', jsonResponseStr);
        return result;
    }

    private static boolean validateIpResponseStatus(String jsonResponse) {
        if (String.isBlank(jsonResponse)) {
            return false;
        }
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            if (responseMap.containsKey('status')) {
                return String.valueOf(responseMap.get('status')) == STATUS_SUCCESS;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error parsing IP response status: ' + e.getMessage());
        }
        return false;
    }

    private static void validateAccumulationInput(AccumulationInput data) {
        if (data == null) {
            throw new AuraHandledException('Input data is null');
        }
        if (String.isBlank(data.versionStr)) {
            throw new AuraHandledException('Version is required');
        }
        if (data.totalTSI == null) {
            throw new AuraHandledException('Total TSI is required');
        }
    }
}