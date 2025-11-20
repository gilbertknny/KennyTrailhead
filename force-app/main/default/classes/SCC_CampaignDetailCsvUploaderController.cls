/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 12-08-2025
 * @last modified by  : Christian Vieri
**/
public with sharing class SCC_CampaignDetailCsvUploaderController {
    @AuraEnabled
    public static void uploadCsvFile(Object records) {
        try {
            List<Campaign_Detail__c> campaignDetails = 
                (List<Campaign_Detail__c>) JSON.deserialize(
                    JSON.serialize(records), 
                    List<Campaign_Detail__c>.class
                );

            if (!campaignDetails.isEmpty()) {
                insert campaignDetails;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error inserting records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String downloadTemplate(String templateName) {
        try {
            StaticResource template = [
                SELECT Id, Body FROM StaticResource 
                WHERE Name = :templateName LIMIT 1
            ];
            return template.Body.toString();
        } catch (Exception e) {
            throw new AuraHandledException('Error downloading template: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getCampaignDetailFieldApiNames() {
        Schema.SObjectType t = Campaign_Detail__c.SObjectType;
        Map<String, Schema.SObjectField> fmap = t.getDescribe().fields.getMap();
        return new List<String>(fmap.keySet()); 
    }

}