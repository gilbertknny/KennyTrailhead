/**
 * @description       : For Generate PDF Quotation Slip
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-23-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_QuotationSlip_Controller {
    /** @description multiRisk */
    public Boolean multiRisk { get; private set; }
    /** @description quoteRecord */
    public Quote quoteRecord { get; private set; }
    /** @description shouldRedirect */
    // public Boolean shouldRedirect { get; private set; }
    /** @description quotationDetails Multi*/
    public List<Aswata_QuotationSlip_Wrapper.QuotationWrapper301> quotationDetails { get; set; }
    /** @description quotationDetail Single */
    public Aswata_QuotationSlip_Wrapper.QuotationWrapper301 quotationDetailSingle {get;set;}
    /** @description totalPertanggungan */
    // public Decimal totalPertanggungan { get; private set; }
    /** @description risk */
    // public Asset risk { get; private set; }
    /**
     * @description function constructor
     */
    public Aswata_QuotationSlip_Controller() {
        Id quoteId = ApexPages.currentPage().getParameters().get('id');
        if (quoteId != null) {
            this.quoteRecord = [
                SELECT OpportunityId, Administration_Cost__c, Stamp_Duty__c, Opportunity.COB__c
                FROM Quote
                WHERE Id = :quoteId
                WITH SECURITY_ENFORCED LIMIT 1
            ];
        }
        generateQuotation301();
    }
    /**
     * @description function for generate PDF Quote COB 301
     */
    public void generateQuotation301(){
        quotationDetails = new List<Aswata_QuotationSlip_Wrapper.QuotationWrapper301>();
        quotationDetailSingle = new Aswata_QuotationSlip_Wrapper.QuotationWrapper301();
        String opptyId = this.quoteRecord.OpportunityId;
        // opptyId = '006MS000007owG7YAI';
        if (opptyId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quote tidak memiliki Opportunity.'));
            return;
        }
        Aswata_QuotationSlip_Wrapper.TrxOpptyWrapper getOpportunity = Aswata_QuotationSlip_DataHandler.getOpportunityQuote(opptyId);
        quotationDetailSingle.opportunityData = getOpportunity.opp;
        quotationDetailSingle.monthsDiff = getOpportunity.monthsDifference;
        quotationDetailSingle.qqName = getOpportunity.qqName;
        quotationDetailSingle.trxDataList = getOpportunity.trxDataList;
        quotationDetailSingle.insuredName = getOpportunity.insuredName;
        quotationDetailSingle.insuredAddress = getOpportunity.insuredAddress;
        List<Asset> assetOppty = Aswata_QuotationSlip_DataHandler.queryRiskOppty(opptyId);
        // List<Asset> assetOppty = [
        //     SELECT Id, Name, Address__c, Amount__c,
        //     Occupation_Code__r.Occupy_Id__c,
        //     Address__r.Name,
        //     Address__r.City__r.Name,
        //     Address__r.Country__r.Name,
        //     Address__r.Zip_Code__r.name,
        //     Total_Premi_Amount__c, Class__c, Occupation_Description__c,Type__c, Amount_Insured__c,
        //     Rate_All_Coverages__c,
        //     Opportunity__c, License_Plate_Number__c,
        //     vehicle_model_desc__c, Year_of_Manufacture__c,
        //     Color__c,  Engine_No__c, Chasis_No__c, Vehicle_Type__c,
        //     jenis_perlengkapan__c, Utilization__c
        //     FROM Asset
        //     WHERE Id = '02iMS000000Q7nVYAS'
        // ];
        // System.debug('### AWT quotation Risk Single'+assetOppty);
        if (assetOppty.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quote tidak memiliki Opportunity.'));
            return;
        }
        if(assetOppty.size()>1){
            handleMultiRiskQuote(assetOppty);
        }else{
            handleSingleRiskQuote(assetOppty);
        }
    }
    /**
     * @description function for get picklist label and value
     * @return Map<String,String>
     */
    public static Map<String, String> getPicklistLabel(){
        Map<String, String> valueToLabelMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Asset.Vehicle_Type__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            valueToLabelMap.put(entry.getValue(), entry.getLabel());
        }
        return valueToLabelMap;
    }
    /**
     * @description function for generate PDF Quote Multi Risk
     * @param assetOppty
     */
    public void handleMultiRiskQuote(List<Asset> assetOppty){
        // Map<String, String> valueToLabelMap = getPicklistLabel();
        this.multiRisk = true;
        quotationDetails.add(new Aswata_QuotationSlip_Wrapper.QuotationWrapper301());
    }
    /**
     * @description function for generate PDF Quote Multi Risk
     * @param assetOppty
     */
    public void handleSingleRiskQuote(List<Asset> assetOppty){
        Map<String, String> valueToLabelMap = getPicklistLabel();
        this.multiRisk = false;
        Asset risk = assetOppty[0];
        quotationDetailSingle.risk = risk;
        //
        List<Aswata_QuotationSlip_Wrapper.DetailAsset> listDetailAsset =Aswata_QuotationSlip_DataHandler.getListDetailAsset(assetOppty);
        quotationDetailSingle.platNomorPolisi = risk.License_Plate_Number__c;
        quotationDetailSingle.merkTypeKendaraan = risk.vehicle_model_desc__c+' / '+risk.Year_of_Manufacture__c+' / '+risk.Color__c;
        quotationDetailSingle.noMesinRangkaKendaraan = risk.Engine_No__c+' / '+risk.Chasis_No__c;
        quotationDetailSingle.jenisKendaraan = valueToLabelMap.get(risk.Vehicle_Type__c);
        if(risk.Utilization__c == 'P'){
            quotationDetailSingle.tipePenggunaan = 'Pribadi';
        }else{
            quotationDetailSingle.tipePenggunaan = 'Dinas';
        }
        quotationDetailSingle.detailAsset = listDetailAsset;
        // Perlengkapan Tambahan
        List<Aswata_QuotationSlip_Wrapper.PerlengkapanTambahan> listTambahan = new List<Aswata_QuotationSlip_Wrapper.PerlengkapanTambahan>();
        if(risk.jenis_perlengkapan__c!=null){
            List<Object> rawList = (List<Object>) JSON.deserializeUntyped(risk.jenis_perlengkapan__c);
            if (!rawList.isEmpty()) {
                for (Object rawItem : rawList) {
                    Map<String, Object> itemMap = (Map<String, Object>) rawItem;
                    Aswata_QuotationSlip_Wrapper.PerlengkapanTambahan wrapper = new Aswata_QuotationSlip_Wrapper.PerlengkapanTambahan();
                    wrapper.merk = (String) itemMap.get('merk');
                    wrapper.value = (Integer) itemMap.get('value');
                    wrapper.curId = (String) itemMap.get('cur_id');
                    listTambahan.add(wrapper);
                }
            }
        }
        quotationDetailSingle.perlengkapan = listTambahan;
        // Kondisi Pertanggungan
        quotationDetailSingle.uraianPertanggungan = risk.Name;
        Decimal amountPertanggungTemp = 0;
        if(risk.Amount__c!=null){
            amountPertanggungTemp = risk.Amount__c;
        }
        quotationDetailSingle.amountPertanggungan = amountPertanggungTemp;
        quotationDetailSingle.amountInsured = risk.Amount_Insured__c;
        // --- Query InsurancePolicyCoverage ---
        Aswata_QuotationSlip_Wrapper.QuotationWrapper calcTotalPremi = Aswata_QuotationSlip_DataHandler.getTotalPremi(risk,quoteRecord,assetOppty);
        quotationDetailSingle.policyCoverage = calcTotalPremi.policyCoverage;
        quotationDetailSingle.totalAllRate = calcTotalPremi.totalAllRate;
        quotationDetailSingle.premiNonStockCalculated = calcTotalPremi.premiNonStockCalculated;
        quotationDetailSingle.stampDuty = calcTotalPremi.stampDuty;
        quotationDetailSingle.adminCost = calcTotalPremi.adminCost;
        quotationDetailSingle.totalPremi = calcTotalPremi.totalPremi;
        quotationDetailSingle.nominalTerbilang = calcTotalPremi.nominalTerbilang;
    }
}