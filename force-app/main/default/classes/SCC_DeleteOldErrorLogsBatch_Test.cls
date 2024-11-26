@isTest
public class SCC_DeleteOldErrorLogsBatch_Test {

    @testSetup
    static void setupTestData() {
        List<Error_Log__c> logs = new List<Error_Log__c>();
        for (Integer i = 0; i < 5; i++) { // Only 5 records older than 7 days
            logs.add(new Error_Log__c(
                CreatedDate = Date.today().addDays(-10) // Older than 7 days
            ));
        }
        insert logs;

        logs.clear();
        for (Integer i = 0; i < 2; i++) { // Only 2 records within 7 days
            logs.add(new Error_Log__c(
                CreatedDate = Date.today().addDays(-2) // Within 7 days
            ));
        }
        insert logs;
    }

    @isTest
    static void testBatchExecution() {
        Integer oldLogsCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate < LAST_N_DAYS:7];
        Integer recentLogsCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate >= LAST_N_DAYS:7];
        System.assertEquals(5, oldLogsCount, 'There should be 5 old logs.');
        System.assertEquals(2, recentLogsCount, 'There should be 2 recent logs.');

        Test.startTest();
        SCC_DeleteOldErrorLogsBatch batch = new SCC_DeleteOldErrorLogsBatch();
        Database.executeBatch(batch, 10); // Set batch size to ensure single execution
        Test.stopTest();

        Integer remainingOldLogsCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate < LAST_N_DAYS:7];
        Integer remainingRecentLogsCount = [SELECT COUNT() FROM Error_Log__c WHERE CreatedDate >= LAST_N_DAYS:7];
        System.assertEquals(0, remainingOldLogsCount, 'All old logs should be deleted.');
        System.assertEquals(2, remainingRecentLogsCount, 'Recent logs should not be deleted.');
    }
}