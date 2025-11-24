/**
 * @description       : List Wrapper PDF Quotation
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-22-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_QuotationSlip_Wrapper {
    /** @description Parent Class */
    public virtual class BaseQuotationData {
        /** @description numberItem */
        public Integer numberItem { get; set; }
        /** @description opportunityData */
        public Opportunity opportunityData { get; set; }
        /** @description monthsDiff */
        public Integer monthsDiff { get; set; }
        /** @description trxDataList */
        public List<Transaction_Data__c> trxDataList { get; set; }
        /** @description risk */
        public Asset risk { get; set; }
        /** @description premiNonStockCalculated */
        public Decimal premiNonStockCalculated { get; set; }
        /** @description stampDuty */
        public Decimal stampDuty { get; set; }
        /** @description adminCost */
        public Decimal adminCost { get; set; }
        /** @description totalPremi */
        public Decimal totalPremi { get; set; }
        /** @description nominalTerbilang */
        public String nominalTerbilang { get; set; }
        /** @description amountInsured */
        public Decimal amountInsured { get; set; }
        /** @description totalAllRate */
        public Decimal totalAllRate { get; set; }
        /** @description jumlahCoverage */
        public Integer jumlahCoverage { get; set; }
        /** @description uraianPertanggungan */
        public String uraianPertanggungan { get; set; }
        /** @description amountPertanggungan */
        public Decimal amountPertanggungan { get; set; }
        /** @description insuredName */
        public String insuredName { get; set; }
        /** @description policyCoverage */
        public List<InsurancePolicyCoverage> policyCoverage { get; set; }
        /** @description detailAsset */
        public List<DetailAsset> detailAsset { get; set; }
        /** @description riskCoverage */
        public List<CoverageRate> riskCoverage { get; set; }
    }
    /** @description wrapper quotation COB 201 */
    public class QuotationWrapper extends BaseQuotationData {
        /** @description riskIdQuote */
        public String riskIdQuote { get; set; }
        /** @description letakRisiko */
        public String letakRisiko { get; set; }
        /** @description kelasKonstruksi */
        public String kelasKonstruksi { get; set; }
        /** @description jenisResiko */
        public String jenisResiko { get; set; }
        /** @description noKode */
        public String noKode { get; set; }
    }
    /** @description wrapper quotation COB 301 */
    public class QuotationWrapper301 extends BaseQuotationData {
        /** @description qqName */
        public String qqName { get; set; }
        /** @description platNomorPolisi */
        public String platNomorPolisi { get; set; }
        /** @description merkTypeKendaraan */
        public String merkTypeKendaraan { get; set; }
        /** @description noMesinRangkaKendaraan */
        public String noMesinRangkaKendaraan { get; set; }
        /** @description jenisKendaraan */
        public String jenisKendaraan { get; set; }
        /** @description tipePenggunaan */
        public String tipePenggunaan { get; set; }
        /** @description insuredAddress */
        public String insuredAddress { get; set; }
        /** @description perlengkapan */
        public List<PerlengkapanTambahan> perlengkapan { get; set; }
    }
    /** @description wrapper perlengkapan tambahan quote COB 301 */
    public class PerlengkapanTambahan{
        /** @description merk */
        public String merk { get; set; }
        /** @description curId */
        public String curId { get; set; }
        /** @description value */
        public Integer value { get; set; }
    }
    /** @description general wrapper Asset/Risk */
    public class DetailAsset{
        /** @description uraianPertanggungan */
        public String uraianPertanggungan { get; set; }
        /** @description amountPertanggungan */
        public Decimal amountPertanggungan { get; set; }
    }
    /** @description general wrapper Coverage */
    public class CoverageRate{
        /** @description riskId */
        public String riskId { get; set; }
        /** @description coverageName */
        public String coverageName { get; set; }
        /** @description premiFixedAmount */
        public Decimal premiFixedAmount { get; set; }
        /** @description deductibleAmountPct */
        public Decimal deductibleAmountPct { get; set; }
        /** @description totalPremi */
        public Decimal totalPremi { get; set; }
    }
    /** @description general wrapper Transaction Data */
    public class TrxOpptyWrapper{
        /** @description opp */
        public Opportunity opp { get; set; }
        /** @description monthsDifference */
        public Integer monthsDifference { get; set; }
        /** @description qqName */
        public String qqName { get; set; }
        /** @description insuredName */
        public String insuredName { get; set; }
        /** @description insuredAddress */
        public String insuredAddress { get; set; }
        /** @description trxDataList */
        public List<Transaction_Data__c> trxDataList { get; set; }
    }
}