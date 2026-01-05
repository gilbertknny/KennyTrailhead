/**
 * @description       : Data Handler for LWC Treaty Distribution
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 01-05-2026
 * @last modified by  : Ahmad Yazid Munif
**/
public without sharing class Aswata_Treaty_Distribution {
    /**
     * @description function for get transaction data from opportunity related in quote
     * @param recordId string Id quote
     * @return Transaction_Data__c object
     */
    @AuraEnabled(cacheable=true)
    public static Transaction_Data__c getTransactionDataOpp(String recordId) {
        //012MS000000BWNyYAO
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
    @AuraEnabled
    public static List<QuoteOpptyRelated> getRelatedListRisk(String recordId) {
        // 012MS000000BcI5YAK
        RecordType rtRisk = [
            SELECT id FROM RecordType
            WHERE SobjectType = 'Asset' AND Name = 'RIsk'
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        Quote resultOppty = [
            SELECT QuoteNumber,OpportunityId,Treaty_Distribution_Response__c,CreatedDate
            FROM Quote WHERE Id = :recordId
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        System.debug('resultOppty'+resultOppty);
        List<Asset> relatedAsset = [
            SELECT Id,Name, Risk_ID__c,Amount_Insured__c,Accumulation_ID__c,
            Accumulation__c, Accumulation__r.Name,Accumulation__r.CreatedDate,
            Opportunity__r.Busreq_ID__c, Opportunity__r.Name,
            Opportunity__r.Start_Date_Periode__c,
            Opportunity__r.End_Date_Periode__c,
            Opportunity__r.Total_Sum_Insured__c,
            Opportunity__c, Address__c,
            Address__r.Name, Address__r.City__r.Name,
            Address__r.Country__r.Name,
            Address__r.Zip_Code__r.Name
            FROM Asset WHERE Opportunity__c = :resultOppty.OpportunityId
            AND RecordTypeId = :rtRisk.Id
            // AND (Accumulation__c != null OR Accumulation_ID__c != null)
            WITH SECURITY_ENFORCED
        ];
        System.debug('relatedAsset'+relatedAsset);
        List<QuoteOpptyRelated> listOpptyQuote = new List<QuoteOpptyRelated>();
        for(Asset item : relatedAsset){
            QuoteOpptyRelated opptyQuote = new QuoteOpptyRelated();
            opptyQuote.id = item.Opportunity__c;
            opptyQuote.riskNo = item.Risk_ID__c;
            opptyQuote.riskName = item.Name;
            opptyQuote.opptyName = item.Opportunity__r.Name;
            opptyQuote.labelName = item.Opportunity__r.Busreq_ID__c+' - '+item.Risk_ID__c;
            opptyQuote.findId = item.Id;
            opptyQuote.busreqId = item.Opportunity__r.Busreq_ID__c;
            opptyQuote.accumId = item.Accumulation_ID__c;
            opptyQuote.oppTotalSumInsured = item.Amount_Insured__c;
            opptyQuote.oppStartDatePeriode = item.Opportunity__r.Start_Date_Periode__c;
            opptyQuote.oppEndDatePeriode = item.Opportunity__r.End_Date_Periode__c;
            opptyQuote.quoteReqDate = resultOppty.CreatedDate.date();
            opptyQuote.quoteNumber = resultOppty.QuoteNumber;
            opptyQuote.addressRisk = generateFormattedAddress(item);
            listOpptyQuote.add(opptyQuote);
        }
        // System.debug('listOpptyQuote'+listOpptyQuote);
        return listOpptyQuote;
    }
    /**
     * @description Menggabungkan komponen alamat dari record Asset menjadi satu string
     * @param risk Record Asset yang memiliki lookup ke Address__c
     * @return String Alamat lengkap
     */
    public static String generateFormattedAddress(Asset risk) {
        if (risk == null || risk.Address__c == null) {
            return '';
        }
        List<String> addressComponents = new List<String>();
        if (String.isNotBlank(risk.Address__r.Name)) {
            addressComponents.add(risk.Address__r.Name);
        }
        if (String.isNotBlank(risk.Address__r.City__r.Name)) {
            addressComponents.add(risk.Address__r.City__r.Name);
        }
        if (String.isNotBlank(risk.Address__r.Country__r.Name)) {
            addressComponents.add(risk.Address__r.Country__r.Name);
        }
        if (String.isNotBlank(risk.Address__r.Zip_Code__r.Name)) {
            addressComponents.add(risk.Address__r.Zip_Code__r.Name);
        }
        if (addressComponents.isEmpty()) {
            return '';
        }
        return String.join(addressComponents, ', ');
    }
    /**
     * @description function for getResponseTreaty from API
     * @param recordId string Id quote
     * @return Map<String,Object>
     */
    @AuraEnabled
    public static Map<String,Object> getResponseTreaty(String recordId) {
        system.debug('recordId'+recordId);
        // recordId = '02iMS000000QOBkYAO';
        Map<String,String> mapstr = new Map<String,String>();
        mapstr.put('recId',recordId);
        Map<String,Object> result = VlocityMapping.callIP('SFAWT27_SendTreaty',json.serialize(mapstr));
        system.debug('result'+result);
        return result;
    }
    /**
     * @description Class wrapper return getRelatedOppty
     * all value JSON can deserialize with this wrapper
     */
    public class QuoteOpptyRelated {
        @AuraEnabled public String id;
        @AuraEnabled public String riskNo;
        @AuraEnabled public String riskName;
        @AuraEnabled public String labelName;
        @AuraEnabled public String findId;
        @AuraEnabled public String busreqId;
        @AuraEnabled public String accumId;
        @AuraEnabled public String opptyName;
        @AuraEnabled public Decimal oppTotalSumInsured;
        @AuraEnabled public Date oppStartDatePeriode;
        @AuraEnabled public Date oppEndDatePeriode;
        @AuraEnabled public Date quoteReqDate;
        @AuraEnabled public String quoteNumber;
        @AuraEnabled public String addressRisk;
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
        Quote oldQuote = [
            SELECT Id, Treaty_Distribution_Response__c 
            FROM Quote 
            WHERE Id = :quoteId 
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];
        Map<String, Map<String, Object>> riskMap = new Map<String, Map<String, Object>>();
        List<Object> finalJsonArray = new List<Object>();
        String existingJson = oldQuote.Treaty_Distribution_Response__c;
        if (String.isNotBlank(existingJson)) {
            List<Object> oldArray = (List<Object>)JSON.deserializeUntyped(existingJson);
            for (Object obj : oldArray) {
                Map<String, Object> oldObjectMap = (Map<String, Object>)obj;
                String riskId = (String)oldObjectMap.get('riskId');
                riskMap.put(riskId, oldObjectMap);
            }
        }
        if (String.isNotBlank(jsonData)) {
            Map<String, Object> newObjectMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
            String newRiskId = (String)newObjectMap.get('riskId');
            if (String.isNotBlank(newRiskId)) {
                riskMap.put(newRiskId, newObjectMap);
            }
        }
        finalJsonArray.addAll(riskMap.values());
        String mergedJsonArrayString = JSON.serialize(finalJsonArray);
        // 4. Update Quote
        // unlock Quote
        Approval.UnlockResult unlockResult = Approval.unlock(quoteId,false);
        Quote updateQuote = new Quote(
            Id = quoteId,
            Treaty_Distribution_Response__c = mergedJsonArrayString
        );
        // System.debug('### AWT updateQuote'+updateQuote);
        // OperationDML
        Database.update(updateQuote, AccessLevel.USER_MODE);
        Approval.LockResult lockResult = Approval.lock(quoteId,false);
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
        // List<String> busreqIdList = new List<String>();
        List<String> riskIdList = new List<String>();
        // Set<String> targetCombinedIdSet = new Set<String>();
        for (RiskPairWrapper pair : riskPairs) {
            String safeRiskId = String.escapeSingleQuotes(pair.riskId);
            riskIdList.add(safeRiskId);
        }
        // System.debug('### AWT busreqIdList'+busreqIdList);
        List<Asset> getAssetByBusreq = [
            SELECT Id, Opportunity__r.Busreq_ID__c,Risk_ID__c,
            Accumulation__r.Group_ID__c
            FROM Asset
            WHERE Id IN :riskIdList
            WITH SECURITY_ENFORCED
        ];
        return getAssetByBusreq;
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
        String folderFaculId = null;
        String groupId = assetsToUpdate[0].Accumulation__r.Group_ID__c;
        List<Asset> assetsByGroup = [
            SELECT Id, Opportunity__r.Busreq_ID__c,Risk_ID__c,
            Accumulation__r.Group_ID__c,Facultative_Folder__c,Has_Facultative__c
            FROM Asset
            WHERE Accumulation__r.Group_ID__c = :groupId
            AND Facultative_Folder__c != null
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (!assetsByGroup.isEmpty()) {
            folderFaculId = assetsByGroup[0].Facultative_Folder__c;
        }else{
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
            folderFaculId = transacData.Id;
        }
        List<Asset> updateAssetList = new List<Asset>();
        for(Asset a : assetsToUpdate){
            updateAssetList.add(new Asset(
                Id = a.Id,
                Facultative__c = facultativeValue,
                Has_Facultative__c = true,
                Facultative_Folder__c = folderFaculId
            ));
        }
        System.debug('### AWT updateAssetList'+updateAssetList);
        // OperationDML
        if (!updateAssetList.isEmpty()){
            Database.update(updateAssetList, AccessLevel.USER_MODE);
        }
    }
}