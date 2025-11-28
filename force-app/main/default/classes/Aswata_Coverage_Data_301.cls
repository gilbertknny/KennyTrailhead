/**
 * @description       : Class for create new Coverage 301
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-27-2025
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
        // System.debug('### AWT risk.COB__c : '+risk.COB__c);
        Integer lastIndex = listCoverage.size() - 1;
        Decimal counter = listCoverage[lastIndex].cov_tahun_id__c;
        if((String)risk.COB__c != '301'){
            return listCoverage;
        }
        singleComposite = 'false';
        List<String> listCategoryId = new List<String>();
        List<Asset> getByParentId = [
            SELECT Id,Amount_Insured__c,Category__c,ParentId,Amount_IDR_new__c
            FROM Asset
            WHERE ParentId = :risk.Id
            WITH SECURITY_ENFORCED
        ];
        List<InsurancePolicyCoverage> newListCoverage = listCoverage;
        if(getByParentId.isEmpty()){
            return newListCoverage;
        }
        for(Asset item: getByParentId){
            listCategoryId.add(item.Category__c);
        }
        Map<String, InsurancePolicyCoverage> coverageMap = generateCoverageMap(listCoverage);
        List<String> listCovId = generateListCoverageId(idParentCoverage,listCoverage);
        System.debug('### AWT coverageMap : '+coverageMap);
        System.debug('### AWT listCategoryId : '+listCategoryId);
        System.debug('### AWT listCovId : '+listCovId);
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
                InsurancePolicyCoverage referenceCov;
                if(singleComposite == 'true'){
                    referenceCov = listCoverage[0];
                }else{
                    referenceCov = coverageMap.get(matchingMasterData.Coverage_301__c);
                    // System.debug('### AWT matchingMasterData.Coverage_301__c : '+matchingMasterData.Coverage_301__c);
                    // System.debug('### AWT referenceCov : '+referenceCov);
                }
                InsurancePolicyCoverage newCov = referenceCov.clone(false, true, false, false);
                newCov.CoverageName = matchingMasterData.Name;
                newCov.Coverage_Name__c = matchingMasterData.Id;
                newCov.Coverage_Id__c = matchingMasterData.COVERAGE_REF_ID__c;
                newCov.amount_insured__c = assetItem.Amount_IDR_new__c;
                counter+=1;
                newCov.cov_tahun_id__c = counter;
                newListCoverage.add(newCov);
            }
        }
        return newListCoverage;
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