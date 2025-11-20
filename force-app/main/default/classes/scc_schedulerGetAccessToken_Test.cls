@isTest
private class scc_schedulerGetAccessToken_Test {
    
    @isTest
    static void testScheduler() {
        Test.startTest();
        
        String jobId = scc_schedulerGetAccessToken.scheduleJob();
        
        List<CronTrigger> scheduledJobs = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        
        System.assertEquals(1, scheduledJobs.size(), 'Job seharusnya dijadwalkan');
        System.assertEquals('0 0 * * * ?', scheduledJobs[0].CronExpression, 'Cron expression seharusnya menjalankan flow setiap jam');
        
        scc_schedulerGetAccessToken scheduler = new scc_schedulerGetAccessToken();
        scheduler.execute(null);
        
        Test.stopTest();
    }
    
    @isTest
    static void testFlowExecutionHandlesException() {
        Test.startTest();

        scc_schedulerGetAccessToken scheduler = new scc_schedulerGetAccessToken();
        
        scheduler.execute(null);
        
        Test.stopTest();
    }
}