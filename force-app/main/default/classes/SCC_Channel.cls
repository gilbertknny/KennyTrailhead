global class SCC_Channel implements Queueable, Database.AllowsCallouts{
	public String csid {get;set;}
    public String logika {get;set;}
    global SCC_Channel(String csid,String logika){
        this.csid = csid;
        this.logika = logika;
    }
    
    global void execute(QueueableContext context) {
        String cond = 'id=:csid';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, ',scc_call_type__r.Send_to_Drone__c', 'Case', cond, '', '', '1');
        Case cs = Database.query(queries);
        if(logika=='Escalation'){
            if(String.isNotBlank(cs.SCC_Terminal_ID__c) && cs.SCC_Terminal_ID__c!=label.tid && cs.SCC_Transaction_Date__c!=null){
                CustomLookupController.RecordsData rd = CustomLookupController.GetDataDetail(String.valueof(cs.SCC_Transaction_Date__c), cs.SCC_Terminal_ID__c);
                cs.terminal_id__c = rd?.value; 
            }
        	if(!cs.isclosed__c){
            	update cs;
        	}
            if(cs.scc_call_type__r.Send_to_Drone__c && !Test.isRunningTest()){
                System.enqueueJob(new SCC_Channel(cs.id,'Send To Drone'));
            }
        }
        if(logika=='Send To Drone'){
            SCC_InvocableDrone.sendCreateToDroneFuture(cs.id);
        }
    }
}