/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 20-05-2025
 * @last modified by  : Ardyta Yudianto
**/
public with sharing class SCC_CampaignDetailAssignmentController {
    @AuraEnabled
    public static Map<String, Object> getAllCampaignDetails() {
        Map<String, Object> result = new Map<String, Object>();
        List<Campaign_Detail__c> campaignDetails = new List<Campaign_Detail__c>();
        
        // Query untuk mendapatkan semua Campaign_Detail__c dengan field tambahan
        String query = 'SELECT Id, Name, OwnerId, CreatedDate, Campaign__r.Name, Customer_Name__c, Dial_Phone_No__c, Status__c, Owner.Name, Outbound_Category_Detail__c FROM Campaign_Detail__c';
        campaignDetails = Database.query(query);
        
        // Ambil User dengan Permission Set 'SCC_Telesales_Maker'
        Set<Id> telesalesMakerUserIds = new Set<Id>();
        List<PermissionSetAssignment> assignments = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SCC_Telesales_Maker'];
        for (PermissionSetAssignment assignment : assignments) {
            telesalesMakerUserIds.add(assignment.AssigneeId);
        }
        
        // Filter Campaign_Detail__c yang Owner-nya tidak memiliki Permission Set 'SCC_Telesales_Maker'
        List<Campaign_Detail__c> filteredCampaignDetails = new List<Campaign_Detail__c>();
        for (Campaign_Detail__c detail : campaignDetails) {
            if (!telesalesMakerUserIds.contains(detail.OwnerId)) {
                filteredCampaignDetails.add(detail);
            }
        }
        
        result.put('campaignDetails', filteredCampaignDetails);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getCampaignDetails(Date createdDate) {
        Map<String, Object> result = new Map<String, Object>();
        List<Campaign_Detail__c> campaignDetails = new List<Campaign_Detail__c>();
        
        // Debug log untuk melacak CreatedDate yang diterima
        System.debug('CreatedDate received: ' + createdDate);
        
        if (createdDate == null) {
            // Jika CreatedDate kosong, panggil getAllCampaignDetails
            return getAllCampaignDetails();
        }
        
        // Menghitung batas waktu untuk query
        DateTime startDateTime = DateTime.newInstance(createdDate, Time.newInstance(0, 0, 0, 0)); // Awal hari
        DateTime endDateTime = DateTime.newInstance(createdDate, Time.newInstance(23, 59, 59, 999)); // Akhir hari

        // Query untuk mendapatkan Campaign_Detail__c berdasarkan CreatedDate dengan field tambahan
        String query = 'SELECT Id, Name, OwnerId, CreatedDate, Campaign__r.Name, Customer_Name__c, Dial_Phone_No__c, Status__c, Owner.Name, Outbound_Category_Detail__c FROM Campaign_Detail__c WHERE CreatedDate >= :startDateTime AND CreatedDate <= :endDateTime';
        campaignDetails = Database.query(query);
        
        // Debug log untuk melacak jumlah data yang ditemukan
        System.debug('Campaign details found: ' + campaignDetails.size());
        
        // Ambil User dengan Permission Set 'SCC_Telesales_Maker'
        Set<Id> telesalesMakerUserIds = new Set<Id>();
        List<PermissionSetAssignment> assignments = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SCC_Telesales_Maker'];
        for (PermissionSetAssignment assignment : assignments) {
            telesalesMakerUserIds.add(assignment.AssigneeId);
        }
        
        // Filter Campaign_Detail__c yang Owner-nya tidak memiliki Permission Set 'SCC_Telesales_Maker'
        List<Campaign_Detail__c> filteredCampaignDetails = new List<Campaign_Detail__c>();
        for (Campaign_Detail__c detail : campaignDetails) {
            if (!telesalesMakerUserIds.contains(detail.OwnerId)) {
                filteredCampaignDetails.add(detail);
            }
        }
        
        result.put('campaignDetails', filteredCampaignDetails);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getMyCampaignDetails() {
        Map<String, Object> result = new Map<String, Object>();
        List<Campaign_Detail__c> myCampaignDetails = new List<Campaign_Detail__c>();

        // Mendapatkan Id user yang sedang login
        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId: ' + currentUserId);

        // Query Campaign_Detail__c yang dimiliki oleh current user
        String query = 'SELECT Id, Name, OwnerId, CreatedDate, Campaign__r.Name, Customer_Name__c, Dial_Phone_No__c, Status__c, Owner.Name, Outbound_Category_Detail__c ' +
                    'FROM Campaign_Detail__c ' +
                    'WHERE OwnerId = :currentUserId';
        myCampaignDetails = Database.query(query);
        System.debug('myCampaignDetails: ' + myCampaignDetails);

        // Masukkan ke dalam map dengan key 'campaignDetails'
        result.put('campaignDetails', myCampaignDetails);
        return result;
    }

    @AuraEnabled
    public static List<User> getTelesalesMakers() {
        // Mengambil pengguna dengan Permission Set 'SCC_Telesales_Maker'
        return [SELECT Id, Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SCC_Telesales_Maker')];
    }

    @AuraEnabled
    public static void assignCampaignDetails(Map<Id, List<Id>> assignments) {
        // Debug log untuk melacak assignments yang diterima
        System.debug('Assignments received: ' + assignments);

        List<Campaign_Detail__c> campaignDetailsToUpdate = new List<Campaign_Detail__c>();

        for (Id makerId : assignments.keySet()) {
            List<Id> campaignDetailIds = assignments.get(makerId);
            for (Id campaignDetailId : campaignDetailIds) {
                Campaign_Detail__c campaignDetail = new Campaign_Detail__c(Id = campaignDetailId, OwnerId = makerId);
                campaignDetailsToUpdate.add(campaignDetail);
            }
        }

        // Debug log untuk melacak jumlah campaign details yang akan diperbarui
        System.debug('Campaign details to update: ' + campaignDetailsToUpdate.size());

        try {
            update campaignDetailsToUpdate;
            System.debug('Campaign details updated successfully');
        } catch (DmlException e) {
            System.debug('Error updating campaign details: ' + e.getMessage());
            throw new AuraHandledException('Error updating campaign details: ' + e.getMessage());
        }
    }
}