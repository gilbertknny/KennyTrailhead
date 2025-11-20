public without sharing class BatchHoliday_APPK implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public String query;
    public BatchHoliday_APPK(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext bc, List<Case> scope){
        try{
            update scope;
        }
        catch(Exception exc){
            InsertErrorLog(exc);
        }
    }
    public void finish(Database.BatchableContext bc){
     
    }

    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'BatchHoliday_APPK';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}