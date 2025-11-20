/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 15-04-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_QA_InPeriode_Scheduler implements Schedulable{
    private static final Integer BATCH_SIZE = 100;

    public void execute(SchedulableContext SC) {
        // Menjalankan batch untuk mengirim email reminder
        SCC_QA_InPeriode_Batch batchJob = new SCC_QA_InPeriode_Batch();
        // Tambahkan parameter BATCH_SIZE
        Database.executeBatch(batchJob, BATCH_SIZE);
    }
}