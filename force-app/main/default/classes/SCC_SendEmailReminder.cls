/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 13-03-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_SendEmailReminder {
    // Constants for hardcoded values
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = label.EmailTemplateHariHButuhDoc;	
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = label.Email_Wide_Organization;

    // Metode utama untuk mengirim email
    @InvocableMethod
    public static void sendEmailReminder(List<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            System.debug('Tidak ada Case ID yang diberikan.');
            return;
        }

        // Query untuk mendapatkan Case yang relevan
        List<Case> cases = [
            SELECT Id, SCC_Email__c, CaseNumber, SCC_List_of_Required_Documents__c, Account.Name, SCC_Call_Type__c, CreatedDate, BRI_CreatedTime__c, SSC_Call_Type_Description__c  
            FROM Case
            WHERE Id IN :caseIds
            AND SCC_Email__c != NULL
        ];

        if (cases.isEmpty()) {
            System.debug('Tidak ada Case yang memenuhi kriteria.');
            return;
        }

        // Ambil Email Template
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, Body, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName = :EMAIL_TEMPLATE_DEVELOPER_NAME
            LIMIT 1
        ];

        // Ambil Email OWD
        OrgWideEmailAddress orgWideEmail = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME
            LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Case caseRecord : cases) {
            try {
                // Buat email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                // Set relasi dengan Case menggunakan setWhatId
                email.setWhatId(caseRecord.Id);
                
                // Aktifkan pembuatan Activity History
                email.setSaveAsActivity(true);

                // Ganti merge fields secara manual
                String emailSubject = emailTemplate.Subject.replace('{!Case.CaseNumber}', caseRecord.CaseNumber);

                // Tentukan greeting berdasarkan keberadaan Account
                String greeting = caseRecord.Account != null && caseRecord.Account.Name != null
                    ? 'Yth. Bapak/Ibu ' + caseRecord.Account.Name
                    : 'Nasabah';

                // Convert to plain text
                String plainTextDocuments = caseRecord.SCC_List_of_Required_Documents__c != null
                    ? caseRecord.SCC_List_of_Required_Documents__c
                        .replaceAll('<br\\s*/?>', '\n') 
                        .replaceAll('<[^>]*>', '')      
                        .trim()
                    : '';   

                String emailBody = emailTemplate.Body
                    .replace('{!Case.Account}', greeting)
                    .replace('{!Case.CaseNumber}', caseRecord.CaseNumber)
                    .replace('{!Case.CreatedDate}', caseRecord.CreatedDate.format('MM/dd/yyyy')) 
                    .replace('{!Case.BRI_CreatedTime__c}', caseRecord.BRI_CreatedTime__c)
                    .replace('{!Case.SSC_Call_Type_Description__c}', caseRecord.SSC_Call_Type_Description__c)
                    .replace('{!Case.SCC_List_of_Required_Documents__c}',
                        !String.isBlank(plainTextDocuments)
                        ? plainTextDocuments
                        : 'Tidak ada dokumen spesifik yang disebutkan');

                // Atur email
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailBody);
                email.setToAddresses(new List<String>{caseRecord.SCC_Email__c});
                email.setOrgWideEmailAddressId(orgWideEmail.Id);

                // Tambahkan attachment jika ada
                if (caseRecord.SCC_Call_Type__c != null) {
                    List<ContentDocumentLink> fileLinks = [
                        SELECT ContentDocumentId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :caseRecord.SCC_Call_Type__c
                    ];

                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

                    for (ContentDocumentLink link : fileLinks) {
                        ContentVersion contentVersion = [
                            SELECT VersionData, Title, FileExtension
                            FROM ContentVersion
                            WHERE ContentDocumentId = :link.ContentDocumentId
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                        ];

                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(contentVersion.Title + '.' + contentVersion.FileExtension);
                        attachment.setBody(contentVersion.VersionData);
                        attachments.add(attachment);
                    }

                    if (!attachments.isEmpty()) {
                        email.setFileAttachments(attachments);
                    }
                }

                emailsToSend.add(email);
            } catch (Exception e) {
                System.debug('Error mempersiapkan email untuk Case ' + caseRecord.Id + ': ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());
            }
        }

        // Kirim semua email
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend, false);
                System.debug('Email berhasil dikirim.');
            } catch (Exception e) {
                System.debug('Error mengirim email: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());
            }
        }
    }
}