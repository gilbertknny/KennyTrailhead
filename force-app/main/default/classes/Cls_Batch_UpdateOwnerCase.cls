global class Cls_Batch_UpdateOwnerCase implements Database.Batchable<Case>{
    
    public List<Case> recordset = new List<Case>();
    
    global Cls_Batch_UpdateOwnerCase(List<Case> recordget){
        recordset = recordget;          
    }
    
    global List<Case> start(Database.BatchableContext BC){
        return recordset;
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Case> listdata = new List<Case>();
        for(Case s : scope){
            listdata.add(s);
        }      
        system.debug('listdata:'+listdata);
        system.debug('listdata.size:'+listdata.size());
        if(listdata.size()>0) update listdata;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}