/**
 * @description Class for capture error Log
 */
public without sharing class ErrorLogRecord {
    /**
     * @description Function for capture error from trigger
     * @param dl
     * @param sp
     * @param exc
     */
    public static void errorException(DebugLog dl,Savepoint sp,Exception exc){
        if(!test.isRunningTest()) {
            dl.cs.addError(exc.getMessage());
        }
        Database.rollback(sp);
        ErrorLogRecord.seteventerror(JSON.serialize(dl));
    }
    /**
     * @description Function for capture error from trigger
     * @param sobj
     * @param classname
     * @param exc
     * @return setError
     */
    public static DebugLog setError(SObject sobj, String classname, Exception exc){
        DebugLog dls = new DebugLog();
        dls.message = exc.getMessage();
        dls.trace = exc.getStackTraceString();
        dls.typename = exc.getTypeName();
        dls.linenumber = string.valueOf(exc.getLineNumber());
        dls.errorcause = string.valueOf(exc.getCause());
        dls.classname = classname;
        dls.cs = sobj;
        return dls;
    }
    /**
     * @description Function for capture error from trigger
     * @param jsonLogError
     */
    public static void seteventerror( String jsonLogError){
        ErrorLogRecord.DebugLog dls = (ErrorLogRecord.DebugLog) JSON.deserialize(jsonLogError,ErrorLogRecord.DebugLog.class);
        String bodyreq = dls.body;
        if(bodyreq?.length()>131072) {
            bodyreq = bodyreq.substring(0, 131072);
        }
        String bodyres = dls.responseBody;
        if(bodyres?.length()>131072) {
            bodyres = bodyres.substring(0, 131072);
        }
        
        if(String.isNotBlank(dls.recid)){
            dls.objnm = dls.recid.getSObjectType().getDescribe().getName();
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
                            request_ip__c=dls.iprequest,
                            Endpoint__c=dls.urlEndpoint,
                            Response_Header__c=dls.responseHeader,
                            Response_Status__c=dls.responseStatus,
                            Response_Status_Code__c=dls.statusCode,
                            Response_Body__c=bodyres,
                            API_Type__c=dls.typeApi,
                            RelatedId__c = dls.recid,
                            Object_Name__c = dls.objnm,
                            String_To_Sign__c = dls.stringtosign
                            );
        EventBus.publish(erl);
    }
    /**
     * @description Function for capture error from class non integration
     * @param jsonLogError
     */
    public static void inserterror(String jsonLogError){
        ErrorLogRecord.seteventerror(jsonLogError);
    }
    /**
     * @description Function for capture error from integration
     * @param jsonLogError
     */
    public static void inserterrorAPI(String jsonLogError){
        ErrorLogRecord.seteventerror(jsonLogError);
    }
    /**
     * @description DebugLog
     */
    public class DebugLog {
        /**
         * @description DebugLog
         */
        public String iduser {get;set;}
        /**
         * @description DebugLog
         */
        public String message {get;set;} 
        /**
         * @description DebugLog
         */
        public String trace {get;set;} 
        /**
         * @description DebugLog
         */
        public String typename {get;set;} 
        /**
         * @description DebugLog
         */
        public String linenumber {get;set;} 
        /**
         * @description DebugLog
         */
        public String errorcause {get;set;} 
        /**
         * @description DebugLog
         */
        public String classname {get;set;}
        /**
         * @description DebugLog
         */
        public String iprequest {get;set;}
        /**
         * @description DebugLog
         */
        public String header {get;set;} 
        /**
         * @description DebugLog
         */
        public String body {get;set;} 
        /**
         * @description DebugLog
         */
        public string urlEndpoint {get;set;}
        /**
         * @description DebugLog
         */
        public String responseHeader {get;set;}
        /**
         * @description DebugLog
         */
        public String responseBody {get;set;}
        /**
         * @description DebugLog
         */
        public String responseStatus {get;set;}
        /**
         * @description DebugLog
         */
        public Integer statusCode {get;set;}
        /**
         * @description DebugLog
         */
        public string typeApi {get;set;}
        /**
         * @description DebugLog
         */
        public Id recid {get;set;}
        /**
         * @description DebugLog
         */
        public string objnm {get;set;}
        /**
         * @description DebugLog
         */
        public SOBJECT cs {get;set;}
        /**
         * @description DebugLog
         */
        public String stringtosign {get;set;}
    }
}