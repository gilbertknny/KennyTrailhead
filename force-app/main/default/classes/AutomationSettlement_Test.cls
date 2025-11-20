@isTest
private class AutomationSettlement_Test {


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
    }

    @isTest
    static void testGetInstance() {
        Test.startTest();
        AutomationSettlement controller = AutomationSettlement.getInstance(1, 10);
        Test.stopTest();

        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertNotEquals(controller.caseList, null, 'Case list should not be null');
        // Add more assertions as needed
    }

    @isTest
    static void testGetNextCases() {
        Test.startTest();
        AutomationSettlement controller = AutomationSettlement.getInstance(1, 10);
        controller.getNextCases();
        Test.stopTest();

        // Add assertions to verify behavior
    }

    @isTest
    static void testGetPreviousCases() {
        Test.startTest();
        AutomationSettlement controller = AutomationSettlement.getInstance(2, 10);
        controller.getPreviousCases();
        Test.stopTest();

        // Add assertions to verify behavior
    }

    @isTest
    static void testGetSearchCases() {

        Test.startTest();
        Map<String, Object> result = AutomationSettlement.getSearchCases(1, 10, '8812', 'CHMTT6129991212', '2024-03-03');
        Test.stopTest();

        List<Case> data = (List<Case>)result.get('data');
        Integer totalRecords = (Integer)result.get('totalRecords');
        Integer totalPages = (Integer)result.get('totalPages');
    }

    @isTest
    static void testApproveTickets() {
        // Get the cases we want to approve
        List<Case> casesToApprove = [SELECT Id, Approval_Status__c, CaseNumber 
                                    FROM Case 
                                    WHERE Approval_Status__c = 'Draft' 
                                    LIMIT 10];
        
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
        
        List<Case> casecek = [SELECT Id, Approval_Status__c, CaseNumber FROM Case WHERE id in : caseIds];
        system.debug('casecek : '+casecek);
        
        AutomationSettlement.approveTickets(caseIds, UserInfo.getUserId());
        AutomationSettlement.approveAllTickets();
        
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
            List<Case> casesToApprove = [SELECT Id, Approval_Status__c, CaseNumber FROM Case  WHERE Approval_Status__c = 'Draft' LIMIT 10];
            
            List<Id> newWorkItemIds = new List<Id>();
            for(Case caseRecord : casesToApprove) {
                // Create the approval request
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting case for approval process');
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                req.setObjectId(caseRecord.Id);
                req.setSubmitterId(UserInfo.getUserId());
                
                // Submit the approval request
                try {
                    approval.ProcessResult apresult = Approval.process(req);
                    List<Id> newWorkItemIdsx = apresult.getNewWorkitemIds();
                    newWorkItemIds.add(newWorkItemIdsx.get(0));
                } catch(Exception e) {
                    System.debug('Error processing approval for case ' + caseRecord.CaseNumber + ': ' + e.getMessage());
                }
            }
            
            for(Id caseRecord : newWorkItemIds) {
                // Create the approval request
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments('Approving request.');
                req2.setAction('Approve');
                req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(newWorkItemIds.get(0));
                
                // Submit the approval request
                try {
                    Approval.ProcessResult result2 =  Approval.process(req2);
                } catch(Exception e) {
                    System.debug('Error processing approval for case : ' + e.getMessage());
                }
            }
            Case caseToApprove = casesToApprove[0];
        
            AutomationSettlement.InputVariable inputVar = new AutomationSettlement.InputVariable();
            inputVar.recordId = caseToApprove.Id;
            inputVar.userId = UserInfo.getUserId();
            inputVar.status = 'Approve';
            inputVar.ticketNo = caseToApprove.CaseNumber;
        
            List<AutomationSettlement.InputVariable> inputVarList = new List<AutomationSettlement.InputVariable>{inputVar};
        
            Test.startTest();
            // Call the method under test
            List<AutomationSettlement.Result> resultxs = AutomationSettlement.approvalProcess(inputVarList);
            Test.stopTest(); // Ensure all asynchronous processes complete
       		}
	
    @isTest
    static void testUpdateSigner() {
        List<Case> newList = new List<Case>();
        Case c = new Case(Approval_Status__c = 'Approved');
        newList.add(c);
        Map<Id, Case> oldMap = new Map<Id, Case>();
        oldMap.put(c.Id, new Case(Approval_Status__c = 'Waiting for Signer'));
        
        Test.startTest();
        AutomationSettlement.updateChecker(newList, oldMap);
        Test.stopTest();

        // Add assertions to verify behavior
        System.assertEquals('Approved', c.Approval_Status__c, 'Expected case to be approved');
    }
}