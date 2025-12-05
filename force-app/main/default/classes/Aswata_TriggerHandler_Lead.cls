public class Aswata_TriggerHandler_Lead extends TriggerHandler {

    public override void beforeInsert(){
        System.debug('before insert');  
    }
    
    public override void afterInsert() {
        Map<Id, Lead> leadsToUpdateMap = new Map<Id, Lead>();
        Set<String> zipCodeIds = new Set<String>();
        String branchId = '';
        Map<Id, String> leadIdToZip = new Map<Id, String>();
        Set<Id> addressIdsToLookup = new Set<Id>();
        Map<Id, Id> leadIdToAddressId = new Map<Id, Id>();

        // Collect zip codes and prepare initial updates
        for (Lead lead : (List<Lead>) Trigger.new) {
            Lead updatedLead = leadsToUpdateMap.containsKey(lead.Id) 
                ? leadsToUpdateMap.get(lead.Id) 
                : new Lead(Id = lead.Id);

            if (!String.isBlank(lead.Zip__c)) {
                zipCodeIds.add(lead.Zip__c);
                leadIdToZip.put(lead.Id, lead.Zip__c);
            }

            if (!String.isBlank(lead.Address__c)) {
                updatedLead.Address_Selected__c = true;
                addressIdsToLookup.add(lead.Address__c);
                leadIdToAddressId.put(lead.Id, lead.Address__c);
            }

            if (String.isBlank(lead.Original_Lead_ID__c)) {
                updatedLead.Original_Lead_ID__c = lead.Id;
            }

            leadsToUpdateMap.put(lead.Id, updatedLead);
        }

        // Bulk fetch branch mappings
        Map<String, String> zipToBranchId = getBranchIds(zipCodeIds); // You already have this

        List<SObject> locations = Database.query('SELECT Id, Address_Name__c FROM Location WHERE Id IN :addressIdsToLookup');

        Map<Id, String> addressIdToDesc = new Map<Id, String>();

        for (SObject sObj : locations) {
            Id locId = (Id) sObj.get('Id');
            String addressName = (String) sObj.get('Address_Name__c');
            addressIdToDesc.put(locId, addressName);
        }
        System.debug('addressIdToDesc: ' + addressIdToDesc);
        /*************************************************************************************** */
        /*************************************************************************************** */
        /*************************************************************************************** */
        for (Lead newLead : (List<Lead>) Trigger.new) {
            Id leadId = newLead.Id;
            Lead leadToUpdate = new Lead(Id = leadId);

            Boolean needsUpdate = false;
            System.debug('leadIdToZip: ' + leadIdToZip);
            // Update Branch__c if needed
            if (leadIdToZip.containsKey(leadId)) {
                String zip = leadIdToZip.get(leadId);
                branchId = zipToBranchId.get(zip);
                if (!String.isBlank(branchId)) {
                    leadToUpdate.Branch__c = branchId;
                    needsUpdate = true;
                }
            }

            // Update Description if Address__c changed
            if (leadIdToAddressId.containsKey(leadId)) {
                Id addressId = leadIdToAddressId.get(leadId);
                String desc_lead = addressIdToDesc.get(addressId);
                if (!String.isBlank(desc_lead)) {
                    leadToUpdate.Description = desc_lead;
                    needsUpdate = true;
                }
            }

            if (needsUpdate) {
                leadsToUpdateMap.put(leadId, leadToUpdate);
            }
        }

        System.debug('leadsToUpdateMap.size: ' + leadsToUpdateMap.size());

        // Final DML
        if (!leadsToUpdateMap.isEmpty()) {
              try {
                update leadsToUpdateMap.values();
                System.debug('leadsToUpdateMap:  ' + leadsToUpdateMap);
                // ✅ Call your distribution logic after update success
                List<Id> branchLeadIds = new List<Id>();
                for (Lead l : leadsToUpdateMap.values()) {
                    if (String.isNotBlank(l.Branch__c)) {
                        branchLeadIds.add(l.Id);
                    }
                }

                System.debug('branchLeadIds.size():  ' + branchLeadIds.size());
                // ✅ Run distribution logic only if branch leads exist
                if (!branchLeadIds.isEmpty()) {
                    if (Trigger.isAfter && Trigger.isInsert) {
                        System.debug('Trigger.isAfter && Trigger.isInsert');
                        System.enqueueJob(new Aswata_Lead_Distribution_Queueable(new List<Id>(Trigger.newMap.keySet())));
                    }
                    //System.debug('Distribution Results: ' + distResults);
                }
            } catch (DmlException dmlEx) {
                System.debug('Update failed: ' + dmlEx.getMessage());
                throw dmlEx; // rethrow if needed
            }
        }
    }


    
    public override void beforeUpdate(){
        List<Lead> leads = (List<Lead>) Trigger.new;

        Set<Id> provinceIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> addressIds = new Set<Id>();

        for (Lead l : leads) {
            if (l.Province__c != null) {
                provinceIds.add(l.Province__c);
            }
            if (l.City__c != null) 
            {
                cityIds.add(l.City__c);
            }
            if (l.Address__c != null) 
            {
                addressIds.add(l.Address__c);
            }
        }

        // Query parents
        Map<Id, Schema.Location> provinceMap = new Map<Id, Schema.Location>(
            [SELECT Id, Name FROM Location WHERE Id IN :provinceIds with SECURITY_ENFORCED]
        );

        Map<Id, Schema.Location> cityMap = new Map<Id, Schema.Location>(
            [SELECT Id, Name FROM Location WHERE Id IN :cityIds with SECURITY_ENFORCED]
        );

        Map<Id, Schema.Location> addressMap = new Map<Id, Schema.Location>(
            [SELECT Id, Address_Name__c FROM Location WHERE Id IN :addressIds with SECURITY_ENFORCED]
        );

        // Apply values
        for (Lead l : leads) {
            if (l.Province__c != null && provinceMap.containsKey(l.Province__c)) {
                l.State = provinceMap.get(l.Province__c).Name;
            }
            if (l.City__c != null && cityMap.containsKey(l.City__c)) {
                l.City = cityMap.get(l.City__c).Name;
            }
            if (l.Address__c != null && addressMap.containsKey(l.Address__c)) {
                l.Street = addressMap.get(l.Address__c).Address_Name__c;
            }
        }
    }
    
    public override void afterUpdate() {
        Map<Id, Lead> leadsToUpdateMap = new Map<Id, Lead>();
        List<Account> accountsToUpdate = new List<Account>();
        Set<String> zipCodesToLookup = new Set<String>();
        Map<Id, String> leadIdToZip = new Map<Id, String>();
        Set<Id> addressIdsToLookup = new Set<Id>();
        Map<Id, Id> leadIdToAddressId = new Map<Id, Id>();

        String accountId = '';
        for (Lead newLead : (List<Lead>) Trigger.new) {
            Lead oldLead = (Lead) Trigger.oldMap.get(newLead.Id);
            

            // Collect Leads with changed Zip__c
            if (newLead.Zip__c != null && newLead.Zip__c != oldLead.Zip__c) {
                zipCodesToLookup.add(newLead.Zip__c);
                leadIdToZip.put(newLead.Id, newLead.Zip__c);
            }

            if(newLead.Address__c != null && newLead.Address__c != oldLead.Address__c){
                /* do logic here*/
                addressIdsToLookup.add(newLead.Address__c);
                leadIdToAddressId.put(newLead.Id, newLead.Address__c);
            }
        }

        // Get Branch ID mapping from zip codes
        Map<String, String> zipToBranchId = getBranchIds(zipCodesToLookup); // You’ll write this method


        List<SObject> locations = Database.query('SELECT Id, Address_Name__c FROM Location WHERE Id IN :addressIdsToLookup');

        Map<Id, String> addressIdToDesc = new Map<Id, String>();

        for (SObject sObj : locations) {
            Id locId = (Id) sObj.get('Id');
            String addressName = (String) sObj.get('Address_Name__c');
            addressIdToDesc.put(locId, addressName);
        }
        System.debug('addressIdToDesc: ' + addressIdToDesc);
        // Prepare Leads to update Branch__c
        for (Lead newLead : (List<Lead>) Trigger.new) {
            Id leadId = newLead.Id;
            Lead leadToUpdate = new Lead(Id = leadId);

            Boolean needsUpdate = false;

            // Update Branch__c if needed
            if (leadIdToZip.containsKey(leadId)) {
                String zip = leadIdToZip.get(leadId);
                String branchId = zipToBranchId.get(zip);
                system.debug('Branch ID : ' + branchId);
                if (!String.isBlank(branchId)) {
                    leadToUpdate.Branch__c = branchId;
                    needsUpdate = true;
                }
            }

            // Update Description if Address__c changed
            if (leadIdToAddressId.containsKey(leadId)) {
                Id addressId = leadIdToAddressId.get(leadId);
                String desc_lead = addressIdToDesc.get(addressId);
                if (!String.isBlank(desc_lead)) {
                    leadToUpdate.Description = desc_lead;
                    needsUpdate = true;
                }
            }

            if (needsUpdate) {
                leadsToUpdateMap.put(leadId, leadToUpdate);
            }
        }

        // Final DML
        if (!leadsToUpdateMap.isEmpty()) {
            //update leadsToUpdateMap.values();
            try {
                update leadsToUpdateMap.values();
            } catch (DmlException dmlEx) {
                System.debug('Update failed: ' + dmlEx.getMessage());
                throw dmlEx; // rethrow if needed
            }
        }
    }



    public static Map<String, String> getBranchIds(Set<String> zipcodeIds) {
        Map<String, String> zipToBranchMap = new Map<String, String>();

        if (zipcodeIds != null && !zipcodeIds.isEmpty()) {
            List<SObject> locations = [
                SELECT Id, Branch_ID__c
                FROM Location
                WHERE Id IN :zipcodeIds
            ];

            for (SObject loc : locations) {
                String zipId = (String) loc.get('Id');
                String branchId = (String) loc.get('Branch_ID__c');
                if (!String.isBlank(branchId)) {
                    zipToBranchMap.put(zipId, branchId);
                }
            }
        }

        return zipToBranchMap;
    }

}