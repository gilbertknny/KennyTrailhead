/**
 * @description       : Async Premi Calculation
 * @author            : Fikri Hailal
 * @last modified on  : 11-25-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_Async_PremiCalculation {
    /**
     * @description function future for calculation total premi
     * @param opportunityId
     */
    @future
    public static void aswataPremiCalculation(String opportunityId) {
        aswataPremiCalculation2(opportunityId);
    }
    /**
     * @description function for calculation total premi
     * @param opportunityId
     */
    public static void aswataPremiCalculation2(String opportunityId) {
        if(String.isNotBlank(opportunityId)){
            List<InsurancePolicyCoverage> lstAllCoverage = [
                SELECT id, Premi_Amount__c, Risk_ID__c,Discount__c
                    ,Commision__c,Agent_Comission__c,Banks_Fee_Comission__c
                    ,Leasing_Fee__c,Overdng_Comission__c,Risk_Closing_Survey_Fee_BSP__c
                    ,Broker_Comission__c,Total_Rebate__c,Finance_Commision_PCT__c
                    from InsurancePolicyCoverage
                WHERE Opportunity__c =: opportunityId and Premi_Amount__c != null
                WITH Security_Enforced
            ];

            List<OpportunityLineItem> lstOLI = [
                SELECT id, UnitPrice from OpportunityLineItem
                WHERE OpportunityId =: opportunityId
                WITH Security_Enforced LIMIT 1
            ];
            if (!lstAllCoverage.isEmpty()) {
                performUpdate(opportunityId,lstAllCoverage,lstOLI);
            }
        }
    }
    /**
     * @description function update total premi
     * @param opportunityId
     * @param lstAllCoverage
     * @param lstOLI
     */
    public static void performUpdate(
        String opportunityId,
        List<InsurancePolicyCoverage> lstAllCoverage,
        List<OpportunityLineItem> lstOLI
    ) {
        if (
            !Schema.sObjectType.Opportunity.isUpdateable() &&
            !Schema.sObjectType.OpportunityLineItem.isUpdateable()
        ){
            throw new SecurityException(
                'Insufficient permissions to access Asset or InsurancePolicyCoverage'
            );
        }
        CoverageDetailWrapper result = generateDetailCoverage(lstAllCoverage);
        CoverageDetailWrapper secondResult = generateDetailCoverage2(lstAllCoverage);
        Decimal totalPremi = result.totalPremi;
        Decimal totalDiscount = result.totalDiscount;
        Decimal totalCommision = result.totalCommision;
        Decimal totalAgentComm = result.totalAgentComm;
        Decimal totalBankFee = result.totalBankFee;
        Decimal totalLeasingFee = secondResult.totalLeasingFee;
        Decimal totalOverdng = secondResult.totalOverdng;
        Decimal totalRiskClosing = secondResult.totalRiskClosing;
        Decimal totalBrokerComm = secondResult.totalBrokerComm;
        Decimal totalRebate = secondResult.totalRebate;
        Decimal totalFinanceComm = secondResult.totalFinanceComm;
        // === Compute Averages ===
        Integer recordCount = lstAllCoverage.size();
        Decimal avgDiscount = totalDiscount / recordCount;
        Decimal avgCommision = totalCommision / recordCount;
        Decimal avgAgentComm = totalAgentComm / recordCount;
        Decimal avgBankFee = totalBankFee / recordCount;
        Decimal avgLeasingFee = totalLeasingFee / recordCount;
        Decimal avgOverdng = totalOverdng / recordCount;
        Decimal avgRiskClosing = totalRiskClosing / recordCount;
        Decimal avgBrokerComm = totalBrokerComm / recordCount;
        Decimal avgRebate = totalRebate / recordCount;
        Decimal avgFinanceComm = totalFinanceComm / recordCount;
        List<OpportunityLineItem> lstAddOli = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : lstOLI){
            oli.UnitPrice = totalPremi;
            lstAddOli.add(oli);
        }
        Database.update(lstAddOli, false);

        Opportunity opp = new Opportunity(
            Id = opportunityId,
            Amount = totalPremi,
            Discount__c = avgDiscount,
            Commision__c = avgCommision,
            Agent_Commission__c = avgAgentComm,
            Banks_Fee_Commission__c = avgBankFee,
            Leasings_Fee__c = avgLeasingFee,
            Overriding_Commission__c = avgOverdng,
            Risk_Closing_Survey_Fee_BSP__c = avgRiskClosing,
            Broker_Commission__c = avgBrokerComm,
            Total_Rebate__c = avgRebate,
            Finance_Commission_pct__c = avgFinanceComm
        );
        Database.update(opp, false);
    }
    /**
     * @description function for checkPermission Access
     * @param lstAllCoverage
     * @return CoverageDetailWrapper
     */
    public static CoverageDetailWrapper generateDetailCoverage(List<InsurancePolicyCoverage> lstAllCoverage){
        CoverageDetailWrapper result = new CoverageDetailWrapper();
        Decimal totalPremi = 0;
        Decimal totalDiscount = 0;
        Decimal totalCommision = 0;
        Decimal totalAgentComm = 0;
        Decimal totalBankFee = 0;
        for (InsurancePolicyCoverage cov : lstAllCoverage) {
            totalPremi += cov.Premi_Amount__c;
            totalDiscount += cov.Discount__c == null ? 0 : cov.Discount__c;
            totalCommision += cov.Commision__c == null ? 0 : cov.Commision__c;
            totalAgentComm += cov.Agent_Comission__c == null ? 0 : cov.Agent_Comission__c;
            totalBankFee += cov.Banks_Fee_Comission__c == null ? 0 : cov.Banks_Fee_Comission__c;
        }
        result.totalPremi = totalPremi;
        result.totalDiscount = totalDiscount;
        result.totalCommision = totalCommision;
        result.totalAgentComm = totalAgentComm;
        result.totalBankFee = totalBankFee;
        return result;
    }
    /**
     * @description function for checkPermission Access
     * @param lstAllCoverage
     * @return CoverageDetailWrapper
     */
    public static CoverageDetailWrapper generateDetailCoverage2(List<InsurancePolicyCoverage> lstAllCoverage){
        CoverageDetailWrapper result = new CoverageDetailWrapper();
        Decimal totalLeasingFee = 0;
        Decimal totalOverdng = 0;
        Decimal totalRiskClosing = 0;
        Decimal totalBrokerComm = 0;
        Decimal totalRebate = 0;
        Decimal totalFinanceComm = 0;

        for (InsurancePolicyCoverage cov : lstAllCoverage) {
            totalLeasingFee += cov.Leasing_Fee__c == null ? 0 : cov.Leasing_Fee__c;
            totalOverdng += cov.Overdng_Comission__c == null ? 0 : cov.Overdng_Comission__c;
            totalRiskClosing += cov.Risk_Closing_Survey_Fee_BSP__c == null ? 0 : cov.Risk_Closing_Survey_Fee_BSP__c;
            totalBrokerComm += cov.Broker_Comission__c == null ? 0 : cov.Broker_Comission__c;
            totalRebate += cov.Total_Rebate__c == null ? 0 : cov.Total_Rebate__c;
            totalFinanceComm += cov.Finance_Commision_PCT__c == null ? 0 : cov.Finance_Commision_PCT__c;
        }
        result.totalLeasingFee = totalLeasingFee;
        result.totalOverdng = totalOverdng;
        result.totalRiskClosing = totalRiskClosing;
        result.totalBrokerComm = totalBrokerComm;
        result.totalRebate = totalRebate;
        result.totalFinanceComm = totalFinanceComm;
        return result;
    }
    /**
     * @description Class wrapper
     */
    public class CoverageDetailWrapper {
        public Decimal totalPremi;
        public Decimal totalDiscount;
        public Decimal totalCommision;
        public Decimal totalAgentComm;
        public Decimal totalBankFee;
        public Decimal totalLeasingFee;
        public Decimal totalOverdng;
        public Decimal totalRiskClosing;
        public Decimal totalBrokerComm;
        public Decimal totalRebate;
        public Decimal totalFinanceComm;
    }
}