/**
 * @description       : 
 * @author            : Ardyta Yudianto, Alvin Vigo
 * @group             : 
 * @last modified on  : 10-15-2024
 * @last modified by  : Ardyta Yudianto, Alvin Vigo
**/
public without sharing class SCC_MultiPicklistController {
    // Edited by Alvin Vigo for Sub Case in tab Case Type
    /**
     * @description getMasterSubCaseReference
     * @return Map<String, String>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getMasterSubCaseReference() {
        Map<String, String> options = new Map<String, String>();
        List<SCC_Sub_Case_Reference__mdt> records = [SELECT Id, MasterLabel, Label, DeveloperName, Sub_Case_Reference__c FROM SCC_Sub_Case_Reference__mdt 
                                                        WITH SECURITY_ENFORCED LIMIT 1000 ];
		
        /* list<Sub_Case_Reference__c> SCR=[SELECT id,name,sub_case_code__c from Sub_Case_Reference__c order by name ASC LIMIT 2000];
        for (Sub_Case_Reference__c record : SCR) {
            options.put(record.sub_case_code__c, record.Name);
        } */
       
        for (SCC_Sub_Case_Reference__mdt record : records) {
            options.put(record.Sub_Case_Reference__c, record.Sub_Case_Reference__c);
        }
        return options;
    }

    /**
     * @description saveSelectedValues
     * @param recordId
     * @param selectedValues
     */

     @AuraEnabled(cacheable=true)
     public static String getUserProfile() {
        User U=[select profile.name from user where id=:userinfo.getuserId()];
        return U.profile.Name;
     }
    
    /// add method by novan
    @AuraEnabled(cacheable=true)
    public static Boolean hasSubCasePermission() {
     
        return FeatureManagement.checkPermission('Sub_Case_Reference');
    }
	
	////
    
    @AuraEnabled
    public static void saveSelectedValues(Id recordId, List<String> selectedValues) {
        SSC_Call_Type__c record = new SSC_Call_Type__c(Id = recordId,SCC_Sub_Description__c = String.join(selectedValues, ';'));
        // Update the record
        if (Schema.sObjectType.SSC_Call_Type__c.fields.SCC_Sub_Description__c.isUpdateable()) {
            update record;
        }
    }

    /**
     * @description getFieldValues
     * @param recordId
     * @return List<String>
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldValues(Id recordId) {        
        // Query the field values
        SSC_Call_Type__c record = [SELECT SCC_Sub_Description__c FROM SSC_Call_Type__c WHERE Id = :recordId 
                                    WITH SECURITY_ENFORCED LIMIT 1];
        
        // Split the values into a list if they are semicolon-separated
        return record.SCC_Sub_Description__c != null ? record.SCC_Sub_Description__c.split(';') : new List<String>();
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getLabels(list<String> selectedValues) {        
         //list<Sub_Case_Reference__c> listSCR=[SELECT name,sub_case_code__c from Sub_Case_Reference__c where sub_case_code__c=:selectedValues];
         list<SCC_Sub_Case_Reference__mdt> listSCR=[SELECT Id, MasterLabel, Label, DeveloperName, Sub_Case_Reference__c FROM SCC_Sub_Case_Reference__mdt WHERE Sub_Case_Reference__c=:selectedValues];
         list<String> listLabelValue=new list<String>();
         for(SCC_Sub_Case_Reference__mdt SCR:listSCR)
         {
            String L=SCR.Sub_Case_Reference__c + ' || ' + SCR.Sub_Case_Reference__c;
            listLabelValue.add(L);
         }
        return listLabelValue;
    }
    // Done Edited by Alvin Vigo for Sub Case in tab Case Type

    /**
     * @description getSubCaseReferenceFromCaseType
     * @param recordId
     * @return String
     */

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSubCaseReferenceFromCaseType(Id recordId) {
        // Query the field values
        SSC_Call_Type__c record = [
            SELECT SCC_Sub_Description__c 
            FROM SSC_Call_Type__c 
            WHERE Id = :recordId 
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];
    
        List<String> lstString = new List<String>();
    
        if (record.SCC_Sub_Description__c != null && record.SCC_Sub_Description__c != '') {
            if (record.SCC_Sub_Description__c.contains(';')) {
                lstString = record.SCC_Sub_Description__c.split(';');
            } else if (record.SCC_Sub_Description__c != '' && record.SCC_Sub_Description__c != null) {
                lstString.add(record.SCC_Sub_Description__c);
            }
            
            Map<String, String> options = new Map<String, String>();
            // Menghapus spasi di depan dan belakang
            for (String item : lstString) {
                String trimmedItem = item.trim();
                options.put(trimmedItem, trimmedItem); // Menggunakan nilai yang sama untuk key dan value
            }
            
            return options;
            // List<Sub_Case_Reference__c> SCR = [
            //     SELECT Id, Name, sub_case_code__c 
            //     FROM Sub_Case_Reference__c 
            //     WHERE sub_case_code__c IN :lstString 
            //     LIMIT 2000
            // ];
    
            // Map<String, String> options = new Map<String, String>();
            // for (Sub_Case_Reference__c rec : SCR) {
            //     options.put(rec.sub_case_code__c, rec.Name);
            // }
    
            // return options;
        } else {
            return null;
        }
    }

    /**
     * @description getSubCaseReferenceFromCase
     * @param recordId
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSubCaseReferenceFromCase(Id recordId) {
        List<Case> lstCase = [
            SELECT SCC_Call_Type__c, SCC_Call_Type__r.SCC_Sub_Description__c, Status 
            FROM Case 
            WHERE Id = :recordId 
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];
        List<String> lstString = new List<String>();
    
        if (lstCase[0].SCC_Call_Type__c == null) {
            Map<String, String> errormsg = new Map<String, String>();
            errormsg.put('error', 'Tiket ini belum ada case type');
            return errormsg;
        }
    
        if (lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c == null || lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c == '') {
            Map<String, String> errormsg = new Map<String, String>();
            errormsg.put('error', 'Case Type ini tidak ada Sub Case');
            return errormsg;
        }
    
        if (lstCase[0].Status == 'Escalated' || lstCase[0].Status == 'Closed') {
            Map<String, String> errormsg = new Map<String, String>();
            errormsg.put('error', 'Tiket yang sudah eskalasi atau closed tidak bisa dirubah Sub Casenya');
            return errormsg;
        }
    
        if (lstCase[0].SCC_Call_Type__c != null && lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c != null) {
            if (lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c.contains(';')) {
                lstString = lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c.split(';');
            } else if (lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c != '') {
                lstString.add(lstCase[0].SCC_Call_Type__r.SCC_Sub_Description__c);
            } else {
                return null;
            }

            Map<String, String> options = new Map<String, String>();
            // Menghapus spasi di depan dan belakang
            for (String item : lstString) {
                String trimmedItem = item.trim();
                options.put(trimmedItem, trimmedItem); // Menggunakan nilai yang sama untuk key dan value
            }

            return options;

            // List<Sub_Case_Reference__c> SCR = [
            //     SELECT Id, Name, sub_case_code__c 
            //     FROM Sub_Case_Reference__c 
            //     WHERE sub_case_code__c IN :lstString 
            //     LIMIT 2000
            // ];
            // Map<String, String> options = new Map<String, String>();
            // for (Sub_Case_Reference__c record : SCR) {
            //     options.put(record.sub_case_code__c, record.Name);
            // }
            // return options;
        } else {
            return null;
        }
    }    
    
    /**
     * @description saveSelectedValuesOnCase
     * @param recordId
     * @param selectedValue
     */
    // @AuraEnabled
    // public static void saveSelectedValuesOnCase(Id recordId, String selectedValue) {
    //     Case record = new Case(Id = recordId, SCC_Sub_Case__c = selectedValue);
    //     if(selectedValue!='' && selectedValue!=null){
    //         Sub_Case_Reference__c Scr=[SELECT id from Sub_Case_Reference__c where sub_case_code__c=:selectedValue];
    //         record.SCC_Sub_Case_Lookup__c=SCR.id;
    //     }
    //     if (Schema.sObjectType.Case.fields.SCC_Sub_Case__c.isUpdateable()) {
    //         update record;
    //     }
    // }

    @AuraEnabled
    public static void saveSelectedValuesOnCase(Id recordId, String selectedValue) {
        Case record = new Case(Id = recordId, SCC_Sub_Case__c = selectedValue);
        
        if (selectedValue != '' && selectedValue != null) {
            try {
                Sub_Case_Reference__c scr = [SELECT Id FROM Sub_Case_Reference__c WHERE sub_case_code__c = :selectedValue LIMIT 1];
                record.SCC_Sub_Case_Lookup__c = scr.Id;
                System.debug('Lookup Sub_Case_Reference__c ID: ' + scr.Id);
            } catch (Exception e) {
                System.debug('Tidak dapat menemukan Sub_Case_Reference dengan kode: ' + selectedValue + '. Error: ' + e.getMessage());
            }
        } else {
            System.debug('Selected value kosong atau null.');
        }

        if (Schema.sObjectType.Case.fields.SCC_Sub_Case__c.isUpdateable()) {
            try {
                update record;
            } catch (DmlException dme) {
                System.debug('Error saat update Case: ' + dme.getMessage());
            }
        } else {
            System.debug('Field SCC_Sub_Case__c tidak dapat di-update.');
        }
    }

    // @AuraEnabled
    // public static void saveSelectedValuesOnCase(Id recordId, String selectedValue) {
    //     try {
    //         // Query Case untuk mendapatkan SCC_Call_Type__c
    //         Case currentCase = [SELECT Id, SCC_Call_Type__c FROM Case WHERE Id = :recordId LIMIT 1];
    //         System.debug('Case Type Number (SCC_Call_Type__c): ' + currentCase.SCC_Call_Type__c);

    //         // Validasi bahwa selectedValue tidak kosong atau null
    //         if (selectedValue != '' && selectedValue != null) {
    //             // Query Sub_Case_Reference__c yang sesuai dengan SCC_Call_Type__c dari Case
    //             Sub_Case_Reference__c scr = [
    //                 SELECT Id 
    //                 FROM Sub_Case_Reference__c 
    //                 WHERE sub_case_code__c = :selectedValue
    //                 AND Case_Type__c = :currentCase.SCC_Call_Type__c
    //                 LIMIT 1
    //             ];

    //             // Jika Sub_Case_Reference ditemukan, set field SCC_Sub_Case_Lookup__c
    //             if (scr != null) {
    //                 Case record = new Case(Id = recordId, SCC_Sub_Case__c = selectedValue);
    //                 record.SCC_Sub_Case_Lookup__c = scr.Id;
                    
    //                 // Cek apakah field SCC_Sub_Case__c bisa di-update
    //                 if (Schema.sObjectType.Case.fields.SCC_Sub_Case__c.isUpdateable()) {
    //                     update record;
    //                     System.debug('Case updated successfully with Sub Case Lookup ID: ' + scr.Id);
    //                 } else {
    //                     System.debug('Field SCC_Sub_Case__c tidak dapat di-update.');
    //                 }
    //             } else {
    //                 System.debug('Sub_Case_Reference tidak ditemukan atau tidak cocok dengan Case Type (SCC_Call_Type__c).');
    //             }
    //         } else {
    //             System.debug('Selected value kosong atau null.');
    //         }
    //     } catch (Exception e) {
    //         System.debug('Error: ' + e.getMessage());
    //     } 
    // }

}