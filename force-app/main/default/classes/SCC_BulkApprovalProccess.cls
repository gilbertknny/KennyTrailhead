/**
    FITUR : WFM
 */
public with sharing class SCC_BulkApprovalProccess implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public SCC_ApprovalProcess.FlowInputvalues fi;
    public SCC_BulkApprovalProccess(SCC_ApprovalProcess.FlowInputvalues f){
        this.fi = f;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(fi.query);
     }
  
    public void execute(Database.BatchableContext bc, List<SObject> scope){
        try{
            for(SObject s:scope){
                system.debug('SObject : '+s);
                SCC_ApprovalProcess.FlowInputvalues fi2 = fi;
                fi2.query = '';
                fi2.type = '';
                fi2.recordId = s.Id;
                SCC_ApprovalProcess.setApproveOrReject(fi2);
            }
        }
        catch(Exception exc){
            InsertErrorLog(exc,'SCC_BulkApprovalProccess');
        }
    }
    public void finish(Database.BatchableContext bc){
     
    }

    public static void insertErrorLog(Exception exc,String cls){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = cls;
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}