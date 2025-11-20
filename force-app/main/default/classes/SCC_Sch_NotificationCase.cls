global with sharing class SCC_Sch_NotificationCase implements Schedulable{
	global void execute(SchedulableContext ctx) {
        SCC_HttpReq_NotificationCase.execute(null); 
        //system.schedule('BRIStar Notification', '0 15 0 * * ?', new SCC_Sch_NotificationCase());
    }
}