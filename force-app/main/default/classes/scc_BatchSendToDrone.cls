public with sharing class scc_BatchSendToDrone implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public String Query;
    public scc_BatchSendToDrone(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext bc, List<Case> scope){
        for(Case cs : scope){
            SCC_InvocableDrone.sendCreateToDrone(cs.id);
        }
    }
  
    public void finish(Database.BatchableContext bc){
     
    }
}