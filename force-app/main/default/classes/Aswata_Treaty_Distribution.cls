/**
 * @description       : Data Handler for LWC Treaty Distribution
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 10-28-2025
 * @last modified by  : Ahmad Yazid Munif
**/
public with sharing class Aswata_Treaty_Distribution {
    /**
     * @description function for get transaction data from opportunity related in quote
     * @param recordId string Id quote
     * @return Transaction_Data__c object
     */
    @AuraEnabled(cacheable=true)
    public static Transaction_Data__c getTransactionDataOpp(String recordId) {
        RecordType rtTrxData = [
            SELECT Id, Name
            FROM RecordType where SobjectType = 'Transaction_Data__c'
            AND Name = 'Co-Insurer'
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        List<Transaction_Data__c> trxData = [
            SELECT Id,Amount__c
            FROM Transaction_Data__c
            WHERE Opportunity__c IN (
                SELECT OpportunityId FROM Quote
                WHERE Id = :recordId
            )
            AND RecordTypeId = :rtTrxData.Id
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (trxData.isEmpty()) {
            return null;
        }
        return trxData[0];
    }
    /**
     * @description function for get opportunity related from quote
     * @param recordId string Id quote
     * @return Quote object
     */
    @AuraEnabled(cacheable=true)
    public static Quote getRelatedOpportunityData(String recordId) {
        if (!Schema.sObjectType.Quote.isAccessible()) {
            throw new SecurityException(
                'Insufficient permissions to access Quote'
            );
        }
        Quote resultOppty = [
            SELECT OpportunityId,
            Opportunity.Name,Opportunity.Total_Sum_Insured__c,
            Opportunity.Start_Date_Periode__c,Opportunity.End_Date_Periode__c,
            Treaty_Distribution_Response__c
            FROM Quote WHERE Id = :recordId
        ];
        return resultOppty;
    }
    /**
     * @description function for save setFacultative
     * @param quoteId : id Quote
     * @param jsonData : id Quote
     * @param listId : list id risk
     * @return String
     */
    @AuraEnabled
    public static String saveTreatyDistribution(String quoteId, String jsonData,String listId) {
        // 1. Deserialisasi Data
        List<RiskPairWrapper> riskPairs = deserializeRiskPairs(listId);
        // 2. Kueri Asset & Pembaruan Quote (DML)
        List<Asset> assetsToUpdate = findAssetsForUpdate(riskPairs);
        // 3. Insert Transaction Folder & Final Update Asset
        if (!assetsToUpdate.isEmpty()) {
            processAssetUpdates(assetsToUpdate, riskPairs[0].setFacultative);
        }
        // 4. Update Quote
        Quote updateQuote = new Quote(
            Id = quoteId,
            Treaty_Distribution_Response__c = jsonData
        );
        // System.debug('### AWT updateQuote'+updateQuote);
        // OperationDML
        Database.update(updateQuote, AccessLevel.USER_MODE);
        return 'Success';
    }
    /**
     * @description Class wrapper JSON String
     * all value JSON can deserialize with this wrapper
     */
    public class RiskPairWrapper {
        /**
         * @description class wrapper JSON String busreqId
         */
        @AuraEnabled public String busreqId;
        /**
         * @description class wrapper JSON String riskNoId
         */
        @AuraEnabled public String riskId;
        /**
         * @description class wrapper JSON String setFacultative
         */
        @AuraEnabled public Decimal setFacultative;
    }
    /**
     * @description deserializeRiskPairs
     * @param listId : list id risk
     * @return List<RiskPairWrapper>
     */
    private static List<RiskPairWrapper> deserializeRiskPairs(String listId) {
        List<RiskPairWrapper> riskPairs = (List<RiskPairWrapper>) JSON.deserialize(listId, List<RiskPairWrapper>.class);
        if (riskPairs[0].setFacultative == 0) {
            throw new AuraHandledException('Set Facultative value is missing.');
        }
        return riskPairs;
    }
    /**
     * @description function for find Asset/Risk Id
     * @param riskPairs : hasil dari deserializeRiskPairs
     * @return List<Asset> asset yang didapat
     */
    private static List<Asset> findAssetsForUpdate(List<RiskPairWrapper> riskPairs) {
        if (riskPairs.isEmpty()) {
            return new List<Asset>();
        }
        List<String> busreqIdList = new List<String>();
        Set<String> targetCombinedIdSet = new Set<String>();
        for (RiskPairWrapper pair : riskPairs) {
            String safeBusreqId = String.escapeSingleQuotes(pair.busreqId);
            String safeRiskNumber = String.escapeSingleQuotes(pair.riskId);
            targetCombinedIdSet.add(safeBusreqId+safeRiskNumber);
            busreqIdList.add(safeBusreqId);
        }
        // System.debug('### AWT busreqIdList'+busreqIdList);
        List<Asset> getAssetByBusreq = [
            SELECT Id, Opportunity__r.Busreq_ID__c,Risk_ID__c
            FROM Asset
            WHERE Opportunity__r.Busreq_ID__c IN :busreqIdList
            WITH SECURITY_ENFORCED
        ];
        List<Asset> finalFilteredAssets = new List<Asset>();
        for(Asset ass: getAssetByBusreq){
            String queriedCombinedId = ass.Opportunity__r.Busreq_ID__c + ass.Risk_ID__c;
            if (targetCombinedIdSet.contains(queriedCombinedId)) {
                finalFilteredAssets.add(ass);
            }
        }
        // System.debug('### AWT finalFilteredAssets'+finalFilteredAssets);
        return finalFilteredAssets;
    }
    /**
     * @description function for proccessing update asset with setFacultative value
     * @param assetsToUpdate : asset date can be updated
     * @param setFacultativeValue : input value setFacultative
     */
    public static void processAssetUpdates(List<Asset> assetsToUpdate, Decimal setFacultativeValue) {
        Decimal facultativeValue = 0;
        if(setFacultativeValue != null && setFacultativeValue != 0){
            facultativeValue = setFacultativeValue;
        }
        RecordType rtFolder = [
            SELECT Id,Name
            FROM RecordType
            WHERE SobjectType = 'Transaction_Data__c' AND Name = 'Facultative Folder'
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        Transaction_Data__c transacData = new Transaction_Data__c(
            Detail_Description__c = 'Treaty Distribution',
            RecordTypeId = rtFolder.Id
        );
        // OperationDML
        Database.insert(transacData, AccessLevel.USER_MODE);
        List<Asset> updateAssetList = new List<Asset>();
        for(Asset a : assetsToUpdate){
            updateAssetList.add(new Asset(
                Id = a.Id,
                Facultative__c = facultativeValue,
                Has_Facultative__c = true,
                Facultative_Folder__c = transacData.Id
            ));
        }
        System.debug('### AWT updateAssetList'+updateAssetList);
        // OperationDML
        if (!updateAssetList.isEmpty()){
            Database.update(updateAssetList, AccessLevel.USER_MODE);
        }
    }
}