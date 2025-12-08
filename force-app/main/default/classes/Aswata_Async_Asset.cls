/*
 * @Date: 2025-11-05 10:14:21 
 * @Author: Baha Williams Azael 
 * @Class: Aswata_Async_Asset
 * @Description: Class untuk menghitung total amount di Parent Asset berdasarkan sum dari Child Assets
 * @Last Modified time: 2025-11-13 16:30:00
 */

public with sharing class Aswata_Async_Asset {    
    private static final String RT_RISK = 'Risk';
    private static final String RT_ASSET = 'Asset';
    
    private static Map<String, Id> recordTypeCache;
    
    /**
     * Get Record Type IDs - dengan caching untuk performance
     * @return Map of DeveloperName to RecordType Id
     */
    private static Map<String, Id> getRecordTypeIds() {
        if (recordTypeCache == null) {
            recordTypeCache = new Map<String, Id>();
            List<RecordType> recordTypes = [
                SELECT Id, DeveloperName 
                FROM RecordType 
                WHERE SObjectType = 'Asset'
                AND DeveloperName IN (:RT_RISK, :RT_ASSET)
            ];
            
            for (RecordType rt : recordTypes) {
                recordTypeCache.put(rt.DeveloperName, rt.Id);
            }
            
            System.debug('RecordType IDs cached: ' + recordTypeCache);
        }
        return recordTypeCache;
    }
    
    /**
     * Future method untuk update total amount di Parent Risk berdasarkan sum dari Child Assets
     * DAN update Opportunity Total_Sum_Insured__c sekaligus
     * 
     * @param assetsId Set of Asset IDs (RecordType=Asset) ATAU Set of Parent Risk IDs
     *                 Function akan auto-detect dan extract parent IDs jika perlu
     */
    @future
    public static void calculateParentAssetAmount(Set<Id> assetsId) {
        calculateParentAssetAmount2(assetsId);
    }
    
    public static void calculateParentAssetAmount2(Set<Id> assetsId) {
        try {
            // Validasi input
            if (assetsId == null || assetsId.isEmpty()) {
                System.debug('No asset IDs provided');
                return;
            }
            
            System.debug('Starting calculateParentAssetAmount for ' + assetsId.size() + ' IDs');
            
            // Query to check RecordType
            List<Asset> inputRecords = [
                SELECT Id, RecordTypeId, RecordType.DeveloperName, ParentId, Parent.Opportunity__c
                FROM Asset
                WHERE Id IN :assetsId
            ];
            
            Set<Id> parentRiskIds = new Set<Id>();
            Set<Id> opportunityIds = new Set<Id>();
            
            for (Asset rec : inputRecords) {
                if (rec.RecordType.DeveloperName == RT_ASSET) {
                    if (rec.ParentId != null) {
                        parentRiskIds.add(rec.ParentId);
                        if (rec.Parent.Opportunity__c != null) {
                            opportunityIds.add(rec.Parent.Opportunity__c);
                        }
                    }
                } else if (rec.RecordType.DeveloperName == RT_RISK) {
                    parentRiskIds.add(rec.Id);
                }
            }
            
            System.debug('Extracted ' + parentRiskIds.size() + ' parent risk IDs');
            System.debug('Tracked ' + opportunityIds.size() + ' opportunity IDs from input');
            
            if (parentRiskIds.isEmpty()) {
                System.debug('No parent risks found');
                return;
            }

            List<Asset> childAssets = [
                SELECT Id, Name, ParentId, Amount_IDR_new__c, Section__c, Category__c, 
                       RecordType.DeveloperName, Parent.Opportunity__c
                FROM Asset 
                WHERE ParentId IN :parentRiskIds
                AND RecordType.DeveloperName = :RT_ASSET
            ];
            
            System.debug('Found ' + childAssets.size() + ' child assets (RecordType: Asset)');
            
            Map<Id, Decimal> parentTotalAmountMap = new Map<Id, Decimal>();
        
            for (Id parentId : parentRiskIds) {
                parentTotalAmountMap.put(parentId, 0);
            }
            
            for (Asset child : childAssets) {
                if (child.ParentId != null && child.Amount_IDR_new__c != null) {
                    Decimal currentTotal = parentTotalAmountMap.get(child.ParentId);
                    parentTotalAmountMap.put(child.ParentId, currentTotal + child.Amount_IDR_new__c);
                    System.debug('Adding ' + child.Amount_IDR_new__c + ' (Amount IDR) from ' + child.Name + ' to parent ' + child.ParentId);
                    
                    if (child.Parent.Opportunity__c != null) {
                        opportunityIds.add(child.Parent.Opportunity__c);
                    }
                }
            }
            
            List<Asset> parentRisksToUpdate = [
                SELECT Id, Name, Amount_Insured__c, RecordType.DeveloperName, Opportunity__c
                FROM Asset 
                WHERE Id IN :parentRiskIds
                AND RecordType.DeveloperName = :RT_RISK
            ];
            
            System.debug('Found ' + parentRisksToUpdate.size() + ' parent risks (RecordType: Risk)');
            
            List<Asset> assetsToUpdate = new List<Asset>();
            for (Asset parent : parentRisksToUpdate) {
                Decimal totalAmount = parentTotalAmountMap.get(parent.Id);
                Decimal oldAmount = parent.Amount_Insured__c;
                
                if (parent.Opportunity__c != null) {
                    opportunityIds.add(parent.Opportunity__c);
                }
                
                if (oldAmount != totalAmount) {
                    parent.Amount_Insured__c = totalAmount;
                    assetsToUpdate.add(parent);
                    System.debug('Updating ' + parent.Name + ' Amount_Insured__c from ' + oldAmount + ' to ' + totalAmount);
                }
            }
            
            if (!assetsToUpdate.isEmpty()) {
                update assetsToUpdate;
                System.debug('Successfully updated ' + assetsToUpdate.size() + ' parent risks Amount_Insured__c');
            } else {
                System.debug('No parent risks needed update');
            }
            
            System.debug('Total tracked opportunity IDs: ' + opportunityIds.size());
            System.debug('Opportunity IDs: ' + opportunityIds);
            
            if (!opportunityIds.isEmpty()) {
                System.debug('Calling updateOpportunityTotals for ' + opportunityIds.size() + ' opportunities');
                updateOpportunityTotals(opportunityIds);
            } else {
                System.debug('No opportunity IDs to update!');
            }
        
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in calculateParentAssetAmount: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * Helper method to update Opportunity Total_Sum_Insured__c
     * This is NOT @future so it can be called from within @future context
     * @param opportunityIds Set of Opportunity IDs to update
     */
    private static void updateOpportunityTotals(Set<Id> opportunityIds) {
        try {
            if (opportunityIds == null || opportunityIds.isEmpty()) {
                System.debug('updateOpportunityTotals: No opportunity IDs provided');
                return;
            }
            
            System.debug('updateOpportunityTotals: Processing ' + opportunityIds.size() + ' opportunities');
            
            List<Asset> allRisks = [
                SELECT Id, Name, Opportunity__c, Amount_Insured__c, RecordType.DeveloperName
                FROM Asset 
                WHERE Opportunity__c IN :opportunityIds 
                AND RecordType.DeveloperName = :RT_RISK
            ];
            
            System.debug('updateOpportunityTotals: Found ' + allRisks.size() + ' risks');
            
            Map<Id, Decimal> opportunityTotalMap = new Map<Id, Decimal>();
            
            for (Id oppId : opportunityIds) {
                opportunityTotalMap.put(oppId, 0);
            }
            
            for (Asset risk : allRisks) {
                if (risk.Opportunity__c != null && risk.Amount_Insured__c != null) {
                    Decimal currentTotal = opportunityTotalMap.get(risk.Opportunity__c);
                    opportunityTotalMap.put(risk.Opportunity__c, currentTotal + risk.Amount_Insured__c);
                    System.debug('  Adding ' + risk.Amount_Insured__c + ' from Risk ' + risk.Name + ' to Opportunity ' + risk.Opportunity__c);
                }
            }
            
            System.debug('Opportunity totals calculated: ' + opportunityTotalMap);
            
            List<Opportunity> opportunitiesToUpdate = [
                SELECT Id, Name, Total_Sum_Insured__c, RecordType.Name
                FROM Opportunity 
                WHERE Id IN :opportunityIds
                AND RecordType.Name = 'General'
            ];
            
            System.debug('Found ' + opportunitiesToUpdate.size() + ' opportunities with RecordType = General');
            
            if (opportunitiesToUpdate.size() < opportunityIds.size()) {
                Integer skipped = opportunityIds.size() - opportunitiesToUpdate.size();
                System.debug('Skipped ' + skipped + ' opportunities (RecordType != General)');
            }
            
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Opportunity opp : opportunitiesToUpdate) {
                Decimal totalAmount = opportunityTotalMap.get(opp.Id);
                Decimal oldAmount = opp.Total_Sum_Insured__c;
                
                if (oldAmount != totalAmount) {
                    opp.Total_Sum_Insured__c = totalAmount;
                    oppsToUpdate.add(opp);
                    System.debug('  Updating Opportunity ' + opp.Name + ' (RecordType: ' + opp.RecordType.Name + ') Total_Sum_Insured__c from ' + oldAmount + ' to ' + totalAmount);
                }
            }
            
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
                System.debug('Successfully updated Total_Sum_Insured__c for ' + oppsToUpdate.size() + ' opportunities (RecordType = General)');
            } else {
                System.debug('No opportunities needed update (amounts unchanged or no General RecordType opportunities)');
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in updateOpportunityTotals: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * Future method untuk recalculate Opportunity Total_Sum_Insured__c berdasarkan sum dari semua Risk Amount_Insured__c
     * Method ini akan find semua Risks di opportunity dan sum Amount_Insured__c mereka ke Opportunity.Total_Sum_Insured__c
     * @param opportunityIds Set of Opportunity IDs
     */
    // @future
    // public static void recalculateAssetsByOpportunity(Set<Id> opportunityIds) {
    //     try {
    //         if (opportunityIds == null || opportunityIds.isEmpty()) {
    //             System.debug('No opportunity IDs provided');
    //             return;
    //         }
            
    //         System.debug('Starting recalculation for opportunities: ' + opportunityIds);
            
    //         List<Asset> allRisks = [
    //             SELECT Id, Name, Opportunity__c, Amount_Insured__c, RecordType.DeveloperName
    //             FROM Asset 
    //             WHERE Opportunity__c IN :opportunityIds 
    //             AND RecordType.DeveloperName = :RT_RISK
    //         ];
            
    //         System.debug('Found ' + allRisks.size() + ' risks in opportunities');
            
    //         Map<Id, Decimal> opportunityTotalMap = new Map<Id, Decimal>();
            
    //         for (Id oppId : opportunityIds) {
    //             opportunityTotalMap.put(oppId, 0);
    //         }
            
    //         for (Asset risk : allRisks) {
    //             if (risk.Opportunity__c != null && risk.Amount_Insured__c != null) {
    //                 Decimal currentTotal = opportunityTotalMap.get(risk.Opportunity__c);
    //                 opportunityTotalMap.put(risk.Opportunity__c, currentTotal + risk.Amount_Insured__c);
    //                 System.debug('Adding ' + risk.Amount_Insured__c + ' from Risk ' + risk.Name + ' to Opportunity ' + risk.Opportunity__c);
    //             }
    //         }
            
    //         List<Opportunity> opportunitiesToUpdate = [
    //             SELECT Id, Name, Total_Sum_Insured__c, RecordType.Name
    //             FROM Opportunity 
    //             WHERE Id IN :opportunityIds
    //             AND RecordType.Name = 'General'
    //         ];
            
    //         System.debug('Found ' + opportunitiesToUpdate.size() + ' opportunities with RecordType = General');
            
    //         if (opportunitiesToUpdate.size() < opportunityIds.size()) {
    //             Integer skipped = opportunityIds.size() - opportunitiesToUpdate.size();
    //             System.debug('Skipped ' + skipped + ' opportunities (RecordType != General)');
    //         }
            
    //         List<Opportunity> oppsToUpdate = new List<Opportunity>();
    //         for (Opportunity opp : opportunitiesToUpdate) {
    //             Decimal totalAmount = opportunityTotalMap.get(opp.Id);
    //             Decimal oldAmount = opp.Total_Sum_Insured__c;
                
    //             if (oldAmount != totalAmount) {
    //                 opp.Total_Sum_Insured__c = totalAmount;
    //                 oppsToUpdate.add(opp);
    //                 System.debug('Updating Opportunity ' + opp.Name + ' (RecordType: ' + opp.RecordType.Name + ') Total_Sum_Insured__c from ' + oldAmount + ' to ' + totalAmount);
    //             }
    //         }
            
    //         if (!oppsToUpdate.isEmpty()) {
    //             update oppsToUpdate;
    //             System.debug('Successfully updated Total_Sum_Insured__c for ' + oppsToUpdate.size() + ' opportunities (RecordType = General)');
    //         } else {
    //             System.debug('No opportunities needed update (amounts unchanged or no General RecordType opportunities)');
    //         }
            
    //     } catch (Exception e) {
    //         System.debug(LoggingLevel.ERROR, 'Error in recalculateAssetsByOpportunity: ' + e.getMessage());
    //         System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
    //     }
    // }
    
    /**
     * Helper method untuk mendapatkan Parent Risk IDs dari Child Assets
     * Method ini hanya return Risk IDs dari Assets (bukan dari child Risks)
     * 
     * @param childAssetIds Set of Child Asset IDs (RecordType = Asset)
     * @return Set of Parent Risk IDs
     */
    public static Set<Id> getParentAssetIds(Set<Id> childAssetIds) {
        Set<Id> parentIds = new Set<Id>();
        
        if (childAssetIds == null || childAssetIds.isEmpty()) {
            return parentIds;
        }
        
        List<Asset> childAssets = [
            SELECT Id, ParentId, RecordType.DeveloperName
            FROM Asset 
            WHERE Id IN :childAssetIds 
            AND ParentId != null
            AND RecordType.DeveloperName = :RT_ASSET
        ];
        
        for (Asset child : childAssets) {
            if (child.ParentId != null) {
                parentIds.add(child.ParentId);
            }
        }
        
        System.debug('Found ' + parentIds.size() + ' parent risk IDs from ' + childAssetIds.size() + ' child assets');
        return parentIds;
    }
    
    /**
     * Helper method untuk mendapatkan Opportunity IDs dari Assets
     * Works untuk both Risk dan Asset records
     * 
     * @param assetIds Set of Asset IDs (bisa Risk atau Asset RecordType)
     * @return Set of Opportunity IDs
     */
    public static Set<Id> getOpportunityIds(Set<Id> assetIds) {
        Set<Id> opportunityIds = new Set<Id>();
        
        if (assetIds == null || assetIds.isEmpty()) {
            return opportunityIds;
        }
        
        List<Asset> assets = [
            SELECT Id, Opportunity__c 
            FROM Asset 
            WHERE Id IN :assetIds 
            AND Opportunity__c != null
        ];
        
        for (Asset asset : assets) {
            if (asset.Opportunity__c != null) {
                opportunityIds.add(asset.Opportunity__c);
            }
        }
        
        System.debug('Found ' + opportunityIds.size() + ' opportunity IDs from ' + assetIds.size() + ' assets');
        return opportunityIds;
    }
}