public with sharing class SCC_Wise_API {

    public class WrapperAPI{
        public HttpRequest req {get;set;}
        public HttpResponse res {get;set;}
        public String urlCurrent {get;set;}
        public WrapperAPI(HttpRequest req , HttpResponse res , String urlCurrent ){
            this.req = req;
            this.res = res;
            this.urlCurrent = urlCurrent;
        }
    }

    // public class WrapperError{
    //     public String urlCurrent {get;set;}
    //     public String clsName {get;set;}
    //     public String recid {get;set;}
    //     public String objnm {get;set;}
    //     public String menu {get;set;}
    //     public String sorc {get;set;}
    //     public String dest {get;set;}
    //     public String inEndpoint {get;set;}
    //     public RestRequest requestApi {get;set;}
    //     public RestResponse respondApi {get;set;}
    //     public map<String,String> mapheader {get;set;}
    //     public WrapperError(String urlCurrent,String clsName){
    //         this.clsName = clsName;
    //         this.urlCurrent = urlCurrent;
    //     }
    // }

    
    // public static void insertErrorLog(Exception exc, HttpRequest req , HttpResponse res, WrapperError we){
    //     Map<String,String> maphdr = new Map<String,String>();
    //     maphdr.put('correlationID',res.getHeader('correlationID'));
    //     if(res?.getHeaderKeys()!=null){
    //         for(String str:res?.getHeaderKeys()){
    //             maphdr.put(str,res.getHeader(str));
    //         }
    //     }

    //     ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
    //     dl.message = exc?.getMessage();
    //     dl.trace = exc?.getStackTraceString();
    //     dl.typename = exc?.getTypeName();
    //     dl.linenumber = string.valueOf(exc?.getLineNumber()); 
    //     dl.errorcause = string.valueOf(exc?.getCause()); 
    //     dl.classname = we.clsName;
    //     dl.header = JSON.serialize(we.mapheader);
    //     dl.body = req?.getBody();
    //     dl.iprequest = we.urlCurrent;
    //     dl.responseStatus = res?.getStatus();
    //     dl.statusCode = res?.getStatusCode(); 
    //     dl.responseHeader = JSON.serialize(maphdr);
    //     dl.responseBody = res?.getBody();
    //     dl.responseStatus = res?.getStatus();
    //     dl.urlEndpoint = req?.getEndpoint();
    //     dl.typeApi = 'Outbound';
    //     dl.iduser = UserInfo.getUserId();
    //     dl.menu = we.menu;
    //     dl.recid = we.recid;
    //     dl.objnm = we.objnm;
    //     dl.sorc = we.sorc;
    //     dl.dest = we.dest;
    //     ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    // }
    public class WrapperError {
        public String urlCurrent { get; set; }
        public String cls_name { get; set; }
        
        public WrapperError(String urlCurrent, String cls_name) {
            this.urlCurrent = urlCurrent;
            this.cls_name = cls_name;
        }
    }

    public static void insertErrorLog(Exception exc, HttpRequest req, HttpResponse res, WrapperError we) {
        Map<String, String> maphdr = new Map<String, String>();
        maphdr.put('correlationID', res.getHeader('correlationID'));
        if (res?.getHeaderKeys() != null) {
            for (String str : res?.getHeaderKeys()) {
                maphdr.put(str, res.getHeader(str));
            }
        }
        String bd = req?.getBody();
        if(bd.length()>130000){
            bd = bd.substring(0, 130000);
        }
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = String.valueOf(exc?.getLineNumber());
        dl.errorcause = String.valueOf(exc?.getCause());
        dl.classname = we.cls_name;
        dl.body = bd;//req?.getBody();
        dl.iprequest = we.urlCurrent;
        dl.responseStatus = res?.getStatus();
        dl.statusCode = res?.getStatusCode();
        dl.responseHeader = JSON.serialize(maphdr);
        dl.responseBody = res?.getBody();
        dl.responseStatus = res?.getStatus();
        dl.urlEndpoint = req?.getEndpoint();
        dl.typeApi = 'Outbound';
        dl.header = req?.getHeader('Content-Type');
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
    
    public static SCC_Wise_API.WrapperAPI getResponseWise(String metaname, String bodyreq, String token, String classname, String path){

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        Map <String,String> mapHeader = new Map<String,String>();


        // WrapperError we = new WrapperError(urlCurrent,classname);
        // we.objnm = 'Knowledge';
        // we.menu = 'Wise';
        // we.dest = 'Wise';

        try{
            SCC_Endpoint_API__mdt metaApi = SCC_Endpoint_API__mdt.getInstance(metaname);

            String endpoint = String.isNotBlank(path) ? metaApi.Named_Credential__c + metaApi.Directory__c + path : metaApi.Named_Credential__c + metaApi.Directory__c;
            //String requestBody = String.isNotBlank(bodyreq) ? bodyreq : defaultBody(metaname);
            String requestBody = bodyreq;
            Blob headerValue = Blob.valueOf(metaApi.Username__c + ':' + metaApi.Password__c);
            String authHeader = 'Basic' + EncodingUtil.base64Encode(headerValue);

            req.setEndpoint(endpoint);
            req.setMethod(metaApi.Method__c);
            req.setTimeout(Integer.valueOf(metaApi.Timeout__c));
            req.setHeader('Content-Type', 'application-bribrain/json');

            if(String.isNotBlank(metaApi.username__c) && String.isNotBlank(metaApi.password__c)){
                req.setHeader('Authorization', authHeader);
            }

            req.setBody(requestBody);
            res = http.send(req);

            mapHeader.put('Authorization',authHeader );
            // we.mapheader = mapHeader;

            if(metaApi.Save_Log__c==true){
                InsertErrorLog(null,req,res,new WrapperError(urlCurrent, classname));
            } 

            InsertErrorLog(null,req,res,new WrapperError(urlCurrent, classname));


        } catch (exception e) {
            InsertErrorLog(null,req,res,new WrapperError(urlCurrent, classname));
        }

        SCC_Wise_API.WrapperAPI resApi = new SCC_Wise_API.WrapperAPI(req,res,urlCurrent);
        return resApi;

    }
}