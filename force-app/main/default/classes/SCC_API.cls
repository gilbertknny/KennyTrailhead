public with sharing class SCC_API {
    public static SCC_API.WrapperAPI getResponseAPI(String metaname,String bodyreq,String token,String classname){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        WrapperError we = new WrapperError(urlCurrent,classname);
        RequestMeta rm = setRequest(metaname, bodyreq, token, classname);
        we.mapheader = rm?.mapheader;
        try{
            req = rm.req;
            res = http.send(req);
            if(rm.eapi.Save_Log__c==true){
                insertErrorLog(null,req,res,we);
            }    
        }
        catch(exception exc){
            insertErrorLog(exc,req,res,we);
        }
        SCC_API.WrapperAPI wapi = new SCC_API.WrapperAPI(req,res,urlCurrent);
        return wapi;
    }

    public static SCC_API.WrapperAPI getResponseAPIUI(WrapperRequest wr){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        WrapperError we = new WrapperError(urlCurrent,wr.clsName);
        we.recid = wr.recid;
        we.objnm = wr.objnm;
        we.menu = wr.menu;
        RequestMeta rm = setRequest(wr.metaname, wr.bodyreq, wr.token, wr.clsName);
        we.dest = rm?.eapi?.Destination__c;
        we.sorc = rm?.eapi?.Source_Data__c;
        we.mapheader = rm?.mapheader;
        try{
            req = rm.req;
            res = http.send(req);
            if(rm.eapi.Save_Log__c==true){
                insertErrorLog(null,req,res,we);
            }    
        }
        catch(exception exc){
            insertErrorLog(exc,req,res,we);
        }
        SCC_API.WrapperAPI wapi = new SCC_API.WrapperAPI(req,res,urlCurrent);
        return wapi;
    }
    
    public class WrapperAPI{
        public HttpRequest req {get;set;}
        public HTTPResponse res {get;set;}
        public String urlCurrent {get;set;}
        public WrapperAPI(HttpRequest req,HTTPResponse res,String urlCurrent){
            this.req = req;
            this.res = res;
            this.urlCurrent = urlCurrent;
        }
    }

    public class WrapperError{
        public String urlCurrent {get;set;}
        public String clsName {get;set;}
        public String recid {get;set;}
        public String objnm {get;set;}
        public String menu {get;set;}
        public String sorc {get;set;}
        public String dest {get;set;}
        public String inEndpoint {get;set;}
        public RestRequest requestApi {get;set;}
        public RestResponse respondApi {get;set;}
        public map<String,String> mapheader {get;set;}
        public WrapperError(String urlCurrent,String clsName){
            this.clsName = clsName;
            this.urlCurrent = urlCurrent;
        }
    }

    public class WrapperRequest{
        public String bodyreq {get;set;}
        public String token {get;set;}
        public String metaname {get;set;}
        public String clsName {get;set;}
        public String recid {get;set;}
        public String objnm {get;set;}
        public String menu {get;set;}
    }

    public class RequestMeta{
        public HttpRequest req {get;set;}
        public SCC_Endpoint_API__mdt eapi {get;set;}
        public map<String,String> mapheader {get;set;}
    }

    public static RequestMeta setRequest(String metaname,String bodyreq,String token,String classname){
        RequestMeta rm = new RequestMeta();
        HttpRequest req = new HttpRequest();
        SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance(metaname);
        map<String,String> mapheader = new map<String,String>();
        String authorizationHeader = '';
        String employeeNumber = label.Personal_Number;
        system.debug(eapi.Named_Credential__c);
        system.debug(eapi.Directory__c);
        req.setEndpoint(eapi.Named_Credential__c+eapi.Directory__c);
        req.setMethod(eapi.Method__c);
        req.setTimeout(integer.valueOf(eapi.Timeout__c));
        req.setHeader('Content-Type', 'application/json');
        if(String.isNotBlank(token)){
            req.setHeader('CHMS-Token', token);
            mapheader.put('CHMS-Token',token);
        }
        if(String.isNotBlank(eapi.app_name__c)){
            req.setHeader('appname', eapi.app_name__c);
            mapheader.put('appname',eapi.app_name__c);
        }
        if(String.isNotBlank(eapi.x_hasura_admin_secret__c)){
            req.setHeader('x-hasura-admin-secret', eapi.x_hasura_admin_secret__c);
            mapheader.put('x-hasura-admin-secret', eapi.x_hasura_admin_secret__c);
        }
        if(String.isNotBlank(eapi.X_DATAHUB_CHANNEL__c)){
            req.setHeader('X-DATAHUB-CHANNEL', eapi.X_DATAHUB_CHANNEL__c);
            mapheader.put('X-DATAHUB-CHANNEL', eapi.X_DATAHUB_CHANNEL__c);
        }
        if(eapi.X_DATAHUB_PERSONAL_NUMBER__c){
            User us = [SELECT Id, EmployeeNumber FROM User where id =:UserInfo.getUserId()];
            if(String.isNotBlank(us.EmployeeNumber)){
                employeeNumber = us.EmployeeNumber;
            } 
            req.setHeader('X-DATAHUB-PERSONAL-NUMBER', employeeNumber);
            mapheader.put('X-DATAHUB-PERSONAL-NUMBER', employeeNumber);
        }
        if(String.isNotBlank(eapi.X_DATAHUB_USER__c)){
            req.setHeader('X-DATAHUB-USER', eapi.X_DATAHUB_USER__c);
            mapheader.put('X-DATAHUB-USER', eapi.X_DATAHUB_USER__c);
        }
        if(String.isNotBlank(eapi.X_DATAHUB_PORTOFOLIO_ALL__c)){
            req.setHeader('X-DATAHUB-PORTOFOLIO-ALL', eapi.X_DATAHUB_PORTOFOLIO_ALL__c);
            mapheader.put('X-DATAHUB-PORTOFOLIO-ALL', eapi.X_DATAHUB_PORTOFOLIO_ALL__c);
        }
        if(String.isnotblank(eapi.ApiKey__c)){
            req.setHeader('ApiKey', eapi.ApiKey__c);
            mapheader.put('ApiKey', eapi.ApiKey__c);
        }
        if(String.isnotblank(eapi.X_ChannelId__c)){
            req.setHeader('X-ChannelId', eapi.X_ChannelId__c);
            mapheader.put('X-ChannelId', eapi.X_ChannelId__c);
        }
        if(String.isnotblank(eapi.X_ApiKey__c)){
            req.setHeader('X-ApiKey', eapi.X_ApiKey__c);
            mapheader.put('X-ApiKey', eapi.X_ApiKey__c);
        }
        if(String.isnotblank(eapi.X_ReffNumber__c)){
            req.setHeader('X-ReffNumber', eapi.X_ReffNumber__c);
            mapheader.put('X-ReffNumber', eapi.X_ReffNumber__c);
        }
        req.setBody(bodyreq);
        rm.eapi = eapi;
        rm.req = req;
        rm.mapheader = mapheader;
        return rm;
    }

    public static void insertErrorLog(Exception exc,HttpRequest req,HTTPResponse res,WrapperError we){
        Map<String,String> maphdr = new Map<String,String>();
        maphdr.put('correlationID',res.getHeader('correlationID'));
        if(res?.getHeaderKeys()!=null){
            for(String str:res?.getHeaderKeys()){
                maphdr.put(str,res.getHeader(str));
            }
        }
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.header = JSON.serialize(we.mapheader);
        dl.body = req?.getBody();
        dl.responseStatus = res?.getStatus();
        dl.statusCode = res?.getStatusCode(); 
        dl.responseHeader = JSON.serialize(maphdr);
        dl.responseBody = res?.getBody();
        dl.responseStatus = res?.getStatus();
        dl.urlEndpoint = req?.getEndpoint(); 
        dl.typeApi = 'Outbound';
        dl.iduser = UserInfo.getUserId();
        dl.classname = we.clsName;
        dl.iprequest = we?.urlCurrent;
        dl.menu = we?.menu;
        dl.recid = we?.recid;
        dl.objnm = we?.objnm;
        dl.sorc = we?.sorc;
        dl.dest = we?.dest;
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }

    public static void insertErrorLogInbound(Exception e,WrapperError we,String returnJson){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = e?.getMessage();
        dl.trace = e?.getStackTraceString();
        dl.typename = e?.getTypeName();
        dl.linenumber = string.valueOf(e?.getLineNumber()); 
        dl.errorcause = string.valueOf(e?.getCause()); 
        dl.header = String.valueof(we?.requestApi?.headers);
        dl.responseBody = returnJson; 
        dl.typeApi = 'Inbound';
        dl.iduser = UserInfo.getUserId();
        dl.body = we?.requestApi?.requestBody?.toString();
        dl.iprequest = we?.requestApi?.remoteAddress; 
        dl.statusCode = we?.respondApi?.statusCode;
        dl.classname = we.clsName;
        dl.urlEndpoint = we?.inEndpoint;
        dl.sorc = we?.sorc;
        dl.dest = we?.dest;
        dl.menu = we?.menu;
        dl.objnm = we?.objnm;
        dl.recid = we?.recid;
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
}