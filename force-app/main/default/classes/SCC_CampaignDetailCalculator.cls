/**  
 * @description       : Menghitung Total Value dari Campaign yang di Trigger dari Flow  
 * @author            : Ardyta Yudianto  
 * @group             :   
 * @last modified on  : 21-02-2025
 * @last modified by  : Ardyta Yudianto
**/  
public with sharing class SCC_CampaignDetailCalculator {  
    @InvocableMethod(label='Calculate Campaign Totals' description='Calculate Total Agent, Customers, and Calls')  
    public static void calculateTotals(List<Id> campaignIds) {  
        // Map untuk menyimpan hasil per kampanye  
        Map<Id, Campaign__c> campaignUpdates = new Map<Id, Campaign__c>();  
  
        // Query untuk mendapatkan semua Campaign_Detail__c yang terkait dengan campaignIds  
        List<Campaign_Detail__c> campaignDetails = [  
            SELECT OwnerId, Customer_Name__c, Duration__c   
            FROM Campaign_Detail__c   
            WHERE Campaign__c IN :campaignIds  
        ];  
        
        // Query untuk mendapatkan user IDs dengan permission set SCC_Telesales_Maker
        Set<Id> usersWithPermSet = new Set<Id>();
        for(PermissionSetAssignment psa : [
            SELECT AssigneeId 
            FROM PermissionSetAssignment 
            WHERE PermissionSet.Name = 'SCC_Telesales_Maker'
        ]) {
            usersWithPermSet.add(psa.AssigneeId);
        }
  
        // Set untuk menyimpan nilai unik  
        Set<Id> uniqueOwners = new Set<Id>();  
        Set<String> uniqueCustomers = new Set<String>();  
        Decimal totalDuration = 0;  
  
        // Menghitung total  
        for (Campaign_Detail__c detail : campaignDetails) {  
            // Menambahkan Owner ke set unik hanya jika memiliki permission set yang sesuai
            if (detail.OwnerId != null && usersWithPermSet.contains(detail.OwnerId)) {  
                uniqueOwners.add(detail.OwnerId);  
            }  
            // Menambahkan Customer Name ke set unik  
            if (detail.Customer_Name__c != null) {  
                uniqueCustomers.add(detail.Customer_Name__c);  
            }  
            // Menambahkan Duration ke total  
            if (detail.Duration__c != null) {  
                totalDuration += detail.Duration__c;  
            }  
        }  
  
        // Mengupdate nilai total di Campaign__c  
        for (Id campaignId : campaignIds) {  
            Campaign__c campaign = new Campaign__c(  
                Id = campaignId,  
                Total_Agent__c = uniqueOwners.size(),  
                Total_Customer__c = uniqueCustomers.size(),  
                Total_Call__c = totalDuration  
            );  
            campaignUpdates.put(campaignId, campaign);  
        }  
  
        // Melakukan update pada Campaign__c  
        if (!campaignUpdates.isEmpty()) {  
            update campaignUpdates.values();  
        }
    }  
}