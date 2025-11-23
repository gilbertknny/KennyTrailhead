/**
 * @description       : PDF Quotation
 * @author            : Febrian
 * @last modified on  : 11-23-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class QuotationVFPController {
    /** @description multiRisk */
    public Boolean multiRisk { get; private set; }
    /** @description pdfPage */
    public Decimal totalPertanggungan { get; private set; }
    /** @description risk */
    public Asset risk { get; private set; }
    /** @description quoteRecord */
    public Quote quoteRecord { get; private set; }
    /** @description policyCoverage */
    // public List<InsurancePolicyCoverage> policyCoverage { get; private set; }
    /** @description quotationDetail Multi */
    public List<Aswata_QuotationSlip_Wrapper.QuotationWrapper> quotationDetails { get; set; }
    /** @description quotationDetail Single */
    public Aswata_QuotationSlip_Wrapper.QuotationWrapper quotationDetailSingle { get; set; }
    /**
     * @description function constructor
     */
    public QuotationVFPController() {
        Id quoteId = ApexPages.currentPage().getParameters().get('id');
        if (quoteId != null) {
            this.quoteRecord = [
                SELECT OpportunityId, Administration_Cost__c, Stamp_Duty__c, Opportunity.COB__c
                FROM Quote
                WHERE Id = :quoteId
                WITH SECURITY_ENFORCED LIMIT 1
            ];
        }
    }
    /**
     * @description function redirectToPdf
     * @return PageReference to Visual Force Page destination
     */
    public PageReference redirectToPdf() {
        PageReference pdfPage;
        String productCode = this.quoteRecord.Opportunity.COB__c;
        Boolean shouldRedirect = false;
        if (productCode != null) {
            if (productCode.contains('301')) {
                pdfPage = Page.Aswata_Quotation_Slip;
                shouldRedirect = true;
            }
        }
        if (shouldRedirect) {
            pdfPage.getParameters().put('id', this.quoteRecord.Id);
            return pdfPage.setRedirect(true);
        } else {
            generateQuotation201();
            return null;
        }
    }
    /**
     * @description function for generate PDF Quote
     */
    public void generateQuotation201(){
        String opptyId = this.quoteRecord.OpportunityId;
        // opptyId = '006MS000007hZJSYA2'; // single
        // opptyId = '006MS000007hgpbYAA'; //Multi Risk
        if (opptyId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quote tidak memiliki Opportunity.'));
            return;
        }
        quotationDetailSingle = new Aswata_QuotationSlip_Wrapper.QuotationWrapper();
        // --- Query Opportunity ---
        Aswata_QuotationSlip_Wrapper.TrxOpptyWrapper getOpportunity = Aswata_QuotationSlip_DataHandler.getOpportunityQuote(opptyId);
        quotationDetailSingle.opportunityData = getOpportunity.opp;
        quotationDetailSingle.monthsDiff = getOpportunity.monthsDifference;
        quotationDetailSingle.trxDataList = getOpportunity.trxDataList;
        quotationDetailSingle.insuredName = getOpportunity.insuredName;

        List<Asset> assetOppty = Aswata_QuotationSlip_DataHandler.queryRiskOppty(opptyId);
        // MULTI or SINGLE
        if(assetOppty.size()>1){
            handleMultiRiskQuote(assetOppty);
        }else{
            handleSingleRiskQuote(assetOppty);
        }
    }
    /**
     * @description function for generate PDF Quote Multi Risk
     * @param assetOppty
     */
    public void handleMultiRiskQuote(List<Asset> assetOppty){
        // System.debug('### AWT quotation Risk Multi');
        this.multiRisk = true;
        Map<Id, List<Aswata_QuotationSlip_Wrapper.CoverageRate>> riskToCoveragesMap = Aswata_QuotationSlip_DataHandler.generateCoverageMap(assetOppty);
        quotationDetails = new List<Aswata_QuotationSlip_Wrapper.QuotationWrapper>();
        Integer counter = 1;
        this.totalPertanggungan = 0;
        Decimal premiNonStock = 0;
        for(Asset risk: assetOppty){
            Aswata_QuotationSlip_Wrapper.QuotationWrapper wrapper = new Aswata_QuotationSlip_Wrapper.QuotationWrapper();
            wrapper.numberItem = counter;
            wrapper.riskIdQuote = risk.Id;
            wrapper.letakRisiko = risk.Address__c;
            wrapper.kelasKonstruksi = risk.Class__c;
            wrapper.jenisResiko = risk.Occupation_Description__c;
            wrapper.noKode = risk.Type__c;
            wrapper.uraianPertanggungan = risk.Name;
            Decimal amountPertanggungTemp = 0;
            if(risk.Amount__c!=null){
                amountPertanggungTemp = risk.Amount__c;
            }
            wrapper.amountPertanggungan = amountPertanggungTemp;
            totalPertanggungan+=amountPertanggungTemp;
            wrapper.amountInsured = risk.Amount_Insured__c;
            wrapper.riskCoverage = riskToCoveragesMap.get(risk.Id);
            if(risk.Amount_Insured__c != null && risk.Rate_All_Coverages__c != null){
                wrapper.totalPremi = risk.Amount_Insured__c * risk.Rate_All_Coverages__c / 100;
                premiNonStock += wrapper.totalPremi;
            }
            if (wrapper.riskCoverage != null) {
                wrapper.jumlahCoverage = wrapper.riskCoverage.size();
            } else {
                wrapper.jumlahCoverage = 1;
            }
            // System.debug('### AWT multi risk coverage '+riskToCoveragesMap.get(risk.Id));
            // wrapper.detailAsset = new List<DetailAsset>();
            quotationDetails.add(wrapper);
            counter++;
        }
        Aswata_QuotationSlip_Wrapper.QuotationWrapper calcTotalPremi = Aswata_QuotationSlip_DataHandler.getTotalPremiMulti(quoteRecord,assetOppty,premiNonStock);
        quotationDetailSingle.policyCoverage = calcTotalPremi.policyCoverage;
        quotationDetailSingle.totalAllRate = calcTotalPremi.totalAllRate;
        quotationDetailSingle.premiNonStockCalculated = calcTotalPremi.premiNonStockCalculated;
        quotationDetailSingle.stampDuty = calcTotalPremi.stampDuty;
        quotationDetailSingle.adminCost = calcTotalPremi.adminCost;
        quotationDetailSingle.totalPremi = calcTotalPremi.totalPremi;
        quotationDetailSingle.nominalTerbilang = calcTotalPremi.nominalTerbilang;
        // System.debug('### AWT quotationDetails '+quotationDetails);
    }
    /**
     * @description function for generate PDF Quote Single Risk
     * @param assetOppty
     */
    public void handleSingleRiskQuote(List<Asset> assetOppty){
        // System.debug('### AWT quotation Risk Single');
        List<Aswata_QuotationSlip_Wrapper.DetailAsset> listDetailAsset = Aswata_QuotationSlip_DataHandler.getListDetailAsset(assetOppty);
        this.multiRisk = false;
        this.risk = assetOppty[0];
        quotationDetailSingle.detailAsset = listDetailAsset;
        if(risk.Address__c != null){
            quotationDetailSingle.letakRisiko = risk.Address__r.Name + ', '+ risk.Address__r.City__r.Name+ ', '+ risk.Address__r.Country__r.Name+', '+ risk.Address__r.Zip_Code__r.Name;
        }
        quotationDetailSingle.kelasKonstruksi = risk.Class__c;
        quotationDetailSingle.jenisResiko = risk.Occupation_Description__c;
        quotationDetailSingle.noKode = risk.Occupation_Code__r.Occupy_Id__c;
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