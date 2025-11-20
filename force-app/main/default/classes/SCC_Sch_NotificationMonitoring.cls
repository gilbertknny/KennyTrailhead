global with sharing class SCC_Sch_NotificationMonitoring implements Schedulable{
	global void execute(SchedulableContext ctx) {
        SCC_HttpReq_Monitoring.execute(null);
        //system.schedule('BRIStar Notification Monitoring', '0 15 0 * * ?', new SCC_Sch_NotificationMonitoring());
    }
}