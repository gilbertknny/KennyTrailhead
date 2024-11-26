global class SCC_DeleteOldErrorLogsBatchStopper {
    public static void stopScheduledJob(String jobName) {
        List<CronTrigger> cronTriggers = [SELECT Id, State FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        for (CronTrigger ct : cronTriggers) {
            if (ct.State == 'WAITING' || ct.State == 'ACQUIRED') {
                System.abortJob(ct.Id);
            }
        }
    }
}