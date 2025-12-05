/**
 * @description       : Class for create new Coverage 301
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-05-2025
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
        Decimal counter = 1;
        // if((String)risk.COB__c != '301'){
        //     return listCoverage;
        // }
        singleComposite = 'false';
        List<String> listCategoryId = new List<String>();
        List<Asset> getByParentId = [
            SELECT Id,Amount_Insured__c,Category__c,ParentId,Amount_IDR_new__c, Currency__r.Name
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
                InsurancePolicyCoverage newCov = referenceCov.clone(false, true, false, false);
                newCov.CoverageName = matchingMasterData.Name;
                newCov.Coverage_Name__c = matchingMasterData.Id;
                newCov.Coverage_Id__c = matchingMasterData.COVERAGE_REF_ID__c;
                newCov.amount_insured__c = assetItem.Amount_IDR_new__c;
                newCov.Currency__c = assetItem.Currency__r.Name;
                // counter+=1;
                newCov.cov_tahun_id__c = counter;
                newListCoverage.add(newCov);
            }
        }
        return newListCoverage;
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
     * @description Menghitung durasi antara tanggal mulai dan tanggal akhir dalam tahun.
     * @param listCoverage
     * @param risk
     * @return List<InsurancePolicyCoverage>
     */
    public static List<InsurancePolicyCoverage> calculateDurationInYears(List<InsurancePolicyCoverage> listCoverage,Asset risk) {
        List<InsurancePolicyCoverage> newListCoverage = listCoverage;
        Date startDate = risk.Opportunity__r.Start_Date_Periode__c;
        Date endDate = risk.Opportunity__r.End_Date_Periode__c;
        Decimal counter = 1;
        if (startDate == null || endDate == null) {
            return newListCoverage;
        }
        Integer durationInYears = calculationYears(risk);
        if (durationInYears <= 1) {
            return newListCoverage;
        }else{
            counter = durationInYears;
        }
        List<InsurancePolicyCoverage> coverageToDuplicate = newListCoverage.clone();
        List<String> check301Cov = generateListMasterCov301(newListCoverage);
        for (Integer i = 2; i <= counter; i++) {
            for (InsurancePolicyCoverage originalCoverage : coverageToDuplicate) {
                if (!check301Cov.isEmpty() && !check301Cov.contains(originalCoverage.Coverage_Name__c)) {
                    InsurancePolicyCoverage duplicatedCoverage = originalCoverage.clone(false, true, false, false);
                    duplicatedCoverage.cov_tahun_id__c = i;
                    newListCoverage.add(duplicatedCoverage);
                }
            }
        }
        return newListCoverage;
    }
    /**
     * @description function for calculate Years Period
     * @param risk
     * @return Integer
     */
    public static Integer calculationYears(Asset risk){
        Date startDate = risk.Opportunity__r.Start_Date_Periode__c;
        Date endDate = risk.Opportunity__r.End_Date_Periode__c;
        Integer durationInYears = endDate.year() - startDate.year();
        Integer extraMonths = endDate.month() - startDate.month();
        if (endDate.day() < startDate.day()) {
            extraMonths--;
        }
        if (extraMonths < 0) {
            durationInYears--;
            extraMonths += 12;
        }
        if (extraMonths > 5) {
            durationInYears += 1;
        }
        return durationInYears;
    }
    /**
     * @description function for get masterData Coverage 301
     * @param newListCoverage
     * @return List<String>
     */
    public static List<String> generateListMasterCov301(List<InsurancePolicyCoverage> newListCoverage){
        List<Id> coverageNameId = new List<Id>();
        for (InsurancePolicyCoverage originalCoverage : newListCoverage) {
            coverageNameId.add(originalCoverage.Coverage_Name__c);
        }
        List<Master_Data__c> check301Cov = [
            SELECT Id,Name,COVERAGE_REF_ID__c,
            PARENT_COVERAGE_ID__c,Coverage_301__c,Asset_Category__c
            FROM Master_Data__c
            WHERE Id IN :coverageNameId AND PARENT_COVERAGE_ID__c = '0'
            WITH SECURITY_ENFORCED
        ];
        Set<String> mdCoverage301Set = new Set<String>();
        for (Master_Data__c mdCov301 : check301Cov) {
            mdCoverage301Set.add(mdCov301.Id);
        }
        List<String> mdCoverage301List = new List<String>(mdCoverage301Set);
        return mdCoverage301List;
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