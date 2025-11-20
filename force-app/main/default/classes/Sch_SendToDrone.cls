global class Sch_SendToDrone implements Schedulable{
	global void execute(SchedulableContext ctx) {
        List<Drone__c> listdata = [SELECT Id,Case__c,Method__c FROM Drone__c WHERE Status__c = 'Draft'];
        Database.executeBatch(new Cls_Batch_SendToDrone(listdata), 50);
    }
}