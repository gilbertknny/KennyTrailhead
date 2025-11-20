public without sharing class SCC_AccountInformationController {
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountData(Id recordId) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('Current user does not have permission to access Account records.');
        }
        try {
            return [SELECT Id, SCC_cifno__c, Name, SCC_Address__c, Provinsi__c, SCC_Jenis_Nasabah__c, SCC_TanggalLahir__c,
                SCC_Tipe_Nasabah__c, Phone, SCC_Primary_Email__c, SCC_Facebook__c, SCC_Instagram__c,
                SCC_X__c,RecordType.Name FROM Account WHERE Id = :recordId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching account data: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAccountFields(Id accountId, String instagram, String facebook, String x) {
        // Perform Field-Level Security (FLS) check
        if (!Schema.sObjectType.Account.fields.SCC_Instagram__c.isUpdateable() ||
            !Schema.sObjectType.Account.fields.SCC_Facebook__c.isUpdateable() ||
            !Schema.sObjectType.Account.fields.SCC_X__c.isUpdateable()) {
            throw new AuraHandledException('Current user does not have permission to update one or more fields.');
        }
        
        // Validate input parameters
        if (String.isBlank(instagram) && String.isBlank(facebook) && String.isBlank(x)) {
            throw new AuraHandledException('At least one field value must be provided for update.');
        }
        
        try {
            Account accToUpdate = new Account(Id = accountId);
            accToUpdate.SCC_Instagram__c = instagram;
            accToUpdate.SCC_Facebook__c = facebook;
            accToUpdate.SCC_X__c = x; 
            update accToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating account fields: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAccountFromDatahub(Id accountId, String provinsi, String age) {
        if (Schema.sObjectType.Account.isUpdateable()) {
            try {
                Account accToUpdate = new Account(Id = accountId);
                accToUpdate.Provinsi__c = provinsi;
                accToUpdate.SCC_TanggalLahir__c = age;
                update accToUpdate;
            } catch (Exception e) {
                throw new AuraHandledException('Error updating account fields: ' + e.getMessage());
            }        
        }
    }
}