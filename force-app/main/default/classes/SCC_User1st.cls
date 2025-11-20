global with sharing class SCC_User1st implements Queueable, Database.AllowsCallouts {
    public String isrequestall {get;set;}
    global SCC_User1st(String num){
        this.isrequestall = num; //0/1
    }
    
    global void execute(QueueableContext context) {
        Map<Integer,List<String>> mapstr = new Map<Integer,List<String>>();
        SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMRequest req = new SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMRequest();
        req.is_request_all = isrequestall;
        try{
            SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse res = SCC_CaseResolution_CHMSupport.SearchInquiryRoleUser(req);
            if(res?.data!=null){
                ID jobID = System.enqueueJob(new SCC_User1st_Extended(res?.data));
            }
        }
        catch(Exception exc){
            InsertErrorLog(exc, 'SCC_User1st');
        }
    }

    public static void insertErrorLog(Exception exc,String clsName){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = clsName;
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}