@isTest
public class Aswata_ApprovalProcess_Logic_Test {

    // ============================================================
    // 1) TEST SETUP – Create Users & Roles (setup objects only)
    // ============================================================
    @testSetup
    static void setupUsers() {

        // Create a UserRole (required so users can own records)
        UserRole r = new UserRole(Name = 'Test Role');
        insert r;

        // Get Standard User profile
        Profile p = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'Standard User' 
            LIMIT 1
        ];

        // Submitter user
        User submitter = new User(
            FirstName='Submitter',
            LastName='User',
            Alias='sbt',
            Email='sbt@test.com',
            Username='sbt'+System.currentTimeMillis()+'@test.com',
            TimeZoneSidKey='Asia/Singapore',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p.Id,
            UserRoleId=r.Id
        );
        insert submitter;

        // Approver user
        User approver = new User(
            FirstName='Approver',
            LastName='User',
            Alias='apv',
            Email='apv@test.com',
            Username='apv'+System.currentTimeMillis()+'@test.com',
            TimeZoneSidKey='Asia/Singapore',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p.Id,
            UserRoleId=r.Id
        );
        insert approver;
    }


    // ============================================================
    // 2) Helper method to create a Quote for approval tests
    // ============================================================
    private static Quote createQuote(User owner, User approver) {

        Quote q;

        // All business data must be created under submitter's ownership
        System.runAs(owner) {

            Account acc = new Account(Name = 'Test Account');
            insert acc;

            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = acc.Id
            );
            insert opp;

            q = new Quote(
                Name = 'Test Quote',
                OpportunityId = opp.Id,
                Assigned_Underwriting__c = approver.Id,
                Status = 'Draft',
                ExpirationDate = Date.today().addDays(30)
            );
            insert q;
        

         	// ⭐ FIX: Share the OPPORTUNITY (not the Quote)	
            insert new OpportunityShare(
                OpportunityId = opp.Id,
                UserOrGroupId = approver.Id,
                OpportunityAccessLevel = 'Read',
                RowCause = Schema.OpportunityShare.RowCause.Manual
            );
        }
        return q;
    }


    // ============================================================
    // 3) TEST — Submit Quote for Approval
    // ============================================================
    @isTest
    static void testInvocableSubmit() {
    
        User submitter = [SELECT Id FROM User WHERE Alias='sbt' LIMIT 1];
        User approver  = [SELECT Id FROM User WHERE Alias='apv' LIMIT 1];
    
        Quote q = createQuote(submitter, approver);
    
        System.runAs(submitter) {
    
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input =
                new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
    
            input.recordId = q.Id;
            input.action   = 'Submit';
            input.comments = 'Submitting via invocable test';
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput> reqList =
                new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{ input };
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> result =
                Aswata_ApprovalProcess_Logic.runApproval(reqList);
    
            System.assertEquals(true, result[0].success, 'Invocable submit should succeed');
        }
    }


    // ============================================================
    // 4) TEST — Approve Quote
    // ============================================================
    @isTest
    static void testInvocableApprove() {
    
        User submitter = [SELECT Id FROM User WHERE Alias='sbt' LIMIT 1];
        User approver  = [SELECT Id FROM User WHERE Alias='apv' LIMIT 1];
    
        Quote q = createQuote(submitter, approver);
    
        // First submit
        System.runAs(submitter) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(q.Id);
            Approval.process(req);
        }
    
        // Approve via your Invocable Apex
        System.runAs(approver) {
    
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input =
                new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
    
            input.recordId = q.Id;
            input.action   = 'Approved';
            input.comments = 'Approving via invocable test';
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput> reqList =
                new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{ input };
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> result =
                Aswata_ApprovalProcess_Logic.runApproval(reqList);
    
            System.assertEquals(true, result[0].success, 'Invocable approve should succeed');
        }
    }


    // ============================================================
    // 5) TEST — Reject Quote
    // ============================================================
    @isTest
    static void testInvocableReject() {
    
        User submitter = [SELECT Id FROM User WHERE Alias='sbt' LIMIT 1];
        User approver  = [SELECT Id FROM User WHERE Alias='apv' LIMIT 1];
    
        Quote q = createQuote(submitter, approver);
    
        // First submit
        System.runAs(submitter) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(q.Id);
            Approval.process(req);
        }
    
        // Reject via your Invocable Apex
        System.runAs(approver) {
    
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input =
                new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
    
            input.recordId = q.Id;
            input.action   = 'Rejected';
            input.comments = 'Rejecting via invocable test';
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput> reqList =
                new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{ input };
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> result =
                Aswata_ApprovalProcess_Logic.runApproval(reqList);
    
            System.assertEquals(true, result[0].success, 'Invocable reject should succeed');
        }
    }
    
    // ============================================================
    // 5) TEST — Reject Quote
    // ============================================================
    @isTest
    static void testInvocableInvalidAction() {
    
        User submitter = [SELECT Id FROM User WHERE Alias='sbt' LIMIT 1];
        User approver  = [SELECT Id FROM User WHERE Alias='apv' LIMIT 1];
    
        Quote q = createQuote(submitter, approver);
    
        // First submit
        System.runAs(submitter) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(q.Id);
            Approval.process(req);
        }
    
        // Reject via your Invocable Apex
        System.runAs(approver) {
    
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input =
                new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
    
            input.recordId = q.Id;
            input.action   = 'invalid';
            input.comments = 'Invalid Action';
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput> reqList =
                new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{ input };
    
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> result =
                Aswata_ApprovalProcess_Logic.runApproval(reqList);
    
            System.assertEquals(false, result[0].success, 'Invalid action should fail.');
        }
    }

}