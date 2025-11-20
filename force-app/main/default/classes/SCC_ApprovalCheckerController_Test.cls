@isTest
private class SCC_ApprovalCheckerController_Test {
    @TestSetup
    static void setupData() {
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

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 50; i++) {
            Case caseRecord = new Case(
                SCC_Call_Type__c = ctList[0].Id,
                SCC_Card_Number__c = '1234567890123456',
                SCC_Case_Category__c = 'Complaint - Transaction',
                Origin = 'Phone',
                SCC_Amount__c = 100000,
                Approval_Status__c = 'Draft', // Update to match your approval status
                SCC_Fitur__c = 'Test Feature ' + i,
                Status = 'Escalated',
                Description = 'Test Descriptionxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
            );
            cases.add(caseRecord);
        }
        insert cases;
        
        // Use System Administrator profile which is available in all orgs
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
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
    }

    @isTest
    static void testGetInstance() {
        User testUser = [SELECT Id FROM User WHERE Name like '%Checker%' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            SCC_ApprovalCheckerController controller = SCC_ApprovalCheckerController.getInstance(1, 10);
            Test.stopTest();

            System.assertNotEquals(null, controller, 'Controller instance should not be null');
            System.assertNotEquals(null, controller.caseList, 'Case list should not be null');
            System.assertEquals(0, controller.caseList.size(), 'Should return 0 cases');
        }
    }

    @isTest
    static void testGetNextCases() {
        Test.startTest();
        SCC_ApprovalCheckerController controller = SCC_ApprovalCheckerController.getInstance(1, 10);
        controller.getNextCases();
        Test.stopTest();

        //System.assertEquals(controller.pageNumber, 2, 'Page number should be 2');
        //System.assertEquals(controller.caseList.size(), 10, 'Case list size should be 10 on next page');
    }

    @isTest
    static void testGetPreviousCases() {
        Test.startTest();
        SCC_ApprovalCheckerController controller = SCC_ApprovalCheckerController.getInstance(2, 10);
        controller.getPreviousCases();
        Test.stopTest();

        System.assertEquals(controller.pageNumber, 1, 'Page number should be 1');
        //System.assertEquals(controller.caseList.size(), 10, 'Case list size should be 10 on previous page');
    }

    @isTest
    static void testGetSearchCases() {
        Test.startTest();
        Map<String, Object> result = SCC_ApprovalCheckerController.getSearchCases(1, 10, '8812', 'TICKET001840041', '2024-07-01', 'true');
        Test.stopTest();
    
        List<Case> data = (List<Case>)result.get('data');
        Integer totalRecords = (Integer)result.get('totalRecords');
        Integer totalPages = (Integer)result.get('totalPages');
        
        System.assertNotEquals(null, data, 'Data seharusnya tidak null');
        System.assertNotEquals(null, totalRecords, 'Total records seharusnya tidak null');
        System.assertNotEquals(null, totalPages, 'Total pages seharusnya tidak null');
    }

    @isTest
    static void testApproveTickets() {
        // Get the cases we want to approve
        List<Case> casesToApprove = [SELECT Id, Approval_Status__c, CaseNumber 
                                    FROM Case 
                                    WHERE Approval_Status__c = 'Draft' 
                                    LIMIT 5];
        
        // Get a user for the approval process
        List<User> approvers = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        System.assertNotEquals(0, approvers.size(), 'No active users found for approval process');
        
        Test.startTest();
        
        List<Approval.ProcessResult> results = new List<Approval.ProcessResult>();
        
        for(Case caseRecord : casesToApprove) {
            // Create the approval request
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting case for approval process');
            req.setNextApproverIds(new Id[] {approvers[0].Id});
            req.setObjectId(caseRecord.Id);
            req.setSubmitterId(UserInfo.getUserId());
            system.debug('test : '+caseRecord);
            
            // Submit the approval request
            try {
                results.add(Approval.process(req));
            } catch(Exception e) {
                System.debug('Error processing approval for case ' + caseRecord.CaseNumber + ': ' + e.getMessage());
            }
        }
        
        // Call the methods under test
        List<Id> caseIds = new List<Id>();
        for(Case c : casesToApprove) {
            caseIds.add(c.Id);
        }
        
    List<Case> casecek = [SELECT Id, Approval_Status__c, CaseNumber FROM Case WHERE Id IN :caseIds];
    system.debug('casecek : ' + casecek);    
    Map<Id, Case> oldMap = new Map<Id, Case>(casecek);    
    SCC_ApprovalCheckerController.approveTickets(casecek, oldMap);
        
        Test.stopTest();
        
        // Verify the results
        List<Case> updatedCases = [SELECT Id, Approval_Status__c, Signer__c, Checker__c 
                                  FROM Case 
                                  WHERE Id IN :caseIds];
        
        for(Case caseRecord : updatedCases) {
            //System.assertNotEquals(null, caseRecord.Checker__c, 'Checker should be set after approval process');
            //System.assertNotEquals(null, caseRecord.Signer__c, 'Signer should be set after approval process');
        }
        
        // Verify approval process results
        for(Approval.ProcessResult result : results) {
            //System.assert(result.isSuccess(), 'Approval process should complete successfully');
            //System.assertEquals('Pending', result.getInstanceStatus(), 'Approval should be pending');
        }
    }    
        
    @isTest
    static void testApprovalProcess() {
        List<Case> casesToApprove = [SELECT Id, Approval_Status__c, CaseNumber FROM Case WHERE Approval_Status__c = 'Draft' LIMIT 10];
        
        List<Id> newWorkItemIds = new List<Id>();
        for(Case caseRecord : casesToApprove) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting case for approval process');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(caseRecord.Id);
            req.setSubmitterId(UserInfo.getUserId());
            
            try {
                Approval.ProcessResult apresult = Approval.process(req);
                List<Id> newWorkItemIdsx = apresult.getNewWorkitemIds();
                newWorkItemIds.add(newWorkItemIdsx.get(0));
            } catch(Exception e) {
                System.debug('Error processing approval for case ' + caseRecord.CaseNumber + ': ' + e.getMessage());
            }
        }
        
        for(Id workItemId : newWorkItemIds) {
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(workItemId);
            
            try {
                Approval.ProcessResult result2 = Approval.process(req2);
            } catch(Exception e) {
                System.debug('Error processing approval for work item : ' + e.getMessage());
            }
        }
        
        Case caseToApprove = casesToApprove[0];
    
        SCC_ApprovalCheckerController.InputVariable inputVar = new SCC_ApprovalCheckerController.InputVariable();
        inputVar.recordId = caseToApprove.Id;
        inputVar.userId = UserInfo.getUserId();
        inputVar.status = 'Approve';
        inputVar.ticketNo = caseToApprove.CaseNumber;
    
        List<SCC_ApprovalCheckerController.InputVariable> inputVarList = new List<SCC_ApprovalCheckerController.InputVariable>{inputVar};
    
        Test.startTest();
        List<SCC_ApprovalCheckerController.Result> resultxs = SCC_ApprovalCheckerController.approvalProcess(inputVarList);
        Test.stopTest(); 
    }
}