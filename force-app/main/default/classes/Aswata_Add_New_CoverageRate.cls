/**
 * @description       : Controller LWC Input Coverage
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-03-2025
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
            // String selectedCoverageId = selectedCoverageId(coverageWrappers);
            // String riskId = coverageWrappers[0].riskId;
            // String policyId = coverageWrappers[0].policyId;
            // Boolean composite = (coverageWrappers[0].coverageSetting == 'COMPOSITE');
            String coverageMode;
            if (coverageWrappers[0].coverageSetting == 'COMPOSITE') {
                coverageMode = 'COMPOSITE';
            } else {
                coverageMode = 'SINGLE';
            }
            performMappingAndDML(coverageWrappers,coverageRefIdMap,coverageMode);
        }catch (Exception e) {
            // System.debug('#ErrorLog - '+e.getMessage());
            throw e;
        }
    }
    /**
     * @description function for generate Map Exchange Rate Coverage
     * @param rtExRate
     * @return Map<String, String>
     */
    public static Map<String, String> generateExchangeMap(RecordType rtExRate) {
        Map<String, String> exchangeMapFull = new Map<String, String>();
        List<Master_Data__c> exchangeList = [SELECT Id,Name FROM Master_Data__c WHERE RecordTypeId = :rtExRate.Id WITH SECURITY_ENFORCED];
        for (Master_Data__c md : exchangeList) {
            exchangeMapFull.put(md.Name, md.Id);
        }
        return exchangeMapFull;
    }
    /**
     * @description function for get lastest cov_tahun_id__c
     * @param risk
     * @return Decimal
     */
    public static Decimal getLastestId(Asset risk) {
        Decimal result = 0;
        List<InsurancePolicyCoverage> latestAssetList = [
            SELECT cov_tahun_id__c
            FROM InsurancePolicyCoverage WHERE Risk_ID__c = :risk.Id
            AND cov_tahun_id__c != null
            WITH SECURITY_ENFORCED
            ORDER BY cov_tahun_id__c DESC LIMIT 1
        ];
        if(!latestAssetList.isEmpty()) {
            result = latestAssetList[0].cov_tahun_id__c;
        }
        return result;
    }
    /**
     * @description function for insert update
     * @param coverageWrappers
     * @param coverageRefIdMap
     * @param composite
     */
    public static void performMappingAndDML(
        List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> coverageWrappers,
        Map<String, Master_Data__c> coverageRefIdMap,
        String composite
    ) {
        try {
            String selectedCoverageId = selectedCoverageId(coverageWrappers);
            String riskId = coverageWrappers[0].riskId;
            String policyId = coverageWrappers[0].policyId;
            RecordType rtExRate = [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'Master_Data__c' AND Name = 'Exchange Rate'
                WITH SECURITY_ENFORCED LIMIT 1
            ];
            Map<String, String> exchangeMapFull = generateExchangeMap(rtExRate);
            // Map<String, String> exchangeMapFull = new Map<String, String>();
            // List<Master_Data__c> exchangeList = [SELECT Id,Name FROM Master_Data__c WHERE RecordTypeId = :rtExRate.Id];
            // for (Master_Data__c md : exchangeList) {
            //     exchangeMapFull.put(md.Name, md.Id);
            // }
            Asset risk = [
                SELECT Id, Amount_Insured__c, Opportunity__c,COB__c,Opportunity__r.Busreq_ID__c,Model__c,
                Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c
                FROM Asset
                WHERE Id = :riskId
                WITH SECURITY_ENFORCED
            ];
            Decimal counter = 1;
            // Decimal counter = getLastestId(risk);
            List<InsurancePolicyCoverage> coverageList = new List<InsurancePolicyCoverage>();
            List<String> coverageParentId = new List<String>();
            // System.debug('### AWT : exchangeMapFull');
            System.debug('### AWT : coverageRefIdMap'+coverageRefIdMap);
            // System.debug('### AWT : to looping');
            for (Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper : coverageWrappers) {
                if(composite == 'COMPOSITE'){
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
                        // counter+=1;
                        generateDataCoverage.cov_tahun_id__c = counter;
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
                        // counter+=1;
                        generateDataCoverage.cov_tahun_id__c = counter;
                        coverageList.add(generateDataCoverage);
                        risk.Rate_All_Coverages__c  = wrapper.commisionAllRate;
                        risk.Commission_All_Coverages__c = wrapper.commisionAllRate;
                    }
                }
            }
            System.debug('### AWT : coverageParentId'+coverageParentId);
            performInsertUpdate(coverageList,risk,coverageParentId);
            // coverageList = Aswata_Coverage_Data_301.coverageByAssetCategory(coverageList,risk,coverageParentId);
            // List<Database.SaveResult> saveResults;
            // if(coverageList.size() > 0) {
            //     saveResults = Database.insert(coverageList, true);
            //     update risk;
            // }
            // Set<Id> newIds = new Set<Id>();
            // for (Database.SaveResult sr : saveResults) {
            //     newIds.add(sr.getId());
            // }
            // if (!newIds.isEmpty()) {
            //     Aswata_Async_PremiCalculation.aswataPremiCalculation(risk.Opportunity__c);
            // }
        } catch (Exception e){
            throw e;
        }
    }
    /**
     * @description function for insert update
     * @param coverageList
     * @param risk
     * @param coverageParentId
     */
    public static void performInsertUpdate(List<InsurancePolicyCoverage> coverageList,Asset risk,List<String> coverageParentId) {
        try {
            if (!Aswata_Coverage_Data_Handler.checkPermission() &&
                !Schema.sObjectType.Asset.isUpdateable()
            ) {
                throw new SecurityException(
                    'Insufficient permissions to access Asset or InsurancePolicyCoverage'
                );
            }
            coverageList = Aswata_Coverage_Data_301.coverageByAssetCategory(coverageList,risk,coverageParentId);
            coverageList = Aswata_Coverage_Data_301.calculateDurationInYears(coverageList,risk);
            System.debug('### AWT coverageList : '+coverageList.size());
            List<Database.SaveResult> saveResults;
            if(coverageList.size() > 0) {
                saveResults = Database.insert(coverageList, true);
                Asset riskUpdate = Aswata_Coverage_Data_301.calculateAllRate(coverageList,risk);
                update riskUpdate;
            }
            Set<Id> newIds = new Set<Id>();
            for (Database.SaveResult sr : saveResults) {
                newIds.add(sr.getId());
            }
            if (!newIds.isEmpty()) {
                Aswata_Async_PremiCalculation.aswataPremiCalculation(risk.Opportunity__c);
            }
        } catch (Exception e){
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
    // Example JSON
    /*
    [
        {
            "batasBawah": 2.94,
            "coverageId": "201101",
            "coverageName": "FLEXAS",
            "parentCoverageId": "201100",
            "sectionList": [
            1
            ],
            "id": "201101",
            "riskId": "02iMS000000PDtKYAW",
            "policyId": "0YTMS0000000FiD4AU",
            "amountInsurance": 155000,
            "isDisabledSelection": false,
            "rowType": "BREAKDOWN_RATE",
            "isSelected": true,
            "isDisabledInput": false,
            "isSingleRate": false,
            "coverageSetting": "BREAKDOWN_DEDUCTIBLE",
            "fixedAmount": null,
            "selfInsurace": null,
            "coverageRate": null,
            "rate": {
            "fixedAmount": 20150,
            "fixedAmount2": null,
            "fixedAmount3": null,
            "fixedAmount4": null,
            "selfInsurace": null,
            "coverageRate": 13,
            "coverageRate2": null,
            "coverageRate3": null,
            "coverageRate4": null,
            "descriptionRate": ""
            },
            "deductible": {
            "descriptionDeductible": "",
            "currencyName": "IDR",
            "deductibleSetting": "Percentage",
            "deductibleAmount": 12,
            "minimumAmount": 123123,
            "descriptionValue": "asdad",
            "deductibleFlag": "3"
            },
            "descriptionRate": "",
            "ddtibleSetting": "BREAKDOWN_DEDUCTIBLE",
            "compositeDisable": false,
            "deductibleSetting": "Percentage",
            "isFlat": false,
            "isPercent": true,
            "deductibleAmount": 12,
            "descriptionValue": "asdad",
            "rebateSetting": "BREAKDOWN_DEDUCTIBLE",
            "coverageAllRate": 13,
            "rebate": {
            "totalRebate": 10,
            "bspValue": 4,
            "overridingValue": 3,
            "commissionValue": 1,
            "discountValue": 2
            },
            "isDisabledTotalRebate": true,
            "isDisabledInputRebate": false,
            "commisionAllRate": 1
        },
        {
            "id": "SINGLE_RATE_ID",
            "riskId": "02iMS000000PDtKYAW",
            "policyId": "0YTMS0000000FiD4AU",
            "amountInsurance": 155000,
            "coverageId": " ",
            "coverageName": "Single/Package Rate",
            "isSelected": true,
            "isDisabledInput": true,
            "isDisabledSelection": true,
            "rowType": "SINGLE_RATE",
            "isSingleRate": true,
            "coverageSetting": "BREAKDOWN_DEDUCTIBLE",
            "rate": {
            "fixedAmount": null,
            "fixedAmount2": null,
            "fixedAmount3": null,
            "fixedAmount4": null,
            "selfInsurace": null,
            "coverageRate": null,
            "coverageRate2": null,
            "coverageRate3": null,
            "coverageRate4": null,
            "descriptionRate": ""
            },
            "deductible": {
            "descriptionDeductible": "",
            "currencyName": "IDR"
            },
            "fixedAmount": null,
            "selfInsurace": null,
            "batasBawah": null,
            "coverageRate": null,
            "descriptionRate": "",
            "coverageAllRate": 13,
            "ddtibleSetting": "BREAKDOWN_DEDUCTIBLE",
            "compositeDisable": true,
            "isFlat": false,
            "isPercent": false,
            "rebateSetting": "BREAKDOWN_DEDUCTIBLE",
            "rebate": {},
            "isDisabledTotalRebate": true,
            "isDisabledInputRebate": false,
            "commisionAllRate": 1
        }
    ]
     */
}