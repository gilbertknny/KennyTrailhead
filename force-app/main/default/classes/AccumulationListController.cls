/**
 * @description Controller class for managing accumulation records related to quotes
 * @author Pepp
 * @date 2025
 */
public with sharing class AccumulationListController {
    
    public class AccumulationRecord {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String groupId { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public String version { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AccumulationRecord> getAccumulationsByQuote(String quoteId) {
        try {
            if (String.isBlank(quoteId)) {
                return new List<AccumulationRecord>();
            }
            
            // 1. Ambil Data Opportunity dan Business Request ID dari Quote
            Quote quoteInfo = getQuoteDetails(quoteId);
            
            if (quoteInfo == null || quoteInfo.OpportunityId == null) {
                return new List<AccumulationRecord>();
            }
            
            Set<Id> accumulationIds = new Set<Id>();
            Id opportunityId = quoteInfo.OpportunityId;
            String businessRequestId = quoteInfo.Opportunity.Busreq_ID__c;

            // --- STRATEGI PENCARIAN GABUNGAN ---
            
            // Cara 1: Cari Accumulation yang masih punya Asset (Biasanya yang Baru)
            accumulationIds.addAll(getAccumulationIdsFromAssets(opportunityId));
            
            // Cara 2: Cari Accumulation yang masih punya Risk (Biasanya yang Original)
            if (quoteInfo.Risk_Name__c != null) {
                accumulationIds.addAll(getAccumulationIdsFromRiskDirect(quoteInfo.Risk_Name__c));
            }
            
            // Cara 3 (SOLUSI UTAMA): Cari berdasarkan Business Request ID
            // Ini akan menemukan Accumulation lama yang sudah "ditinggalkan" oleh Risk/Asset
            // asalkan Business Request ID-nya sama.
            if (String.isNotBlank(businessRequestId)) {
                accumulationIds.addAll(getAccumulationIdsByRequestNum(businessRequestId));
            }

            if (accumulationIds.isEmpty()) {
                return new List<AccumulationRecord>();
            }
            
            return buildAccumulationRecords(accumulationIds);
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error fetching accumulations: ' + ex.getMessage());
            throw new AuraHandledException('Error fetching accumulations: ' + ex.getMessage());
        }
    }
    
    // Helper: Ambil detail Quote + Busreq ID Opportunity
    private static Quote getQuoteDetails(String quoteId) {
        List<Quote> quotes = [
            SELECT OpportunityId, Opportunity.Busreq_ID__c, Risk_Name__c 
            FROM Quote 
            WHERE Id = :quoteId 
            LIMIT 1
        ];
        return quotes.isEmpty() ? null : quotes[0];
    }
    
    // Helper 1: Ambil dari Asset (Standard)
    private static Set<Id> getAccumulationIdsFromAssets(Id opportunityId) {
        Set<Id> ids = new Set<Id>();
        for (Asset a : [SELECT Accumulation__c FROM Asset WHERE Opportunity__c = :opportunityId AND Accumulation__c != null]) {
            ids.add(a.Accumulation__c);
        }
        return ids;
    }

    // Helper 2: Ambil dari Risk (Standard)
	private static Set<Id> getAccumulationIdsFromRiskDirect(Id riskId) {
        Set<Id> ids = new Set<Id>();
        try {
            // FIX: Mengganti 'Risk__c' menjadi 'Asset' sesuai info user
            String query = 'SELECT Accumulation__c FROM Asset WHERE Id = :riskId LIMIT 1';
            
            // Execute Dynamic Query
            List<SObject> assets = Database.query(String.escapeSingleQuotes(query));
            
            if (!assets.isEmpty() && assets[0].get('Accumulation__c') != null) {
                ids.add((Id)assets[0].get('Accumulation__c'));
            }
        } catch (Exception e) { 
            System.debug('Error in getAccumulationIdsFromRiskDirect: ' + e.getMessage());
        }
        return ids;
    }

    // Helper 3: Ambil berdasarkan Request Number (PENYELAMAT DATA HILANG)
    private static Set<Id> getAccumulationIdsByRequestNum(String busReqId) {
        Set<Id> ids = new Set<Id>();
        
        // Mencari semua accumulation yang punya Request Number sama
        List<Accumulation__c> accList = [
            SELECT Id FROM Accumulation__c 
            WHERE Request_Number__c = :busReqId
        ];
        
        for (Accumulation__c acc : accList) {
            ids.add(acc.Id);
        }
        return ids;
    }
    
    private static List<AccumulationRecord> buildAccumulationRecords(Set<Id> accumulationIds) {
        List<AccumulationRecord> results = new List<AccumulationRecord>();
        
        List<Accumulation__c> accumulations = [
            SELECT Id, Name, Group_ID__c, CreatedDate, Version__c
            FROM Accumulation__c
            WHERE Id IN :accumulationIds
            AND Group_ID__c != NULL
            ORDER BY CreatedDate DESC 
        ];
        
        for (Accumulation__c acc : accumulations) {
            AccumulationRecord rec = new AccumulationRecord();
            rec.id = acc.Id;
            rec.name = acc.Name;
            rec.groupId = String.isNotBlank(acc.Group_ID__c) ? acc.Group_ID__c : '-';
            rec.version = acc.Version__c;
            rec.createdDate = acc.CreatedDate;
            results.add(rec);
        }
        return results;
    }
}