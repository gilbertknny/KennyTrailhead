/**
 * @description       : Generate Data for Insert Coverage
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 01-06-2026
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_Coverage_Data_Handler {
    /**
     * @description function for insert data coverage
     * @param wrapper list of Json String after deserialize
     * @param coverageRefIdMap map must be contain REF ID and Master_Data__c
     * @param risk
     * @return InsurancePolicyCoverage
     */
    public static InsurancePolicyCoverage coverageBreakdown(Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper,Map<String, Master_Data__c> coverageRefIdMap,Asset risk){
        InsurancePolicyCoverage coverage = new InsurancePolicyCoverage();
        coverage.Propose_Rate__c = wrapper.batasBawah;
        if (wrapper.id != 'SINGLE_RATE_ID') {
            //coverageName
            Master_Data__c getData = coverageRefIdMap.get(wrapper.coverageId);
            coverage.Coverage_Name__c = getData.Id;
            coverage.CoverageName = wrapper.coverageName;
        }else {
            coverage.CoverageName = wrapper.rate.descriptionRate;
        }
        // Rate
        coverage.Proposed_Fixed_Amount__c = wrapper.rate.coverageRate;
        coverage.Premi_Amount__c = wrapper.rate.fixedAmount;
        // coverage.Proposed_Fixed_Amount_Section_2__c = wrapper.rate.coverageRate2;
        // coverage.Premi_Amount_Section_2__c = wrapper.rate.fixedAmount2;
        // coverage.Proposed_Fixed_Amount_Section_3__c = wrapper.rate.coverageRate3;
        // coverage.Premi_Amount_Section_3__c = wrapper.rate.fixedAmount3;
        // coverage.Proposed_Fixed_Amount_Section_4__c = wrapper.rate.coverageRate4;
        // coverage.Premi_Amount_Section_4__c = wrapper.rate.fixedAmount4;
        // deductible
        coverage = wrapperDeductible(coverage,wrapper,risk);
        // rebate
        if(wrapper.rebate!=null){
            coverage.Total_Rebate__c = wrapper.rebate.totalRebate;
            coverage.Discount__c = wrapper.rebate.discountValue;
            coverage.Commision__c = wrapper.rebate.commissionValue;
            coverage.Banks_Fee_Comission__c = wrapper.rebate.bankFeeValue;
            coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebate.bspValue;
            coverage.Leasing_Fee__c = wrapper.rebate.leasingValue;
            coverage.Overdng_Comission__c = wrapper.rebate.overridingValue;
            coverage.Agent_Comission__c = wrapper.rebate.agentCommissionValue;
            coverage.Broker_Comission__c = wrapper.rebate.brokerCommissionValue;
            coverage.Finance_Commision_PCT__c = wrapper.rebate.financialCommissionValue;
        }
        if(wrapper.rebates.size()>0){
            coverage = Aswata_Coverage_SectionData_Handler.wrapperRebate4(coverage,wrapper,risk);
        }
        return coverage;
    }
    /**
     * @description function for generate data deductible
     * @param coverage
     * @param wrapper list of Json String after deserialize
     * @param risk
     * @return InsurancePolicyCoverage
     */
    public static InsurancePolicyCoverage wrapperDeductible(InsurancePolicyCoverage coverage,Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper,Asset risk){
        // InsurancePolicyCoverage coverage = new InsurancePolicyCoverage();
        // System.debug('## AWT Deductible'+wrapper.deductible);
        // System.debug('## AWT wrapper.deductibles'+wrapper.deductibles);
        // if(wrapper.deductible!=null && wrapper.deductible.deductibleSetting!=null){
        if(wrapper.deductible!=null){
            coverage.Deductible_Type__c = wrapper.deductible.deductibleSetting;
            coverage.Deductible__c = wrapper.deductible.deductibleFlag;
            coverage.Minimum_Cur_ID__c = wrapper.deductible.currencyName;
            if(wrapper.deductible.deductibleSetting=='FLAT'){
                coverage.DeductibleAmount = wrapper.deductible.deductibleAmount;
                coverage.Deductible_PCT__c = null;
            }else{
                coverage.DeductibleAmount = null;
                coverage.Deductible_PCT__c = wrapper.deductible.deductibleAmount;
                coverage.Minimum_Amount__c = wrapper.deductible.minimumAmount;
            }
            coverage.Description = wrapper.deductible.descriptionDeductible;
            coverage.Description__c = wrapper.deductible.descriptionValue;

            if(wrapper.deductibles.size()>0){
                coverage = Aswata_Coverage_SectionData_Handler.wrapperDeductible4(coverage,wrapper,risk);
            }
        }
        return coverage;
    }
    /**
     * @description Ambil coverage existing
     * @param riskId : ID Risk
     * @return List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure> list coverage
     */
    @AuraEnabled(cacheable=false)
    public static List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure> getExistingCoverage(String riskId) {
        List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure> results = new List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure>();
        List<InsurancePolicyCoverage> existingCoverageList = [
            SELECT Id,CoverageName,Coverage_Name__c,
            Coverage_Name__r.COVERAGE_REF_ID__c,Proposed_Fixed_Amount__c,Selected_Coverages_ID__c,
            Deductible_Type__c,DeductibleAmount,Deductible_PCT__c,Deductible__c,
            Minimum_Cur_ID__c,Description,Description__c,Minimum_Amount__c,
            Discount__c,Commision__c,Banks_Fee_Comission__c,Risk_Closing_Survey_Fee_BSP__c,
            Leasing_Fee__c,Overdng_Comission__c,Agent_Comission__c,Broker_Comission__c,Finance_Commision_PCT__c
            FROM InsurancePolicyCoverage
            WHERE Risk_ID__c = :riskId
            WITH SECURITY_ENFORCED
        ];
        for (InsurancePolicyCoverage cfg : existingCoverageList) {
            Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure config = new Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure();
            config.coverageId = cfg.Coverage_Name__r.COVERAGE_REF_ID__c;
            config.coverageName = cfg.CoverageName;
            config.rate.coverageRate = cfg.Proposed_Fixed_Amount__c;
            config.deductible.deductibleSetting = cfg.Deductible_Type__c;
            if(cfg.Deductible_Type__c == 'FLAT'){
                config.deductible.deductibleAmount = cfg.DeductibleAmount;
            }else{
                config.deductible.deductibleAmount = cfg.Deductible_PCT__c;
            }
            config.deductible.deductibleFlag = cfg.Deductible__c;
            config.deductible.currencyName = cfg.Minimum_Cur_ID__c;
            config.deductible.descriptionDeductible = cfg.Description;
            config.deductible.descriptionValue = cfg.Description__c;
            config.deductible.minimumAmount = cfg.Minimum_Amount__c;
            config.rebate.discountValue = cfg.Discount__c;
            config.rebate.commissionValue = cfg.Commision__c;
            config.rebate.bankFeeValue = cfg.Banks_Fee_Comission__c;
            config.rebate.bspValue = cfg.Risk_Closing_Survey_Fee_BSP__c;
            config.rebate.leasingValue = cfg.Leasing_Fee__c;
            config.rebate.overridingValue = cfg.Overdng_Comission__c;
            config.rebate.agentCommissionValue = cfg.Agent_Comission__c;
            config.rebate.brokerCommissionValue = cfg.Broker_Comission__c;
            config.rebate.financialCommissionValue = cfg.Finance_Commision_PCT__c;
            config.existing.idCoverage = cfg.Id;
            config.existing.listSelectedId = cfg.Selected_Coverages_ID__c;
            String modeCoverage = 'COMPOSITE';
            if(!cfg.CoverageName.contains('+')){
                modeCoverage = 'BREAKDOWN_DEDUCTIBLE';
            }
            config.existing.coverageSetting = modeCoverage;
            results.add(config);
        }
        return results;
    }
    /**
     * @description Ambil coverage configuration data dari Master_Data__c berdasarkan Record Type dan COB ID,
     * dan di gunakan untuk inisialisasi data LWC input COverage
     * @param rtId : ID RecordType dari master data untuk di filter
     * @param cob : BSN_ID__c value (COB ID) digunakan untuk filtering Master_Data__c configs.
     * @param riskId : id risk
     * @return List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfig> sebuah list wrapper yang berisi value dari Master Data berdasarkan filter.
     */
    @AuraEnabled(cacheable=true)
    public static List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfig> getCoverageFields(String rtId, String cob,String riskId) {
        List<Decimal> sectionList = new List<Decimal>();
        List<Asset> assetRisk = [
            SELECT Id, Name, Section__r.Section__c
            FROM Asset
            WHERE ParentId = :riskId
            WITH SECURITY_ENFORCED
        ];
        for (Asset detailAsset : assetRisk) {
            sectionList.add(detailAsset.Section__r.Section__c);
        }

        List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfig> results = new List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfig>();
        List<Master_Data__c> configs = new List<Master_Data__c>();
        if(cob == '301'){
            configs = [
                SELECT Id,Name,COVERAGE_REF_ID__c,PARENT_COVERAGE_ID__c
                FROM Master_Data__c WHERE BSN_ID__c = :cob
                AND RecordTypeId = :rtId AND Asset_Section__c = null
                WITH SECURITY_ENFORCED
                ORDER BY PARENT_COVERAGE_ID__c,COVERAGE_REF_ID__c
            ];
        }else{
            configs = [
                SELECT Id,Name,COVERAGE_REF_ID__c,PARENT_COVERAGE_ID__c
                FROM Master_Data__c WHERE BSN_ID__c = :cob
                AND RecordTypeId = :rtId AND PARENT_COVERAGE_ID__c != '0' AND Asset_Section__c = null
                WITH SECURITY_ENFORCED
                ORDER BY COVERAGE_REF_ID__c
            ];
        }
        if (configs.isEmpty()) {
            return results;
        }
        List<Id> covIds = new List<Id>();
        for (Master_Data__c cfg : configs) {
            covIds.add(cfg.Id);
        }
        RecordType rtCovRate = [
            SELECT Id, Name FROM RecordType
            WHERE SobjectType = 'Master_Data__c' AND Name = 'Coverage Rate'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        List<Master_Data__c> coverageRateList = [
            SELECT Id,Coverage__c,Occupy__c,Name,Tarif_Bawah__c,PARENT_COVERAGE_ID__c
            FROM Master_Data__c
            WHERE RecordTypeId = :rtCovRate.Id AND Coverage__c IN :covIds
            WITH SECURITY_ENFORCED
        ];
        Map<Id, Master_Data__c> coverageRateMap = new Map<Id, Master_Data__c>();
        for (Master_Data__c covRate : coverageRateList) {
            coverageRateMap.put(covRate.Coverage__c, covRate);
        }
        for (Master_Data__c cfg : configs) {
            Master_Data__c covRate = coverageRateMap.get(cfg.Id);
            Decimal tarifBawahValue = 0;
            if (covRate != null && covRate.Tarif_Bawah__c != null) {
                tarifBawahValue = covRate.Tarif_Bawah__c * 100;
            }
            Aswata_Coverage_Data_Wrapper.DynamicFieldConfig configField = new Aswata_Coverage_Data_Wrapper.DynamicFieldConfig();
            configField.coverageId = cfg.COVERAGE_REF_ID__c;
            configField.parentCoverageId = cfg.PARENT_COVERAGE_ID__c;
            configField.coverageName = cfg.Name;
            configField.batasBawah = tarifBawahValue;
            configField.sectionList = sectionList;
            results.add(configField);
        }
        return results;
    }
    /**
     * @description function untuk mendapatkan picklist value Deductible Flag dari InsurancePolicyCoverage.
     * @return List<Map<String, String>> sebuah list wrapper yang sudah dimapping label dan value untuk dropdown item
     */
    @AuraEnabled(cacheable=true)
    public static Aswata_Coverage_Data_Wrapper.PicklistWrapper getDeductiblePicklistValues() {
        Aswata_Coverage_Data_Wrapper.PicklistWrapper results = new Aswata_Coverage_Data_Wrapper.PicklistWrapper();
        results.deductibleOptions = new List<Map<String, String>>();
        results.currencyOptions = new List<Map<String, String>>();
        Schema.DescribeFieldResult ddtibleField = InsurancePolicyCoverage.Deductible__c.getDescribe();
        for (Schema.PicklistEntry f : ddtibleField.getPicklistValues()) {
            Map<String, String> option = new Map<String, String>{
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            results.deductibleOptions.add(option);
        }
        Schema.DescribeFieldResult curField = Opportunity.Cur__c.getDescribe();
        for (Schema.PicklistEntry f : curField.getPicklistValues()) {
            Map<String, String> option = new Map<String, String>{
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            results.currencyOptions.add(option);
        }
        return results;
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
     * @description function for get Record Type Exchange Rate
     * @return recordType
     */
    public static RecordType queryRecordType() {
        SOQL_SOBJECT.SOQL_Param sp = new SOQL_SOBJECT.SOQL_Param();
        sp.sobjectName = 'RecordType';
        sp.condition = 'SobjectType = \'Master_Data__c\' AND Name = \'Exchange Rate\'';
        sp.fields = 'Id, Name';
        String dpquery = SOQL_SOBJECT.SOQL(sp)+' WITH SECURITY_ENFORCED LIMIT 1';
        RecordType rtExRate = Database.query(dpquery);
        // RecordType rtExRate = [
        //     SELECT Id, Name
        //     FROM RecordType
        //     WHERE SobjectType = 'Master_Data__c' AND Name = 'Exchange Rate'
        //     WITH SECURITY_ENFORCED LIMIT 1
        // ];
        return rtExRate;
    }
    /**
     * @description function for get Asset by RiskId
     * @param riskId
     * @return Asset
     */
    public static Asset queryAssetByRiskId(String riskId) {
        SOQL_SOBJECT.SOQL_Param sp = new SOQL_SOBJECT.SOQL_Param();
        sp.sobjectName = 'Asset';
        sp.condition = 'Id = :riskId';
        sp.fields = 'Id, Amount_Insured__c, Opportunity__c,COB__c,Model__c';
        sp.addField = ',Opportunity__r.Busreq_ID__c,Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c';
        String dpquery = SOQL_SOBJECT.SOQL(sp)+' WITH SECURITY_ENFORCED LIMIT 1';
        Asset rawData = Database.query(dpquery);
        // Asset risk = [
        //     SELECT Id, Amount_Insured__c, Opportunity__c,
        //     COB__c,
        //     Opportunity__r.Busreq_ID__c,Model__c,
        //     Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c
        //     FROM Asset
        //     WHERE Id = :riskId
        //     WITH SECURITY_ENFORCED
        // ];
        return rawData;
    }
}