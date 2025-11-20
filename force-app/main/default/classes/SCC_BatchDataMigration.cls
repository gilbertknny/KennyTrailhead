public without sharing class SCC_BatchDataMigration implements  Database.Batchable<sObject>{
	public String Query;
    public SCC_BatchDataMigration(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
    
    public void execute(Database.BatchableContext bc, List<Case> scope){
        //DataMigration.updateUnitKerjaFieldForCases(scope);
    }
    
    public void finish(Database.BatchableContext bc){
     
    }       
}