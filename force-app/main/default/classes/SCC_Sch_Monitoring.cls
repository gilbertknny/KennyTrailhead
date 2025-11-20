global with sharing class SCC_Sch_Monitoring implements Schedulable{
	global void execute(SchedulableContext ctx) {
        SCC_Monitoring.execute(null,null,'Extremely');
        //SCC_Monitoring.execute(null,null,'Business_Hours');
        //SCC_Monitoring.execute(null,null,'Not_Create_Case');
        //SCC_HttpReq_Monitoring.execute(null); 
        //SCC_HttpReq_NotificationCase.execute(null); 
        //Database.executeBatch(new SCC_BristarSummary(null,null));
        //system.schedule('Monitoring Summary', '0 0 0 * * ?', new SCC_Sch_Monitoring());
    }
}