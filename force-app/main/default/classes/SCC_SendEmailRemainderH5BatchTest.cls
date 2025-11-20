/**
 * @description       : Test class for SCC_SendEmailRemainderH5Batch
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : Ahmad Yazid Munif
**/
@isTest
private class SCC_SendEmailRemainderH5BatchTest {
    
    // Set up constants to match those in the batch class
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.Email_Template_H5; 
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification; 	
    
    @testSetup
    static void setupTestData() {
        // Create Email Template
        EmailTemplate template = new EmailTemplate(
            Name = 'Reminder 1 H Case Email',
            DeveloperName = EMAIL_TEMPLATE_DEVELOPER_NAME,
            FolderId = UserInfo.getUserId(),
            TemplateType = 'text',
            Subject = 'Reminder for Case {!Case.CaseNumber}',
            Body = 'Dear {!Case.Account},\n\nThis is a reminder for your case {!Case.CaseNumber}.\n\nRequired Documents:\n{!Case.SCC_List_of_Required_Documents__c}\n\nRegards,\nSupport Team'
        );
        insert template;
    }
    
    @isTest
    static void testBatchSendEmailRemainder() {
        // Step 1: Create test data
        
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

        // Create test Cases with different scenarios
        
        // Case 1: Should receive email reminder
        Case caseWithEmail = new Case(
            Subject = 'Test Case 1',
            Status = 'Waiting Document',
            SCC_Email__c = 'test1@example.com',
            AccountId = testAccount.Id,
            SCC_List_of_Required_Documents__c = 'KTP<br>NPWP<br>Form Application',
            SCC_Call_Type__c = callTypeRecord.Id,
            Notification_4__c = false
        );
        
        // Case 2: Missing email, shouldn't receive reminder
        Case caseNoEmail = new Case(
            Subject = 'Test Case 2',
            Status = 'Waiting Document',
            AccountId = testAccount.Id,
            SCC_List_of_Required_Documents__c = 'KTP<br>NPWP',
            SCC_Call_Type__c = callTypeRecord.Id,
            Notification_4__c = false
        );
        
        // Case 3: Already notified, shouldn't receive reminder
        Case caseAlreadyNotified = new Case(
            Subject = 'Test Case 3',
            Status = 'Waiting Document',
            SCC_Email__c = 'test3@example.com',
            AccountId = testAccount.Id,
            SCC_List_of_Required_Documents__c = 'KTP only',
            SCC_Call_Type__c = callTypeRecord.Id,
            Notification_4__c = true
        );
        
        // Case 4: Wrong status, shouldn't receive reminder
        Case caseWrongStatus = new Case(
            Subject = 'Test Case 4',
            Status = 'In Progress',
            SCC_Email__c = 'test4@example.com',
            AccountId = testAccount.Id,
            SCC_List_of_Required_Documents__c = 'Sample doc',
            SCC_Call_Type__c = callTypeRecord.Id,
            Notification_4__c = false
        );
        Case caseWithEmail2 = new Case(
            Subject = 'Test Case 2',
            Status = 'Waiting Document',
            SCC_Email__c = 'test2@example.com',
            SCC_List_of_Required_Documents__c = 'KTP<br>NPWP<br>Form Application',
            SCC_Call_Type__c = callTypeRecord.Id,
            Notification_4__c = false
        );
        List<Case> casesToInsert = new List<Case>{
            caseWithEmail, caseNoEmail, caseAlreadyNotified, caseWrongStatus, caseWithEmail2
        };
        
        insert casesToInsert;
        
        // Make the cases old enough to be picked up by the batch job
        Test.setCreatedDate(caseWithEmail.Id, DateTime.now().addDays(-7));
        Test.setCreatedDate(caseNoEmail.Id, DateTime.now().addDays(-7));
        Test.setCreatedDate(caseAlreadyNotified.Id, DateTime.now().addDays(-7));
        Test.setCreatedDate(caseWrongStatus.Id, DateTime.now().addDays(-7));
        Test.setCreatedDate(caseWithEmail2.Id, DateTime.now().addDays(-3));
        
        // Step 2: Execute the batch
        Test.startTest();
        
        // Mock email sending
        Integer emailInvocations = Limits.getEmailInvocations();
        
        // Run the batch
        SCC_SendEmailRemainderH5Batch batch = new SCC_SendEmailRemainderH5Batch();
        Database.executeBatch(batch, 10);
        
        Test.stopTest();

        // Step 3: Verify the results
        
        // Check if the flag was updated on the case
        Case updatedCase = [
            SELECT Id, Notification_4__c 
            FROM Case 
            WHERE Id = :caseWithEmail.Id
        ];
        
        System.assertEquals(true, updatedCase.Notification_4__c, 'Notification flag should be set to true');
        
        // Verify other cases weren't affected
        Case noEmailCase = [SELECT Id, Notification_4__c FROM Case WHERE Id = :caseNoEmail.Id];
        System.assertEquals(false, noEmailCase.Notification_4__c, 'Case without email should not be updated');
        
        Case alreadyNotifiedCase = [SELECT Id, Notification_4__c FROM Case WHERE Id = :caseAlreadyNotified.Id];
        System.assertEquals(true, alreadyNotifiedCase.Notification_4__c, 'Already notified case should remain true');
        
        Case wrongStatusCase = [SELECT Id, Notification_4__c FROM Case WHERE Id = :caseWrongStatus.Id];
        System.assertEquals(false, wrongStatusCase.Notification_4__c, 'Case with wrong status should not be updated');
        
        // Test the calculateBusinessDaysAgo method
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1];
        Datetime fiveDaysAgo = SCC_SendEmailRemainderH5Batch.calculateBusinessDaysAgo(bh.Id, 5);
        System.assertNotEquals(null, fiveDaysAgo, 'Should return a valid DateTime');
        
        // Test the manual run method
        try {
            SCC_SendEmailRemainderH5Batch.runBatch();
        } catch (Exception e) {
            System.assert(false, 'runBatch() method threw an exception: ' + e.getMessage());
        }
    }

    
    @isTest
    static void testBatchWithEmailErrors() {
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

        // Create Account
        Account testAccount = new Account(Name = 'Test Error Account');
        insert testAccount;
        
        // Create Case with invalid email to trigger errors
        Case errorCase = new Case(
            Subject = 'Test Error Case',
            Status = 'Waiting Document',
            SCC_Email__c = 'test2@example.com',
            SCC_Call_Type__c = callTypeRecord.Id,
            Notification_4__c = false
        );
        
        insert errorCase;
        Test.setCreatedDate(errorCase.Id, DateTime.now().addDays(-7));
        List<Case> caseList = [SELECT Id, SCC_Email__c, SCC_Sent_Email_Perpanjangan_SLA__c, Subject, Account.Name, SCC_Call_Type__c FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = false];
        System.assert(caseList.size() > 0, 'There should be at least one case to process.');

        String error;
        try {
            Test.startTest();
            SCC_SendEmailRemainderH5Batch batchJob = new SCC_SendEmailRemainderH5Batch();
            batchJob.execute(null, caseList);
            Test.stopTest();
        } catch (Exception e) {
            error = e.getMessage();
            System.assertEquals(true, error.contains('CaseNumber'), 'Masuk Exception');
        }
    }
}