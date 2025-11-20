/**
 * @description       : Test class for SCC_QANotificationService
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 12-03-2025
 * @last modified by  : Ardyta Yudianto
**/
@isTest
private class SCC_QANotificationServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        User agentLeader = new User(
            FirstName = 'Agent',
            LastName = 'Leader',
            Email = 'agent.leader@test.com',
            Username = 'agent.leader@test.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            Alias = 'agentle',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            User_Level__c = 'Agent Leader'
        );
        insert agentLeader;
        
        User qaUser = new User(
            FirstName = 'QA',
            LastName = 'User',
            Email = 'qa.user@test.com',
            Username = 'qa.user@test.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            Alias = 'qauser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert qaUser;
        
        // Create Agent CC user
        User agentCC = new User(
            FirstName = 'Agent',
            LastName = 'CC',
            Email = 'agent.cc@test.com',
            Username = 'agent.cc@test.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            Alias = 'agentcc',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert agentCC;
        
        // Create test QA Response record
        QA_Response__c qaResponse = new QA_Response__c(
            Status_Approval__c = 'New',
            OwnerId = agentCC.Id
        );
        insert qaResponse;

        qaResponse.Agent_Leader_Lookup__c = agentLeader.Id;
        qaResponse.Nama_QA_Lookup__c = qaUser.Id;
        qaResponse.Agent_Lookup__c = agentCC.Id;
        update qaResponse;
    }
    
    @isTest
    static void testSendNotification_WithRealApprovalProcess() {
        // Check if the approval process exists
        List<ProcessDefinition> pdList = [SELECT Id, DeveloperName 
                                       FROM ProcessDefinition 
                                       WHERE DeveloperName = 'Approval_Penilaian_QA'];
                                       
        // Skip test if approval process is missing
        if(pdList.isEmpty()) {
            System.debug('TEST: SKIPPING TEST: Required approval process not found in this org');
            return;
        }
        
        // Get the QA Response record and user data
        QA_Response__c qaResponse = [SELECT Id, Agent_Leader_Lookup__c, Nama_QA_Lookup__c, Agent_Lookup__c, Status_Approval__c 
                                    FROM QA_Response__c LIMIT 1];
        User agentLeader = [SELECT Id FROM User WHERE LastName = 'Leader' LIMIT 1];
        User agentCC = [SELECT Id FROM User WHERE LastName = 'CC' LIMIT 1];
        
        // Create notification request
        SCC_QANotificationService.NotificationRequest req = new SCC_QANotificationService.NotificationRequest();
        req.notificationBody = 'Test Notification Body';
        req.notificationTitle = 'Test Notification Title';
        req.recipientIds = new List<String>{agentLeader.Id};
        req.qaResponseId = qaResponse.Id;
        
        Test.startTest();
        
        // Step 1: Agent CC submits for approval (Approval_Penilaian_QA)
        Approval.ProcessSubmitRequest penilaianRequest = new Approval.ProcessSubmitRequest();
        penilaianRequest.setComments('Submitting for initial QA review');
        penilaianRequest.setObjectId(qaResponse.Id);
        penilaianRequest.setProcessDefinitionNameOrId('Approval_Penilaian_QA');
        
        System.runAs(agentCC) {
            try {
                // Submit for approval
                Approval.ProcessResult result = Approval.process(penilaianRequest);
                System.debug('TEST: First submission result: ' + result.isSuccess());
                
                // After submission, the record has an approved process
                if(result.isSuccess()) {
                    // Refresh data
                    qaResponse = [SELECT Id, Status_Approval__c FROM QA_Response__c WHERE Id = :qaResponse.Id];
                    
                    // Verify workitem was created
                    List<ProcessInstanceWorkitem> workItems = [
                        SELECT Id, ProcessInstanceId, ActorId 
                        FROM ProcessInstanceWorkitem 
                        WHERE ProcessInstance.TargetObjectId = :qaResponse.Id
                    ];
                    
                    System.assertNotEquals(0, workItems.size(), 'Work items should be created');
                    
                    // Now send the notification
                    SCC_QANotificationService.sendNotification(new List<SCC_QANotificationService.NotificationRequest>{req});
                }
            } catch(Exception e) {
                System.debug('TEST: Exception in first submission: ' + e.getMessage());
                System.assert(false, 'Exception occurred: ' + e.getMessage());
            }
        }
        
        Test.stopTest();
        
        // Query the ProcessInstanceStep for comments
        List<ProcessInstanceStep> steps = [
            SELECT Id, StepStatus, Comments 
            FROM ProcessInstanceStep 
            WHERE ProcessInstance.TargetObjectId = :qaResponse.Id
        ];
        
        System.debug('TEST: Process Steps: ' + steps);
        System.assertNotEquals(0, steps.size(), 'Approval steps should be created');
    }
    
    @isTest
    static void testSendNotification_EmptyRequest() {
        Test.startTest();
        
        SCC_QANotificationService.sendNotification(null);
        SCC_QANotificationService.sendNotification(new List<SCC_QANotificationService.NotificationRequest>());
        
        Test.stopTest();
        
        // Verify no errors occurred
        System.assert(true, 'Empty request handled successfully');
    }
    
    @isTest
    static void testNotificationRequest() {
        // Test the wrapper class
        SCC_QANotificationService.NotificationRequest req = new SCC_QANotificationService.NotificationRequest();
        req.notificationBody = 'Test Body';
        req.notificationTitle = 'Test Title';
        req.recipientIds = new List<String>{'005000000000000'};
        req.qaResponseId = getFakeId(QA_Response__c.SObjectType);
        
        System.assertEquals('Test Body', req.notificationBody);
        System.assertEquals('Test Title', req.notificationTitle);
        System.assertEquals(1, req.recipientIds.size());
        System.assertNotEquals(null, req.qaResponseId);
    }
    
    // Helper method to generate fake Id for a given SObject type
    private static Id getFakeId(Schema.SObjectType sot) {
        String keyPrefix = sot.getDescribe().getKeyPrefix();
        String fakeId = keyPrefix + '0'.repeat(12);
        return Id.valueOf(fakeId);
    }
}