/**
 * @description Class for capture error Log
 */
public without sharing class ErrorLogRecord {
    /**
     * @description Function for capture error from trigger
     * 
     */
    public static void errorexception(
        DebugLog dl,
        Savepoint sp,
        Exception exc){
        if(!test.isRunningTest()) {
            dl.cs.addError(exc.getMessage());
        }
        Database.rollback(sp);
        DebugLog dls = new DebugLog();
        dls.message = exc.getMessage();
        dls.trace = exc.getStackTraceString();
        dls.typename = exc.getTypeName();
        dls.linenumber = string.valueOf(exc.getLineNumber());
        dls.errorcause = string.valueOf(exc.getCause());
        dls.classname = dl.classname;
        ErrorLogRecord.seteventerror(JSON.serialize(dls));
    }
    /**
     * @description Function for capture error from trigger
     * 
     */
    public static void seteventerror( String jsonLogError){
        ErrorLogRecord.DebugLog dls = (ErrorLogRecord.DebugLog) JSON.deserialize(jsonLogError,ErrorLogRecord.DebugLog.class);
        String bodyreq = dls.body;
        if(bodyreq?.length()>130000) {
            bodyreq = bodyreq.substring(0, 130000);
        }
        String bodyres = dls.responseBody;
        if(bodyres?.length()>130000) {
            bodyres = bodyres.substring(0, 130000);
        }
        String ipreq = dls.iprequest;
        if(ipreq?.length()>255) {
            ipreq = ipreq.substring(0,255);
        }
        String endp = dls.urlEndpoint;
        if(endp?.length()>255) {
            endp = endp.substring(0,255);
        }
        Error_Logs__e erl = new Error_Logs__e(
                            Class_Flow_Name__c=dls.classname,
                            user_run__c=dls.iduser,
                            Error_Cause__c=dls.errorcause,
                            Error_Messages__c=dls.message,
                            Line_Number__c=dls.linenumber,
                            Stack_Trace__c=dls.trace,
                            Type_Name__c=dls.typename,
                            request_header__c=dls.header,
                            request_body__c=bodyreq,
                            request_ip__c=ipreq,
                            Request_IP_Long__c=dls.iprequest,
                            endpoint__c=endp,
                            Endpoint_Long__c=dls.urlEndpoint,
                            Response_Header__c=dls.responseHeader,
                            Response_Status__c=dls.responseStatus,
                            Response_Status_Code__c=dls.statusCode,
                            Response_Body__c=bodyres,
                            API_Type__c=dls.typeApi,
                            Menu__c	 = dls.menu,
                            RelatedId__c = dls.recid,
                            Object_Name__c = dls.objnm,
                            Source__c = dls.sorc,
                            Destination__c = dls.dest);
        EventBus.publish(erl);
    }
    /**
     * @description Function for capture error from class non integration
     * 
     */
    public static void inserterror(String jsonLogError){
        ErrorLogRecord.seteventerror(jsonLogError);
    }
    /**
     * @description Function for capture error from integration
     * 
     */
    public static void inserterrorAPI(String jsonLogError){
        ErrorLogRecord.seteventerror(jsonLogError);
        /*
        if (Schema.sObjectType.Error_Log__c.isCreateable()) {
            insert el;
        }
            */
    }

    public class DebugLog {
        public String iduser {get;set;}
        public String message {get;set;} 
        public String trace {get;set;} 
        public String typename {get;set;} 
        public String linenumber {get;set;} 
        public String errorcause {get;set;} 
        public String classname {get;set;}
        public String header {get;set;} 
        public String body {get;set;} 
        public String iprequest {get;set;}
        public String responseStatus {get;set;}
        public Integer statusCode {get;set;}
        public String responseHeader {get;set;}
        public String responseBody {get;set;}
        public string urlEndpoint {get;set;}
        public string typeApi {get;set;}
        public string menu {get;set;}
        public string recid {get;set;}
        public string objnm {get;set;}
        public string sorc {get;set;}
        public string dest {get;set;}
        public SOBJECT cs {get;set;}
    }
}