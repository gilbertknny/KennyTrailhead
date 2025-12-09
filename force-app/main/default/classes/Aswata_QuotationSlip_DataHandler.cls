/**
 * @description       : Data Handler Quotation
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-03-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_QuotationSlip_DataHandler {
    /**
     * @description function for Query Opportunity
     * @param opptyId opportunity Id
     * @return Aswata_QuotationSlip_Wrapper.TrxOpptyWrapper
     */
    public static Aswata_QuotationSlip_Wrapper.TrxOpptyWrapper getOpportunityQuote(String opptyId){
        Aswata_QuotationSlip_Wrapper.TrxOpptyWrapper result = new Aswata_QuotationSlip_Wrapper.TrxOpptyWrapper();
        List<Opportunity> opps = [
            SELECT
                Id, Name, Busreq_ID__c,
                The_Insured_Name__r.Name, The_Insured_Address__c,
                Start_Date_Periode__c, End_Date_Periode__c, Warranty__c
            FROM Opportunity
            WHERE Id = :opptyId
            WITH SECURITY_ENFORCED
            // LIMIT 1
        ];
        Opportunity opptyQuote = opps[0];
        Date startDate = opptyQuote.Start_Date_Periode__c;
        Date endDate = opptyQuote.End_Date_Periode__c;
        result.monthsDifference = startDate.monthsBetween(endDate);
        if (!opps.isEmpty()) {
            result.opp = opptyQuote;
            result.insuredName = (opptyQuote.The_Insured_Name__r != null) ? opptyQuote.The_Insured_Name__r.Name : '';
            result.insuredAddress = opptyQuote.The_Insured_Address__c;
        }
        String cond = 'Opportunity__c = :opptyId';
        String dpFields = SOQL_SOBJECT.getallfield('Transaction_Data__c');
        SOQL_SOBJECT.SOQL_Param sp = new SOQL_SOBJECT.SOQL_Param();
        sp.sobjectName = 'Transaction_Data__c';
        sp.condition = cond;
        sp.fields = dpFields;
        sp.addField = ',QQ_Name__r.Name';
        String dpquery = SOQL_SOBJECT.SOQL(sp)+' WITH SECURITY_ENFORCED';
        // String queryx = 'SELECT '+field+' ,QQ_Name__r.Name FROM Transaction_Data__c WHERE Opportunity__c = :opptyId WITH SECURITY_ENFORCED';
        // List<Transaction_Data__c> rawTrxData = [
        //     SELECT Id, Clauses_Name__c,Clause_Description__c,QQ_Name__r.Name
        //     FROM Transaction_Data__c
        //     WHERE Opportunity__c = :opptyId
        //     WITH SECURITY_ENFORCED
        // ];
        List<Transaction_Data__c> rawTrxData = Database.query(dpquery);
        List<Transaction_Data__c> trxDataOppty = new List<Transaction_Data__c>();
        for (Transaction_Data__c trx : rawTrxData) {
            if (String.isNotBlank(trx.Clauses_Name__c) && trx.Clauses_Name__c!='-') {
                trxDataOppty.add(trx);
            }
        }
        // result.qqName = rawTrxData[0].QQ_Name__r.Name;
        result.qqName = '';
        if (!rawTrxData.isEmpty()) {
            Transaction_Data__c firstTrx = rawTrxData[0];
            if (firstTrx.QQ_Name__r != null) {
                result.qqName = firstTrx.QQ_Name__r.Name;
            }
        }
        result.trxDataList = trxDataOppty;

        return result;
    }
    /**
     * @description function for Query Risk base on Oppty
     * @param opptyId opportunity Id
     * @return List<Asset>
     */
    public static List<Asset> queryRiskOppty(String opptyId){
        List<Asset> assetOppty = [
            SELECT Id, Name, Address__c, Amount__c,
            Occupation_Code__r.Occupy_Id__c,
            Address__r.Name,
            Address__r.City__r.Name,
            Address__r.Country__r.Name,
            Address__r.Zip_Code__r.name,
            Total_Premi_Amount__c, Class__c, Occupation_Description__c,Type__c, Amount_Insured__c,
            Rate_All_Coverages__c,
            Opportunity__c, License_Plate_Number__c,
            vehicle_model_desc__c, Year_of_Manufacture__c,
            Color__c,  Engine_No__c, Chasis_No__c, Vehicle_Type__c,
            jenis_perlengkapan__c, Utilization__c
            FROM Asset
            WHERE Opportunity__c = :opptyId AND Record_Type__c = 'Risk'
            WITH SECURITY_ENFORCED
        ];
        return assetOppty;
    }
    /**
     * @description function for Query Coverage base on Risk
     * @param assetOppty list of Risk
     * @return List<InsurancePolicyCoverage>
     */
    public static List<InsurancePolicyCoverage> queryCoverage(List<Asset> assetOppty){
        Set<String> idRisk = new Set<String>();
        for(Asset risk: assetOppty){
            idRisk.add(risk.Id);
        }
        List<InsurancePolicyCoverage> coverages = [
                SELECT
                    Id, Risk_ID__c, Coverage_Name__r.Name,
                    CoverageName, Coverage_Name__c, Proposed_Fixed_Amount__c,
                    Deductible_PCT__c, DeductibleAmount, Final_Approved_Rate__c,Deductible_Type__c
                FROM InsurancePolicyCoverage
                WHERE Risk_ID__c IN :idRisk
                WITH SECURITY_ENFORCED
            ];
        return coverages;
    }
    /**
     * @description function for generate Coverage base on Risk for multi Risk
     * @param assetOppty list of Risk
     * @return Map<Id, List<Aswata_QuotationSlip_Wrapper.CoverageRate>>
     */
    public static Map<Id, List<Aswata_QuotationSlip_Wrapper.CoverageRate>> generateCoverageMap(List<Asset> assetOppty){
        Map<Id, List<Aswata_QuotationSlip_Wrapper.CoverageRate>> riskToCoveragesMap = new Map<Id, List<Aswata_QuotationSlip_Wrapper.CoverageRate>>();
        List<InsurancePolicyCoverage> coverages = queryCoverage(assetOppty);
        if (coverages.isEmpty()) {
            return riskToCoveragesMap;
        }
        for (InsurancePolicyCoverage ipc : coverages) {
            Aswata_QuotationSlip_Wrapper.CoverageRate wrapper = new Aswata_QuotationSlip_Wrapper.CoverageRate();
            Id riskId = ipc.Risk_ID__c;
            wrapper.riskId = riskId;
            if(ipc.CoverageName == null){
                wrapper.coverageName = ipc.Coverage_Name__r.Name;
            }else{
                wrapper.coverageName = ipc.CoverageName;
            }
            wrapper.premiFixedAmount = ipc.Proposed_Fixed_Amount__c;
            if (!riskToCoveragesMap.containsKey(riskId)) {
                riskToCoveragesMap.put(riskId, new List<Aswata_QuotationSlip_Wrapper.CoverageRate>());
            }
            riskToCoveragesMap.get(riskId).add(wrapper);
        }
        return riskToCoveragesMap;
    }
    /**
     * @description function for get List Risk
     * @param assetOppty list of Risk
     * @return List<Aswata_QuotationSlip_Wrapper.DetailAsset>
     */
    public static List<Aswata_QuotationSlip_Wrapper.DetailAsset> getListDetailAsset(List<Asset> assetOppty){
        List<Aswata_QuotationSlip_Wrapper.DetailAsset> listDetailAsset = new List<Aswata_QuotationSlip_Wrapper.DetailAsset>();
        for(Asset risk: assetOppty){
            Decimal amountPertanggungTemp = 0;
            Aswata_QuotationSlip_Wrapper.DetailAsset detail = new Aswata_QuotationSlip_Wrapper.DetailAsset();
            detail.uraianPertanggungan = risk.Name;
            if(risk.Amount__c!=null){
                amountPertanggungTemp = risk.Amount__c;
            }
            detail.amountPertanggungan = amountPertanggungTemp;
            listDetailAsset.add(detail);
        }
        return listDetailAsset;
    }
    /**
     * @description function for calculation total Premi
     * @param risk
     * @param quoteRecord
     * @param assetOppty list of Risk
     * @return Aswata_QuotationSlip_Wrapper.QuotationWrapper
     */
    public static Aswata_QuotationSlip_Wrapper.QuotationWrapper getTotalPremi(
        Asset risk,
        Quote quoteRecord,
        List<Asset> assetOppty
    ) {
        Aswata_QuotationSlip_Wrapper.QuotationWrapper singleRisk = new Aswata_QuotationSlip_Wrapper.QuotationWrapper();
        List<InsurancePolicyCoverage> coverages = queryCoverage(assetOppty);
        Decimal allRate = 0;
        if (!coverages.isEmpty()) {
            for(InsurancePolicyCoverage cov: coverages){
                allRate+=cov.Proposed_Fixed_Amount__c;
            }
            singleRisk.totalAllRate = allRate/coverages.size();
            singleRisk.policyCoverage = coverages;
        } else {
            singleRisk.policyCoverage = new List<InsurancePolicyCoverage>();
        }
        singleRisk.premiNonStockCalculated=0;
        if (risk != null && !coverages.isEmpty() && risk.Amount_Insured__c != null)
        {
            Decimal sumInsured = risk.Amount_Insured__c;
            if(singleRisk.totalAllRate>0){
                Decimal ratePerMille = singleRisk.totalAllRate;
                // Hitung: (Sum Insured * Rate) / 1000
                Decimal calcAmountInsured = sumInsured * (ratePerMille/100);
                singleRisk.premiNonStockCalculated = calcAmountInsured;
            }else{
                singleRisk.premiNonStockCalculated = 0;
            }
        }
        // Jumlah
        // Decimal totalPremiSingleRisk = 0;
        Decimal tempStampDuty = (quoteRecord.Stamp_Duty__c != null)
            ? quoteRecord.Stamp_Duty__c
            : 0;
        Decimal tempStampAdmin = (quoteRecord.Administration_Cost__c != null)
            ? quoteRecord.Administration_Cost__c
            : 0;
        singleRisk.stampDuty = tempStampDuty;
        singleRisk.adminCost = tempStampAdmin;
        singleRisk.totalPremi = singleRisk.premiNonStockCalculated + tempStampDuty + tempStampDuty;
        singleRisk.nominalTerbilang = Aswata_QuotationSlip_Terbilang.terbilangRupiah(singleRisk.totalPremi);
        return singleRisk;
    }
    /**
     * @description function for calculation total Premi for Multi Risk
     * @param quoteRecord
     * @param assetOppty list of Risk
     * @param premiNonStock total
     * @return Aswata_QuotationSlip_Wrapper.QuotationWrapper
     */
    public static Aswata_QuotationSlip_Wrapper.QuotationWrapper getTotalPremiMulti(
        Quote quoteRecord,
        List<Asset> assetOppty,
        Decimal premiNonStock
    ) {
        List<InsurancePolicyCoverage> coverages = queryCoverage(assetOppty);
        Aswata_QuotationSlip_Wrapper.QuotationWrapper singleRisk = new Aswata_QuotationSlip_Wrapper.QuotationWrapper();
        Decimal allRate = 0;
        if (!coverages.isEmpty()) {
            for(InsurancePolicyCoverage cov: coverages){
                if(cov.Proposed_Fixed_Amount__c!=null){
                    allRate+=cov.Proposed_Fixed_Amount__c;
                }
            }
            singleRisk.totalAllRate = allRate/coverages.size();
            singleRisk.policyCoverage = coverages;
        } else {
            singleRisk.policyCoverage = new List<InsurancePolicyCoverage>();
        }
        // Jumlah
        // Decimal totalPremiSingleRisk = 0;
        Decimal tempStampDuty = (quoteRecord.Stamp_Duty__c != null)
            ? quoteRecord.Stamp_Duty__c
            : 0;
        Decimal tempStampAdmin = (quoteRecord.Administration_Cost__c != null)
            ? quoteRecord.Administration_Cost__c
            : 0;
        singleRisk.stampDuty = tempStampDuty;
        singleRisk.adminCost = tempStampAdmin;
        singleRisk.premiNonStockCalculated = premiNonStock;
        singleRisk.totalPremi = premiNonStock + tempStampDuty + tempStampDuty;
        singleRisk.nominalTerbilang = Aswata_QuotationSlip_Terbilang.terbilangRupiah(singleRisk.totalPremi);
        return singleRisk;
    }
}