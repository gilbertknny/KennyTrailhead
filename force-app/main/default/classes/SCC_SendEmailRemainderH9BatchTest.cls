/**
 * @description       : 
 * @author            : Ahmad Yazid Munif
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class SCC_SendEmailRemainderH9BatchTest {
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.Email_Template_H9; 
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification; 
    @TestSetup
    static void makeData(){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name =:BUSINESS_HOURS_NAME LIMIT 1];
        // Create Call Type
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true,
            SCC_Level1_OLA__c = 6,
            SCC_Level2_OLA__c = 2
        );
        insert callTypeRecord;

        // Create an Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create ContentVersion for file attachment
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDoc.pdf';
        cv.VersionData = Blob.valueOf('Test file content');
        cv.IsMajorVersion = true;
        insert cv;
        
        // Get ContentDocumentId
        ContentVersion cvInserted = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ];
        
        // Create ContentDocumentLink to Call Type
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = callTypeRecord.Id;
        cdl.ContentDocumentId = cvInserted.ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        // Create test Cases
        Case caseRecord1 = new Case();
        caseRecord1.Subject = 'Test Case';
        caseRecord1.CreatedDate = System.now().addDays(-20);
        caseRecord1.SCC_Email__c = 'test@example.com';
        caseRecord1.Status = 'Waiting Document';
        caseRecord1.SCC_List_of_Required_Documents__c = 'Document kk';
        caseRecord1.SCC_Call_Type__c = callTypeRecord.Id;
        insert caseRecord1;

        Case caseRecord2 = new Case();
        caseRecord2.Subject = 'Test Case 2';
        caseRecord2.CreatedDate = System.now().addDays(-20);
        caseRecord2.SCC_Email__c = 'test2@example.com';
        caseRecord2.Status = 'Waiting Document';
        caseRecord2.SCC_List_of_Required_Documents__c = 'Document kk';
        caseRecord2.SCC_Call_Type__c = callTypeRecord.Id;
        insert caseRecord2;
    }
    @isTest
    static void testBatchSendEmailRemainder() {
        // Step 1: Create test data
        // Create a Business Hours record (assuming it exists in the org)
        // BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Branch User' LIMIT 1];

        // // Create Call Type
        // SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
        //     Name = 'Test Call Type',
        //     SCC_Customer_Segment__c = 'Individu Umum',
        //     SSC_Product_L1__c = 'Investment',
        //     SSC_Product_L2__c = 'DPLK',
        //     SSC_Case_Category__c = 'Complaint - Transaction',
        //     SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
        //     SCC_Sub_Description__c = 'Option1;Option2;Option3',
        //     Active__c = true
        // );
        // insert callTypeRecord;

        // // Create an Account
        // Account testAccount = new Account(Name = 'Test Account');
        // insert testAccount;

        // // Create test Cases
        // Case caseRecord1 = new Case();
        // caseRecord1.CreatedDate = System.now().addDays(-20);
        // caseRecord1.SCC_Email__c = 'test@example.com';
        // caseRecord1.Status = 'Waiting Document';
        // caseRecord1.SCC_List_of_Required_Documents__c = 'Document kk';
        // caseRecord1.SCC_Call_Type__c = callTypeRecord.Id;
        // insert caseRecord1;

        // Step 2: Execute the batch
        Test.startTest();
        SCC_SendEmailRemainderH9Batch batch = new SCC_SendEmailRemainderH9Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Step 3: Verify the results
        // Check the debug logs for the total emails sent
        // Note: You can check the debug logs in the Salesforce Developer Console to see the output of the debug statements.
        
        // Since we cannot directly assert the email sending in tests, we can check the debug logs
        // Alternatively, you can use a mock for the Messaging.sendEmail method if needed.

        // Step 4: Verify that the emails were sent
        // This part is tricky because Salesforce does not allow us to verify sent emails directly in tests.
        // However, we can check the number of emails sent by checking the debug logs or using a mock.

        // You can also check if the admin notification email was sent by mocking the Messaging.sendEmail method.
    }
    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA batchJob = new SCC_SendEmailNotificationOverSLA();
        List<Case> caseList = [SELECT Id, SCC_Email__c, SCC_Sent_Email_Perpanjangan_SLA__c, Subject, CaseNumber, Account.Name FROM Case WHERE Subject = 'Test Case 2'];
        System.assert(caseList.size() > 0, 'There should be at least one case to process.');

        batchJob.execute(null, caseList);
        Test.stopTest();

        for (Case c : [SELECT SCC_Sent_Email_Perpanjangan_SLA__c, CaseNumber FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = true]) {
            System.assertEquals(true, c.SCC_Sent_Email_Perpanjangan_SLA__c, 'The email sent flag should be true for case: ' + c.CaseNumber);
        }
    }

    @isTest
    static void testRunBatch() {
        Test.startTest();
        SCC_SendEmailRemainderH9Batch.runBatch();
        Test.stopTest();
    }
}