/**
 * @description       : Test class for SCC_SendEmailNotificationOverSLA_Sch
 * @last modified on  : 03-05-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_SendEmailNotificationOverSLA_SchTes {
    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        SCC_SendEmailNotificationOverSLA_Sch scheduler = new SCC_SendEmailNotificationOverSLA_Sch();
        scheduler.execute(null);
        
        Test.stopTest();
    }
    @isTest
    static void testScheduleJob() {
        Test.startTest();
        
        // Schedule the job
        String cronExp = '0 0 8 * * ?';
        String jobId = System.schedule('Test Email Reminder Scheduler', 
                                       cronExp, 
                                       new SCC_SendEmailNotificationOverSLA_Sch());
        
        Test.stopTest();
        
        // Verify that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        
        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertNotEquals(null, ct.NextFireTime);
    }
}