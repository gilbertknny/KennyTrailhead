/**
 * @description       : Controller LWC Input Coverage
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-21-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_Add_New_CoverageRate {
    /**
     * @description function for generate map data coverage
     * @param coverageWrappers list of Json String after deserialize
     * @return Map<String,String> contain REF ID Coverage and Id Coverage
     */
    public static Map<String,Master_Data__c> generateData(List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> coverageWrappers){
        List<String> coverageIds = new List<String>();
        for (Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper : coverageWrappers) {
            if (wrapper.id != 'SINGLE_RATE_ID') {
                coverageIds.add(wrapper.coverageId);
            }
        }
        List<Master_Data__c> configs = [
            SELECT Id,Name,COVERAGE_REF_ID__c
            FROM Master_Data__c WHERE COVERAGE_REF_ID__c IN :coverageIds
            WITH SECURITY_ENFORCED
        ];
        Map<String, Master_Data__c> coverageRefMap = new Map<String, Master_Data__c>();
        for (Master_Data__c cfg : configs) {
            coverageRefMap.put(cfg.COVERAGE_REF_ID__c,cfg);
        }
        return coverageRefMap;
    }

    /**
     * @description function for checkPermission Access
     * @return boolean accessible
     */
    public static Boolean checkPermission(){
        Boolean access = true;
        if (!Schema.sObjectType.RecordType.isAccessible() &&
            !Schema.sObjectType.Asset.isAccessible() &&
            !Schema.sObjectType.Master_Data__c.isAccessible() &&
            !Schema.sObjectType.InsurancePolicyCoverage.isCreateable() &&
            !Schema.sObjectType.Asset.isUpdateable()
        ){
            access = false;
        }
        return access;
    }
    /**
     * @description function for generate selected CoverageId as string
     * @param coverageWrappers list of Json String after deserialize
     * @return string selected coverageId
     */
    public static String selectedCoverageId(List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> coverageWrappers){
        List<String> listId = new List<String>();
        for (Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper : coverageWrappers) {
            // Master_Data__c getData = coverageRefIdMap.get(wrapper.coverageId);
            if(wrapper.coverageId!=null){
                listId.add(wrapper.coverageId);
            }
        }
        if (!listId.isEmpty()) {
            String resultString = String.join(listId, ',');
            return resultString;
        }
        return null;
    }
    /**
     * @description function for insert data Coverage from list coverageWrappers
     * @param coverageWrappers list of Json String after deserialize
     * @param coverageRefIdMap map must be contain REF ID and Master_Data__c
     */
    public static void insertCoverageData(List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> coverageWrappers,Map<String, Master_Data__c> coverageRefIdMap){
        try{
            String selectedCoverageId = selectedCoverageId(coverageWrappers);
            String riskId = coverageWrappers[0].riskId;
            String policyId = coverageWrappers[0].policyId;
            if (!checkPermission()) {
                throw new SecurityException(
                    'Insufficient permissions to access Asset or InsurancePolicyCoverage'
                );
            }
            RecordType rtExRate = [SELECT Id, Name FROM RecordType where SobjectType = 'Master_Data__c' and Name = 'Exchange Rate' LIMIT 1];
            List<Master_Data__c> exchangeList = [SELECT Id,Name FROM Master_Data__c WHERE RecordTypeId = :rtExRate.Id];
            Map<String, String> exchangeMapFull = new Map<String, String>();
            for (Master_Data__c md : exchangeList) {
                exchangeMapFull.put(md.Name, md.Id);
            }
            Boolean composite = (coverageWrappers[0].coverageSetting == 'COMPOSITE');
            Asset risk = [SELECT Id, Amount_Insured__c, Opportunity__c,COB__c,Opportunity__r.Busreq_ID__c FROM Asset WHERE Id = :riskId];
            List<InsurancePolicyCoverage> coverageList = new List<InsurancePolicyCoverage>();
            List<String> coverageParentId = new List<String>();
            // System.debug('### AWT : exchangeMapFull');
            // System.debug('### AWT : coverageRefIdMap'+coverageRefIdMap);
            // System.debug('### AWT : to looping');
            for (Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper : coverageWrappers) {
                if(composite){
                    // System.debug('### AWT : in looping composite'+wrapper.coverageId);
                    if (wrapper.id == 'SINGLE_RATE_ID') {
                        InsurancePolicyCoverage generateDataCoverage = Aswata_Coverage_Data_Handler.coverageBreakdown(wrapper,coverageRefIdMap,risk);
                        generateDataCoverage.Coverage_Id__c = wrapper.coverageId;
                        generateDataCoverage.InsurancePolicyId = wrapper.policyId;
                        generateDataCoverage.Risk_ID__c = riskId;
                        generateDataCoverage.Opportunity__c = risk.Opportunity__c;
                        String idCurrency = exchangeMapFull.get(generateDataCoverage.Minimum_Cur_ID__c);
                        generateDataCoverage.Deductible_Currency__c = idCurrency;
                        generateDataCoverage.Selected_Coverages_ID__c = selectedCoverageId;
                        coverageList.add(generateDataCoverage);
                        risk.Rate_All_Coverages__c  = wrapper.rate.coverageRate;
                        risk.Commission_All_Coverages__c = wrapper.rebate.commissionValue;
                    }else if(wrapper.id != 'SINGLE_RATE_ID' && wrapper.parentCoverageId == '0'){
                        Master_Data__c getData = coverageRefIdMap.get(wrapper.coverageId);
                        // System.debug('### AWT getData : '+getData);
                        coverageParentId.add(getData.Id);
                    }
                }else{
                    if (wrapper.id != 'SINGLE_RATE_ID') {
                        // System.debug('### AWT : in looping breakdown'+wrapper.coverageId);
                        InsurancePolicyCoverage generateDataCoverage = Aswata_Coverage_Data_Handler.coverageBreakdown(wrapper,coverageRefIdMap,risk);
                        // System.debug('('### AWT Description : '+generateDataCoverage.Description + ' - '+generateDataCoverage.Description__c);
                        generateDataCoverage.Coverage_Id__c = wrapper.coverageId;
                        generateDataCoverage.InsurancePolicyId = wrapper.policyId;
                        generateDataCoverage.Risk_ID__c = riskId;
                        generateDataCoverage.Opportunity__c = risk.Opportunity__c;
                        String idCurrency = exchangeMapFull.get(generateDataCoverage.Minimum_Cur_ID__c);
                        generateDataCoverage.Deductible_Currency__c = idCurrency;
                        coverageList.add(generateDataCoverage);
                        risk.Rate_All_Coverages__c  = wrapper.commisionAllRate;
                        risk.Commission_All_Coverages__c = wrapper.commisionAllRate;
                    }
                }
            }
            // System.debug('### AWT : to function coverageByAssetCategory');
            coverageList = Aswata_Coverage_Data_301.coverageByAssetCategory(coverageList,risk,coverageParentId);
            // System.debug('### AWT coverageList : '+coverageList.size());
            List<Database.SaveResult> saveResults;
            if(coverageList.size() > 0) {
                saveResults = Database.insert(coverageList, true);
                update risk;
            }
            // system.debug('### AWT coverageList :'+coverageList);
            Set<Id> newIds = new Set<Id>();
            for (Database.SaveResult sr : saveResults) {
                newIds.add(sr.getId());
            }
            if (!newIds.isEmpty()) {
                Aswata_Async_PremiCalculation.aswataPremiCalculation(risk.Opportunity__c);
                // System.debug('Semua insert sukses dan Future class berhasil dipanggil.');
            }
        }catch (Exception e) {
            // System.debug('#ErrorLog - '+e.getMessage());
            throw e;
        }
    }
    /**
     * @description function for insert Coverage
     * this function call from Flow
     * @param jsonStringList list of json string from FLOW
     */
    @InvocableMethod(label='Insert Coverage Detail Data (JSON String)')
    public static void insertCoverageDetails(List<String> jsonStringList) {
        try {
            String jsonString = jsonStringList[0];
            List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> coverageWrappers = (List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>) JSON.deserialize(
                jsonString,
                List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>.class
            );
            Map<String, Master_Data__c> coverageRefIdMap = generateData(coverageWrappers);
            insertCoverageData(coverageWrappers,coverageRefIdMap);
        } catch (Exception e){
            throw e;
        }
    }
    /**
     * @description function for insert Coverage
     * this function call from Flow
     * @param jsonStringList list of json string from FLOW
     */
    // @AuraEnabled
    // public static String insertCoverageJson(String jsonStringList) {
    //     try {
    //         String jsonString = jsonStringList;
    //         List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> coverageWrappers = (List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>) JSON.deserialize(
    //             jsonString,
    //             List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>.class
    //         );
    //         Map<String, Master_Data__c> coverageRefIdMap = generateData(coverageWrappers);
            
    //         insertCoverageData(coverageWrappers,coverageRefIdMap);   
    //         return 'Success';
    //     } catch (Exception e){
    //         return e.getMessage();
    //     }
    // }
}