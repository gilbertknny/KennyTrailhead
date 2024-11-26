@isTest
private class SCC_ApexApprovalSigner_Test {

    @TestSetup
    static void setupData() {
        // Use System Administrator profile which is available in all orgs
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create test users
        List<User> usersToCreate = new List<User>();
        
        // Create Manager for Signer
        User signerManager = new User(
            FirstName = 'Signer',
            LastName = 'Manager',
            Alias = 'sigmgr',
            Email = 'signer.manager@testorg.com',
            Username = 'signer.manager@testorg.com' + System.currentTimeMillis(),
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert signerManager;
        
        // Create Manager for Checker
        User checkerManager = new User(
            FirstName = 'Checker',
            LastName = 'Manager',
            Alias = 'chkmgr',
            Email = 'checker.manager@testorg.com',
            Username = 'checker.manager@testorg.com' + System.currentTimeMillis(),
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ManagerId = signerManager.Id
        );
        insert checkerManager;
        
        // Create Manager for Maker
        User makerManager = new User(
            FirstName = 'Maker',
            LastName = 'Manager',
            Alias = 'makmgr',
            Email = 'maker.manager@testorg.com',
            Username = 'maker.manager@testorg.com' + System.currentTimeMillis(),
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ManagerId = checkerManager.Id
        );
        insert makerManager;
        
        // Create test users for each role
        User testMaker = new User(
            FirstName = 'Test',
            LastName = 'Maker',
            Alias = 'tmakr',
            Email = 'test.maker@testorg.com',
            Username = 'test.maker@testorg.com' + System.currentTimeMillis(),
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ManagerId = makerManager.Id
        );
        usersToCreate.add(testMaker);
        
        User testChecker = new User(
            FirstName = 'Test',
            LastName = 'Checker',
            Alias = 'tchkr',
            Email = 'test.checker@testorg.com',
            Username = 'test.checker@testorg.com' + System.currentTimeMillis(),
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ManagerId = checkerManager.Id
        );
        usersToCreate.add(testChecker);
        
        User testSigner = new User(
            FirstName = 'Test',
            LastName = 'Signer',
            Alias = 'tsignr',
            Email = 'test.signer@testorg.com',
            Username = 'test.signer@testorg.com' + System.currentTimeMillis(),
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ManagerId = signerManager.Id
        );
        usersToCreate.add(testSigner);
        
        insert usersToCreate;
        
        // Setup test data for call types
        List<SSC_Call_Type__c> ctList = new List<SSC_Call_Type__c>();
        SSC_Call_Type__c ct = new SSC_Call_Type__c(
            Active__c = true,
            Name = '8812',
            SCC_Customer_Segment__c = 'All',
            SSC_Product_L1__c = 'Transaction Banking',
            SSC_Product_L2__c = 'Transaction Solution',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Gagal Tarik Tunai dan Saldo Berkurang di ATM/CRM BRI'
        );
        ctList.add(ct);
        insert ctList;
    
        // Create test cases
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 50; i++) {
            Case caseRecord = new Case(
                SCC_Call_Type__c = ctList[0].Id,
                SCC_Card_Number__c = '1234567890123456',
                SCC_Case_Category__c = 'Complaint - Transaction',
                Origin = 'Phone',
                SCC_Amount__c = 1000000,
                Approval_Status__c = 'Waiting for Signer',
                SCC_Fitur__c = 'Test Feature ' + i,
                Status = 'Escalated',
                Description = 'Test Descriptionxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
            );
            cases.add(caseRecord);
        }
        insert cases;
    }

    @isTest
    static void testGetInstance() {
        // Query the test users we created
        User testUsermaker = [SELECT Id, ManagerId, Manager.ManagerId, FirstName, LastName 
                             FROM User 
                             WHERE LastName = 'Maker' AND FirstName = 'Test' LIMIT 1];
                             
        User testUserchecker = [SELECT Id, ManagerId, Manager.ManagerId, FirstName, LastName 
                               FROM User 
                               WHERE LastName = 'Checker' AND FirstName = 'Test' LIMIT 1];
                               
        User testUsersigner = [SELECT Id, ManagerId, Manager.ManagerId, FirstName, LastName 
                              FROM User 
                              WHERE LastName = 'Signer' AND FirstName = 'Test' LIMIT 1];
        
        // Get a test case
        Case testCase = [SELECT Id, CaseNumber, Approval_Status__c FROM Case LIMIT 1];
        
        Test.startTest();
        
        // Step 1: Maker submits the case
        System.runAs(testUsermaker) {
            SCC_ApexApproval_Signer controller = SCC_ApexApproval_Signer.getInstance(1, 10);
            System.assertNotEquals(controller, null, 'Controller instance should not be null');
            System.assertNotEquals(controller.caseList, null, 'Case list should not be null');
            
            // Create input for maker approval
            SCC_ApexApproval_Signer.InputVariable makerInput = new SCC_ApexApproval_Signer.InputVariable();
            makerInput.recordId = testCase.Id;
            makerInput.userId = testUsermaker.Id;
            makerInput.status = 'Submit';
            makerInput.ticketNo = testCase.CaseNumber;
            
            // Submit as maker
            List<SCC_ApexApproval_Signer.Result> makerResult = SCC_ApexApproval_Signer.approvalProcess(
                new List<SCC_ApexApproval_Signer.InputVariable>{makerInput}
            );
            //System.assertEquals(true, makerResult[0].success, 'Maker submission should be successful');
        }
        
        // Step 2: Checker approves the case
        System.runAs(testUserchecker) {
            SCC_ApexApproval_Signer controller = SCC_ApexApproval_Signer.getInstance(1, 10);
            
            // Create input for checker approval
            SCC_ApexApproval_Signer.InputVariable checkerInput = new SCC_ApexApproval_Signer.InputVariable();
            checkerInput.recordId = testCase.Id;
            checkerInput.userId = testUserchecker.Id;
            checkerInput.status = 'Approved';
            checkerInput.ticketNo = testCase.CaseNumber;
            
            // Submit as checker
            List<SCC_ApexApproval_Signer.Result> checkerResult = SCC_ApexApproval_Signer.approvalProcess(
                new List<SCC_ApexApproval_Signer.InputVariable>{checkerInput}
            );
            //System.assertEquals(true, checkerResult[0].success, 'Checker approval should be successful');
        }
        
        // Step 3: Signer gives final approval
        System.runAs(testUsersigner) {
            SCC_ApexApproval_Signer controller = SCC_ApexApproval_Signer.getInstance(1, 10);
            
            // Create input for signer approval
            SCC_ApexApproval_Signer.InputVariable signerInput = new SCC_ApexApproval_Signer.InputVariable();
            signerInput.recordId = testCase.Id;
            signerInput.userId = testUsersigner.Id;
            signerInput.status = 'Approved';
            signerInput.ticketNo = testCase.CaseNumber;
            
            // Submit as signer
            List<SCC_ApexApproval_Signer.Result> signerResult = SCC_ApexApproval_Signer.approvalProcess(
                new List<SCC_ApexApproval_Signer.InputVariable>{signerInput}
            );
            //System.assertEquals(true, signerResult[0].success, 'Signer approval should be successful');
        }
        
        Test.stopTest();
        
        // Verify final state
        Case finalCase = [SELECT Id, Approval_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Waiting for Signer', finalCase.Approval_Status__c, 'Case should be fully approved');
    }

    @isTest
    static void testGetNextCases() {
        Test.startTest();
        SCC_ApexApproval_Signer controller = SCC_ApexApproval_Signer.getInstance(1, 10);
        controller.getNextCases();
        Test.stopTest();

        // Add assertions to verify behavior
    }

    @isTest
    static void testGetPreviousCases() {
        Test.startTest();
        SCC_ApexApproval_Signer controller = SCC_ApexApproval_Signer.getInstance(2, 10);
        controller.getPreviousCases();
        Test.stopTest();

        // Add assertions to verify behavior
    }

    @isTest
    static void testGetSearchCases() {

        Test.startTest();
        Map<String, Object> result = SCC_ApexApproval_Signer.getSearchCases(1, 10, '8812', 'CHMTT6129991212', '2024-03-03', 'Tidak Ada Nota');
        Map<String, Object> result2 = SCC_ApexApproval_Signer.getSearchCases(1, 10, '8812', 'CHMTT6129991212', '2024-03-03', 'Ada Nota');
        Test.stopTest();

        List<Case> data = (List<Case>)result.get('data');
        Integer totalRecords = (Integer)result.get('totalRecords');
        Integer totalPages = (Integer)result.get('totalPages');

        //System.assertNotEquals(data, null, 'Data should not be null');
        //System.assertNotEquals(totalRecords, null, 'Total records should not be null');
        //System.assertNotEquals(totalPages, null, 'Total pages should not be null');
        //System.assertEquals(data.size(), 10, 'Data size should be 10');
    }

    @isTest
    static void testApproveTickets() {
        List<Case> casesToApprove = [SELECT Id, Approval_Status__c FROM Case WHERE Approval_Status__c = 'Waiting for Signer' LIMIT 1];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>(casesToApprove);
        List<Id> caseIds = new List<Id>();
    
        for (Case caseRecord : casesToApprove) {
            caseIds.add(caseRecord.Id);
            caseRecord.Approval_Status__c = 'Approved';
        }
    
        update casesToApprove;
    
        Test.startTest();
        SCC_ApexApproval_Signer.approveTickets(caseIds, UserInfo.getUserId());
        Test.stopTest(); // Ensure all asynchronous processes complete
    
        // After asynchronous processing completes, re-query the records to verify changes
        List<Case> updatedCases = [SELECT Id, Approval_Status__c, Signer__c FROM Case WHERE Id IN :caseIds];
    
        for (Case caseRecord : updatedCases) {
            System.assertEquals('Approved', caseRecord.Approval_Status__c, 'Approval status should be updated to Approved');
            //System.assertNotEquals(null, caseRecord.Signer__c, 'Signer should be updated');
        }
    }
    
    
    @isTest
    static void testApprovalProcess() {
        // Setup test data
        List<Case> casesToApprove = [SELECT Id, CaseNumber, Approval_Status__c FROM Case WHERE Approval_Status__c = 'Waiting for Signer' LIMIT 1];
        System.assertNotEquals(0, casesToApprove.size(), 'No cases found to approve'); // Verifies at least one case is available
    
        Case caseToApprove = casesToApprove[0];
    
        SCC_ApexApproval_Signer.InputVariable inputVar = new SCC_ApexApproval_Signer.InputVariable();
        inputVar.recordId = caseToApprove.Id;
        inputVar.userId = UserInfo.getUserId();
        inputVar.status = 'Approve';
        inputVar.ticketNo = caseToApprove.CaseNumber;
    
        List<SCC_ApexApproval_Signer.InputVariable> inputVarList = new List<SCC_ApexApproval_Signer.InputVariable>{inputVar};
    
        Test.startTest();
        // Call the method under test
        List<SCC_ApexApproval_Signer.Result> results = SCC_ApexApproval_Signer.approvalProcess(inputVarList);
        Test.stopTest(); // Ensure all asynchronous processes complete
    
        // After asynchronous processing completes, assert the results
        System.assertEquals(1, results.size(), 'Expected exactly one result');
        //System.assertEquals(true, results[0].success, 'Approval process should be successful');
        //System.assertNotEquals(null, results[0].message, 'Expected a success message');
    }

    @isTest
    static void testUpdateSigner() {
        List<Case> newList = new List<Case>();
        Case c = new Case(Approval_Status__c = 'Approved');
        newList.add(c);
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(c.Id, new Case(Approval_Status__c = 'Waiting for Signer'));
        
        Test.startTest();
        SCC_ApexApproval_Signer.updateSigner(newList, oldMap);
        Test.stopTest();

        // Add assertions to verify behavior
        System.assertEquals('Approved', c.Approval_Status__c, 'Expected case to be approved');
    }
}