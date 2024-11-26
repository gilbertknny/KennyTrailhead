global class SCC_Batch_NotificationCase implements Database.AllowsCallouts,Database.Batchable<Case>{
    public List<Case> recordset = new List<Case>();
    
    global SCC_Batch_NotificationCase(List<Case> recordget){
        recordset = recordget;          
    }
    
	global List<Case> start(Database.BatchableContext bc) {
        return recordset;
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        for(Case s : scope){
            //SCC_HttpReq_NotificationCase.sendNotif(Message,Date,Orgeh,Branch,Is_Konsolidasi,Uker_Type);
            SCC_HttpReq_NotificationCase.sendNotif(s.Sosmed_Message_Content__c,String.valueOf(s.Approved_Date_Checker__c),s.Main_Branch_Description__c,s.Main_Branch__c,s.SCC_Attachment__c,s.SCC_Bank_BRI__c);
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients
    }
   
}