@isTest
public class SCC_DeleteOldErrorLogsScheduler_Test {
    
    @isTest
    static void testScheduler() {
        Test.startTest();

        String cronExp = '0 0 7 * * ?';
        System.debug(cronExp);
        String jobId = System.schedule('Test SCC_DeleteOldErrorLogsScheduler', cronExp, new SCC_DeleteOldErrorLogsScheduler());

        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, ct, 'Job should be scheduled');
        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression should match');
    }
}