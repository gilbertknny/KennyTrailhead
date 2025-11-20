global with sharing class SCC_Sch_Monitoring2 implements Schedulable{
	global void execute(SchedulableContext ctx) {
        SCC_Monitoring.execute(null,null,'Not_Create_Case');
        //system.schedule('Monitoring Summary 2', '0 0 0 * * ?', new SCC_Sch_Monitoring2());
    }
}