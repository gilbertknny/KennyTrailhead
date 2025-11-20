trigger RestrictCaseClosed on Case (before update) {
    Boolean isByPassValidationforMigration = FeatureManagement.checkPermission('By_Pass_Validation_for_Migration');
    
    if (isByPassValidationforMigration) {
        return;
    }
    
    // Field yang bisa edit di Ticket Closed,, tambahkan disini utk bypass
    Set<String> fieldsOK = new Set<String>{
        'scc_legacy_ticket_id__c',
        'scc_brinotif_reffnumber__c',
        'scc_remark__c',
        'scc_drone_remark__c',
        'scc_drone_remark_update__c',
        'scc_tipe_remark__c',
        'done_survey__c',
        'invitation_link__c',
        'notification_13__c',
        'scc_itsm_closed__c',
        'notification_12__c',
        'notification_3__c',
        'notification_2__c',
        'waiting_document_duration__c',
        'scc_result_pembukuan__c',
        'date_time_answer__c',
        'priority',
        'ownerid',
        'status',
        'scc_attachment_done_date__c'
    };
    
    for (Case newCase : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        
        if (oldCase.Status == 'Closed') {
            Boolean hasUnauthorizedChanges = false;
            String unauthorizedFields = '';

            for (String fieldName : Schema.SObjectType.Case.fields.getMap().keySet()) {
                if (fieldName.startsWith('Id') || 
                    fieldName.startsWith('Is') || 
                    fieldsOK.contains(fieldName)) {
                    continue;
                }

                Object newValue = newCase.get(fieldName);
                Object oldValue = oldCase.get(fieldName);
                
                if (newValue != oldValue) {
                    hasUnauthorizedChanges = true;
                    unauthorizedFields += fieldName + ', ';
                }
            }
            
            // Pop Up Error
            if (hasUnauthorizedChanges) {
                unauthorizedFields = unauthorizedFields.removeEnd(', ');
                newCase.addError('Tidak dapat merubah Ticket yang sudah Closed. Beberapa field yang tidak seharusnya terubah: ' + unauthorizedFields);
            }
        }
    }
}