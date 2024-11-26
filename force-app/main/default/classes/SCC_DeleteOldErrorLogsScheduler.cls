global class SCC_DeleteOldErrorLogsScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        SCC_DeleteOldErrorLogsBatch batch = new SCC_DeleteOldErrorLogsBatch();
        Database.executeBatch(batch,100);
    }
}