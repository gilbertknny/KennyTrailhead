/*** @description BatchRiskAssetCoverage */
public with sharing class BatchRiskAssetCoverage implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public String query;
    public Id newoptyId;
    public Id newaccId;
    /*** @description BatchRiskAssetCoverage @param q @param optyId @param accountId */
    public BatchRiskAssetCoverage(String q, Id optyId, Id accountId) {
        this.query = q;
        this.newoptyId = optyId;
        this.newaccId = accountId;
    }
    /*** @description start @param bc @return Database.QueryLocator */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    } 
    /*** @description execute @param bc @param scope */
    public void execute(Database.BatchableContext bc, List<Asset> scope){
        try{
            Map<String, Object> inputs = new Map<String, Object>();
            for(Asset oldrsk : scope){
                inputs.put('OldRiskId', oldrsk.Id);
                inputs.put('NewOptyId', newoptyId);
                inputs.put('AccountId', newaccId);
            }
            Flow.Interview myFlow = Flow.Interview.createInterview('Risk_Asset_Clone', inputs);
            myFlow.start();
        }
        catch(Exception exc){
            insertErrorLog(exc);
        }
    }
    /*** @description finish @param bc */
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG,'finish');
    }
    /*** @description insertErrorLog @param exc */
    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'BatchRiskAssetCoverage';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}