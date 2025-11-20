global class SCC_Batch_Monitoring implements Database.AllowsCallouts,Database.Batchable<Monitoring_Summary__c>{
    public List<Monitoring_Summary__c> recordset = new List<Monitoring_Summary__c>();
    
    global SCC_Batch_Monitoring(List<Monitoring_Summary__c> recordget){
        recordset = recordget;          
    }
    
	global List<Monitoring_Summary__c> start(Database.BatchableContext bc) {
        return recordset;
    }

    global void execute(Database.BatchableContext bc, List<Monitoring_Summary__c> scope) {
        for(Monitoring_Summary__c s : scope){
            SCC_HttpReq_Monitoring.sendNotif(s.Message_API__c,String.valueOf(s.Date__c),s.Orgeh_API__c,s.Branch_API__c,s.is_konsolidasi__c,s.Cost_Center_Desc__c);
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients
    }
   
}