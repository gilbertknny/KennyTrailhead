/**
 * @description       : Data Handler per Section
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-17-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_Coverage_SectionData_Handler {
    /**
     * @description function for generate data rebate
     * @param coverage
     * @param wrapper list of Json String after deserialize
     * @param risk
     * @return InsurancePolicyCoverage
     */
    public static InsurancePolicyCoverage wrapperRebate4(InsurancePolicyCoverage coverage,Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper,Asset risk){
        // coverage.Total_Rebate__c = wrapper.rebate.totalRebate;
        // coverage.Discount__c = wrapper.rebate.discountValue;
        // coverage.Commision__c = wrapper.rebate.commissionValue;
        // coverage.Banks_Fee_Comission__c = wrapper.rebate.bankFeeValue;
        // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebate.bspValue;
        // coverage.Leasing_Fee__c = wrapper.rebate.leasingValue;
        // coverage.Overdng_Comission__c = wrapper.rebate.overridingValue;
        // coverage.Agent_Comission__c = wrapper.rebate.agentCommissionValue;
        // coverage.Broker_Comission__c = wrapper.rebate.brokerCommissionValue;
        // coverage.Finance_Commision_PCT__c = wrapper.rebate.financialCommissionValue;
        if(wrapper.rebates[0] != null){
            // coverage.Total_Rebate__c = wrapper.rebates[0].totalRebate;
            // coverage.Discount__c = wrapper.rebates[0].discountValue;
            // coverage.Commision__c = wrapper.rebates[0].commissionValue;
            coverage.Banks_Fee_Section_2__c = wrapper.rebates[0].bankFeeValue;
            // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebates[0].bspValue;
            // coverage.Leasing_Fee__c = wrapper.rebates[0].leasingValue;
            coverage.Overdng_Comission_Section_2__c = wrapper.rebates[0].overridingValue;
            coverage.Agent_Comission_Section_2__c = wrapper.rebates[0].agentCommissionValue;
            coverage.Broker_Comission_Section_2__c = wrapper.rebates[0].brokerCommissionValue;
            // coverage.Finance_Commision_PCT__c = wrapper.rebates[0].financialCommissionValue;
        }
        if(wrapper.rebates[1] != null){
            // coverage.Total_Rebate__c = wrapper.rebates[1].totalRebate;
            // coverage.Discount__c = wrapper.rebates[1].discountValue;
            // coverage.Commision__c = wrapper.rebates[1].commissionValue;
            coverage.Banks_Fee_Section_3__c = wrapper.rebates[1].bankFeeValue;
            // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebates[1].bspValue;
            // coverage.Leasing_Fee__c = wrapper.rebates[1].leasingValue;
            coverage.Overdng_Comission_Section_3__c = wrapper.rebates[1].overridingValue;
            coverage.Agent_Comission_Section_3__c = wrapper.rebates[1].agentCommissionValue;
            coverage.Broker_Comission_Section_3__c = wrapper.rebates[1].brokerCommissionValue;
            // coverage.Finance_Commision_PCT__c = wrapper.rebates[1].financialCommissionValue;
        }
        if(wrapper.rebates[2] != null){
            // coverage.Total_Rebate__c = wrapper.rebates[2].totalRebate;
            // coverage.Discount__c = wrapper.rebates[2].discountValue;
            // coverage.Commision__c = wrapper.rebates[2].commissionValue;
            coverage.Banks_Fee_Section_4__c = wrapper.rebates[2].bankFeeValue;
            // coverage.Risk_Closing_Survey_Fee_BSP__c = wrapper.rebates[2].bspValue;
            // coverage.Leasing_Fee__c = wrapper.rebates[2].leasingValue;
            coverage.Overdng_Comission_Section_4__c = wrapper.rebates[2].overridingValue;
            coverage.Agent_Comission_Section_4__c = wrapper.rebates[2].agentCommissionValue;
            coverage.Broker_Comission_Section_4__c = wrapper.rebates[2].brokerCommissionValue;
            // coverage.Finance_Commision_PCT__c = wrapper.rebates[2].financialCommissionValue;
        }
        return coverage;
    }
    /**
     * @description function for generate data deductible Section 2-4
     * @param coverage
     * @param wrapper list of Json String after deserialize
     * @param risk
     * @return InsurancePolicyCoverage
     */
    public static InsurancePolicyCoverage wrapperDeductible4(InsurancePolicyCoverage coverage,Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper,Asset risk){
        // InsurancePolicyCoverage coverage = new InsurancePolicyCoverage();
        if(wrapper.deductibles[0]!=null){
            coverage.Deductible_Type_Section_2__c = wrapper.deductibles[0].deductibleSetting;
            coverage.Deductible_Section_2__c = wrapper.deductibles[0].deductibleFlag;
            coverage.Minimum_Cur_ID_Section_2__c = wrapper.deductibles[0].currencyName;
            if(wrapper.deductibles[0].deductibleSetting=='FLAT'){
                coverage.Deductible_Amount_Section_2__c = wrapper.deductibles[0].deductibleAmount;
                coverage.Deductible_PCT_Section_2__c = null;
            }else{
                coverage.Deductible_Amount_Section_2__c = null;
                coverage.Deductible_PCT_Section_2__c = wrapper.deductibles[0].deductibleAmount;
            }
            coverage.Minimum_Amount_Section_2__c = wrapper.deductibles[0].minimumAmount;
        }
        if(wrapper.deductibles[1]!=null){
            coverage.Deductible_Type_Section_3__c = wrapper.deductibles[1].deductibleSetting;
            coverage.Deductible_Section_3__c = wrapper.deductibles[1].deductibleFlag;
            coverage.Minimum_Cur_ID_Section_3__c = wrapper.deductibles[1].currencyName;
            if(wrapper.deductibles[1].deductibleSetting=='FLAT'){
                coverage.Deductible_Amount_Section_3__c = wrapper.deductibles[1].deductibleAmount;
                coverage.Deductible_PCT_Section_3__c = null;
            }else{
                coverage.Deductible_Amount_Section_3__c = null;
                coverage.Deductible_PCT_Section_3__c = wrapper.deductibles[1].deductibleAmount;
            }
            coverage.Minimum_Amount_Section_3__c = wrapper.deductibles[1].minimumAmount;
        }
        if(wrapper.deductibles[2]!=null){
            coverage.Deductible_Type_Section_4__c = wrapper.deductibles[2].deductibleSetting;
            coverage.Deductible_Section_4__c = wrapper.deductibles[2].deductibleFlag;
            coverage.Minimum_Cur_ID_Section_4__c = wrapper.deductibles[2].currencyName;
            if(wrapper.deductibles[2].deductibleSetting=='FLAT'){
                coverage.Deductible_Amount_Section_4__c = wrapper.deductibles[2].deductibleAmount;
                coverage.Deductible_PCT_Section_4__c = null;
            }else{
                coverage.Deductible_Amount_Section_4__c = null;
                coverage.Deductible_PCT_Section_4__c = wrapper.deductibles[2].deductibleAmount;
            }
            coverage.Minimum_Amount_Section_4__c = wrapper.deductibles[2].minimumAmount;
        }
        return coverage;
    }
}