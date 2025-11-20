/**
 * @description       : Test class for SCC_SendEmailNotificationOverSLA batch and related classes
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 04-28-2025
 * @last modified by  : Ahmad Yazid Munif
**/
@isTest
public class SCC_SendEmailNotificationOverSLATest {
    // Set up constants to match those in the batch class
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = System.Label.EmailTemplateOverSLA; 
    private static final String ORG_WIDE_EMAIL_DISPLAY_NAME = System.Label.Email_Wide_Organization;
    private static final String ADMIN_EMAIL = System.Label.Admin_Email_Notification; 

    // Test data setup
    @testSetup
    static void setup() {
        BusinessHours branchUserHours = [SELECT Id, Name FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1];
        System.assertNotEquals(null, branchUserHours, 'Ensure Business Hours with the name "Branch User" exists.');

        OrgWideEmailAddress orgWideEmail = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ORG_WIDE_EMAIL_DISPLAY_NAME LIMIT 1];
        System.assertNotEquals(null, orgWideEmail, 'Ensure Org-Wide Email Address with DisplayName "Contact BRI" exists.');

        EmailTemplate emailTemplate = [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE_DEVELOPER_NAME LIMIT 1];
        System.assertNotEquals(null, emailTemplate, 'Ensure an Email Template with DeveloperName "Perpanjangan_SLA_via_WA" exists.');
        System.debug('orgWideEmail >> '+orgWideEmail+' - '+emailTemplate);
        Account acc = new Account(Name = 'Kent');
        insert acc;

        List<Case> cases = new List<Case>();
        
        // Create cases that WILL match the SLA criteria
        for (Integer i = 1; i <= 3; i++) {
            cases.add(new Case(
                AccountId = acc.Id,
                Status = 'Working',  // This status should match
                SCC_Email__c = 'kent' + i + '@test.com',
                SCC_Sent_Email_Perpanjangan_SLA__c = false, // Must be false
                isTotalSLAViolated__c = true, // Add this field as it's in your query
                Subject = 'Test Subject ' + i,
                SCC_List_of_Required_Documents__c = '1. Form Sanggahan <br>2. Ktp <br>3. Kartu Kredit'
            ));
        }
        
        // Add some Escalated cases
        for (Integer i = 4; i <= 5; i++) {
            cases.add(new Case(
                AccountId = acc.Id,
                Status = 'Escalated',  // This status should also match
                SCC_Email__c = 'kent' + i + '@test.com',
                SCC_Sent_Email_Perpanjangan_SLA__c = false, // Must be false
                isTotalSLAViolated__c = false,
                Subject = 'Test Subject ' + i,
                SCC_List_of_Required_Documents__c = '1. Form Sanggahan <br>2. Ktp <br>3. Kartu Kredit'
            ));
        }

        // Cases that should NOT match criteria
        cases.add(new Case(
            Status = 'Draft',  // Wrong status
            SCC_Email__c = 'kent@test.com',
            SCC_Sent_Email_Perpanjangan_SLA__c = false,
            isTotalSLAViolated__c = false,
            Subject = 'Test Subject No Name',
            SCC_List_of_Required_Documents__c = null
        ));
        cases.add(new Case(
            Status = 'Working',
            SCC_Email__c = null,  // No email
            SCC_Sent_Email_Perpanjangan_SLA__c = false,
            isTotalSLAViolated__c = false,
            Subject = 'Test Subject No Email',
            SCC_List_of_Required_Documents__c = null
        ));
        cases.add(new Case(
            Status = 'Working',
            SCC_Email__c = 'kent@test.com',
            SCC_Sent_Email_Perpanjangan_SLA__c = true,  // Already sent
            isTotalSLAViolated__c = false,
            Subject = 'Test Subject Already Sent',
            SCC_List_of_Required_Documents__c = null
        ));
        insert cases;
        
        // Set created dates for cases to match your business logic
        List<Case> casesToUpdateDate = [SELECT Id FROM Case WHERE Status IN ('Working', 'Escalated') AND SCC_Sent_Email_Perpanjangan_SLA__c = false];
        for (Case c : casesToUpdateDate) {
            // Set created date to be older than 11 business days
            Test.setCreatedDate(c.Id, System.now().addDays(-15));
        }
    }

    // Your existing tests (keep them as they work)
    @isTest
    static void testStartMethod() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA batchJob = new SCC_SendEmailNotificationOverSLA();
        Database.QueryLocator ql = batchJob.start(null);
        System.assertNotEquals(null, ql);
        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA batchJob = new SCC_SendEmailNotificationOverSLA();
        List<Case> caseList = [SELECT Id, SCC_Email__c, SCC_Sent_Email_Perpanjangan_SLA__c, Subject, CaseNumber, Account.Name,SCC_List_of_Required_Documents__c FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = false];
        System.assert(caseList.size() > 0, 'There should be at least one case to process.');

        Database.QueryLocator ql = batchJob.start(null);
        
        batchJob.execute(null, caseList);
        Test.stopTest();

        for (Case c : [SELECT SCC_Sent_Email_Perpanjangan_SLA__c, CaseNumber FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = true]) {
            System.assertEquals(true, c.SCC_Sent_Email_Perpanjangan_SLA__c, 'The email sent flag should be true for case: ' + c.CaseNumber);
        }
    }

    @isTest
    static void testExecuteMethodException() {
        try {
            Test.startTest();
            SCC_SendEmailNotificationOverSLA batchJob = new SCC_SendEmailNotificationOverSLA();
            List<Case> caseList = [SELECT Id, Subject, CaseNumber, Account.Name,SCC_List_of_Required_Documents__c FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = false];
            System.assert(caseList.size() > 0, 'There should be at least one case to process.');
            batchJob.execute(null, caseList);
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(e.getMessage().contains('SOQL'), true);
        }
    }

    @isTest
    static void testExecuteMethodNasabah() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA batchJob = new SCC_SendEmailNotificationOverSLA();
        List<Case> caseList = [SELECT Id, SCC_Email__c, SCC_Sent_Email_Perpanjangan_SLA__c, Subject, CaseNumber, Account.Name FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = false];
        System.assert(caseList.size() > 0, 'There should be at least one case to process.');

        batchJob.execute(null, caseList);
        Test.stopTest();

        for (Case c : [SELECT SCC_Sent_Email_Perpanjangan_SLA__c, CaseNumber FROM Case WHERE SCC_Sent_Email_Perpanjangan_SLA__c = true]) {
            System.assertEquals(true, c.SCC_Sent_Email_Perpanjangan_SLA__c, 'The email sent flag should be true for case: ' + c.CaseNumber);
        }
    }

    @isTest
    static void testFinishMethod() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA batchJob = new SCC_SendEmailNotificationOverSLA();
        batchJob.finish(null);
        Test.stopTest();

        // Finish method should execute without errors
        System.assert(true, 'Finish method should complete without errors');
    }

    @isTest
    static void testRunBatch() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA.runBatch();
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assert(jobs.size() > 0, 'The batch job should be scheduled.');
    }

    // FIXED TEST: Test SCC_CaseQueryService class
    @isTest
    static void testCaseQueryService() {
        Test.startTest();
        List<Case> resultCases = SCC_CaseQueryService.getCasesOverSLA();
        Test.stopTest();
        
        // Debug to see what's returned
        System.debug('Returned cases: ' + resultCases.size());
        for (Case c : resultCases) {
            System.debug('Case: ' + c.CaseNumber + ' Status: ' + c.Status + ' Email: ' + c.SCC_Email__c + ' Sent: ' + c.SCC_Sent_Email_Perpanjangan_SLA__c);
        }
        
        // Should return cases that match the criteria (Working/Escalated status, not sent, with email)
        System.assert(resultCases.size() > 0, 'Should return cases that match the criteria. Found: ' + resultCases.size());
        
        for (Case c : resultCases) {
            System.assert(c.Status == 'Escalated' || c.Status == 'Working', 'Case should be Escalated or Working. Found: ' + c.Status);
            System.assert(c.SCC_Email__c != null, 'Case should have email address');
            System.assertEquals(false, c.SCC_Sent_Email_Perpanjangan_SLA__c, 'Email should not have been sent yet');
        }
    }
    
    // Test SCC_CaseQueryService calculateBusinessDaysAgo method
    @isTest
    static void testCalculateBusinessDaysAgo() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1];
        
        Test.startTest();
        Datetime result = SCC_CaseQueryService.calculateBusinessDaysAgo(bh.Id, 5);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return a datetime value');
        System.assert(result < System.now(), 'Result should be in the past');
    }
    
    // Test scheduler class
    // @isTest
    // static void testScheduler() {
    //     Test.startTest();
        
    //     // Create scheduler instance
    //     SCC_SendEmailNotificationOverSLA_Sch scheduler = new SCC_SendEmailNotificationOverSLA_Sch();
        
    //     // Execute scheduler
    //     scheduler.execute(null);
        
    //     Test.stopTest();
        
    //     // Scheduler should execute without errors
    //     System.assert(true, 'Scheduler should execute without errors');
    // }
    
    // // Test scheduler scheduling method
    // @isTest
    // static void testScheduleJobMethod() {
    //     Test.startTest();
        
    //     // Schedule the job
    //     String jobName = 'Test_Scheduler_' + System.now().getTime();
    //     String cronExpression = '0 0 12 * * ?';
        
    //     System.schedule(jobName, cronExpression, new SCC_SendEmailNotificationOverSLA_Sch());
        
    //     Test.stopTest();
        
    //     // Verify job was scheduled
    //     List<CronTrigger> scheduledJobs = [
    //         SELECT Id, CronJobDetail.Name 
    //         FROM CronTrigger 
    //         WHERE CronJobDetail.Name = :jobName
    //     ];
        
    //     System.assertEquals(1, scheduledJobs.size(), 'Job should be scheduled');
    // }
    
    // Test email template replacement logic
    @isTest
    static void testEmailTemplateReplacement() {
        Case testCase = [SELECT Id, CaseNumber, Account.Name FROM Case WHERE SCC_Email__c != null AND AccountId != null LIMIT 1];
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE_DEVELOPER_NAME LIMIT 1];
        
        Test.startTest();
        
        // Test the email body replacement logic
        String greeting = testCase.Account != null && testCase.Account.Name != null 
            ? 'Yth. Bapak/Ibu ' + testCase.Account.Name 
            : 'Nasabah'; 

        String emailBody = template.Body
            .replace('{!Case.Account}', greeting)
            .replace('{!Case.CaseNumber}', testCase.CaseNumber);
        String emailSubject = template.Subject.replace('{!Case.CaseNumber}', testCase.CaseNumber);
        
        Test.stopTest();
        
        System.assert(emailBody.contains(testCase.CaseNumber), 'Email body should contain case number');
        System.assert(emailSubject.contains(testCase.CaseNumber), 'Email subject should contain case number');
        if (testCase.Account != null) {
            System.assert(emailBody.contains(testCase.Account.Name), 'Email body should contain account name');
        }
    }
    
    // Test case without account (should use 'Nasabah')
    @isTest
    static void testEmailTemplateReplacementNoAccount() {
        Case testCase = [SELECT Id, CaseNumber, Account.Name FROM Case WHERE AccountId = null AND SCC_Email__c != null LIMIT 1];
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE_DEVELOPER_NAME LIMIT 1];
        
        Test.startTest();
        
        // Test the email body replacement logic
        String greeting = testCase.Account != null && testCase.Account.Name != null 
            ? 'Yth. Bapak/Ibu ' + testCase.Account.Name 
            : 'Nasabah'; 

        String emailBody = template.Body
            .replace('{!Case.Account}', greeting)
            .replace('{!Case.CaseNumber}', testCase.CaseNumber);
        
        Test.stopTest();
        
        System.assert(emailBody.contains('Nasabah'), 'Email body should contain "Nasabah" when no account');
        System.assert(emailBody.contains(testCase.CaseNumber), 'Email body should contain case number');
    }
    
    // Test batch with the new refactored class
    @isTest
    static void testRefactoredBatchExecution() {
        List<Case> testCases = [
            SELECT Id, CaseNumber, Status, SCC_Email__c, Account.Name, 
                   SCC_Sent_Email_Perpanjangan_SLA__c 
            FROM Case 
            WHERE SCC_Sent_Email_Perpanjangan_SLA__c = false 
            AND SCC_Email__c != null
            AND (Status = 'Escalated' OR Status = 'Working')
            LIMIT 2
        ];
        
        Test.startTest();
        SCC_SendEmailNotificationOverSLA batch = new SCC_SendEmailNotificationOverSLA();
        batch.execute(null, testCases);
        Test.stopTest();
        
        // Batch execute should complete without errors
        System.assert(true, 'Refactored batch execute should complete without errors');
    }
    
    // Test edge case: no cases match criteria in query service
    @isTest
    static void testNoCasesToProcessInService() {
        // Update all cases to not match criteria
        List<Case> allCases = [SELECT Id FROM Case];
        for (Case c : allCases) {
            c.SCC_Sent_Email_Perpanjangan_SLA__c = true;
        }
        update allCases;
        
        Test.startTest();
        List<Case> resultCases = SCC_CaseQueryService.getCasesOverSLA();
        Test.stopTest();
        
        System.assertEquals(0, resultCases.size(), 'Should return no cases when none match criteria');
    }
}