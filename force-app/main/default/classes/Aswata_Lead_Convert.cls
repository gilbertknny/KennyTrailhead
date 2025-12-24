public with sharing class Aswata_Lead_Convert {

    @InvocableMethod(label='Convert Leads with Custom Mapping')
    public static List<LeadConvertResultWrapper> convertLeads(List<LeadIdWrapper> leadIdWrappers) {

        List<LeadConvertResultWrapper> results = new List<LeadConvertResultWrapper>();
        Map<Id, LeadConvertResultWrapper> resultMap = new Map<Id, LeadConvertResultWrapper>();

        Set<Id> leadIds = new Set<Id>();
        for (LeadIdWrapper w : leadIdWrappers) {
            leadIds.add(w.leadId);
        }

        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, FirstName, LastName, Company, Email, Phone, OwnerId,
                   Account__c, Interest_COB__c, Description, Address__c,
                   Account_Segment__c, Account_Sub_Segment__c, Account_Type__c,
                   Account_Pipeline_Status__c, Channel__c, Business_Segmentation__c,
                   Province__c, City__c, Village__c, Zip__c,
                   Company_Email__c, Company_Phone__c
            FROM Lead
            WHERE Id IN :leadIds
        ]);

        
        Map<String, Id> accountRTMap = new Map<String, Id>();
        for (RecordType rt : [
            SELECT Id, Name
            FROM RecordType
            WHERE SObjectType = 'Account'
              AND Name IN ('Individu', 'Business')
              AND IsActive = true
        ]) {
            accountRTMap.put(rt.Name, rt.Id);
        }

        List<Account> accountsToInsert = new List<Account>();
        Map<Id, Account> leadToAccount = new Map<Id, Account>();

        for (Lead l : leadMap.values()) {
            Id rtId = l.Account_Segment__c == 'I'
                ? accountRTMap.get('Individu')
                : accountRTMap.get('Business');

            PhoneWrapper phone = parsePhone(
                String.isBlank(l.Company) ? l.Phone : l.Company_Phone__c
            );

            Account acc = new Account(
                Name = String.isBlank(l.Company)
                    ? l.FirstName + ' ' + l.LastName
                    : l.Company,
                Phone = String.isBlank(l.Company) ? l.Phone : l.Company_Phone__c,
                Email__c = String.isBlank(l.Company) ? l.Email : l.Company_Email__c,
                House_Phone__c = phone.phoneNumber,
                House_Phone_Area__c = phone.area,
                Account_Segment__c = l.Account_Segment__c,
                Account_Sub_Segment__c = l.Account_Sub_Segment__c,
                Type = l.Account_Type__c,
                Account_Channel__c = l.Channel__c,
                Account_Pipeline_Status__c = l.Account_Pipeline_Status__c,
                Business_Segmentation__c = l.Business_Segmentation__c,
                Province__c = l.Province__c,
                City__c = l.City__c,
                Village__c = l.Village__c,
                Zip__c = l.Zip__c,
                Address__c = l.Description,
                Address_LU__c = l.Address__c,
                RecordTypeId = rtId,
                OwnerId = l.OwnerId,
                ParentId = l.Account__c,
                Has_Beneficial_Owner__c = 'Y',
                Interest_COB__c = l.Interest_COB__c,
                Marital_Status__c = '0',
                Employment__c = '0',
                Yearly_Income__c = '0',
                Source_of_Income__c = '0'
            );
            
            System.debug('|||||||||||||ACC|||||||||||||| ' + acc);

            accountsToInsert.add(acc);
            leadToAccount.put(l.Id, acc);
        }

        insert accountsToInsert;

        List<Contact> contactsToInsert = new List<Contact>();
        Map<Id, Contact> leadToContact = new Map<Id, Contact>();

        for (Lead l : leadMap.values()) {
            PhoneWrapper phone = parsePhone(l.Phone);

            Contact c = new Contact(
                FirstName = l.FirstName,
                LastName = l.LastName,
                Email = l.Email,
                AccountId = l.Account__c != null
                    ? l.Account__c
                    : leadToAccount.get(l.Id).Id,
                Phone_Area__c = phone.area,
                Phone = phone.phoneNumber,
                Address__c = l.Description,
                Status__c = 'CP',
                Actived__c = '1'
            );

            contactsToInsert.add(c);
            leadToContact.put(l.Id, c);
        }

        insert contactsToInsert;

        String convertedStatus = getConvertedStatus();

        for (Lead l : leadMap.values()) {
            LeadConvertResultWrapper r = new LeadConvertResultWrapper();

            try {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(l.Id);
                lc.setConvertedStatus(convertedStatus);
                lc.setAccountId(leadToAccount.get(l.Id).Id);
                lc.setContactId(leadToContact.get(l.Id).Id);
                lc.setDoNotCreateOpportunity(true);

                Database.convertLead(lc);

                r.success = true;
                r.message = 'Lead converted successfully';
                r.convertedAccountId = leadToAccount.get(l.Id).Id;
                r.convertedContactId = leadToContact.get(l.Id).Id;

            } catch (Exception e) {
                r.success = false;
                r.message = e.getMessage();
            }

            resultMap.put(l.Id, r);
        }

        for (LeadIdWrapper w : leadIdWrappers) {
            results.add(resultMap.get(w.leadId));
        }

        return results;
    }

    /* ===================== HELPERS ===================== */

    private class PhoneWrapper {
        String area;
        String phoneNumber;
        PhoneWrapper(String a, String n) {
            area = a; phoneNumber = n;
        }
    }

    private static PhoneWrapper parsePhone(String raw) {
        if (String.isBlank(raw)) return new PhoneWrapper('', '');

        raw = raw.trim();
        if (raw.startsWith('+62')) return new PhoneWrapper('+62', raw.substring(3));
        if (raw.startsWith('62'))  return new PhoneWrapper('+62', raw.substring(2));
        if (raw.startsWith('0'))   return new PhoneWrapper('+62', raw.substring(1));

        return new PhoneWrapper('', raw);
    }

    private static String getConvertedStatus() {
        return [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ].MasterLabel;
    }

    /* ===================== WRAPPERS ===================== */

    public class LeadIdWrapper {
        @InvocableVariable(required=true)
        public Id leadId;
    }

    public class LeadConvertResultWrapper {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
        @InvocableVariable public Id convertedAccountId;
        @InvocableVariable public Id convertedContactId;
    }
}