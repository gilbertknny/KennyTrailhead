global class SCC_Batch_AutomationSettlement implements Database.AllowsCallouts,Database.Batchable<Case>{
    public List<Case> recordset = new List<Case>();
    
    global SCC_Batch_AutomationSettlement(List<Case> recordget){
        recordset = recordget;          
    }
    
	global List<Case> start(Database.BatchableContext bc) {
        return recordset;
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        for(Case s : scope){
            if(!Test.isRunningTest()) update s;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients
    }
   
}