/**
 * @description       : Send notification emails for cases that are over SLA
 * @author            : System.Label.Batch_Size_Notification
 * @group             : 
 * @last modified on  : 30-10-2025
 * @last modified by  : Christian Vieri
 **/
public class SCC_SendEmailNotificationOverSLA implements Database.Batchable<SObject>, Database.Stateful {
    // Constants
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.EmailTemplateOverSLA;
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification;
    private static final Integer BATCH_SIZE = 5;

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

    // Start method - simplified
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query template and org-wide email once
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

        // Use the service class to get cases
        List<Case> cases = SCC_CaseQueryService.getCasesOverSLA();
        
        // Convert to QueryLocator
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, SCC_Email__c, CaseNumber, Status, Account.Name, 
                   isTotalSLAViolated__c, SCC_Sent_Email_Perpanjangan_SLA__c
            FROM Case 
            WHERE Id IN :cases
        ]);
    }

    // Execute method - optimized
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        totalProcessed += scope.size();

        // Separate processing into clear phases
        List<Messaging.SingleEmailMessage> emailsToSend = prepareEmails(scope);
        processEmailSending(emailsToSend, scope);
        updateCaseStatuses(scope);
    }

    // Phase 1: Prepare emails
    private List<Messaging.SingleEmailMessage> prepareEmails(List<Case> cases) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Case caseRecord : cases) {
            try {
                Messaging.SingleEmailMessage email = createEmailForCase(caseRecord);
                emailsToSend.add(email);
            } catch (Exception e) {
                failedEmailResults.add(new CaseResult(
                    caseRecord.Id,
                    caseRecord.CaseNumber,
                    caseRecord.Account?.Name,
                    caseRecord.SCC_Email__c,
                    'Error preparing email: ' + e.getMessage()
                ));
            }
        }
        
        return emailsToSend;
    }

    // Create individual email
    private Messaging.SingleEmailMessage createEmailForCase(Case caseRecord) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(caseRecord.Id);
        email.setToAddresses(new List<String>{caseRecord.SCC_Email__c});
        email.setOrgWideEmailAddressId(orgWideEmail.Id);

        String greeting = caseRecord.Account != null && caseRecord.Account.Name != null 
            ? 'Yth. Bapak/Ibu ' + caseRecord.Account.Name 
            : 'Nasabah'; 

        String emailBody = emailTemplate.Body
            .replace('{!Case.Account}', greeting)
            .replace('{!Case.CaseNumber}', caseRecord.CaseNumber);
        String emailSubject = emailTemplate.Subject.replace('{!Case.CaseNumber}', caseRecord.CaseNumber);

        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);

        return email;
    }

    // Phase 2: Process email sending
    private void processEmailSending(List<Messaging.SingleEmailMessage> emailsToSend, List<Case> cases) {
        if (emailsToSend.isEmpty()) return;

        Map<Id, Case> caseMap = new Map<Id, Case>();
        for (Case c : cases) {
            caseMap.put(c.Id, c);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
        for (Integer i = 0; i < results.size(); i++) {
            Case c = cases[i];
            if (results[i].isSuccess()) {
                emailsSent++;
                successResults.add(new CaseResult(c.Id, c.CaseNumber, c.Account?.Name, c.SCC_Email__c, null));
            } else {
                String error = '';
                for (Messaging.SendEmailError err : results[i].getErrors()) {
                    error += err.getMessage() + '; ';
                }
                failedEmailResults.add(new CaseResult(c.Id, c.CaseNumber, c.Account?.Name, c.SCC_Email__c, 'Email send error: ' + error));
                // Remove from processing for update
                caseMap.remove(c.Id);
            }
        }
    }

    // Phase 3: Update case statuses
    private void updateCaseStatuses(List<Case> cases) {
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : cases) {
            // Only update if email was sent successfully (not in failedEmailResults)
            Boolean emailFailed = false;
            for (CaseResult failed : failedEmailResults) {
                if (failed.caseId == c.Id) {
                    emailFailed = true;
                    break;
                }
            }
            
            if (!emailFailed) {
                c.SCC_Sent_Email_Perpanjangan_SLA__c = true;
                casesToUpdate.add(c);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(casesToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    String errorMsg = '';
                    for (Database.Error err : updateResults[i].getErrors()) {
                        errorMsg += err.getMessage() + '; ';
                    }
                    Case c = casesToUpdate[i];
                    failedUpdateResults.add(new CaseResult(c.Id, c.CaseNumber, c.Account?.Name, c.SCC_Email__c, 'Update error: ' + errorMsg));
                }
            }
        }
    }

    // Finish method (same as original)
    public void finish(Database.BatchableContext BC) {
        System.debug('Total processed: ' + totalProcessed);
        System.debug('Emails sent: ' + emailsSent);
        System.debug('Failures: ' + (failedEmailResults.size() + failedUpdateResults.size()));
        sendEmailReport();
    }

    // Send email report (same as original)
    private void sendEmailReport() {
        try {
            String body = createEmailReportBody();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { ADMIN_EMAIL });
            mail.setSubject('Laporan Batch SCC_SendEmailNotificationOverSLA - ' + System.today().format());
            mail.setHtmlBody(body);

            if (orgWideEmail != null) {
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug('Error sending admin report: ' + e.getMessage());
        }
    }

    // Build email report body (same as original)
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

    // Helper to build a table (same as original)
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