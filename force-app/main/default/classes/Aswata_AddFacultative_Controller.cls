public with sharing class Aswata_AddFacultative_Controller {
    
    @AuraEnabled(cacheable=false)
    public static List<Asset> getRiskList() {
        return [
            SELECT Id,
                Name,
                Amount_Insured__c,
                Risk_ID__c,
                Opportunity__c,
                Opportunity__r.Name,
                Opportunity__r.Busreq_ID__c 
                FROM Asset WHERE RecordType.Name = 'Risk' 
                AND Has_Facultative__c = true 
                AND Facultative_Owner__c =: UserInfo.getUserId() 
                AND Opportunity__r.Busreq_ID__c != null
                AND Facultative_Folder__c = null WITH SECURITY_ENFORCED  
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getRiskByFolder(Id recordId) {
        return [
            SELECT Id,
                   Name,
                   Amount_Insured__c,
                   Risk_ID__c,
                   Opportunity__c,
                   Opportunity__r.Name,
                   Opportunity__r.Busreq_ID__c
            FROM Asset
            WHERE RecordType.Name = 'Risk'
              AND Has_Facultative__c = true
              //AND Opportunity__r.Opportunity_Type__c != 'Facultative Outward'
              AND Facultative_Folder__c = :recordId
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled
    public static void updateSelectedRisks(List<Id> assetIds, Id folderId) {
        
        System.debug(assetIds.size() + ' - ' + folderId);
        if (assetIds == null || assetIds.isEmpty()) return;

        List<Asset> assetsToUpdate = [
            SELECT Id, Facultative_Folder__c
            FROM Asset
            WHERE Id IN :assetIds
            WITH SECURITY_ENFORCED
        ];

        for (Asset a : assetsToUpdate) {
            a.Facultative_Folder__c = folderId;
        }

        update assetsToUpdate;
    }

    @AuraEnabled(cacheable=false)
    public static List<Account> searchAccounts(String searchKey) {
        if (String.isBlank(searchKey)) {
            return new List<Account>();
        }
        return [
            SELECT Id, Name, Insurance_ID__c
            FROM Account
            WHERE Name LIKE :('%' + searchKey + '%') and Type = 'REINSURANCE'
            With SECURITY_ENFORCED 
            ORDER BY Name
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static void updateFacultativeStatus(Id recordId, String newStatus) {
        if (String.isBlank(recordId) || String.isBlank(newStatus)) {
            throw new AuraHandledException('Missing parameters.');
        }

        Opportunity so = [SELECT Id, Offering_status__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        so.Offering_status__c = newStatus;
        update so;
    }


    

}