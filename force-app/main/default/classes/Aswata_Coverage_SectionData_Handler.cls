/**
 * @description       : Data Handler per Section
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 01-02-2026
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_Coverage_SectionData_Handler {
    // /**
    //  * @description function for generate data rebate
    //  * @param coverage
    //  * @param wrapper list of Json String after deserialize
    //  * @param risk
    //  * @return InsurancePolicyCoverage
    //  */
    // public static InsurancePolicyCoverage wrapperRebate4(InsurancePolicyCoverage coverage,Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper,Asset risk){
    //     // coverage.Total_Rebate__c = wrapper.rebate.totalRebate;
    //     // coverage.Discount__c = wrapper.rebate.discountValue;
    //     // coverage.Commision__c = wrapper.rebate.commissionValue;
    //     // coverage.Banks_Fee_Comission__c = wrapper.rebate.bankFeeValue;
    //     // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebate.bspValue;
    //     // coverage.Leasing_Fee__c = wrapper.rebate.leasingValue;
    //     // coverage.Overdng_Comission__c = wrapper.rebate.overridingValue;
    //     // coverage.Agent_Comission__c = wrapper.rebate.agentCommissionValue;
    //     // coverage.Broker_Comission__c = wrapper.rebate.brokerCommissionValue;
    //     // coverage.Finance_Commision_PCT__c = wrapper.rebate.financialCommissionValue;
    //     if(wrapper.rebates[0] != null){
    //         // coverage.Total_Rebate__c = wrapper.rebates[0].totalRebate;
    //         // coverage.Discount__c = wrapper.rebates[0].discountValue;
    //         // coverage.Commision__c = wrapper.rebates[0].commissionValue;
    //         coverage.Banks_Fee_Section_2__c = wrapper.rebates[0].bankFeeValue;
    //         // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebates[0].bspValue;
    //         // coverage.Leasing_Fee__c = wrapper.rebates[0].leasingValue;
    //         coverage.Overdng_Comission_Section_2__c = wrapper.rebates[0].overridingValue;
    //         coverage.Agent_Comission_Section_2__c = wrapper.rebates[0].agentCommissionValue;
    //         coverage.Broker_Comission_Section_2__c = wrapper.rebates[0].brokerCommissionValue;
    //         // coverage.Finance_Commision_PCT__c = wrapper.rebates[0].financialCommissionValue;
    //     }
    //     if(wrapper.rebates[1] != null){
    //         // coverage.Total_Rebate__c = wrapper.rebates[1].totalRebate;
    //         // coverage.Discount__c = wrapper.rebates[1].discountValue;
    //         // coverage.Commision__c = wrapper.rebates[1].commissionValue;
    //         coverage.Banks_Fee_Section_3__c = wrapper.rebates[1].bankFeeValue;
    //         // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebates[1].bspValue;
    //         // coverage.Leasing_Fee__c = wrapper.rebates[1].leasingValue;
    //         coverage.Overdng_Comission_Section_3__c = wrapper.rebates[1].overridingValue;
    //         coverage.Agent_Comission_Section_3__c = wrapper.rebates[1].agentCommissionValue;
    //         coverage.Broker_Comission_Section_3__c = wrapper.rebates[1].brokerCommissionValue;
    //         // coverage.Finance_Commision_PCT__c = wrapper.rebates[1].financialCommissionValue;
    //     }
    //     if(wrapper.rebates[2] != null){
    //         // coverage.Total_Rebate__c = wrapper.rebates[2].totalRebate;
    //         // coverage.Discount__c = wrapper.rebates[2].discountValue;
    //         // coverage.Commision__c = wrapper.rebates[2].commissionValue;
    //         coverage.Banks_Fee_Section_4__c = wrapper.rebates[2].bankFeeValue;
    //         // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebates[2].bspValue;
    //         // coverage.Leasing_Fee__c = wrapper.rebates[2].leasingValue;
    //         coverage.Overdng_Comission_Section_4__c = wrapper.rebates[2].overridingValue;
    //         coverage.Agent_Comission_Section_4__c = wrapper.rebates[2].agentCommissionValue;
    //         coverage.Broker_Comission_Section_4__c = wrapper.rebates[2].brokerCommissionValue;
    //         // coverage.Finance_Commision_PCT__c = wrapper.rebates[2].financialCommissionValue;
    //     }
    //     return coverage;
    // }
    // /**
    //  * @description function for generate data deductible Section 2-4
    //  * @param coverage
    //  * @param wrapper list of Json String after deserialize
    //  * @param risk
    //  * @return InsurancePolicyCoverage
    //  */
    // public static InsurancePolicyCoverage wrapperDeductible4(InsurancePolicyCoverage coverage,Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper,Asset risk){
    //     // InsurancePolicyCoverage coverage = new InsurancePolicyCoverage();
    //     if(wrapper.deductibles[0]!=null){
    //         coverage.Deductible_Type_Section_2__c = wrapper.deductibles[0].deductibleSetting;
    //         coverage.Deductible_Section_2__c = wrapper.deductibles[0].deductibleFlag;
    //         coverage.Minimum_Cur_ID_Section_2__c = wrapper.deductibles[0].currencyName;
    //         if(wrapper.deductibles[0].deductibleSetting=='FLAT'){
    //             coverage.Deductible_Amount_Section_2__c = wrapper.deductibles[0].deductibleAmount;
    //             coverage.Deductible_PCT_Section_2__c = null;
    //         }else{
    //             coverage.Deductible_Amount_Section_2__c = null;
    //             coverage.Deductible_PCT_Section_2__c = wrapper.deductibles[0].deductibleAmount;
    //         }
    //         coverage.Minimum_Amount_Section_2__c = wrapper.deductibles[0].minimumAmount;
    //     }
    //     if(wrapper.deductibles[1]!=null){
    //         coverage.Deductible_Type_Section_3__c = wrapper.deductibles[1].deductibleSetting;
    //         coverage.Deductible_Section_3__c = wrapper.deductibles[1].deductibleFlag;
    //         coverage.Minimum_Cur_ID_Section_3__c = wrapper.deductibles[1].currencyName;
    //         if(wrapper.deductibles[1].deductibleSetting=='FLAT'){
    //             coverage.Deductible_Amount_Section_3__c = wrapper.deductibles[1].deductibleAmount;
    //             coverage.Deductible_PCT_Section_3__c = null;
    //         }else{
    //             coverage.Deductible_Amount_Section_3__c = null;
    //             coverage.Deductible_PCT_Section_3__c = wrapper.deductibles[1].deductibleAmount;
    //         }
    //         coverage.Minimum_Amount_Section_3__c = wrapper.deductibles[1].minimumAmount;
    //     }
    //     if(wrapper.deductibles[2]!=null){
    //         coverage.Deductible_Type_Section_4__c = wrapper.deductibles[2].deductibleSetting;
    //         coverage.Deductible_Section_4__c = wrapper.deductibles[2].deductibleFlag;
    //         coverage.Minimum_Cur_ID_Section_4__c = wrapper.deductibles[2].currencyName;
    //         if(wrapper.deductibles[2].deductibleSetting=='FLAT'){
    //             coverage.Deductible_Amount_Section_4__c = wrapper.deductibles[2].deductibleAmount;
    //             coverage.Deductible_PCT_Section_4__c = null;
    //         }else{
    //             coverage.Deductible_Amount_Section_4__c = null;
    //             coverage.Deductible_PCT_Section_4__c = wrapper.deductibles[2].deductibleAmount;
    //         }
    //         coverage.Minimum_Amount_Section_4__c = wrapper.deductibles[2].minimumAmount;
    //     }
    //     return coverage;
    // }
    /**
     * @description function for generate InsurancePolicyCoverage for 301
     * @param listCoverage list of InsurancePolicyCoverage
     * @param getByParentId
     * @return List<InsurancePolicyCoverage>
     */
    public static List<InsurancePolicyCoverage> getAmountInsuredfromAsset(List<InsurancePolicyCoverage> listCoverage,List<Asset> getByParentId){
        Decimal totalSumAsset = 0;
        Set<String> validAssetNames = new Set<String>{
            'CASCO',
            'NON STANDARD EQUIPMENT',
            'Box/Truck Bed/Container'
        };
        for (Asset ast : getByParentId) {
            if (ast.Category__r.Name != null && validAssetNames.contains(ast.Category__r.Name)) {
                if (ast.Amount_IDR_new__c != null) {
                    totalSumAsset += ast.Amount_IDR_new__c;
                }
            }
        }
        for (InsurancePolicyCoverage cov : listCoverage) {
            cov.amount_insured__c = totalSumAsset;
        }
        return listCoverage;
    }
    /**
     * @description function for mapping from asset to coverage
     * @param risk
     * @return List<Asset>
     */
    public static List<Asset> getAssetByParentId(Asset risk){
        List<Asset> getByParentId = [
            SELECT Id,Amount_Insured__c,Category__c,ParentId,Amount_IDR_new__c, Currency__r.Name,
            Indemnity_Type__c, Declare_Value__c, Category__r.Name
            FROM Asset
            WHERE ParentId = :risk.Id
            WITH SECURITY_ENFORCED
        ];
        return getByParentId;
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
}