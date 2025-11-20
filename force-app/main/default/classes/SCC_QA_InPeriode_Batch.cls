/**
 * Batch Apex untuk memproses QA Response records dengan kriteria tertentu
 * Mengatasi masalah CPU Limit pada flow dengan pemisahan record bermasalah
 */
global class SCC_QA_InPeriode_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Email settings menggunakan OrgWideEmailAddress
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification;
    private static final Integer BATCH_SIZE = 5;
    
    // Variabel untuk menyimpan log processing
    private Integer recordsProcessed = 0;
    private Integer recordsUpdated = 0;
    private List<ErrorRecord> failedRecords = new List<ErrorRecord>();
    
    // Inner class untuk melacak record yang gagal dan pesan errornya
    private class ErrorRecord {
        public String recordId;
        public String recordName;
        public String errorMessage;
        
        public ErrorRecord(String recordId, String recordName, String errorMessage) {
            this.recordId = recordId;
            this.recordName = recordName;
            this.errorMessage = errorMessage;
        }
    }
    
    /**
     * Method start untuk query data yang akan diproses
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query sama dengan yang digunakan pada flow
        String query = 'SELECT Id, Name, Status_Approval__c, In_Periode_Formula__c, In_Periode__c, QA_Final__c ' +
                      'FROM QA_Response__c ' +
                      'WHERE Status_Approval__c = \'New\' ' +
                      'AND In_Periode_Formula__c = true ' +
                      'AND In_Periode__c = false ' +
                      'AND QA_Final__c = true';
        
        System.debug('SCC_QA_InPeriode_Batch: Starting with query - ' + query);
        
        // Debug query hasil
        List<QA_Response__c> testRecords = Database.query(query);
        System.debug('SCC_QA_InPeriode_Batch: Query returned ' + testRecords.size() + ' records');
        
        return Database.getQueryLocator(query);
    }
    
    /**
     * Method execute untuk memproses setiap batch records
     * Implementasi partial success dengan memproses satu record pada satu waktu
     */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('SCC_QA_InPeriode_Batch: Processing batch with ' + scope.size() + ' records');
        
        // Proses setiap record satu per satu untuk mengisolasi error
        for (sObject s : scope) {
            QA_Response__c record = (QA_Response__c)s;
            recordsProcessed++;
            
            try {
                // Update field In_Periode__c menjadi true
                QA_Response__c recordToUpdate = new QA_Response__c(
                    Id = record.Id,
                    In_Periode__c = true
                );
                
                // Update record satu per satu dengan allOrNone=false
                Database.SaveResult result = Database.update(recordToUpdate, false);
                
                if (result.isSuccess()) {
                    recordsUpdated++;
                    System.debug('Successfully updated record: ' + record.Id);
                } else {
                    // Tangkap error dan tambahkan ke daftar failed records
                    String errorMsg = '';
                    for (Database.Error err : result.getErrors()) {
                        errorMsg += err.getStatusCode() + ': ' + err.getMessage() + ' ';
                    }
                    
                    failedRecords.add(new ErrorRecord(
                        record.Id,
                        record.Name,
                        errorMsg
                    ));
                    
                    System.debug('Failed to update record ' + record.Id + ': ' + errorMsg);
                }
            } catch (Exception e) {
                // Tangkap exception untuk setiap record
                failedRecords.add(new ErrorRecord(
                    record.Id,
                    record.Name,
                    'Exception: ' + e.getMessage()
                ));
                
                System.debug('Exception updating record ' + record.Id + ': ' + e.getMessage());
            }
        }
        
        System.debug('SCC_QA_InPeriode_Batch: Successfully updated ' + recordsUpdated + 
                    ' records out of ' + recordsProcessed + ' records in this batch');
    }
    
    /**
     * Method finish untuk menyelesaikan proses batch
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('SCC_QA_InPeriode_Batch: Processed total of ' + recordsProcessed + ' records');
        System.debug('SCC_QA_InPeriode_Batch: Successfully updated ' + recordsUpdated + ' records');
        System.debug('SCC_QA_InPeriode_Batch: Failed to update ' + failedRecords.size() + ' records');
        
        // Get batch job details
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
        String emailSubject = 'SCC QA InPeriode Batch Process Completed';
        
        // Buat email body dengan error detail
        String emailBody = 'The batch process has completed.\n\n' +
                           'Records processed: ' + recordsProcessed + '\n' +
                           'Records successfully updated: ' + recordsUpdated + '\n' +
                           'Records failed to update: ' + failedRecords.size() + '\n' +
                           'Job Status: ' + job.Status + '\n' +
                           'Number of errors: ' + job.NumberOfErrors + '\n' +
                           'Started by: ' + job.CreatedBy.Name + '\n\n';
        
        // Tambahkan detail record yang gagal jika ada
        if (!failedRecords.isEmpty()) {
            emailBody += 'FAILED RECORDS DETAILS:\n';
            emailBody += '=======================\n\n';
            
            Integer counter = 1;
            for (ErrorRecord err : failedRecords) {
                emailBody += counter + '. Record ID: ' + err.recordId + '\n' +
                             '   Record Name: ' + err.recordName + '\n' +
                             '   Error: ' + err.errorMessage + '\n\n';
                counter++;
            }
        }
        
        // Send email notification using OrgWideEmailAddress
        try {
            // Get org wide email address
            OrgWideEmailAddress orgWideEmail;
            try {
                orgWideEmail = [SELECT Id FROM OrgWideEmailAddress 
                               WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME LIMIT 1];
            } catch (Exception e) {
                System.debug('OrgWideEmailAddress not found: ' + e.getMessage());
            }
            
            // Set up email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Set recipient(s)
            List<String> toAddresses = new List<String>();
            toAddresses.add(ADMIN_EMAIL);
            mail.setToAddresses(toAddresses);
            
            // Set email details
            mail.setSubject(emailSubject);
            mail.setPlainTextBody(emailBody);
            
            // Set OrgWideEmailAddress if found
            if (orgWideEmail != null) {
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            
            // Send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Email notification sent to admin successfully');
        } catch (Exception e) {
            System.debug('Error sending email notification: ' + e.getMessage());
        }
    }

    // Method to run batch manually
    public static void runBatch() {
        SCC_QA_InPeriode_Batch batchJob = new SCC_QA_InPeriode_Batch();
        Database.executeBatch(batchJob, BATCH_SIZE);
    }
}