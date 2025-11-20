/**
 * @description       : Batch class to close cases with status 'Waiting Document' that are older than 10 business days.
 *                      Enhanced with error handling and email reporting.
 * @author            : Ardyta Yudianto
 * @last modified on  : 12-03-2025
 * @last modified by  : Ardyta Yudianto
**/
global class SCC_CloseWaitingDocumentCasesBatch implements Database.Batchable<SObject>, Database.Stateful {
    // Constants for hardcoded values
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final Integer BUSINESS_DAYS_AGO = 10;
    private static final Integer BATCH_SIZE = 50;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification;
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    
    // Stateful variables to track progress across batch execution
    private Integer totalProcessed = 0;
    private Integer totalSuccess = 0;
    private Integer totalFailed = 0;
    private List<CaseResult> successResults = new List<CaseResult>();
    private List<CaseResult> failedResults = new List<CaseResult>();
    
    // Inner class to store case results for reporting
    private class CaseResult {
        public Id caseId;
        public String caseNumber;
        public String reporterName;
        public String errorMessage;
        
        public CaseResult(Id caseId, String caseNumber, String reporterName, String errorMessage) {
            this.caseId = caseId;
            this.caseNumber = caseNumber;
            this.reporterName = reporterName;
            this.errorMessage = errorMessage;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Start method called');

        // Retrieve Business Hours for Branch User
        BusinessHours userBusinessHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = :BUSINESS_HOURS_NAME
            LIMIT 1
        ];
        System.debug('Business Hours ID: ' + userBusinessHours.Id);

        // Calculate the date 10 business days ago
        Datetime tenBusinessDaysAgo = calculateBusinessDaysAgo(userBusinessHours.Id, BUSINESS_DAYS_AGO);
        DateTime tenBusinessDaysAgoAtEndOfDay = DateTime.newInstance(tenBusinessDaysAgo.date(), Time.newInstance(23, 59, 0, 0));  
        DateTime tenBusinessDaysAgoAtEndOfDayPlus7Hours = tenBusinessDaysAgoAtEndOfDay.addHours(7); 
        System.debug('Ten business days ago: ' + tenBusinessDaysAgoAtEndOfDayPlus7Hours);
        
        // Query for cases to be closed with additional fields for reporting
        return Database.getQueryLocator([
            SELECT Id,
                   CaseNumber,
                   CreatedDate, 
                   Status, 
                   SCC_Resolution_Category__c,
                   SCC_Remark__c,
                   SCC_Nama_Pelapor__c
            FROM Case 
            WHERE Status = 'Waiting Document' 
            AND CreatedDate <= :tenBusinessDaysAgoAtEndOfDayPlus7Hours
            AND SCC_Nama_Pelapor__c != null
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        System.debug('Execute method called with scope size: ' + scope.size());
        
        List<Case> casesToUpdate = new List<Case>();
        totalProcessed += scope.size();
        
        // Pre-process cases to check for potential issues
        for (Case caseRecord : scope) {
            try {
                // Validate case data before processing
                Boolean isValid = validateCase(caseRecord);
                
                if (isValid) {
                    // Prepare case for update
                    caseRecord.Status = 'Closed';
                    caseRecord.SCC_Resolution_Category__c = 'Dokumen Tidak Lengkap';
                    caseRecord.SCC_Remark__c = 'Close otomatis by System';
                    casesToUpdate.add(caseRecord);
                } else {
                    // Log failed validation as an error
                    failedResults.add(new CaseResult(
                        caseRecord.Id, 
                        caseRecord.CaseNumber, 
                        caseRecord.SCC_Nama_Pelapor__c, 
                        'Case gagal validasi pra-pemrosesan'
                    ));
                    totalFailed++;
                }
            } catch (Exception e) {
                // Handle pre-processing exceptions
                failedResults.add(new CaseResult(
                    caseRecord.Id, 
                    caseRecord.CaseNumber, 
                    caseRecord.SCC_Nama_Pelapor__c, 
                    'Error pra-pemrosesan: ' + e.getMessage()
                ));
                totalFailed++;
            }
        }
        
        // Process valid cases using Database.update with allOrNone=false
        if (!casesToUpdate.isEmpty()) {
            // Use Database.SaveResult to process each record individually
            List<Database.SaveResult> updateResults = Database.update(casesToUpdate, false);
            
            // Process the results
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                Case caseRecord = casesToUpdate[i];
                
                if (result.isSuccess()) {
                    // Success case
                    successResults.add(new CaseResult(
                        caseRecord.Id, 
                        caseRecord.CaseNumber, 
                        caseRecord.SCC_Nama_Pelapor__c,
                        null
                    ));
                    totalSuccess++;
                    System.debug('Successfully closed Case: ' + caseRecord.Id);
                } else {
                    // Failed case - collect errors
                    List<String> errors = new List<String>();
                    for (Database.Error err : result.getErrors()) {
                        errors.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    
                    failedResults.add(new CaseResult(
                        caseRecord.Id, 
                        caseRecord.CaseNumber, 
                        caseRecord.SCC_Nama_Pelapor__c, 
                        String.join(errors, ', ')
                    ));
                    totalFailed++;
                    System.debug('Failed to close Case: ' + caseRecord.Id + ' - Errors: ' + String.join(errors, ', '));
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Finished - Total Processed: ' + totalProcessed + 
                     ', Success: ' + totalSuccess + ', Failed: ' + totalFailed);
        
        // Generate and send email report
        sendEmailReport();
    }

    // Validate case before processing
    private Boolean validateCase(Case caseRecord) {
        // Add any specific validation logic here
        // For example, check if required fields have valid values
        return caseRecord.Status == 'Waiting Document' && 
               caseRecord.SCC_Nama_Pelapor__c != null;
    }

    private static Datetime calculateBusinessDaysAgo(Id businessHoursId, Integer businessDays) {
        Datetime currentTime = System.now();
        Datetime resultTime = currentTime;
        Integer daysSubtracted = 0;

        while (daysSubtracted < businessDays) {
            resultTime = resultTime.addDays(-1);
            if (BusinessHours.isWithin(businessHoursId, resultTime)) {
                daysSubtracted++;
            }
        }

        return resultTime;
    }
    
    // Send email report to admin
    private void sendEmailReport() {
        try {
            // Create email body with HTML formatting
            String emailBody = createEmailReportBody();
            
            // Set up email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { ADMIN_EMAIL });
            mail.setSubject('Laporan Batch SCC_CloseWaitingDocumentCases ' + 
                           System.today().format() + ' - Success: ' + totalSuccess + 
                           ', Failed: ' + totalFailed);
            mail.setHtmlBody(emailBody);
            
            // Send email using OWD (Organization-Wide Default email address) dengan DisplayName
            OrgWideEmailAddress orgWideEmail = [
                SELECT Id 
                FROM OrgWideEmailAddress 
                WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME 
                LIMIT 1
            ];
            
            if (orgWideEmail != null) {
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Email report sent successfully');
        } catch (Exception e) {
            System.debug('Error sending email report: ' + e.getMessage());
        }
    }
    
    // Create HTML email report body
    private String createEmailReportBody() {
        String body = '<h2>Laporan Batch SCC_CloseWaitingDocumentCases</h2>';
        body += '<p><strong>Tanggal Eksekusi:</strong> ' + System.now().format() + '</p>';
        body += '<p><strong>Total Diproses:</strong> ' + totalProcessed + '</p>';
        body += '<p><strong>Berhasil:</strong> ' + totalSuccess + '</p>';
        body += '<p><strong>Gagal:</strong> ' + totalFailed + '</p>';
        
        // Add successful cases table
        if (!successResults.isEmpty()) {
            body += '<h3>Daftar Case Berhasil Di-close:</h3>';
            body += '<table border="1" style="border-collapse: collapse; width: 100%;">';
            body += '<tr style="background-color: #f2f2f2;">' +
                   '<th style="padding: 8px; text-align: left;">Case Number</th>' +
                   '<th style="padding: 8px; text-align: left;">Case ID</th>' +
                   '<th style="padding: 8px; text-align: left;">Nama Pelapor</th>' +
                   '</tr>';
            
            for (CaseResult result : successResults) {
                body += '<tr>' +
                       '<td style="padding: 8px;">' + result.caseNumber + '</td>' +
                       '<td style="padding: 8px;">' + result.caseId + '</td>' +
                       '<td style="padding: 8px;">' + result.reporterName + '</td>' +
                       '</tr>';
            }
            
            body += '</table>';
        }
        
        // Add failed cases table
        if (!failedResults.isEmpty()) {
            body += '<h3>Daftar Case Gagal Di-close:</h3>';
            body += '<table border="1" style="border-collapse: collapse; width: 100%;">';
            body += '<tr style="background-color: #f2f2f2;">' +
                   '<th style="padding: 8px; text-align: left;">Case Number</th>' +
                   '<th style="padding: 8px; text-align: left;">Case ID</th>' +
                   '<th style="padding: 8px; text-align: left;">Nama Pelapor</th>' +
                   '<th style="padding: 8px; text-align: left;">Pesan Error</th>' +
                   '</tr>';
            
            for (CaseResult result : failedResults) {
                body += '<tr>' +
                       '<td style="padding: 8px;">' + result.caseNumber + '</td>' +
                       '<td style="padding: 8px;">' + result.caseId + '</td>' +
                       '<td style="padding: 8px;">' + result.reporterName + '</td>' +
                       '<td style="padding: 8px;">' + result.errorMessage + '</td>' +
                       '</tr>';
            }
            
            body += '</table>';
        }
        
        return body;
    }

    // Method to run the batch manually
    public static void runBatch() {
        SCC_CloseWaitingDocumentCasesBatch batchJob = new SCC_CloseWaitingDocumentCasesBatch();
        Database.executeBatch(batchJob, BATCH_SIZE);
        System.debug('Batch job initiated');
    }
}