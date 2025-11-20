/**  
 * @description       : Batch job to send email reminders for cases  
 * @author            : Ardyta Yudianto  
 * @group             :   
 * @last modified on  : 03-13-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SCC_SendEmailRemainderH9Batch implements Database.Batchable<SObject>, Database.Stateful {
    // Constants for hardcoded values
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.Email_Template_H9; 
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification; 	
    private static final Integer BUSINESS_DAYS_AGO = 9;
    private static final Integer BATCH_SIZE = 20;

    // Variables to track processing
    private Integer emailsSent = 0;
    private List<String> caseNamesSent = new List<String>();
    private List<Id> casesToUpdate = new List<Id>();
    private Map<String, String> failedCasesMap = new Map<String, String>(); // Store CaseNumber -> Error Message
    private Map<String, String> failedEmailsMap = new Map<String, String>(); // Store CaseNumber -> Email Error Message

    // Start method to retrieve records
    public Database.QueryLocator start(Database.BatchableContext BC) {
        BusinessHours userBusinessHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = :BUSINESS_HOURS_NAME 
            LIMIT 1
        ];
        System.debug(LoggingLevel.DEBUG, 'userBusinessHours.Id= ' + userBusinessHours.Id);  

        Datetime nineDaysAgo = calculateBusinessDaysAgo(userBusinessHours.Id, BUSINESS_DAYS_AGO);  
        DateTime nineDaysAgoAtEndOfDay = DateTime.newInstance(nineDaysAgo.date(), Time.newInstance(23, 59, 0, 0));  
        DateTime nineDaysAgoAtEndOfDayPlus7Hours = nineDaysAgoAtEndOfDay.addHours(7);  
                
        System.debug(LoggingLevel.DEBUG, 'nineDaysAgo= ' + nineDaysAgo);
        System.debug(LoggingLevel.DEBUG, 'nineDaysAgoAtEndOfDay= ' + nineDaysAgoAtEndOfDay);
        System.debug(LoggingLevel.DEBUG, 'nineDaysAgoAtEndOfDayPlus7Hours= ' + nineDaysAgoAtEndOfDayPlus7Hours);

        return Database.getQueryLocator([
            SELECT Id, CreatedDate, SCC_Email__c, CaseNumber, SCC_List_of_Required_Documents__c, Account.Name, SCC_Call_Type__c, Notification_5__c
            FROM Case 
            WHERE Status = 'Waiting Document'
            AND CreatedDate <= :nineDaysAgoAtEndOfDayPlus7Hours
            AND SCC_Email__c != NULL
            AND Notification_5__c = false
        ]);
    }

    // Execute method to process records
    public void execute(Database.BatchableContext BC, List<Case> scope) {
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
                failedEmailsMap.put(caseRecord.CaseNumber, 'Error preparing email: ' + e.getMessage());
            }
        }

        // Second pass: Update cases with validation check
        if (!validCases.isEmpty()) {
            List<Case> casesToValidate = validCases.values();
            for (Case c : casesToValidate) {
                c.Notification_5__c = true;
            }

            List<Database.SaveResult> updateResults = Database.update(casesToValidate, false);

            // Process results and remove invalid cases
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                Id caseId = casesToValidate[i].Id;
                
                if (!result.isSuccess()) {
                    String errorMsg = '';
                    for (Database.Error err : result.getErrors()) {
                        errorMsg += err.getMessage() + '; ';
                    }
                    failedCasesMap.put(casesToValidate[i].CaseNumber, errorMsg);
                    
                    // Remove failed cases from both maps
                    validCases.remove(caseId);
                    emailsByCase.remove(caseId);
                    
                    System.debug(LoggingLevel.ERROR, 'Case update failed for ' + 
                        casesToValidate[i].CaseNumber + ': ' + errorMsg);
                }
            }
        }

        // Final pass: Send emails only for valid cases
        if (!emailsByCase.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsByCase.values(), false);
            
            for (Integer i = 0; i < results.size(); i++) {
                Messaging.SendEmailResult result = results[i];
                Id caseId = new List<Id>(emailsByCase.keySet())[i];
                Case currentCase = validCases.get(caseId);
                
                if (result.isSuccess()) {
                    emailsSent++;
                    caseNamesSent.add(currentCase.CaseNumber);
                    casesToUpdate.add(caseId);
                } else {
                    String emailErrorMsg = '';
                    for (Messaging.SendEmailError err : result.getErrors()) {
                        emailErrorMsg += err.getMessage() + '; ';
                    }
                    failedEmailsMap.put(currentCase.CaseNumber, emailErrorMsg);
                    
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

    // Finish method for logging and sending admin email
    public void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'Total email reminder sent: ' + emailsSent);
        
        OrgWideEmailAddress orgWideEmail = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME 
            LIMIT 1
        ];
        
        String caseNames = String.join(caseNamesSent, ', ');
        
        // Build error report sections
        String updateErrorsReport = '';
        if (!failedCasesMap.isEmpty()) {
            updateErrorsReport = '\n\nKasus yang gagal diupdate:\n';
            for (String caseNumber : failedCasesMap.keySet()) {
                updateErrorsReport += '- Case ' + caseNumber + ': ' + failedCasesMap.get(caseNumber) + '\n';
            }
        }
        
        String emailErrorsReport = '';
        if (!failedEmailsMap.isEmpty()) {
            emailErrorsReport = '\n\nKasus yang gagal mengirim email:\n';
            for (String caseNumber : failedEmailsMap.keySet()) {
                emailErrorsReport += '- Case ' + caseNumber + ': ' + failedEmailsMap.get(caseNumber) + '\n';
            }
        }

        // Prepare admin email with comprehensive report
        Messaging.SingleEmailMessage adminEmail = new Messaging.SingleEmailMessage();
        adminEmail.setToAddresses(new List<String>{ADMIN_EMAIL});
        adminEmail.setSubject('Email Reminder SCC_SendEmailRemainderH9Batch Selesai (UAT)');
        adminEmail.setPlainTextBody(
            'Total email reminder yang terkirim: ' + emailsSent + 
            '\nNama kasus yang berhasil dikirim email: ' + caseNames +
            updateErrorsReport +
            emailErrorsReport
        );
        adminEmail.setOrgWideEmailAddressId(orgWideEmail.Id);

        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{adminEmail});
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending admin email: ' + e.getMessage() + 
                ' Stack Trace: ' + e.getStackTraceString());
        }
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
        SCC_SendEmailRemainderH9Batch batchJob = new SCC_SendEmailRemainderH9Batch();
        Database.executeBatch(batchJob, BATCH_SIZE);
    }
}