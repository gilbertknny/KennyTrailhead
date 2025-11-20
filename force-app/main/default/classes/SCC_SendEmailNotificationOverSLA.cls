/**
 * @description       : Send notification emails for cases that are over SLA
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public class SCC_SendEmailNotificationOverSLA implements Database.Batchable<SObject>, Database.Stateful {
    // Constants
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.EmailTemplateOverSLA;
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification;
    private static final Integer BATCH_SIZE = 10; // Increased batch size for better performance

    // Stateful variables
    private Integer totalProcessed = 0;
    private Integer emailsSent = 0;
    private List<CaseResult> successResults = new List<CaseResult>();
    private List<CaseResult> failedUpdateResults = new List<CaseResult>();
    private List<CaseResult> failedEmailResults = new List<CaseResult>();

    // Store queried template and org-wide email
    private EmailTemplate emailTemplate;
    private OrgWideEmailAddress orgWideEmail;

    // Inner class for result tracking
    private class CaseResult {
        public Id caseId;
        public String caseNumber;
        public String accountName;
        public String email;
        public String errorMessage;
        
        public CaseResult(Id caseId, String caseNumber, String accountName, String email, String errorMessage) {
            this.caseId = caseId;
            this.caseNumber = caseNumber;
            this.accountName = accountName;
            this.email = email;
            this.errorMessage = errorMessage;
        }
    }

    // Constructor to initialize email template and org-wide email
    public SCC_SendEmailNotificationOverSLA() {
        initializeEmailResources();
    }

    // Initialize email resources once
    private void initializeEmailResources() {
        try {
            emailTemplate = [
                SELECT Id, Subject, Body, HtmlValue
                FROM EmailTemplate 
                WHERE DeveloperName = :EMAIL_TEMPLATE_DEVELOPER_NAME 
                LIMIT 1
            ];

            orgWideEmail = [
                SELECT Id 
                FROM OrgWideEmailAddress 
                WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME 
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('Error initializing email resources: ' + e.getMessage());
        }
    }

    // Start method - optimized to use direct query
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Get the date threshold once to avoid recalculating for each record
        Datetime slaThreshold = SCC_CaseQueryService.getSLANotificationThreshold();
        
        String query = 'SELECT Id, CreatedDate, SCC_Email__c, CaseNumber, Status, ' +
                      'Account.Name, isTotalSLAViolated__c, SCC_Sent_Email_Perpanjangan_SLA__c ' +
                      'FROM Case ' +
                      'WHERE (Status = \'Escalated\' OR Status = \'Working\') ' +
                      'AND SCC_Email__c != NULL ' +
                      'AND SCC_Sent_Email_Perpanjangan_SLA__c = false ' +
                      'AND ((CreatedDate > :slaThreshold AND isTotalSLAViolated__c = true) ' +
                      'OR CreatedDate <= :slaThreshold)';
        
        return Database.getQueryLocator(query);
    }

    // Execute method - optimized with bulk processing
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        totalProcessed += scope.size();
        
        if (emailTemplate == null || orgWideEmail == null) {
            // If email resources weren't initialized, add all to failed results
            for (Case caseRecord : scope) {
                failedEmailResults.add(new CaseResult(
                    caseRecord.Id, caseRecord.CaseNumber, caseRecord.Account?.Name, 
                    caseRecord.SCC_Email__c, 'Email template or org-wide email not found'
                ));
            }
            return;
        }

        // Process in bulk phases
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        
        // Phase 1: Prepare all emails and data
        for (Case caseRecord : scope) {
            caseMap.put(caseRecord.Id, caseRecord);
            
            try {
                Messaging.SingleEmailMessage email = createEmailForCase(caseRecord);
                emailsToSend.add(email);
            } catch (Exception e) {
                failedEmailResults.add(new CaseResult(
                    caseRecord.Id, caseRecord.CaseNumber, caseRecord.Account?.Name,
                    caseRecord.SCC_Email__c, 'Error preparing email: ' + e.getMessage()
                ));
                caseMap.remove(caseRecord.Id); // Remove from further processing
            }
        }

        // Phase 2: Send emails in bulk
        if (!emailsToSend.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend, false);
            
            Set<Id> successfulEmailCases = new Set<Id>();
            for (Integer i = 0; i < results.size(); i++) {
                Case currentCase = scope[i]; // Use original scope order
                
                if (results[i].isSuccess()) {
                    emailsSent++;
                    successfulEmailCases.add(currentCase.Id);
                    successResults.add(new CaseResult(
                        currentCase.Id, currentCase.CaseNumber, currentCase.Account?.Name,
                        currentCase.SCC_Email__c, null
                    ));
                } else {
                    String error = '';
                    for (Messaging.SendEmailError err : results[i].getErrors()) {
                        error += err.getMessage() + '; ';
                    }
                    failedEmailResults.add(new CaseResult(
                        currentCase.Id, currentCase.CaseNumber, currentCase.Account?.Name,
                        currentCase.SCC_Email__c, 'Email send error: ' + error
                    ));
                    caseMap.remove(currentCase.Id);
                }
            }
            
            // Phase 3: Update cases where email was sent successfully
            updateSuccessfulCases(successfulEmailCases);
        }
    }

    // Optimized email creation
    private Messaging.SingleEmailMessage createEmailForCase(Case caseRecord) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(caseRecord.Id);
        email.setToAddresses(new List<String>{caseRecord.SCC_Email__c});
        email.setOrgWideEmailAddressId(orgWideEmail.Id);
        email.setSaveAsActivity(false); // Reduce DML operations

        // Use template directly instead of manual replacement
        email.setTemplateId(emailTemplate.Id);
        email.setTargetObjectId(UserInfo.getUserId()); // Required when using template
        email.setWhatId(caseRecord.Id);
        email.setSaveAsActivity(false);
        
        return email;
    }

    // Bulk update successful cases
    private void updateSuccessfulCases(Set<Id> successfulCaseIds) {
        if (successfulCaseIds.isEmpty()) return;
        
        List<Case> casesToUpdate = new List<Case>();
        for (Id caseId : successfulCaseIds) {
            casesToUpdate.add(new Case(
                Id = caseId,
                SCC_Sent_Email_Perpanjangan_SLA__c = true
            ));
        }
        
        Database.SaveResult[] updateResults = Database.update(casesToUpdate, false);
        for (Integer i = 0; i < updateResults.size(); i++) {
            if (!updateResults[i].isSuccess()) {
                Case failedCase = casesToUpdate[i];
                String errorMsg = '';
                for (Database.Error err : updateResults[i].getErrors()) {
                    errorMsg += err.getMessage() + '; ';
                }
                failedUpdateResults.add(new CaseResult(
                    failedCase.Id, null, null, null, 'Update error: ' + errorMsg
                ));
            }
        }
    }

    // Finish method - optimized
    public void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'Batch completed: ' + totalProcessed + ' processed, ' + emailsSent + ' emails sent');
        sendEmailReport();
    }

    // Send email report - optimized
    private void sendEmailReport() {
        try {
            if (String.isBlank(ADMIN_EMAIL)) return;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { ADMIN_EMAIL });
            mail.setSubject('Laporan Batch SCC_SendEmailNotificationOverSLA - ' + System.today().format());
            mail.setHtmlBody(createEmailReportBody());
            mail.setSaveAsActivity(false);

            if (orgWideEmail != null) {
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending admin report: ' + e.getMessage());
        }
    }

    // Build email report body - optimized with string concatenation
    private String createEmailReportBody() {
        String body = '<h2>Laporan Batch SCC_SendEmailNotificationOverSLA</h2>';
        body += '<p><strong>Tanggal Eksekusi:</strong> ' + System.now().format() + '</p>';
        body += '<p><strong>Total Diproses:</strong> ' + totalProcessed + '</p>';
        body += '<p><strong>Email Berhasil Terkirim:</strong> ' + emailsSent + '</p>';
        body += '<p><strong>Gagal Update Status:</strong> ' + failedUpdateResults.size() + '</p>';
        body += '<p><strong>Gagal Kirim Email:</strong> ' + failedEmailResults.size() + '</p>';

        if (!successResults.isEmpty()) {
            body += createTable('Daftar Case Berhasil Dikirim Email', successResults, false);
        }
        if (!failedUpdateResults.isEmpty()) {
            body += createTable('Daftar Case Gagal Update Status', failedUpdateResults, true);
        }
        if (!failedEmailResults.isEmpty()) {
            body += createTable('Daftar Case Gagal Kirim Email', failedEmailResults, true);
        }
        
        return body;
    }

    // Helper to build a table - optimized
    private String createTable(String title, List<CaseResult> results, Boolean includeError) {
        String table = '<h3>' + title + ':</h3>';
        table += '<table border="1" style="border-collapse: collapse; width: 100%;">';
        table += '<tr style="background-color: #f2f2f2;">' +
                 '<th style="padding: 8px;">Case Number</th>' +
                 '<th style="padding: 8px;">Case ID</th>' +
                 '<th style="padding: 8px;">Nama Account</th>' +
                 '<th style="padding: 8px;">Email</th>';
        if (includeError) {
            table += '<th style="padding: 8px;">Pesan Error</th>';
        }
        table += '</tr>';
        
        for (CaseResult result : results) {
            table += '<tr>' +
                     '<td style="padding: 8px;">' + result.caseNumber + '</td>' +
                     '<td style="padding: 8px;">' + result.caseId + '</td>' +
                     '<td style="padding: 8px;">' + (result.accountName != null ? result.accountName : '-') + '</td>' +
                     '<td style="padding: 8px;">' + result.email + '</td>';
            if (includeError) {
                table += '<td style="padding: 8px;">' + result.errorMessage + '</td>';
            }
            table += '</tr>';
        }
        
        table += '</table>';
        return table;
    }

    // Run batch
    public static void runBatch() {
        Database.executeBatch(new SCC_SendEmailNotificationOverSLA(), BATCH_SIZE);
    }
}