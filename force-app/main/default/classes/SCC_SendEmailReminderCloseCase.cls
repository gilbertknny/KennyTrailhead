/**    
 * @description       : Class yang dipanggil dari Flow untuk mengirim email reminder berdasarkan Case ID    
 * @author            : Ardyta Yudianto    
 * @group             :     
 * @last modified on  : 28-02-2025
 * @last modified by  : Ardyta Yudianto
**/    
public class SCC_SendEmailReminderCloseCase {    
    
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;

    public class EmailReminderRequest {    
        @InvocableVariable    
        public Id caseId; // Single Case ID    
            
        @InvocableVariable    
        public Id emailTemplateId; // Email Template ID    
    }    
    
    // Metode utama untuk mengirim email    
    @InvocableMethod    
    public static void sendEmailReminder(List<EmailReminderRequest> requests) {    
        System.debug('===== START: sendEmailReminder =====');
        System.debug('Requests received: ' + (requests != null ? requests.size() : 0));
        
        if (requests == null || requests.isEmpty()) {    
            System.debug('Tidak ada permintaan yang diberikan.');    
            return;    
        }    
    
        // Process each request    
        for (EmailReminderRequest request : requests) {    
            System.debug('Processing request for Case ID: ' + request.caseId);
            System.debug('Email Template ID: ' + request.emailTemplateId);
            
            if (request.caseId == null) {    
                System.debug('Tidak ada Case ID yang diberikan.');    
                continue;    
            }    
    
            // Query untuk mendapatkan Case yang relevan    
            List<Case> cases = [    
                SELECT Id, SCC_Email__c, CaseNumber, Account.Name, SCC_Call_Type__c, CreatedDate , BRI_CreatedTime__c, SSC_Call_Type_Description__c      
                FROM Case    
                WHERE Id = :request.caseId    
                AND SCC_Email__c != NULL    
            ];    
    
            System.debug('Cases found: ' + cases.size());
            
            if (cases.isEmpty()) {    
                System.debug('Tidak ada Case yang memenuhi kriteria.');    
                continue;    
            }    
    
            try {
                // Ambil Email Template berdasarkan ID yang diberikan    
                SCC_Email_Template__c emailTemplate = [    
                    SELECT Id, Name, Template_Subject__c, Template_Body__c    
                    FROM SCC_Email_Template__c    
                    WHERE Id = :request.emailTemplateId    
                    LIMIT 1    
                ];
                
                System.debug('Email Template found: ' + emailTemplate.Name);
        
                // Ambil Email OWD    
                OrgWideEmailAddress orgWideEmail = [    
                    SELECT Id 
                    FROM OrgWideEmailAddress 
                    WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME 
                    LIMIT 1
                ];    
                
                System.debug('OrgWideEmailAddress found: ' + orgWideEmail.Id);
            } catch (Exception e) {
                System.debug('ERROR: Error querying template or OrgWideEmailAddress: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
                continue;
            }
    
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();    
    
            for (Case caseRecord : cases) {    
                System.debug('Preparing email for Case: ' + caseRecord.CaseNumber);
                
                try {
                    // Buat email message    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
    
                    // Untuk debugging, tampilkan data merge field
                    System.debug('Case Number: ' + caseRecord.CaseNumber);
                    System.debug('Account Name: ' + (caseRecord.Account != null ? caseRecord.Account.Name : 'null'));
                    System.debug('Created Date: ' + caseRecord.CreatedDate);
                    System.debug('BRI Created Time: ' + caseRecord.BRI_CreatedTime__c);
                    System.debug('Call Type Description: ' + caseRecord.SSC_Call_Type_Description__c);
                    System.debug('Recipient Email: ' + caseRecord.SCC_Email__c);
                    
                    // Ambil Email Template berdasarkan ID yang diberikan    
                    SCC_Email_Template__c emailTemplate = [    
                        SELECT Id, Name, Template_Subject__c, Template_Body__c    
                        FROM SCC_Email_Template__c    
                        WHERE Id = :request.emailTemplateId    
                        LIMIT 1    
                    ];
                
                    // Ambil Email OWD    
                    OrgWideEmailAddress orgWideEmail = [    
                        SELECT Id 
                        FROM OrgWideEmailAddress 
                        WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME 
                        LIMIT 1
                    ];
                    
                    // Ganti merge fields secara manual    
                    String emailSubject = emailTemplate.Template_Subject__c.replace('{!Case.CaseNumber}', caseRecord.CaseNumber);    
    
                    // Tentukan greeting berdasarkan keberadaan Account    
                    String greeting = caseRecord.Account != null && caseRecord.Account.Name != null    
                        ? 'Yth. Bapak/Ibu ' + caseRecord.Account.Name    
                        : 'Nasabah';    
    
                    String emailBody = emailTemplate.Template_Body__c    
                        .replace('{!Case.Account}', greeting)    
                        .replace('{!Case.CaseNumber}', caseRecord.CaseNumber)    
                        .replace('{!Case.CreatedDate}', caseRecord.CreatedDate.format('MM/dd/yyyy'))     
                        .replace('{!Case.BRI_CreatedTime__c}', caseRecord.BRI_CreatedTime__c != null ? caseRecord.BRI_CreatedTime__c : '')    
                        .replace('{!Case.SSC_Call_Type_Description__c}', caseRecord.SSC_Call_Type_Description__c != null ? caseRecord.SSC_Call_Type_Description__c : '');  
    
                    System.debug('Final Email Subject: ' + emailSubject);
                    System.debug('Final Email Body: ' + emailBody);
                    
                    // Atur email    
                    email.setSubject(emailSubject);    
                    email.setPlainTextBody(emailBody);    
                    email.setToAddresses(new List<String>{caseRecord.SCC_Email__c});    
                    email.setOrgWideEmailAddressId(orgWideEmail.Id);    
                    email.setWhatId(caseRecord.Id);
                    email.setSaveAsActivity(true); 
                    emailsToSend.add(email);
                    
                    System.debug('Email message prepared successfully');
                } catch (Exception e) {    
                    System.debug('ERROR: Error mempersiapkan email untuk Case ' + caseRecord.Id + ': ' + e.getMessage());    
                    System.debug('Stack trace: ' + e.getStackTraceString());
                }    
            }    
    
            // Kirim semua email    
            System.debug('Emails to send: ' + emailsToSend.size());
            
            if (!emailsToSend.isEmpty()) {    
                try {    
                    Messaging.sendEmail(emailsToSend, false);    
                    System.debug('Email berhasil dikirim.');    
                } catch (Exception e) {    
                    System.debug('ERROR: Error mengirim email: ' + e.getMessage());
                    System.debug('Stack trace: ' + e.getStackTraceString());
                }    
            }    
        }
        
        System.debug('===== END: sendEmailReminder =====');
    }    
}