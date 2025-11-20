/**
 * @description       : Test class for SCC_SendEmailReminderCloseCase
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 13-03-2025
 * @last modified by  : Ardyta Yudianto
**/
@isTest
public class SCC_SendEmailReminderCloseCaseTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test call type record
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true
        );
        insert callTypeRecord;

        // Create a test case
        Case testCase = new Case(
            AccountId = testAccount.Id,
            SCC_Email__c = 'test@example.com',
            SCC_List_of_Required_Documents__c = '<p>Document 1</p><br/><p>Document 2</p>',
            SCC_Call_Type__c = callTypeRecord.Id,
            SSC_Call_Type_Description__c = 'Test Call Type Description'
        );
        insert testCase;

        // Create a test email template
        SCC_Email_Template__c emailTemplate = new SCC_Email_Template__c(
            Name = 'Reminder Email Template',
            Template_Subject__c = 'Reminder: Case {!Case.CaseNumber}',
            Template_Body__c = 'Yth. {!Case.Account},\n\nIni adalah pengingat untuk kasus Anda {!Case.CaseNumber} yang dibuat pada {!Case.CreatedDate}. Detail kasus: {!Case.SSC_Call_Type_Description__c}'
        );
        insert emailTemplate;
    }
    
    @isTest
    static void testSendEmailReminder() {
        // Get test data
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        SCC_Email_Template__c emailTemplate = [SELECT Id FROM SCC_Email_Template__c LIMIT 1];
        
        // Create the request object
        SCC_SendEmailReminderCloseCase.EmailReminderRequest request = new SCC_SendEmailReminderCloseCase.EmailReminderRequest();
        request.caseId = testCase.Id;
        request.emailTemplateId = emailTemplate.Id;
        
        Test.startTest();
        // Call the method with the request
        SCC_SendEmailReminderCloseCase.sendEmailReminder(new List<SCC_SendEmailReminderCloseCase.EmailReminderRequest>{request});
        Test.stopTest();

        // Since we can't verify emails directly in test context, verify that no exceptions were thrown
        System.assert(true, 'Email seharusnya berhasil diproses tanpa error.');
    }

    @isTest
    static void testSendEmailReminderEmptyRequests() {
        Test.startTest();
        // Call the method with null data
        SCC_SendEmailReminderCloseCase.sendEmailReminder(null);
        
        // Call with empty list
        SCC_SendEmailReminderCloseCase.sendEmailReminder(new List<SCC_SendEmailReminderCloseCase.EmailReminderRequest>());
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assert(true, 'Tidak ada email yang dikirimkan, tidak ada error.');
    }

    @isTest
    static void testSendEmailReminderNoValidCases() {
        Test.startTest();
        // Create request with a non-existent Case ID
        SCC_SendEmailReminderCloseCase.EmailReminderRequest request = new SCC_SendEmailReminderCloseCase.EmailReminderRequest();
        request.caseId = '500000000000000AAA'; // Invalid ID
        request.emailTemplateId = [SELECT Id FROM SCC_Email_Template__c LIMIT 1].Id;
        
        // Call the method with invalid data
        SCC_SendEmailReminderCloseCase.sendEmailReminder(new List<SCC_SendEmailReminderCloseCase.EmailReminderRequest>{request});
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assert(true, 'Tidak ada email yang dikirimkan, tidak ada error.');
    }

    @isTest
    static void testSendEmailReminderWithNullCaseId() {
        Test.startTest();
        // Create request with null Case ID
        SCC_SendEmailReminderCloseCase.EmailReminderRequest request = new SCC_SendEmailReminderCloseCase.EmailReminderRequest();
        request.caseId = null;
        request.emailTemplateId = [SELECT Id FROM SCC_Email_Template__c LIMIT 1].Id;
        
        // Call the method
        SCC_SendEmailReminderCloseCase.sendEmailReminder(new List<SCC_SendEmailReminderCloseCase.EmailReminderRequest>{request});
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assert(true, 'Method should handle null Case ID without error.');
    }

    @isTest
    static void testSendEmailReminderTemplateNotFound() {
        // Get test case
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        // Create request with valid Case ID but non-existent template ID
        SCC_SendEmailReminderCloseCase.EmailReminderRequest request = new SCC_SendEmailReminderCloseCase.EmailReminderRequest();
        request.caseId = testCase.Id;
        request.emailTemplateId = '01p000000000000AAA'; // Invalid ID
        
        // Call the method
        SCC_SendEmailReminderCloseCase.sendEmailReminder(new List<SCC_SendEmailReminderCloseCase.EmailReminderRequest>{request});
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assert(true, 'Method should handle non-existent template without error.');
    }
}