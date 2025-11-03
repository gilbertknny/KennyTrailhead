/**
 * @description Hello World
 */
public with sharing class BatchFileSFAWT6 implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    /**
     * @description Hello World
     */
    public String query;
    /**
     * @description Hello World
     */
    public VlocityMapping.RequestAPI reqapi;
    /**
     * @description Hello World
     * @param q
     * @param r
     */
    public BatchFileSFAWT6(String q,VlocityMapping.RequestAPI r){
        this.query = q;
        this.reqapi = r;
    }
    /**
     * @description start
     * @param bc
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }  
    /**
     * @description Hello World
     * @param bc
     * @param scope
     */
    public void execute(Database.BatchableContext bc, List<ContentDocumentLink> scope){
        try{
            List<Id> lcdid = new List<Id>();
            for(ContentDocumentLink cdl: scope){
                lcdid.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> listcv = [select Id,Title,PathOnClient,ID_Type__c,VersionData,SyncFile__c from ContentVersion where ContentDocumentId in : lcdid and SyncFile__c=false 
                                            and (fieldtype__c = Null or fieldtype__c = :reqapi.metafile )];
            List<ContentVersion> listcv2 = new List<ContentVersion>(); 
            for(ContentVersion cv:listcv){
                Map<String,Object> mapbd = new Map<String,Object>();
                mapbd.put('ID_Type__c', cv.ID_Type__c);
                mapbd.put('Title', cv.Title);
                mapbd.put('PathOnClient', cv.PathOnClient);
                mapbd.put('LinkedEntityId__c', reqapi.externalId);
                mapbd.put('fieldtype__c', reqapi.metafile);
                mapbd.put('VersionData', cv.VersionData);
                APILog.WrapperRequest wr = new APILog.WrapperRequest();     
                wr.bodyreq = JSON.serialize(mapbd);
                wr.clsName = 'VlocityMapping';
                wr.metaname = reqapi.meta;
                wr.token = reqapi.token;
                APILog.WrapperAPI wapi = APILog.getResponseAPI(wr);
                Map<String,Object> mapres2 = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
                String status = (String) mapres2.get('status'); 
                if(status == '00'){
                    ContentVersion cv2 = new ContentVersion();
                    cv2.Id = cv.Id;
                    cv2.SyncFile__c = true;
                    listcv2.add(cv2);
                }
            }
            if(!listcv2.isempty()){
                update listcv2;
            }
        }
        catch(Exception exc){
            InsertErrorLog(exc);
        }
    }
    /**
     * @description finish
     * @param bc
     */
    public void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.DEBUG,'finish');
    }
    
    /**
     * @description insertErrorLog
     * @param exc
     */
    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'BatchFileSFAWT6';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}