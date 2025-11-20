/**
* @description       : Queue Notification to Leader Every Hour
* @last modified on  : 18/11/2024
* @last modified by  : Alvin Vigo
**/

@IsTest
public class BellNotificationForCasesTest {
    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'stduser',
            Email = 'stduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'stduser@testzzz5.com'
        );
        insert testUser;

        Group queue1 = new Group(Name = 'Test Queue 1', Type = 'Queue', DeveloperName = 'TestQueue1');
        Group queue2 = new Group(Name = 'Test Queue 2', Type = 'Queue', DeveloperName = 'TestQueue2');
        insert new List<Group>{queue1, queue2};
        
        QueueSObject qsob1 = new QueueSObject(QueueId = queue1.Id, SObjectType = 'Case');
        QueueSObject qsob2 = new QueueSObject(QueueId = queue2.Id, SObjectType = 'Case');
        insert new List<QueueSObject>{qsob1, qsob2};

        System.runAs(testUser) {
            Group queue1_2 = [SELECT Id FROM Group WHERE DeveloperName = 'TestQueue1' LIMIT 1];
            Group queue2_2 = [SELECT Id FROM Group WHERE DeveloperName = 'TestQueue2' LIMIT 1];

            Case case1 = new Case(OwnerId = queue1.Id, Subject = 'Test Case 1');
            Case case2 = new Case(OwnerId = queue1.Id, Subject = 'Test Case 2');
            Case case3 = new Case(OwnerId = queue2.Id, Subject = 'Test Case 3');
            insert new List<Case>{case1, case2, case3};
        }
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();

        BellNotificationForCases.isTest = true;
        
        BellNotificationForCases scheduledJob = new BellNotificationForCases();
        String jobId = System.schedule('Test BellNotificationForCases', '0 0 12 * * ?', scheduledJob);

        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Job should be scheduled.');

        List<Group> queues = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('TestQueue1', 'TestQueue2')];
        System.assertEquals(2, queues.size(), 'There should be 2 queues.');
    }

    @isTest
    static void testBatchExecuteAndFinish() {
        Test.startTest();
        
        BellNotificationForCases.isTest = true;
        
        BellNotificationForCases batchInstance = new BellNotificationForCases();
        
        List<Group> groupList = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN ('TestQueue1', 'TestQueue2')];

        batchInstance.execute(null, groupList);

        batchInstance.finish(null);

        Test.stopTest();

        for (Group groupRecord : groupList) {
            System.assertNotEquals(null, groupRecord.Id, 'Group Id should not be null.');
            System.assertNotEquals(null, groupRecord.DeveloperName, 'Group DeveloperName should not be null.');
        }
    }
}