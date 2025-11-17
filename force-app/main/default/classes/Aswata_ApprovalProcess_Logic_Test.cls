@isTest
public class Aswata_ApprovalProcess_Logic_Test {
    
    @testSetup
    static void setupTestData() {
        // Gunakan factory untuk create standard dataset
        Map<String, SObject> standardData = Aswata_TestDataFactory.createStandardDataSet();
        Account testAcc = Aswata_TestDataFactory.createAccount('Test Acc');

        Opportunity testOpp = Aswata_TestDataFactory.createOpportunity(testAcc, 'Test Oppty');
        
        // Gunakan factory method untuk create quotes
        List<Quote> quotes = new List<Quote>();
        for (Integer i = 0; i < 3; i++) {
            Quote q = Aswata_TestDataFactory.createQuote(testOpp, 'Test Quote ' + i);
            // Update field yang diperlukan
            q.Status = 'Draft';
            q.ExpirationDate = Date.today().addDays(30);
            quotes.add(q);
        }
        update quotes; // Update untuk set Status dan ExpirationDate
    }
    
    // ========== TEST SUBMIT ACTION ==========
    
    @isTest
    static void testSubmit_WithComments() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Submit';
        input.comments = 'Submitting for approval';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertNotEquals(null, outputs);
        System.assertEquals(1, outputs.size());
        System.assertNotEquals(null, outputs[0].message);
    }
    
    @isTest
    static void testSubmit_WithoutComments() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Submit';
        // No comments - test null branch
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertNotEquals(null, outputs);
    }
    
    @isTest
    static void testSubmit_Bulk() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        
        Test.startTest();
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput> inputs = new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>();
        
        for (Quote q : quotes) {
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
            input.recordId = q.Id;
            input.action = 'Submit';
            input.comments = 'Bulk submit';
            inputs.add(input);
        }
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(inputs);
        
        Test.stopTest();
        
        System.assertEquals(quotes.size(), outputs.size());
    }
    
    // ========== TEST APPROVE/REJECT ACTIONS ==========
    
    @isTest
    static void testApproved_WithWorkItem() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        // Submit first
        submitQuote(testQuote.Id);
        
        // Check if work item exists
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :testQuote.Id 
            LIMIT 1
        ];
        
        if (!workItems.isEmpty()) {
            Test.startTest();
            
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
            input.recordId = testQuote.Id;
            input.action = 'Approved';
            input.comments = 'Approving';
            
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
                Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
            
            Test.stopTest();
            
            System.assertNotEquals(null, outputs[0].message);
        }
    }
    
    @isTest
    static void testApproved_WithoutWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[quotes.size() - 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Approved';
        input.comments = 'Trying to approve';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
        System.assert(outputs[0].message.contains('Error'));
    }
    
    @isTest
    static void testRejected_WithWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[0];
        
        submitQuote(testQuote.Id);
        
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :testQuote.Id 
            LIMIT 1
        ];
        
        if (!workItems.isEmpty()) {
            Test.startTest();
            
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
            input.recordId = testQuote.Id;
            input.action = 'Rejected';
            input.comments = 'Rejecting';
            
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
                Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
            
            Test.stopTest();
            
            System.assertNotEquals(null, outputs[0].message);
        }
    }
    
    @isTest
    static void testRejected_WithoutWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[quotes.size() - 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Rejected';
        input.comments = 'Rejecting';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
    }
    
    @isTest
    static void testContraQuote_WithWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[1];
        
        submitQuote(testQuote.Id);
        
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :testQuote.Id 
            LIMIT 1
        ];
        
        if (!workItems.isEmpty()) {
            Test.startTest();
            
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
            input.recordId = testQuote.Id;
            input.action = 'Contra Quote';
            input.comments = 'Contra quote';
            
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
                Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
            
            Test.stopTest();
            
            System.assertNotEquals(null, outputs[0].message);
        }
    }
    
    @isTest
    static void testContraQuote_WithoutWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[quotes.size() - 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Contra Quote';
        input.comments = 'Contra';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
    }
    
    @isTest
    static void testApproveOnHoldBinding_WithWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[2];
        
        submitQuote(testQuote.Id);
        
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :testQuote.Id 
            LIMIT 1
        ];
        
        if (!workItems.isEmpty()) {
            Test.startTest();
            
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
            input.recordId = testQuote.Id;
            input.action = 'Approve On Hold Binding';
            input.comments = 'Approve on hold';
            
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
                Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
            
            Test.stopTest();
            
            System.assertNotEquals(null, outputs[0].message);
        }
    }
    
    @isTest
    static void testApproveOnHoldBinding_WithoutWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[quotes.size() - 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Approve On Hold Binding';
        input.comments = 'Approve on hold';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
    }
    
    @isTest
    static void testCancel_WithWorkItem() {
        // Create new quote untuk test ini
        Map<String, SObject> standardData = Aswata_TestDataFactory.createStandardDataSet();
        Opportunity testOpp = (Opportunity)standardData.get('Opportunity');
        Quote newQuote = Aswata_TestDataFactory.createQuote(testOpp, 'Cancel Test Quote');
        
        submitQuote(newQuote.Id);
        
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :newQuote.Id 
            LIMIT 1
        ];
        
        if (!workItems.isEmpty()) {
            Test.startTest();
            
            Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
            input.recordId = newQuote.Id;
            input.action = 'Cancel';
            input.comments = 'Cancelling';
            
            List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
                Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
            
            Test.stopTest();
            
            System.assertNotEquals(null, outputs[0].message);
        }
    }
    
    @isTest
    static void testCancel_WithoutWorkItem() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        Quote testQuote = quotes[quotes.size() - 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'Cancel';
        input.comments = 'Cancel';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
    }
    
    // ========== TEST INVALID ACTIONS ==========
    
    @isTest
    static void testInvalidAction() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = 'InvalidAction';
        input.comments = 'Invalid';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
        System.assert(outputs[0].message.contains('Invalid action'));
    }
    
    @isTest
    static void testEmptyAction() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = '';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
    }
    
    @isTest
    static void testNullAction() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = testQuote.Id;
        input.action = null;
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
    }
    
    // ========== TEST EXCEPTION HANDLING ==========
    
    @isTest
    static void testNullRecordId() {
        Test.startTest();
        
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = null;
        input.action = 'Submit';
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
        
        Test.stopTest();
        
        System.assertEquals(false, outputs[0].success);
        System.assert(outputs[0].message.contains('Error'));
    }
    
    @isTest
    static void testMixedBulk() {
        List<Quote> quotes = [SELECT Id FROM Quote];
        
        Test.startTest();
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput> inputs = new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>();
        
        // Valid submit
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input1 = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input1.recordId = quotes[0].Id;
        input1.action = 'Submit';
        input1.comments = 'Valid';
        inputs.add(input1);
        
        // Invalid action
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input2 = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input2.recordId = quotes[1].Id;
        input2.action = 'WrongAction';
        inputs.add(input2);
        
        // Approve without workitem
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input3 = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input3.recordId = quotes[2].Id;
        input3.action = 'Approved';
        inputs.add(input3);
        
        List<Aswata_ApprovalProcess_Logic.ApprovalRequestOutput> outputs = 
            Aswata_ApprovalProcess_Logic.runApproval(inputs);
        
        Test.stopTest();
        
        System.assertEquals(3, outputs.size());
        System.assertEquals(false, outputs[1].success); // Invalid action
        System.assertEquals(false, outputs[2].success); // No workitem
    }
    
    // ========== HELPER METHOD ==========
    
    private static void submitQuote(Id quoteId) {
        Aswata_ApprovalProcess_Logic.ApprovalRequestInput input = new Aswata_ApprovalProcess_Logic.ApprovalRequestInput();
        input.recordId = quoteId;
        input.action = 'Submit';
        input.comments = 'Submit';
        
        Aswata_ApprovalProcess_Logic.runApproval(new List<Aswata_ApprovalProcess_Logic.ApprovalRequestInput>{input});
    }
}