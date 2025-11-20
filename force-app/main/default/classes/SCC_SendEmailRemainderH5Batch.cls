/**  
 * @description       : Batch job to send email reminders for cases  
 * @author            : Ardyta Yudianto  
 * @group             :   
 * @last modified on  : 12-03-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_SendEmailRemainderH5Batch implements Database.Batchable<SObject>, Database.Stateful {
    // Constants for hardcoded values
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.Email_Template_H5; 
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification; 	
    private static final Integer BUSINESS_DAYS_AGO = 5;
    private static final Integer BATCH_SIZE = 50;

    // Stateful variables to track progress across batch execution
    private Integer totalProcessed = 0;
    private Integer emailsSent = 0;
    private List<CaseResult> successResults = new List<CaseResult>();
    private List<CaseResult> failedUpdateResults = new List<CaseResult>();
    private List<CaseResult> failedEmailResults = new List<CaseResult>();
    
    // Inner class to store case results for reporting
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

    // Start method to retrieve records
    public Database.QueryLocator start(Database.BatchableContext BC) {
        BusinessHours userBusinessHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = :BUSINESS_HOURS_NAME 
            LIMIT 1
        ];
        System.debug(LoggingLevel.DEBUG, 'userBusinessHours.Id= ' + userBusinessHours.Id);  

        Datetime fiveDaysAgo = calculateBusinessDaysAgo(userBusinessHours.Id, BUSINESS_DAYS_AGO);  
        DateTime fiveDaysAgoAtEndOfDay = DateTime.newInstance(fiveDaysAgo.date(), Time.newInstance(23, 59, 0, 0));  
        DateTime fiveDaysAgoAtEndOfDayPlus7Hours = fiveDaysAgoAtEndOfDay.addHours(7);  
                
        System.debug(LoggingLevel.DEBUG, 'fiveDaysAgo= ' + fiveDaysAgo);
        System.debug(LoggingLevel.DEBUG, 'fiveDaysAgoAtEndOfDay= ' + fiveDaysAgoAtEndOfDay);
        System.debug(LoggingLevel.DEBUG, 'fiveDaysAgoAtEndOfDayPlus7Hours= ' + fiveDaysAgoAtEndOfDayPlus7Hours);

        return Database.getQueryLocator([
            SELECT Id, CreatedDate, SCC_Email__c, CaseNumber, SCC_List_of_Required_Documents__c, Account.Name, SCC_Call_Type__c
            FROM Case 
            WHERE Status = 'Waiting Document'
            AND CreatedDate <= :fiveDaysAgoAtEndOfDayPlus7Hours
            AND SCC_Email__c != NULL
            AND Notification_4__c = false
        ]);
    }

    // Execute method to process records
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        totalProcessed += scope.size();
        
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, Body, HtmlValue
            FROM EmailTemplate 
            WHERE DeveloperName = :EMAIL_TEMPLATE_DEVELOPER_NAME 
            LIMIT 1
        ];
        OrgWideEmailAddress orgWideEmail = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME 
            LIMIT 1
        ];
    
        // Maps to track valid and invalid cases
        Map<Id, Case> validCases = new Map<Id, Case>();
        Map<Id, Messaging.SingleEmailMessage> emailsByCase = new Map<Id, Messaging.SingleEmailMessage>();
        
        // Pre-fetch ContentDocumentLinks and ContentVersions
        Set<Id> callTypeIds = new Set<Id>();
        for (Case c : scope) {
            if (c.SCC_Call_Type__c != null) {
                callTypeIds.add(c.SCC_Call_Type__c);
            }
        }
    
        Map<Id, List<ContentDocumentLink>> fileLinksByCallType = new Map<Id, List<ContentDocumentLink>>();
        if (!callTypeIds.isEmpty()) {
            for (ContentDocumentLink link : [
                SELECT LinkedEntityId, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :callTypeIds
            ]) {
                if (!fileLinksByCallType.containsKey(link.LinkedEntityId)) {
                    fileLinksByCallType.put(link.LinkedEntityId, new List<ContentDocumentLink>());
                }
                fileLinksByCallType.get(link.LinkedEntityId).add(link);
            }
        }
    
        Set<Id> contentDocIds = new Set<Id>();
        for (List<ContentDocumentLink> links : fileLinksByCallType.values()) {
            for (ContentDocumentLink link : links) {
                contentDocIds.add(link.ContentDocumentId);
            }
        }
    
        Map<Id, ContentVersion> contentVersionsById = new Map<Id, ContentVersion>();
        if (!contentDocIds.isEmpty()) {
            for (ContentVersion cv : [
                SELECT ContentDocumentId, VersionData, Title, FileExtension 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocIds 
                ORDER BY CreatedDate DESC
            ]) {
                contentVersionsById.put(cv.ContentDocumentId, cv);
            }
        }

        // First pass: Prepare emails and validate cases
        for (Case caseRecord : scope) {
            try {
                // Create email message
                Messaging.SingleEmailMessage email = prepareEmail(
                    caseRecord, 
                    emailTemplate, 
                    orgWideEmail, 
                    fileLinksByCallType, 
                    contentVersionsById
                );
                
                // Add to tracking maps
                emailsByCase.put(caseRecord.Id, email);
                validCases.put(caseRecord.Id, caseRecord);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Error preparing email for Case ' + 
                    caseRecord.CaseNumber + ': ' + e.getMessage());
                failedEmailResults.add(new CaseResult(
                    caseRecord.Id,
                    caseRecord.CaseNumber,
                    caseRecord.Account?.Name,
                    caseRecord.SCC_Email__c,
                    'Error preparing email: ' + e.getMessage()
                ));
            }
        }

        // Second pass: Update cases with validation check
        if (!validCases.isEmpty()) {
            List<Case> casesToValidate = validCases.values();
            for (Case c : casesToValidate) {
                c.Notification_4__c = true;
            }

            List<Database.SaveResult> updateResults = Database.update(casesToValidate, false);

            // Process results and remove invalid cases
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                Id caseId = casesToValidate[i].Id;
                Case currentCase = casesToValidate[i];
                
                if (!result.isSuccess()) {
                    String errorMsg = '';
                    for (Database.Error err : result.getErrors()) {
                        errorMsg += err.getMessage() + '; ';
                    }
                    
                    failedUpdateResults.add(new CaseResult(
                        currentCase.Id,
                        currentCase.CaseNumber,
                        currentCase.Account?.Name,
                        currentCase.SCC_Email__c,
                        'Update error: ' + errorMsg
                    ));
                    
                    // Remove failed cases from both maps
                    validCases.remove(caseId);
                    emailsByCase.remove(caseId);
                    
                    System.debug(LoggingLevel.ERROR, 'Case update failed for ' + 
                        currentCase.CaseNumber + ': ' + errorMsg);
                }
            }
        }

        // Final pass: Send emails only for valid cases
        if (!emailsByCase.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsByCase.values(), false);
            List<Id> validCaseIds = new List<Id>(emailsByCase.keySet());
            
            for (Integer i = 0; i < results.size(); i++) {
                Messaging.SendEmailResult result = results[i];
                Id caseId = validCaseIds[i];
                Case currentCase = validCases.get(caseId);
                
                if (result.isSuccess()) {
                    emailsSent++;
                    successResults.add(new CaseResult(
                        currentCase.Id,
                        currentCase.CaseNumber,
                        currentCase.Account?.Name,
                        currentCase.SCC_Email__c,
                        null 
                    ));
                } else {
                    String emailErrorMsg = '';
                    for (Messaging.SendEmailError err : result.getErrors()) {
                        emailErrorMsg += err.getMessage() + '; ';
                    }
                    
                    failedEmailResults.add(new CaseResult(
                        currentCase.Id,
                        currentCase.CaseNumber,
                        currentCase.Account?.Name,
                        currentCase.SCC_Email__c,
                        'Email send error: ' + emailErrorMsg
                    ));
                    
                    System.debug(LoggingLevel.ERROR, 'Failed to send email for case ' + 
                        currentCase.CaseNumber + ': ' + emailErrorMsg);
                }
            }
        }
    }

    // Helper method to prepare email
    private Messaging.SingleEmailMessage prepareEmail(
        Case caseRecord, 
        EmailTemplate emailTemplate, 
        OrgWideEmailAddress orgWideEmail,
        Map<Id, List<ContentDocumentLink>> fileLinksByCallType,
        Map<Id, ContentVersion> contentVersionsById
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(caseRecord.Id);
        email.setSaveAsActivity(true);

        String emailSubject = emailTemplate.Subject.replace('{!Case.CaseNumber}', caseRecord.CaseNumber);
        String greeting = caseRecord.Account != null && caseRecord.Account.Name != null 
            ? 'Yth. Bapak/Ibu ' + caseRecord.Account.Name 
            : 'Nasabah';

        String plainTextDocuments = '';  
        if (caseRecord.SCC_List_of_Required_Documents__c != null) {  
            plainTextDocuments = caseRecord.SCC_List_of_Required_Documents__c  
                .replaceAll('<br\\s*/?>', '\n')   
                .replaceAll('<[^>]*>', '')        
                .trim();    
        } else {  
            plainTextDocuments = 'Tidak ada dokumen spesifik yang disebutkan';  
        }  

        String emailBody = emailTemplate.Body
            .replace('{!Case.Account}', greeting)
            .replace('{!Case.CaseNumber}', caseRecord.CaseNumber)
            .replace('{!Case.SCC_List_of_Required_Documents__c}', plainTextDocuments);                

        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);
        email.setToAddresses(new List<String>{caseRecord.SCC_Email__c});
        email.setOrgWideEmailAddressId(orgWideEmail.Id);

        // Handle attachments
        if (caseRecord.SCC_Call_Type__c != null && fileLinksByCallType.containsKey(caseRecord.SCC_Call_Type__c)) {
            List<ContentDocumentLink> fileLinks = fileLinksByCallType.get(caseRecord.SCC_Call_Type__c);
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

            for (ContentDocumentLink link : fileLinks) {
                if (contentVersionsById.containsKey(link.ContentDocumentId)) {
                    ContentVersion cv = contentVersionsById.get(link.ContentDocumentId);
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(cv.Title + '.' + cv.FileExtension);
                    attachment.setBody(cv.VersionData);
                    attachments.add(attachment);
                }
            }

            if (!attachments.isEmpty()) {
                email.setFileAttachments(attachments);
            }
        }

        return email;
    }

    // Finish method for logging and sending admin email with HTML format
    public void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'Total cases processed: ' + totalProcessed);
        System.debug(LoggingLevel.INFO, 'Total email reminder sent: ' + emailsSent);
        System.debug(LoggingLevel.INFO, 'Total successful cases: ' + successResults.size());
        System.debug(LoggingLevel.INFO, 'Total failed update cases: ' + failedUpdateResults.size());
        System.debug(LoggingLevel.INFO, 'Total failed email cases: ' + failedEmailResults.size());
        
        // Send HTML email report to admin
        sendEmailReport();
    }
    
    // Send email report to admin with HTML formatting
    private void sendEmailReport() {
        try {
            // Create email body with HTML formatting
            String emailBody = createEmailReportBody();
            
            // Set up email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { ADMIN_EMAIL });
            mail.setSubject('Laporan Batch SCC_SendEmailRemainderH5Batch ' + 
                           System.today().format() + ' - Sent: ' + emailsSent + 
                           ', Failed: ' + (failedUpdateResults.size() + failedEmailResults.size()));
            mail.setHtmlBody(emailBody);
            
            // Send email using OWD
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
            System.debug(LoggingLevel.ERROR, 'Error sending email report: ' + e.getMessage());
        }
    }
    
    // Create HTML email report body
    private String createEmailReportBody() {
        String body = '<h2>Laporan Batch SCC_SendEmailRemainderH5Batch</h2>';
        body += '<p><strong>Tanggal Eksekusi:</strong> ' + System.now().format() + '</p>';
        body += '<p><strong>Total Diproses:</strong> ' + totalProcessed + '</p>';
        body += '<p><strong>Email Berhasil Terkirim:</strong> ' + emailsSent + '</p>';
        body += '<p><strong>Gagal Update Status:</strong> ' + failedUpdateResults.size() + '</p>';
        body += '<p><strong>Gagal Kirim Email:</strong> ' + failedEmailResults.size() + '</p>';
        
        // Add successful cases table
        if (!successResults.isEmpty()) {
            body += '<h3>Daftar Case Berhasil Dikirim Email:</h3>';
            body += '<table border="1" style="border-collapse: collapse; width: 100%;">';
            body += '<tr style="background-color: #f2f2f2;">' +
                   '<th style="padding: 8px; text-align: left;">Case Number</th>' +
                   '<th style="padding: 8px; text-align: left;">Case ID</th>' +
                   '<th style="padding: 8px; text-align: left;">Nama Account</th>' +
                   '<th style="padding: 8px; text-align: left;">Email</th>' +
                   '</tr>';
            
            for (CaseResult result : successResults) {
                body += '<tr>' +
                       '<td style="padding: 8px;">' + result.caseNumber + '</td>' +
                       '<td style="padding: 8px;">' + result.caseId + '</td>' +
                       '<td style="padding: 8px;">' + (result.accountName != null ? result.accountName : '-') + '</td>' +
                       '<td style="padding: 8px;">' + result.email + '</td>' +
                       '</tr>';
            }
            
            body += '</table>';
        }
        
        // Add failed update cases table
        if (!failedUpdateResults.isEmpty()) {
            body += '<h3>Daftar Case Gagal Dikirim Email:</h3>';
            body += '<table border="1" style="border-collapse: collapse; width: 100%;">';
            body += '<tr style="background-color: #f2f2f2;">' +
                   '<th style="padding: 8px; text-align: left;">Case Number</th>' +
                   '<th style="padding: 8px; text-align: left;">Case ID</th>' +
                   '<th style="padding: 8px; text-align: left;">Nama Account</th>' +
                   '<th style="padding: 8px; text-align: left;">Email</th>' +
                   '<th style="padding: 8px; text-align: left;">Pesan Error</th>' +
                   '</tr>';
            
            for (CaseResult result : failedUpdateResults) {
                body += '<tr>' +
                       '<td style="padding: 8px;">' + result.caseNumber + '</td>' +
                       '<td style="padding: 8px;">' + result.caseId + '</td>' +
                       '<td style="padding: 8px;">' + (result.accountName != null ? result.accountName : '-') + '</td>' +
                       '<td style="padding: 8px;">' + result.email + '</td>' +
                       '<td style="padding: 8px;">' + result.errorMessage + '</td>' +
                       '</tr>';
            }
            
            body += '</table>';
        }
        
        // Add failed email cases table
        if (!failedEmailResults.isEmpty()) {
            body += '<h3>Daftar Case Gagal Kirim Email:</h3>';
            body += '<table border="1" style="border-collapse: collapse; width: 100%;">';
            body += '<tr style="background-color: #f2f2f2;">' +
                   '<th style="padding: 8px; text-align: left;">Case Number</th>' +
                   '<th style="padding: 8px; text-align: left;">Case ID</th>' +
                   '<th style="padding: 8px; text-align: left;">Nama Account</th>' +
                   '<th style="padding: 8px; text-align: left;">Email</th>' +
                   '<th style="padding: 8px; text-align: left;">Pesan Error</th>' +
                   '</tr>';
            
            for (CaseResult result : failedEmailResults) {
                body += '<tr>' +
                       '<td style="padding: 8px;">' + result.caseNumber + '</td>' +
                       '<td style="padding: 8px;">' + result.caseId + '</td>' +
                       '<td style="padding: 8px;">' + (result.accountName != null ? result.accountName : '-') + '</td>' +
                       '<td style="padding: 8px;">' + result.email + '</td>' +
                       '<td style="padding: 8px;">' + result.errorMessage + '</td>' +
                       '</tr>';
            }
            
            body += '</table>';
        }
        
        return body;
    }

    // Method to calculate business days ago
    public static Datetime calculateBusinessDaysAgo(Id businessHoursId, Integer businessDays) {
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

    // Method to run batch manually
    public static void runBatch() {
        SCC_SendEmailRemainderH5Batch batchJob = new SCC_SendEmailRemainderH5Batch();
        Database.executeBatch(batchJob, BATCH_SIZE);
    }
}