global class SCC_Batch_ActionMonitoring implements Database.AllowsCallouts,Database.Batchable<sObject>{
    public List<sObject> record = new List<sObject>();
    public String action;
    
    global SCC_Batch_ActionMonitoring(List<sObject> record,String action){
        this.record = record;          
        this.action = action;
    }
    
	global List<sObject> start(Database.BatchableContext bc) {
        return record;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        if(action == 'insert') insert scope;
        else if(action == 'update') update scope;
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients
    }
   
}