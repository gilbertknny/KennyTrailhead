@isTest
public class DeleteErrorLogBatchTest {
    @testSetup
    static void setup() {
        List<Error_Log__c> logs = new List<Error_Log__c>();
        for (Integer i = 0; i < 5; i++) {
            logs.add(new Error_Log__c(
                CreatedDate = DateTime.newInstance(2024, 7, 1, 0, 0, 0)
            ));
        }
        for (Integer i = 0; i < 5; i++) {
            logs.add(new Error_Log__c(
                CreatedDate = DateTime.newInstance(2024, 7, 10, 0, 0, 0)
            ));
        }
        insert logs;
    }

    @isTest
    static void testDeleteErrorLogBatch() {
        Integer initialCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate <= 2024-07-07T00:14:07.000+0000];
        System.assertEquals(5, initialCount, 'There should be 5 logs created before the cutoff date.');

        Test.startTest();
        DeleteErrorLogBatch batch = new DeleteErrorLogBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        Integer remainingCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate <= 2024-07-07T00:14:07.000+0000];
        System.assertEquals(0, remainingCount, 'All logs created before the cutoff date should be deleted.');

        Integer recentLogsCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate > 2024-07-07T00:14:07.000+0000];
        System.assertEquals(5, recentLogsCount, 'Logs created after the cutoff date should remain.');
    }
}