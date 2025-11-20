global class Cls_Batch_SendToDrone implements Database.AllowsCallouts,Database.Batchable<Drone__c>{
	public List<Drone__c> recordset = new List<Drone__c>();
    
    global Cls_Batch_SendToDrone(List<Drone__c> recordget){
        recordset = recordget;          
    }
    
    global List<Drone__c> start(Database.BatchableContext BC){
        return recordset;
    }
    
    global void execute(Database.BatchableContext BC, List<Drone__c> scope){
        List<Drone__c> listdata = new List<Drone__c>();
        for(Drone__c d : scope){
            if(d.Case__c != null){
                if(d.Method__c == 'Insert') SCC_InvocableDrone.sendCreateToDrone(d.Case__c);
                else if(d.Method__c == 'Update') SCC_InvocableDrone.sendUpdateToDrone(d.Case__c);
                d.Status__c = 'Send';
                listdata.add(d);
            }
        }      
        if(listdata.size()>0) update listdata;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}