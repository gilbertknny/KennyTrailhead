/*
 * @Author: Williams 
 * @Date: 2025-11-06 15:14:53 
 * @Last Modified by: Williams
 * @Class: Aswata_TriggerHandler_Asset
 * @Last Modified time: 2025-11-10 16:40:29
 * @Description: Trigger handler untuk Asset - automatically calculate parent Risk Amount_Insured__c and Opportunity Total_Sum_Insured__c
 */

public with sharing class Aswata_TriggerHandler_Asset extends TriggerHandler {
    private static final String RT_ASSET = 'Asset';
    private static final String RT_RISK = 'Risk';
    
    // Cache RecordType IDs untuk performance
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
        handleAssetChanges((List<Asset>) Trigger.new, (Map<Id, Asset>) Trigger.oldMap);
    }
    
    /**
     * After Delete - Recalculate parent Risk when Assets are deleted, or Opportunity when Risks are deleted
     */
    public override void afterDelete() {
        handleAssetChanges((List<Asset>) Trigger.old, null);
    }
    
    /**
     * Main handler method untuk process Asset changes
     * Handles both Asset (RecordType=Asset) and Risk (RecordType=Risk) changes
     * 
     * @param assets List of Assets from trigger context
     * @param oldMap Old values map (null for Insert/Delete)
     */
    private void handleAssetChanges(List<Asset> assets, Map<Id, Asset> oldMap) {
        // Collections for Asset (RecordType = Asset) processing
        Set<Id> assetIdsToProcess = new Set<Id>();
        Set<Id> parentRiskIdsFromDeletedAssets = new Set<Id>();
        
        // Collections for Risk (RecordType = Risk) processing
        Set<Id> riskIdsToProcess = new Set<Id>();
        Set<Id> opportunityIdsFromDeletedRisks = new Set<Id>();
        
        Map<Id, String> rtMapping = getRecordTypeMapping();
        Integer processedAssetCount = 0;
        Integer processedRiskCount = 0;
        
        for (Asset asset : assets) {
            String recordTypeName = rtMapping.get(asset.RecordTypeId);
            
            System.debug('Processing record type: ' + recordTypeName + ' - ID: ' + asset.Id);
            
            // ========================================
            // HANDLE ASSET RECORDS (RecordType = Asset)
            // ========================================
            if (recordTypeName == RT_ASSET && asset.ParentId != null) {
                processedAssetCount++;
                
                // AFTER INSERT - Collect asset IDs untuk calculation
                if (Trigger.isInsert) {
                    assetIdsToProcess.add(asset.Id);
                    System.debug('Insert: Adding asset ' + asset.Id + ' (Parent: ' + asset.ParentId + ')');
                }
                
                // AFTER UPDATE - Process only if relevant fields changed
                else if (Trigger.isUpdate && oldMap != null) {
                    Asset oldAsset = oldMap.get(asset.Id);
                    
                    Boolean amountChanged = (asset.Amount__c != oldAsset.Amount__c);
                    Boolean parentChanged = (asset.ParentId != oldAsset.ParentId);
                    
                    if (amountChanged || parentChanged) {
                        assetIdsToProcess.add(asset.Id);
                        System.debug('Update: Adding asset ' + asset.Id + ' (Amount changed: ' + amountChanged + ', Parent changed: ' + parentChanged + ')');
                        
                        // If parent changed, also need to recalculate old parent
                        if (parentChanged && oldAsset.ParentId != null) {
                            parentRiskIdsFromDeletedAssets.add(oldAsset.ParentId);
                            System.debug('Update: Old parent ' + oldAsset.ParentId + ' needs recalculation');
                        }
                    }
                }
                
                // AFTER DELETE - Collect parent IDs untuk recalculation
                else if (Trigger.isDelete) {
                    parentRiskIdsFromDeletedAssets.add(asset.ParentId);
                    System.debug('Delete: Parent ' + asset.ParentId + ' needs recalculation (asset ' + asset.Id + ' deleted)');
                }
            }
            
            // ========================================
            // HANDLE RISK RECORDS (RecordType = Risk)
            // ========================================
            else if (recordTypeName == RT_RISK) {
                processedRiskCount++;
                
                // AFTER INSERT - ALWAYS recalculate Opportunity when Risk is inserted
                if (Trigger.isInsert && asset.Opportunity__c != null) {
                    riskIdsToProcess.add(asset.Id);
                    System.debug('Insert: Adding risk ' + asset.Id + ' (Opportunity: ' + asset.Opportunity__c + ')');
                }
                
                // AFTER UPDATE - Process only if Amount_Insured__c or Opportunity__c changed
                else if (Trigger.isUpdate && oldMap != null) {
                    Asset oldRisk = oldMap.get(asset.Id);
                    
                    Boolean amountInsuredChanged = (asset.Amount_Insured__c != oldRisk.Amount_Insured__c);
                    Boolean opportunityChanged = (asset.Opportunity__c != oldRisk.Opportunity__c);
                    
                    if (amountInsuredChanged || opportunityChanged) {
                        riskIdsToProcess.add(asset.Id);
                        System.debug('Update: Adding risk ' + asset.Id + ' (Amount_Insured changed: ' + amountInsuredChanged + ', Opportunity changed: ' + opportunityChanged + ')');
                        
                        // If opportunity changed, also need to recalculate old opportunity
                        if (opportunityChanged && oldRisk.Opportunity__c != null) {
                            opportunityIdsFromDeletedRisks.add(oldRisk.Opportunity__c);
                            System.debug('Update: Old opportunity ' + oldRisk.Opportunity__c + ' needs recalculation');
                        }
                    }
                }
                
                // AFTER DELETE - Collect opportunity IDs untuk recalculation
                else if (Trigger.isDelete) {
                    opportunityIdsFromDeletedRisks.add(asset.Opportunity__c);
                    System.debug('Delete: Opportunity ' + asset.Opportunity__c + ' needs recalculation (risk ' + asset.Id + ' deleted)');
                }
            }
        }
        
        System.debug('========================================');
        System.debug('Processed ' + processedAssetCount + ' Asset records (RecordType=Asset)');
        System.debug('Processed ' + processedRiskCount + ' Risk records (RecordType=Risk)');
        System.debug('Asset IDs to process: ' + assetIdsToProcess.size());
        System.debug('Parent Risk IDs from deleted/moved assets: ' + parentRiskIdsFromDeletedAssets.size());
        System.debug('Risk IDs to process: ' + riskIdsToProcess.size());
        System.debug('Opportunity IDs from deleted/moved risks: ' + opportunityIdsFromDeletedRisks.size());
        System.debug('========================================');
        
        // Call async calculations
        if (!System.isFuture() && !System.isBatch() && !System.isQueueable()) {
            
            // ========================================
            // PROCESS ASSET CHANGES (update parent Risk Amount_Insured__c)
            // ========================================
            
            // Process inserted/updated assets
            if (!assetIdsToProcess.isEmpty()) {
                System.debug('Calling calculateParentAssetAmount() with ' + assetIdsToProcess.size() + ' asset IDs');
                Aswata_Async_Asset.calculateParentAssetAmount(assetIdsToProcess);
            }
            
            // Process deleted/moved assets by parent ID
            if (!parentRiskIdsFromDeletedAssets.isEmpty()) {
                System.debug('Calling calculateParentAssetAmount() for ' + parentRiskIdsFromDeletedAssets.size() + ' parent risk IDs (from deleted/moved assets)');
                Aswata_Async_Asset.calculateParentAssetAmount(parentRiskIdsFromDeletedAssets);
            }
            
            // ========================================
            // PROCESS RISK CHANGES (update Opportunity Total_Sum_Insured__c)
            // ========================================
            
            // Collect opportunity IDs from inserted/updated risks
            Set<Id> opportunityIds = new Set<Id>();
            if (!riskIdsToProcess.isEmpty()) {
                for (Asset risk : assets) {
                    if (riskIdsToProcess.contains(risk.Id) && risk.Opportunity__c != null) {
                        opportunityIds.add(risk.Opportunity__c);
                    }
                }
            }
            
            // Add opportunity IDs from deleted/moved risks
            if (!opportunityIdsFromDeletedRisks.isEmpty()) {
                opportunityIds.addAll(opportunityIdsFromDeletedRisks);
            }
            
            // Call recalculate opportunity
            if (!opportunityIds.isEmpty()) {
                System.debug('Calling recalculateAssetsByOpportunity() for ' + opportunityIds.size() + ' opportunity IDs');
                Aswata_Async_Asset.recalculateAssetsByOpportunity(opportunityIds);
            }
            
        } else {
            System.debug('⚠️ Skipping @future call - already in async context');
            // TODO: Consider using Platform Events or Queueable as alternative
        }
    }
}