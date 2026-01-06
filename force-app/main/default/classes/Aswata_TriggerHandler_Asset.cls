/*
 * @Author: Williams 
 * @Date: 2025-11-06 15:14:53 
 * @Last Modified by: Williams
 * @Class: Aswata_TriggerHandler_Asset
 * @Last Modified time: 2025-11-14 17:26:43
 * @Description: Trigger handler untuk Asset - automatically calculate parent Risk Amount_Insured__c and Opportunity Total_Sum_Insured__c
 */

public with sharing class Aswata_TriggerHandler_Asset extends TriggerHandler {
    private static final String RT_ASSET = 'Asset';
    private static final String RT_RISK = 'Risk';
    
    private static Map<Id, String> recordTypeIdToNameMap;
    
    /**
     * Get RecordType ID to DeveloperName mapping
     * Cache untuk avoid multiple SOQL dalam trigger context
     */
    private static Map<Id, String> getRecordTypeMapping() {
        if (recordTypeIdToNameMap == null) {
            recordTypeIdToNameMap = new Map<Id, String>();
            List<RecordType> recordTypes = [
                SELECT Id, DeveloperName 
                FROM RecordType 
                WHERE SObjectType = 'Asset'
                AND DeveloperName IN (:RT_RISK, :RT_ASSET)
            ];
            
            for (RecordType rt : recordTypes) {
                recordTypeIdToNameMap.put(rt.Id, rt.DeveloperName);
            }
            
            System.debug('RecordType mapping cached: ' + recordTypeIdToNameMap);
        }
        return recordTypeIdToNameMap;
    }
    
    /**
     * After Insert - Calculate parent Risk when new Assets are created, or Opportunity when new Risks are created
     */
    public override void afterInsert() {
        handleAssetChanges((List<Asset>) Trigger.new, null);
    }
    
    /**
     * After Update - Recalculate parent Risk when Asset amount or parent changes, or Opportunity when Risk amount changes
     */
    public override void afterUpdate() {
        
        Boolean isChangedSetFacul = false;
        for (Asset newAsset : (List<Asset>) Trigger.new) {
            Asset oldAsset = (Asset) Trigger.oldMap.get(newAsset.Id);
            
            if(newAsset.Facultative__c != oldAsset.Facultative__c && newAsset.Facultative__c != null && newAsset.Facultative__c >= 1 ){
                isChangedSetFacul = true;
            }
        	
        }
        
        if(isChangedSetFacul){
            facultativeUserMatrix((List<Asset>) Trigger.new, (Map<Id, Asset>) Trigger.oldMap);
        }
        
        handleAssetChanges((List<Asset>) Trigger.new, (Map<Id, Asset>) Trigger.oldMap);
        //facultativeUserMatrix((List<Asset>) Trigger.new, (Map<Id, Asset>) Trigger.oldMap);
    }
    
    /**
     * After Update - Recalculate parent Risk when Asset amount or parent changes, or Opportunity when Risk amount changes
     */
    public override void beforeUpdate() {
        
    }
    
    
    
    /**
     * After Delete - Recalculate parent Risk when Assets are deleted, or Opportunity when Risks are deleted
     */
    public override void afterDelete() {
        handleAssetChanges((List<Asset>) Trigger.old, null);
    }
    

    private void facultativeUserMatrix(List<Asset> assets, Map<Id, Asset> oldMap) {

        // 1️⃣ Collect Asset Ids
        Set<Id> assetIds = new Set<Id>();
        for (Asset a : assets) {
            if (a.Facultative__c != oldMap.get(a.Id).Facultative__c) {
                assetIds.add(a.Id);
            }
        }
        if (assetIds.isEmpty()) return;
    
        // 2️⃣ Re-query with parent fields
        List<Asset> queriedAssets = [
            SELECT Id,
                   Facultative__c,
                   Opportunity__c,
                   Opportunity__r.COB__c,
                   Opportunity__r.Owner_Branch__c
            FROM Asset
            WHERE Id IN :assetIds
        ];
    
        List<Asset> lstAssetToUpdate = new List<Asset>();
        Map<Id, Set<Id>> oppToUserIds = new Map<Id, Set<Id>>();
    
        // 3️⃣ Business logic
        for (Asset a : queriedAssets) {
    
            if (a.Opportunity__r.COB__c != null &&
                a.Opportunity__r.Owner_Branch__c != null &&
                a.Facultative__c != null) {
    
                String userId = Aswata_GlobalFunction.matrixUserFacultativeCached(
                    a.Opportunity__r.Owner_Branch__c,
                    a.Opportunity__r.COB__c,
                    a.Facultative__c
                );
    
                if (userId != null) {
                    a.Facultative_Owner__c = userId;
                    lstAssetToUpdate.add(a);
                
                    if (!oppToUserIds.containsKey(a.Opportunity__c)) {
                        oppToUserIds.put(a.Opportunity__c, new Set<Id>());
                    }
                    oppToUserIds.get(a.Opportunity__c).add(userId);
                }
            }
        }
    
        // 4️⃣ DML
        if (!lstAssetToUpdate.isEmpty()) {
            update lstAssetToUpdate;
        }
    
        // 5️⃣ Team assignment
        if (!oppToUserIds.isEmpty()) {
            Aswata_GlobalFunction.addUsersToOpportunityTeamBulk(
                oppToUserIds,
                'Facultative Owner',
                'Edit'
            );
        }
    }

    /**
     * Main handler method untuk process Asset changes
     * Handles both Asset (RecordType=Asset) and Risk (RecordType=Risk) changes
     * 
     * @param assets List of Assets from trigger context
     * @param oldMap Old values map (null for Insert/Delete)
     */
    private void handleAssetChanges(List<Asset> assets, Map<Id, Asset> oldMap) {
        Set<Id> assetIdsToProcess = new Set<Id>();
        Set<Id> parentRiskIdsFromDeletedAssets = new Set<Id>();
        
        Set<Id> riskIdsToProcess = new Set<Id>();
        Set<Id> opportunityIdsFromDeletedRisks = new Set<Id>();
        
        Map<Id, String> rtMapping = getRecordTypeMapping();
        Integer processedAssetCount = 0;
        Integer processedRiskCount = 0;
        
        for (Asset asset : assets) {
            String recordTypeName = rtMapping.get(asset.RecordTypeId);
            
            System.debug('Processing record type: ' + recordTypeName + ' - ID: ' + asset.Id);
            
            if (recordTypeName == RT_ASSET && asset.ParentId != null) {
                processedAssetCount++;
                
                if (Trigger.isInsert) {
                    assetIdsToProcess.add(asset.Id);
                    System.debug('Insert: Adding asset ' + asset.Id + ' (Parent: ' + asset.ParentId + ')');
                }
                
                else if (Trigger.isUpdate && oldMap != null) {
                    Asset oldAsset = oldMap.get(asset.Id);
                    
                    Boolean amountChanged = (asset.Amount__c != oldAsset.Amount__c);
                    Boolean exchangeRateChanged = (asset.Exchange_Rate__c != oldAsset.Exchange_Rate__c);
                    Boolean parentChanged = (asset.ParentId != oldAsset.ParentId);
                    
                    if (amountChanged || exchangeRateChanged || parentChanged) {
                        assetIdsToProcess.add(asset.Id);
                        System.debug('Update: Adding asset ' + asset.Id + 
                                    ' (Amount changed: ' + amountChanged + 
                                    ', Exchange Rate changed: ' + exchangeRateChanged +
                                    ', Parent changed: ' + parentChanged + ')');
                        
                        if (parentChanged && oldAsset.ParentId != null) {
                            parentRiskIdsFromDeletedAssets.add(oldAsset.ParentId);
                            System.debug('Update: Old parent ' + oldAsset.ParentId + ' needs recalculation');
                        }
                    }
                }
                
                else if (Trigger.isDelete) {
                    parentRiskIdsFromDeletedAssets.add(asset.ParentId);
                    System.debug('Delete: Parent ' + asset.ParentId + ' needs recalculation (asset ' + asset.Id + ' deleted)');
                }
            }
            
            else if (recordTypeName == RT_RISK) {
                processedRiskCount++;
                
                if (Trigger.isInsert && asset.Opportunity__c != null) {
                    riskIdsToProcess.add(asset.Id);
                    System.debug('Insert: Adding risk ' + asset.Id + ' (Opportunity: ' + asset.Opportunity__c + ')');
                }
                
                else if (Trigger.isUpdate && oldMap != null) {
                    Asset oldRisk = oldMap.get(asset.Id);
                    
                    Boolean amountInsuredChanged = (asset.Amount_Insured__c != oldRisk.Amount_Insured__c);
                    Boolean opportunityChanged = (asset.Opportunity__c != oldRisk.Opportunity__c);
                    
                    if (amountInsuredChanged || opportunityChanged) {
                        riskIdsToProcess.add(asset.Id);
                        System.debug('Update: Adding risk ' + asset.Id + ' (Amount_Insured changed: ' + amountInsuredChanged + ', Opportunity changed: ' + opportunityChanged + ')');
                        
                        if (opportunityChanged && oldRisk.Opportunity__c != null) {
                            opportunityIdsFromDeletedRisks.add(oldRisk.Opportunity__c);
                            System.debug('Update: Old opportunity ' + oldRisk.Opportunity__c + ' needs recalculation');
                        }
                    }
                }
                
                else if (Trigger.isDelete) {
                    opportunityIdsFromDeletedRisks.add(asset.Opportunity__c);
                    System.debug('Delete: Opportunity ' + asset.Opportunity__c + ' needs recalculation (risk ' + asset.Id + ' deleted)');
                }
            }
        }
        
        // System.debug('========================================');
        // System.debug('Processed ' + processedAssetCount + ' Asset records (RecordType=Asset)');
        // System.debug('Processed ' + processedRiskCount + ' Risk records (RecordType=Risk)');
        // System.debug('Asset IDs to process: ' + assetIdsToProcess.size());
        // System.debug('Parent Risk IDs from deleted/moved assets: ' + parentRiskIdsFromDeletedAssets.size());
        // System.debug('Risk IDs to process: ' + riskIdsToProcess.size());
        // System.debug('Opportunity IDs from deleted/moved risks: ' + opportunityIdsFromDeletedRisks.size());
        // System.debug('========================================');
        
        if (!System.isFuture() && !System.isBatch() && !System.isQueueable()) {
            
            if (!assetIdsToProcess.isEmpty()) {
                System.debug('Calling calculateParentAssetAmount() with ' + assetIdsToProcess.size() + ' asset IDs');
                Aswata_Async_Asset.calculateParentAssetAmount(assetIdsToProcess);
            }
            
            if (!parentRiskIdsFromDeletedAssets.isEmpty() ) {
                if(!System.isQueueable()){
                    System.debug('Calling calculateParentAssetAmount() for ' + parentRiskIdsFromDeletedAssets.size() + ' parent risk IDs (from deleted/moved assets)');
                    Aswata_Async_Asset.calculateParentAssetAmount(parentRiskIdsFromDeletedAssets);
                } else {
                    Aswata_Async_Asset.calculateParentAssetAmount2(parentRiskIdsFromDeletedAssets);
                }
            }
            
            Set<Id> opportunityIds = new Set<Id>();
            if (!riskIdsToProcess.isEmpty()) {
                for (Asset risk : assets) {
                    if (riskIdsToProcess.contains(risk.Id) && risk.Opportunity__c != null) {
                        opportunityIds.add(risk.Opportunity__c);
                    }
                }
            }
            
            if (!opportunityIdsFromDeletedRisks.isEmpty()) {
                opportunityIds.addAll(opportunityIdsFromDeletedRisks);
            }
            
            // if (!opportunityIds.isEmpty()) {
            //     System.debug('Calling recalculateAssetsByOpportunity() for ' + opportunityIds.size() + ' opportunity IDs');
            //     Aswata_Async_Asset.recalculateAssetsByOpportunity(opportunityIds);
            // }
            
        } else {
            System.debug('⚠️ Skipping @future call - already in async context');
            // TODO: Consider using Platform Events or Queueable as alternative
        }
    }
}