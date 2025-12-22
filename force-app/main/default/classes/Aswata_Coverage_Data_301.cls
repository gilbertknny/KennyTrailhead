/**
 * @description       : Class for create new Coverage 301
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-11-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_Coverage_Data_301 {
    /**
     * @description function for generate InsurancePolicyCoverage for 301
     */
    public static String singleComposite {get; set;}
    /**
     * @description function for generate InsurancePolicyCoverage for 301
     * @param listCoverage list of InsurancePolicyCoverage
     * @param risk
     * @param idParentCoverage
     * @return InsurancePolicyCoverage
     */
    public static List<InsurancePolicyCoverage> coverageByAssetCategory(List<InsurancePolicyCoverage> listCoverage,Asset risk,List<String> idParentCoverage){
        // Decimal counter = 1;
        if((String)risk.COB__c != '301'){
            return listCoverage;
        }
        singleComposite = 'false';
        List<String> listCategoryId = new List<String>();
        List<Asset> getByParentId = getAssetByParentId(risk);
        List<InsurancePolicyCoverage> newListCoverage = listCoverage;
        if(getByParentId.isEmpty()){
            return newListCoverage;
        }
        for(Asset item: getByParentId){
            listCategoryId.add(item.Category__c);
        }
        Map<String, InsurancePolicyCoverage> coverageMap = generateCoverageMap(listCoverage);
        List<String> listCovId = generateListCoverageId(idParentCoverage,listCoverage);
        // System.debug('### AWT coverageMap : '+coverageMap);
        // System.debug('### AWT listCategoryId : '+listCategoryId);
        // System.debug('### AWT listCovId : '+listCovId);
        Map<String, Master_Data__c> mdCoverage301 = generateMasterDataCoverage(listCategoryId,listCovId);
        if(mdCoverage301 == null){
            return listCoverage;
        }
        // System.debug('### AWT mdCoverage301 : '+mdCoverage301);
        for(Asset assetItem : getByParentId){
            if(assetItem.Category__c == null){
                continue;
            }
            Master_Data__c matchingMasterData = mdCoverage301.get(assetItem.Category__c);
            if (matchingMasterData != null) {
                InsurancePolicyCoverage referenceCov = getReferenceCoverage(matchingMasterData, listCoverage, coverageMap);
                // System.debug('### AWT referenceCov : '+referenceCov);
                InsurancePolicyCoverage newCov = assignmentValue301(referenceCov.clone(false, true, false, false),matchingMasterData,assetItem);
                newCov.cov_tahun_id__c = listCoverage[0].cov_tahun_id__c;
                newListCoverage.add(newCov);
            }
        }
        return newListCoverage;
    }
    /**
     * @description function for mapping from asset to coverage
     * @param risk
     * @return List<Asset>
     */
    public static List<Asset> getAssetByParentId(Asset risk){
        List<Asset> getByParentId = [
            SELECT Id,Amount_Insured__c,Category__c,ParentId,Amount_IDR_new__c, Currency__r.Name,
            Indemnity_Type__c, Declare_Value__c
            FROM Asset
            WHERE ParentId = :risk.Id
            WITH SECURITY_ENFORCED
        ];
        return getByParentId;
    }
    /**
     * @description function for mapping from asset to coverage
     * @param newCov
     * @param matchingMasterData
     * @param assetItem
     * @return InsurancePolicyCoverage
     */
    public static InsurancePolicyCoverage assignmentValue301(InsurancePolicyCoverage newCov,Master_Data__c matchingMasterData,Asset assetItem){
        newCov.CoverageName = matchingMasterData.Name;
        newCov.Coverage_Name__c = matchingMasterData.Id;
        newCov.Coverage_Id__c = matchingMasterData.COVERAGE_REF_ID__c;
        newCov.amount_insured__c = assetItem.Amount_IDR_new__c;
        newCov.Currency__c = assetItem.Currency__r.Name;
        newCov.Claim_Options__c = getShortCode('indemnity',assetItem.Indemnity_Type__c);
        newCov.Claim_Loss_Amount__c = getSafeDecimal(assetItem.Declare_Value__c);
        newCov.Claim_UR_Id__c = getShortCode('currency',assetItem.Currency__r.Name);
        return newCov;
    }
    /**
     * @description function for mapping from asset to coverage
     * @param type
     * @param picklistValue
     * @return String
     */
    public static String getShortCode(String type,String picklistValue){
        if(type == 'indemnity'){
            if (String.isBlank(picklistValue)) {
                return null;
            }
            String normalizedValue = picklistValue.toUpperCase().trim();
            if (normalizedValue.contains('FIRST LOSS')) {
                return 'FL';
            }else if (normalizedValue.contains('LOSS LIMIT')) {
                return 'LL';
            }else if (normalizedValue.contains('SUM INSURED')) {
                return 'SI';
            }
        }else{
            List<String> picklistCurrency = new List<String>();
            Schema.DescribeFieldResult ddtibleField = InsurancePolicyCoverage.Claim_UR_Id__c.getDescribe();
            for (Schema.PicklistEntry f : ddtibleField.getPicklistValues()) {
                picklistCurrency.add(f.getValue());
            }
            if(picklistCurrency.contains(picklistValue)){
                return picklistValue;
            }else{
                return 'IDR';
            }
        }
        return null;
    }
    /**
     * @description function for mapping from asset to coverage
     * @param dataValue
     * @return Decimal
     */
    public static Decimal getSafeDecimal(Decimal dataValue){
        if(dataValue == null){
            return 0;
        }
        return dataValue;
    }
    /**
     * @description function for get reference coverage Asset
     * @param matchingMasterData
     * @param listCoverage
     * @param coverageMap
     * @return InsurancePolicyCoverage
     */
    private static InsurancePolicyCoverage getReferenceCoverage(
        Master_Data__c matchingMasterData,
        List<InsurancePolicyCoverage> listCoverage,
        Map<String, InsurancePolicyCoverage> coverageMap)
    {
        if (singleComposite == 'true') {
            return listCoverage[0];
        } else {
            // System.debug('### AWT matchingMasterData.Coverage_301__c : '+matchingMasterData.Coverage_301__c);
            return coverageMap.get(matchingMasterData.Coverage_301__c);
        }
    }
    /**
     * @description function for get masterData Coverage 301
     * @param listCategoryId
     * @param listCovId
     * @return Map<String, Master_Data__c>
     */
    public static Map<String, Master_Data__c> generateMasterDataCoverage(List<String> listCategoryId,List<String> listCovId){
        Map<String, Master_Data__c> mdCoverage301 = new Map<String, Master_Data__c>();
        List<Master_Data__c> masterDataCov301 = [
            SELECT Id,Name,COVERAGE_REF_ID__c,Coverage_301__c,Asset_Category__c
            FROM Master_Data__c
            WHERE Asset_Category__c IN :listCategoryId AND Coverage_301__c IN :listCovId
            WITH SECURITY_ENFORCED
        ];
        if (masterDataCov301.isEmpty()){
            return null;
        }
        for(Master_Data__c item : masterDataCov301){
            mdCoverage301.put(item.Asset_Category__c, item);
        }
        return mdCoverage301;
    }
    /**
     * @description function for generate ListCoverageId
     * @param idParentCoverage
     * @param listCoverage
     * @return List<String>
     */
    public static List<String> generateListCoverageId(List<String> idParentCoverage,List<InsurancePolicyCoverage> listCoverage){
        List<String> listCovId = new List<String>();
        if(!idParentCoverage.isEmpty()){
            listCovId.addAll(idParentCoverage);
            singleComposite = 'true';
        }else{
            for(InsurancePolicyCoverage item: listCoverage){
                listCovId.add(item.Coverage_Name__c);
            }
        }
        return listCovId;
    }
    /**
     * @description function for generate ListCoverageId
     * @param listCoverage
     * @return Map<String, InsurancePolicyCoverage>
     */
    public static Map<String, InsurancePolicyCoverage> generateCoverageMap(List<InsurancePolicyCoverage> listCoverage){
        Map<String, InsurancePolicyCoverage> coverageMap = new Map<String, InsurancePolicyCoverage>();
        for (InsurancePolicyCoverage cov : listCoverage) {
            if (cov.Coverage_Name__c != null) {
                coverageMap.put(cov.Coverage_Name__c, cov);
            }
        }
        return coverageMap;
    }
    /**
     * @description function for generate ListCoverageId
     * @param coverageList
     * @param risk
     * @return Asset
     */
    public static Asset calculateAllRate(List<InsurancePolicyCoverage> coverageList,Asset risk){
        Asset updateRisk = risk;
        Decimal sumOfRate = 0;
        Decimal sumOfCommision = 0;
        Integer countCov = 0;
        for (InsurancePolicyCoverage coverage : coverageList) {
            Decimal currentRate = coverage.Proposed_Fixed_Amount__c;
            Decimal currentCommision = coverage.Commision__c;
            if (currentRate != null) {
                sumOfRate += currentRate;
            }
            if(currentCommision != null){
                sumOfCommision += currentCommision;
            }
            countCov++;
        }
        if (countCov > 0) {
            Decimal averageRate = sumOfRate / countCov;
            Decimal averageCommision = sumOfCommision / countCov;
            // System.debug('### AWT coverageList'+coverageList.size());
            // System.debug('### AWT sumOfRate'+sumOfRate+' - '+countCov);
            // System.debug('### AWT averageRate'+averageRate+' - '+averageCommision);
            // System.debug('### AWT updateRisk'+updateRisk.Model__c);
            updateRisk.Rate_All_Coverages__c  = averageRate;
            updateRisk.Commission_All_Coverages__c = averageCommision;
            return updateRisk;
        }
        return risk;
    }
}
// newCov.InsurancePolicyId = item.InsurancePolicyId;
// newCov.Opportunity__c = item.Opportunity__c;
// newCov.Risk_ID__c = item.Risk_ID__c;
// newCov.Propose_Rate__c = item.Propose_Rate__c;
// newCov.Coverage_Name__c = item.ProposeCoverage_Name__c_Rate__c;
// newCov.Proposed_Fixed_Amount__c = item.Proposed_Fixed_Amount__c;
// newCov.Premi_Amount__c = item.Premi_Amount__c;
// newCov.Deductible_Type__c = item.Deductible_Type__c;
// newCov.Deductible__c = item.Deductible__c;
// newCov.DeductibleAmount = item.DeductibleAmount;
// newCov.Minimum_Cur_ID__c = item.Minimum_Cur_ID__c;
// newCov.Deductible_PCT__c = item.Deductible_PCT__c;
// newCov.Description = item.Description;
// newCov.Description__c = item.Description__c;
// newCov.Minimum_Amount__c = item.Minimum_Amount__c;
// newCov.Total_Rebate__c = item.Total_Rebate__c;
// newCov.Discount__c = item.Discount__c;
// newCov.Commision__c = item.Commision__c;
// newCov.Banks_Fee_Comission__c = item.Banks_Fee_Comission__c;
// newCov.Risk_Closing_Survey_Fee_BSP__c = item.Risk_Closing_Survey_Fee_BSP__c;
// newCov.Profit_Sharing__c = item.Profit_Sharing__c;
// newCov.Leasing_Fee__c = item.Leasing_Fee__c;
// newCov.Overdng_Comission__c = item.Overdng_Comission__c;
// newCov.Agent_Comission__c = item.Agent_Comission__c;
// newCov.Broker_Comission__c = item.Broker_Comission__c;
// newCov.Finance_Commision_PCT__c = item.Finance_Commision_PCT__c;