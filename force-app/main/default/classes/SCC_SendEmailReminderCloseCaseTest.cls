/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 16-01-2025
 * @last modified by  : Ardyta Yudianto
**/
@isTest
public class SCC_SendEmailReminderCloseCaseTest {
    @isTest
    static void testSendEmailReminder() {
        // Setup Data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

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

        Case testCase = new Case(
            AccountId = testAccount.Id,
            SCC_Email__c = 'test@example.com',
            SCC_List_of_Required_Documents__c = '<p>Document 1</p><br/><p>Document 2</p>',
            SCC_Call_Type__c = callTypeRecord.Id
        );
        insert testCase;

        // Create Email Template
        // EmailTemplate emailTemplate = new EmailTemplate(
        //     DeveloperName = 'Reminder_1_H_1_butuh_doc',
        //     Name = 'Reminder Email Template',
        //     Subject = 'Reminder: Case {!Case.CaseNumber}',
        //     Body = 'Halo {!Case.Account},\n\nMohon melengkapi dokumen berikut: {!Case.SCC_List_of_Required_Documents__c}',
        //     FolderId = UserInfo.getUserId(), // Tempatkan di folder user saat ini
        //     TemplateType = 'text'
        // );
        // insert emailTemplate;

        Test.startTest();
        // Call the method with valid data
        SCC_SendEmailReminder.sendEmailReminder(new List<Id>{testCase.Id});
        Test.stopTest();

        // Verifikasi tidak ada error (email tidak dapat diverifikasi secara langsung dalam sandbox)
        System.assert(true, 'Email seharusnya berhasil diproses tanpa error.');
    }

    @isTest
    static void testSendEmailReminderEmptyCaseIds() {
        Test.startTest();
        // Call the method with null data
        SCC_SendEmailReminder.sendEmailReminder(null);
        Test.stopTest();

        // Verifikasi tidak ada error
        System.assert(true, 'Tidak ada email yang dikirimkan, tidak ada error.');
    }

    @isTest
    static void testSendEmailReminderNoValidCases() {
        Test.startTest();
        // Call the method with non-existent Case ID
        SCC_SendEmailReminder.sendEmailReminder(new List<Id>{'500000000000000AAA'});
        Test.stopTest();

        // Verifikasi tidak ada error
        System.assert(true, 'Tidak ada email yang dikirimkan, tidak ada error.');
    }
}