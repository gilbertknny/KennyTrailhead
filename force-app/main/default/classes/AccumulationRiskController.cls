/**
 * @description  Controller class to retrieve related Asset (Risk) records 
 *               for a given Accumulation__c parent Id.
 * @author       Peppp
 * @createdDate  
 * @group        Accumulation
 */
public with sharing class AccumulationRiskController {

    /**
     * @description   Returns list of Asset records linked to the specified Accumulation__c.
     * @param         accumulationId   The Id of the Accumulation__c parent record.
     * @return        List of Asset records sorted by CreatedDate DESC.
     * @AuraEnabled(cacheable=true)
     */
    @AuraEnabled(cacheable=true)
    public static List<Asset> getRelatedRisks(String accumulationId) {
        if (String.isBlank(accumulationId)) {
            return new List<Asset>();
        }

        return [
            SELECT Id, Name, SerialNumber, InstallDate, Account.Name, Accumulation__c
            FROM Asset 
            WHERE Accumulation__c = :accumulationId
            ORDER BY CreatedDate DESC
        ];
    }
}