global with sharing class SCC_Sch_BristarSummary implements Schedulable{
	global void execute(SchedulableContext ctx) {
        Database.executeBatch(new SCC_BristarSummary(null,null,null));
        //system.schedule('BRIStar Summary', '0 15 0 * * ?', new SCC_Sch_BristarSummary());
    }
}