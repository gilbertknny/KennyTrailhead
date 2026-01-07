/**
 * @description       : Class for create new Coverage 301
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 01-06-2026
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
        List<Asset> getByParentId = Aswata_Coverage_SectionData_Handler.getAssetByParentId(risk);
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
        newListCoverage = Aswata_Coverage_SectionData_Handler.getAmountInsuredfromAsset(newListCoverage,getByParentId);
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
        newCov.Claim_Options__c = Aswata_Coverage_SectionData_Handler.getShortCode('indemnity',assetItem.Indemnity_Type__c);
        newCov.Claim_Loss_Amount__c = Aswata_Coverage_SectionData_Handler.getSafeDecimal(assetItem.Declare_Value__c);
        newCov.Claim_UR_Id__c = Aswata_Coverage_SectionData_Handler.getShortCode('currency',assetItem.Currency__r.Name);
        return newCov;
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
    /**
     * @description function for generate ListCoverageId
     * @param coverageList
     * @param risk
     * @return List<InsurancePolicyCoverage>
     */
    public static List<InsurancePolicyCoverage> getExistingIdCoverage(List<InsurancePolicyCoverage> coverageList,Asset risk){
        List<String> listCovMasterData = new List<String>();
        for (InsurancePolicyCoverage cov : coverageList) {
            if(cov.Coverage_Name__c!=null){
                listCovMasterData.add(cov.Coverage_Name__c);
            }
        }
        List<InsurancePolicyCoverage> existingCoverage = [
            SELECT Id,CoverageName,Coverage_Name__c,cov_tahun_id__c,Master_Data__c
            FROM InsurancePolicyCoverage
            WHERE (Coverage_Name__c IN :listCovMasterData OR CoverageName LIKE '%+%')
            AND Risk_ID__c =: risk.Id
            WITH SECURITY_ENFORCED
        ];
        if(existingCoverage.isEmpty()){
            return coverageList;
        }
        return applyExistingIds(coverageList, existingCoverage);
    }
    /**
     * @description function for generate ListCoverageId
     * @param coverageList
     * @param existingCoverage
     * @return List<InsurancePolicyCoverage>
     */
    public static List<InsurancePolicyCoverage> applyExistingIds(List<InsurancePolicyCoverage> coverageList, List<InsurancePolicyCoverage> existingCoverage) {
        Map<String,String> mappExistingCoverage = new Map<String,String>();
        for (InsurancePolicyCoverage cov : existingCoverage) {
            String covTahun = String.valueOf(cov.cov_tahun_id__c);
            String keySection = cov.Coverage_Name__c+ '-'+ covTahun+'-'+ cov.Master_Data__c;
            System.debug('cov.Coverage_Name__c+keySection : '+keySection);
            if(cov.Coverage_Name__c!=null){
                mappExistingCoverage.put(keySection,cov.Id);
            }else if(cov.CoverageName.contains('+')){
                mappExistingCoverage.put('Single-'+covTahun,cov.Id);
            }
        }
        for (InsurancePolicyCoverage cov : coverageList) {
            String covTahun = String.valueOf(cov.cov_tahun_id__c);
            String keySection = cov.Coverage_Name__c+ '-'+ covTahun+'-'+ cov.Master_Data__c;
            System.debug('tryGetId with keySection : '+keySection);
            if (mappExistingCoverage.containsKey(keySection)) {
                cov.Id = mappExistingCoverage.get(keySection);
            } else if (cov.CoverageName != null && cov.CoverageName.contains('+')) {
                cov.Id = mappExistingCoverage.get('Single-'+covTahun);
            }
        }
        return coverageList;
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