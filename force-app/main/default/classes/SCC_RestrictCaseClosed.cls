/**
 * @description       : Class untuk restrict field yang ada di UI ketika Closed, tambahkan di metadata [SCC_RestrictCaseClosed] untuk restrict field
 * @author            : Alvin Vigo
 * @group             : 
 * @last modified on  : 16/12/2024
 * @last modified by  : Alvin Vigo
**/

public class SCC_RestrictCaseClosed {
    @TestVisible
    private static Boolean isBypassEnabled = false;
    
    @TestVisible
    private static Boolean isTest = false;
    
    public static void restrictCaseClosed(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        // bypass case migrasi
        Boolean isByPassValidationforMigration = Test.isRunningTest() 
            ? isBypassEnabled 
            : FeatureManagement.checkPermission('By_Pass_Validation_for_Migration');
        
        if (isByPassValidationforMigration) {
            return;
        }
        
        // fields yang engga bisa edit di ticket closed,, tambahkan di metadata [SCC_RestrictCaseClosed] untuk restrict
        Set<String> fieldRestricted = new Set<String>();
        
        if(isTest){
            fieldRestricted = new Set<String>{
                'accountid',
                'cust_current_phone__c',
                'description',
                'dokumen_nasabah_c__c',
                'origin',
                'progress_ticket__c',
                'returned_case__c',
                'scc_account_number__c',
                'scc_amount__c',
                'scc_bersedia_di_survey__c',
                'scc_call_type__c',
                'scc_card_number__c',
                'scc_case_category__c',
                'scc_channel_transaksi__c',
                'scc_closure_comments__c',
                'scc_email__c',
                'scc_list_of_required_documents__c',
                'scc_nama_pelapor__c',
                'scc_notes__c',
                'scc_product_l1__c',
                'scc_product_l2__c',
                'scc_resolution_category__c',
                'scc_segment__c',
                'scc_sub_escalation_level__c',
                'scc_sudah_di_survey__c',
                'scc_terminal_id__c',
                'scc_waktu_transaksi__c',
                'ssc_call_type_description__c',
                'unit_kerja_2__c'
            };
        }
        else {
            List<SCC_RestrictCaseClosed__mdt> restrictedFieldList = [
                SELECT SCC_Field__c
                FROM SCC_RestrictCaseClosed__mdt
                WHERE SCC_Jenis__c = 'Field Restricted'
            ];
            
            for (SCC_RestrictCaseClosed__mdt field : restrictedFieldList) {
                fieldRestricted.add(field.SCC_Field__c.toLowerCase());
            }
        }
        
        for (Case newCase : newCases) {
            Case oldCase = oldCaseMap.get(newCase.Id);
            
            if (oldCase.Origin != 'MMS' && (oldCase.Status == 'Closed' || oldCase.Status == 'Disconnected' || oldCase.Status == 'Cancelled')) {
                Boolean hasUnauthorizedChanges = false;
                String unauthorizedFields = '';
                
                for (String fieldName : Schema.SObjectType.Case.fields.getMap().keySet()) {
                    // field yang engga ada di metadata akan di-skip
                    if (!fieldRestricted.contains(fieldName)) {
                        continue;
                    }
                    
                    Object newValue = newCase.get(fieldName);
                    Object oldValue = oldCase.get(fieldName);
                    
                    if (newValue != oldValue) {
                        hasUnauthorizedChanges = true;
                        unauthorizedFields += fieldName + ', ';
                    }
                }
                
                // pop up error
                if (hasUnauthorizedChanges) {
                    unauthorizedFields = unauthorizedFields.removeEnd(', ');
                    newCase.addError(System.Label.SCC_CaseCloseValidationError + 
                        ' Beberapa field yang dibatasi perubahannya: ' + unauthorizedFields);
                }
            }
        }
    }
}