/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 18-02-2025
 * @last modified by  : Christian Vieri
**/
global class scc_schedulerGetAccessToken implements Schedulable {
    
    private static final String FLOW_API_NAME = 'Sabrina_Get_Acess_Token_Authentication'; 
    global void execute(SchedulableContext ctx) {
        try {
            Flow.Interview myFlow = Flow.Interview.createInterview(FLOW_API_NAME, new Map<String, Object>());
            myFlow.start();
            
            System.debug('Flow ' + FLOW_API_NAME + ' berhasil dijalankan');
        } catch (Exception e) {
            System.debug('Error menjalankan flow: ' + e.getMessage());
        }
    }
    
    public static String scheduleJob() {
        String jobName = 'Hourly Flow Scheduler';
        String cronExp = '0 0 * * * ?'; 
        
        return System.schedule(jobName, cronExp, new scc_schedulerGetAccessToken());
    }
}