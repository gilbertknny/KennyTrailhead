/**
 * @description       : Wrapper Coverage
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 01-02-2026
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_Coverage_Data_Wrapper {
    /** @description The wrapper for mapping dynamic fields need for input coverage */
    public class DynamicFieldConfigure {
        /** @description Coverage REF ID */
        @AuraEnabled public String coverageId   {get;set;}
        /** @description Section Id */
        @AuraEnabled public String coverageIdSection   {get;set;}
        /** @description coverage Name */
        @AuraEnabled public String coverageName {get;set;}
        /** @description batas bawah coverage */
        @AuraEnabled public Decimal batasBawah  {get;set;}
        /** @description wrapper coverage */
        @AuraEnabled public CoverageRate rate {get;set;}
        /** @description wrapper Deductible */
        @AuraEnabled public Deductible deductible {get;set;}
        /** @description wrapper Rebate */
        @AuraEnabled public Rebate rebate {get;set;}
        /** @description wrapper */
        @AuraEnabled public ExistingCoverage existing {get;set;}
        /** @description constructor */
        public DynamicFieldConfigure() {
            this.rate = new CoverageRate();
            this.deductible = new Deductible();
            this.rebate = new Rebate();
            this.existing = new ExistingCoverage();
        }
    }
    /** @description The wrapper for mapping dynamic fields need for input coverage */
    public class DynamicFieldConfig {
        /** @description ID referensi (COVERAGE_REF_ID__c) from coverage data */
        @AuraEnabled public String coverageId {get;set;}
        /** @description ID referensi (PARENT_COVERAGE_ID__c) from coverage data */
        @AuraEnabled public String parentCoverageId {get;set;}
        /** @description Name coverage from Master_Data__c */
        @AuraEnabled public String coverageName {get;set;}
        /** @description Nilai batas bawah or tarif dasar (Tarif_Bawah__c) from coverage */
        @AuraEnabled public Decimal batasBawah {get;set;}
        /** @description section Section No from detail asset */
        @AuraEnabled public String coverageIdSection {get;set;}
        /** @description section Id from detail asset */
        @AuraEnabled public String sectionId {get;set;}
        /** @description section Name from detail asset */
        @AuraEnabled public String sectionName {get;set;}
        /** @description section Number from detail asset */
        @AuraEnabled public Decimal sectionDisplay {get;set;}
        /** @description section from detail asset */
        @AuraEnabled public List<Decimal> sectionList {get;set;}
    }
    /** @description class wrapper for picklist value */
    public class PicklistWrapper {
        @AuraEnabled public List<Map<String, String>> deductibleOptions;
        @AuraEnabled public List<Map<String, String>> currencyOptions;
    }
    /** @description Class wrapper JSON String
     * all value JSON can deserialize with this wrapper
     */
    public class CoverageDetailWrapper {
        public String id;
        public Decimal covTahun;
        public String policyId;
        public String riskId;
        public String coverageId;
        public String sectionId;
        public String parentCoverageId;
        public String coverageName;
        public Decimal batasBawah;
        public String coverageSetting;
        public CoverageRate rate = new CoverageRate();
        public Deductible deductible = new Deductible();
        public Rebate rebate = new Rebate();
        // public List<Deductible> deductibles = new List<Deductible>();
        // public List<Rebate> rebates = new List<Rebate>();
        public ExistingCoverage existing = new ExistingCoverage();
    }
    /** @description class wrapper JSON String input CoverageRate */
    public class CoverageRate{
        /** @description fixAmount */
        @AuraEnabled public Decimal fixedAmount {get;set;}
        /** @description fixedAmount2 */
        @AuraEnabled public Decimal fixedAmount2 {get;set;}
        /** @description fixedAmount3 */
        @AuraEnabled public Decimal fixedAmount3 {get;set;}
        /** @description fixedAmount4 */
        @AuraEnabled public Decimal fixedAmount4 {get;set;}
        /** @description proposed rate section 1 */
        @AuraEnabled public Decimal coverageRate {get;set;}
        /** @description proposed rate section 2 */
        @AuraEnabled public Decimal coverageRate2 {get;set;}
        /** @description proposed rate section 3 */
        @AuraEnabled public Decimal coverageRate3 {get;set;}
        /** @description proposed rate section 4 */
        @AuraEnabled public Decimal coverageRate4 {get;set;}
        /** @description coverage rate */
        @AuraEnabled public String descriptionRate {get;set;}
    }
    /** @description class wrapper JSON String input Deductible */
    public class Deductible{
        /** @description deductible amount */
        @AuraEnabled public Decimal deductibleAmount {get;set;}
        /** @description minimum */
        @AuraEnabled public Decimal minimumAmount {get;set;}
        /** @description currencyId */
        @AuraEnabled public String currencyId {get;set;}
        /** @description currency Name */
        @AuraEnabled public String currencyName {get;set;}
        /** @description deductibleSetting single/breakdown */
        @AuraEnabled public String deductibleSetting {get;set;}
        /** @description flag Flat/Percentage */
        @AuraEnabled public String deductibleFlag {get;set;}
        /** @description description deductible */
        @AuraEnabled public String descriptionValue {get;set;}
        /** @description description deductible */
        @AuraEnabled public String descriptionDeductible {get;set;}
    }
    /** @description class wrapper JSON String input Rebate */
    public class Rebate{
        /** @description total rebate */
        @AuraEnabled public Decimal totalRebate {get;set;}
        /** @description profit */
        // @AuraEnabled public Decimal profitValue {get;set;}
        /** @description bsp */
        @AuraEnabled public Decimal bspValue {get;set;}
        /** @description overriding */
        @AuraEnabled public Decimal overridingValue {get;set;}
        /** @description leasing */
        @AuraEnabled public Decimal leasingValue {get;set;}
        /** @description bank fee */
        @AuraEnabled public Decimal bankFeeValue {get;set;}
        /** @description commision */
        @AuraEnabled public Decimal commissionValue {get;set;}
        /** @description agentCommissionValue */
        @AuraEnabled public Decimal agentCommissionValue {get;set;}
        /** @description brokerCommissionValue */
        @AuraEnabled public Decimal brokerCommissionValue {get;set;}
        /** @description financialCommissionValue */
        @AuraEnabled public Decimal financialCommissionValue {get;set;}
        /** @description discount */
        @AuraEnabled public Decimal discountValue {get;set;}
    }
    /** @description class wrapper JSON String Existing Coverage */
    public class ExistingCoverage{
        /** @description coverage Id */
        @AuraEnabled public String idCoverage {get;set;}
        /** @description list REF ID coverage */
        @AuraEnabled public String listSelectedId {get;set;}
        /** @description coverage setting BREAKDOWN/COMPOSITE */
        @AuraEnabled public String coverageSetting {get;set;}
    }
}