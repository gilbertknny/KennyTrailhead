public without sharing class SCC_Migration implements  Database.Batchable<sObject>, Database.AllowsCallouts{
	public String Query;
    public SCC_Migration(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
    
    public void execute(Database.BatchableContext bc, List<Case> scope){
       /*List<Case> listcs = CaseOwnerUpdater.updateCaseOwners(scope);
        if(!listcs.isempty()){
            update listcs;
        }*/
    }
    
    public void finish(Database.BatchableContext bc){
     
    }       
}