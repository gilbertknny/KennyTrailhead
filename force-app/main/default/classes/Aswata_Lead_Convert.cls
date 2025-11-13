public with sharing class Aswata_Lead_Convert {
    
    @InvocableMethod(label='Convert Leads with Custom Mapping')
    public static List<LeadConvertResultWrapper> convertLeads(List<LeadIdWrapper> leadIdWrappers) {
        List<LeadConvertResultWrapper> results = new List<LeadConvertResultWrapper>();
        Map<Id, LeadConvertResultWrapper> leadResultsMap = new Map<Id, LeadConvertResultWrapper>();

        // Extract Lead IDs
        Set<Id> leadIds = new Set<Id>();
        for (LeadIdWrapper wrapper : leadIdWrappers) {
            leadIds.add(wrapper.leadId);
        }

        // Query Leads
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Company, Email, Phone, Account_Segment__c, Account__c, Interest_COB__c,
            Account_Sub_Segment__c, Account_Type__c,Account_Pipeline_Status__c, Channel__c, Business_Segmentation__c, 
            Province__c, City__c, Village__c, Zip__c, Address__c, Description, OwnerId FROM Lead WHERE Id IN :leadIds
        ];

        // Prepare Accounts and Contacts
        List<Account> accountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();

        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SObjectType = 'Account' AND Name IN ('Individu', 'Business') and IsActive = true
        ]) {
            recordTypeMap.put(rt.Name, rt.Id);
        }

         System.debug('recordTypeMap: ' +recordTypeMap);

        for (Lead lead : leads) {
            leadMap.put(lead.Id, lead);
            System.debug('Business Segment: ' + lead.Account_Segment__c);
            Id recordTypeId = lead.Account_Segment__c == 'I' 
                              ? recordTypeMap.get('Individu') 
                              : recordTypeMap.get('Business');
            System.debug('recordTypeId: ' + recordTypeId);

            String rawPhone = lead.Phone;
            String phoneArea = '';
            String phoneNumber = '';
            System.debug('Process Account' + rawPhone);

            if (!String.isBlank(rawPhone)) {
                rawPhone = rawPhone != null ? rawPhone.trim() : '';

                // If number starts with "0"
                if (rawPhone.startsWith('0')) {
                    phoneArea = '+62';
                    phoneNumber = rawPhone.substring(1); 
                    // remove leading zero
                    System.debug('Process with 0' + phoneArea);
                    System.debug('Process with 0' + phoneNumber);
                } 
                // If number already starts with +62
                else if (rawPhone.startsWith('+62')) {
                    phoneArea = '+62';
                    phoneNumber = rawPhone.replace('+62', '');
                    
                    System.debug('Process with +62' + phoneArea);
                    System.debug('Process with +62' + phoneNumber);
                } 
                // If number starts with 62 (no +)
                else if (rawPhone.startsWith('62')) {
                    phoneArea = '+62';
                    phoneNumber = rawPhone.substring(2);
                    
                    System.debug('Process with 62' + phoneArea);
                    System.debug('Process with 62' + phoneNumber);
                } 
                // Fallback: unknown format
                else {
                    phoneArea = '';
                    phoneNumber = rawPhone;
                    
                    System.debug('Process with +62' + phoneArea);
                    System.debug('Process with +62' + phoneNumber);
                }
            }

            Account acc = new Account(
                Name = lead.FirstName + ' ' + lead.LastName  ,
                Phone = lead.Phone,
                House_Phone__c = phoneNumber,
                House_Phone_Area__c = phoneArea,
                Email__c = lead.Email,
                Account_Segment__c = lead.Account_Segment__c,
                Account_Sub_Segment__c = lead.Account_Sub_Segment__c,
                Type = lead.Account_Type__c,
                Account_Channel__c = lead.Channel__c,
                Account_Pipeline_Status__c = lead.Account_Pipeline_Status__c,
                Business_Segmentation__c = lead.Business_Segmentation__c,
                Province__c = lead.Province__c,
                City__c = lead.City__c,
                Village__c = lead.Village__c,
                Zip__c = lead.Zip__c,
                Address__c = lead.Description,
                Address_LU__c = lead.Address__c,
                recordTypeId = recordTypeId,
                OwnerId = lead.OwnerId, 
                ParentId = lead.Account__c,
                Has_Beneficial_Owner__c = 'Y',
                Interest_COB__c = lead.Interest_COB__c
            );
            accountsToInsert.add(acc);
        }

        // Insert Accounts in bulk
        if(accountsToInsert.size()>=1){
            insert accountsToInsert;
        }
        
        // Link Leads to Accounts
        for (Integer i = 0; i < leads.size(); i++) {
            Lead lead = leads[i];
            Account acc = accountsToInsert[i];
           

            String rawPhone = lead.Phone;
            String phoneArea = '';
            String phoneNumber = '';
            System.debug('Process Account' + rawPhone);

            if (!String.isBlank(rawPhone)) {
                rawPhone = rawPhone != null ? rawPhone.trim() : '';

                // If number starts with "0"
                if (rawPhone.startsWith('0')) {
                    phoneArea = '+62';
                    phoneNumber = rawPhone.substring(1); 
                    // remove leading zero
                    System.debug('Process with 0' + phoneArea);
                    System.debug('Process with 0' + phoneNumber);
                } 
                // If number already starts with +62
                else if (rawPhone.startsWith('+62')) {
                    phoneArea = '+62';
                    phoneNumber = rawPhone.replace('+62', '');
                    
                    System.debug('Process with +62' + phoneArea);
                    System.debug('Process with +62' + phoneNumber);
                } 
                // If number starts with 62 (no +)
                else if (rawPhone.startsWith('62')) {
                    phoneArea = '+62';
                    phoneNumber = rawPhone.substring(2);
                    
                    System.debug('Process with 62' + phoneArea);
                    System.debug('Process with 62' + phoneNumber);
                } 
                // Fallback: unknown format
                else {
                    phoneArea = '';
                    phoneNumber = rawPhone;
                    
                    System.debug('Process with +62' + phoneArea);
                    System.debug('Process with +62' + phoneNumber);
                }
            }


            Contact con = new Contact(
                FirstName = lead.FirstName,
                LastName = lead.LastName,
                Email = lead.Email,
                AccountId = acc.Id,
                Status__c = 'CP',
                Phone_Area__c  = phoneArea,
                Phone = phoneNumber,
                Address__c = lead.Description,
                Actived__c = '1'
            );

            System.debug('con: ' + con);
            contactsToInsert.add(con);
        }

        if(contactsToInsert.size()>=1){
        // Insert Contacts in bulk
            insert contactsToInsert;
        }
        

        if(leads.size()>=1){
        // Convert Leads
            for (Integer i = 0; i < leads.size(); i++) {
                Lead lead = leads[i];
                Account acc = new Account();
                Contact con = new Contact();
                if(accountsToInsert.size()>=1){
                    acc = accountsToInsert[i];
                }
                if(contactsToInsert.size()>=1){
                    con = contactsToInsert[i];
                }
                LeadConvertResultWrapper resultWrapper = new LeadConvertResultWrapper();

                try {
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(lead.Id);
                    lc.setConvertedStatus(getConvertedStatus());
                    lc.setAccountId(acc.Id);
                    lc.setContactId(con.Id);
                    lc.setDoNotCreateOpportunity(true); // Set false if you want to create Opp

                    Database.LeadConvertResult lcr = Database.convertLead(lc);

                    resultWrapper.success = lcr.isSuccess();
                    resultWrapper.message = 'Lead converted successfully.';
                    resultWrapper.convertedAccountId = acc.Id;
                    resultWrapper.convertedContactId = con.Id;

                } catch (Exception e) {
                    resultWrapper.success = false;
                    resultWrapper.message = e.getMessage();
                }

                leadResultsMap.put(lead.Id, resultWrapper);
            }

        }
        // Preserve order of original input
        for (LeadIdWrapper wrapper : leadIdWrappers) {
            results.add(leadResultsMap.get(wrapper.leadId));
        }

        return results;
    }

    public class LeadIdWrapper {
        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;
    }

    public class LeadConvertResultWrapper {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public Id convertedAccountId;
        @InvocableVariable public Id convertedContactId;
    }

    private static String getConvertedStatus() {
        for (LeadStatus status : [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1]) {
            return status.MasterLabel;
        }
        return 'Qualified'; // fallback
    }
}