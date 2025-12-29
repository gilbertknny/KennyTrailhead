public with sharing class ListTotalAmountPerCurrency_Controller {
    @AuraEnabled(cacheable=true)
    public static List<AssetSummaryWrapper> getAssetSummary(String riskId) {
        // group by lookup IDs
        List<AggregateResult> groupedResults = [
            SELECT 
                Section__c sectionId, 
                Currency__c currencyId, 
                SUM(Amount__c) totalAmount,
                SUM(Amount_IDR_New__c) totalAmountIDR
            FROM Asset
            WHERE ParentId = :riskId
            GROUP BY Section__c, Currency__c
        ];

        // collect IDs to resolve names later
        Set<Id> sectionIds = new Set<Id>();
        Set<Id> currencyIds = new Set<Id>();
        for (AggregateResult ar : groupedResults) {
            if (ar.get('sectionId') != null) sectionIds.add((Id) ar.get('sectionId'));
            if (ar.get('currencyId') != null) currencyIds.add((Id) ar.get('currencyId'));
        }

        // query lookup names
        Map<Id, String> sectionNames = new Map<Id, String>();
        Map<Id, String> currencyNames = new Map<Id, String>();

        for (Master_Data__c s : [
            SELECT Id, Name FROM Master_Data__c WHERE Id IN :sectionIds
        ]) {
            sectionNames.put(s.Id, s.Name);
        }

        for (Master_Data__c c : [
            SELECT Id, Name FROM Master_Data__c WHERE Id IN :currencyIds
        ]) {
            currencyNames.put(c.Id, c.Name);
        }

        // build final wrappers
        List<AssetSummaryWrapper> summaries = new List<AssetSummaryWrapper>();
        for (AggregateResult ar : groupedResults) {
            Id sectionId = (Id) ar.get('sectionId');
            Id currencyId = (Id) ar.get('currencyId');
            summaries.add(new AssetSummaryWrapper(
                sectionId,
                sectionNames.get(sectionId),
                currencyId,
                currencyNames.get(currencyId),
                (Decimal) ar.get('totalAmount'),
                (Decimal) ar.get('totalAmountIDR')
            ));
        }

        return summaries;
    }

    public class AssetSummaryWrapper {
        @AuraEnabled public Id sectionId { get; set; }
        @AuraEnabled public String sectionName { get; set; }
        @AuraEnabled public Id currencyId { get; set; }
        @AuraEnabled public String currencyName { get; set; }
        @AuraEnabled public Decimal totalAmount { get; set; }
        @AuraEnabled public Decimal totalAmountIDR { get; set; } // ✅ new field

        public AssetSummaryWrapper(Id sId, String sName, Id cId, String cName, Decimal total, Decimal totalIDR) {
            sectionId = sId;
            sectionName = sName;
            currencyId = cId;
            currencyName = cName;
            totalAmount = total;
            totalAmountIDR = totalIDR;
        }
    }
}