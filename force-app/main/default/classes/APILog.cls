/**
 *  @description APILog
 */
public with sharing class APILog {
    /**
     * @description getResponseAPI
     * @param wr WrapperRequest
     * @return getResponseAPI
     */
    public static WrapperAPI getResponseAPI(WrapperRequest wr){
        wr.ExternalID = UUID.randomUUID().tostring();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        WrapperError we = new WrapperError(urlCurrent,wr.clsName);
        we.recid = wr.recid;
        we.objnm = wr.objnm;
        we.typeApi = 'Outbound';
        try{
            RequestMeta rm = setRequest(wr);
            we.mapheader = rm.maphd;
            we.req = rm.req;
            we.inEndpoint = rm.req.getEndpoint();
            we.StringToSign = rm.StringToSign;
            req = rm.req;
            res = http.send(req);
            we.res = res;
            insertErrorLog(null,we,res.getbody());
        }
        catch(exception exc){
            insertErrorLog(exc,we,res.getbody());
        }
        WrapperAPI wapi = new WrapperAPI(req,res,urlCurrent);
        return wapi;
    }
    /**
     * @description WrapperAPI
     */
	public class WrapperAPI{
        /**
         * @description Bar
         */
        public HttpRequest req {get;set;}
        /**
         * @description Bar
         */
        public HTTPResponse res {get;set;}
        /**
         * @description Bar
         */
        public String urlCurrent {get;set;}
        /**
         * @description WrapperAPI
         * @param req HttpRequest
         * @param res HTTPResponse
         * @param urlCurrent String
         */
        public WrapperAPI(HttpRequest req,HTTPResponse res,String urlCurrent){
            this.req = req;
            this.res = res;
            this.urlCurrent = urlCurrent;
        }
    }
   /**
     * @description Bar
     */
    public class WrapperError{
        /**
         * @description Bar
         */
        public String urlCurrent {get;set;}
        /**
         * @description Bar
         */
        public String clsName {get;set;}
        /**
         * @description Bar
         */
        public String recid {get;set;}
        /**
         * @description Bar
         */
        public String objnm {get;set;}
        /**
         * @description Bar
         */
        public String inEndpoint {get;set;}
        /**
         * @description Bar
         */
        public String typeApi {get;set;}
        /**
         * @description Bar
         */
        public RestRequest requestApi {get;set;}
        /**
         * @description Bar
         */
        public RestResponse respondApi {get;set;}
        /**
         * @description Bar
         */
        public HttpRequest req {get;set;}
        /**
         * @description Bar
         */
        public HttpResponse res {get;set;}
        /**
         * @description Bar
         */
        public map<String,String> mapheader {get;set;}
        /**
         * @description Bar
         */
        public String stringToSign {get;set;}
        /**
         * @description WrapperError
         * @param urlCurrent String
         * @param clsName String
         */
        public WrapperError(String urlCurrent,String clsName){
            this.clsName = clsName;
            this.urlCurrent = urlCurrent;
        }
    }
    /**
     * @description Bar
     */
    public class WrapperRequest{
         /**
         * @description Bar
         */
        public String bodyreq {get;set;}
        /**
         * @description Bar
         */
        public String token {get;set;}
        /**
         * @description Bar
         */
        public String externalID {get;set;}
        /**
         * @description Bar
         */
        public String clsName {get;set;}
        /**
         * @description Bar
         */
        public String metaname {get;set;}
        /**
         * @description Bar
         */
        public String recid {get;set;}
        /**
         * @description Bar
         */
        public String objnm {get;set;}
        /**
         * @description Bar
         */
        public String timestamp {get;set;}
        /**
         * @description Bar
         */
        public Blob bodyblob {get;set;}
    }
   /**
     * @description Bar
     */
    public class RequestMeta{
         /**
         * @description Bar
         */
        public HttpRequest req {get;set;}
         /**
         * @description Bar
         */
        public Endpoint__mdt eapi {get;set;}
         /**
         * @description Bar
         */
        public Map<String,String> maphd {get;set;}
         /**
         * @description Bar
         */
        public String stringToSign {get;set;}
    }
    /**
     * @description Bar
     * @return Bar
     * @param wr WrapperRequest
     */
    public static RequestMeta setRequest(WrapperRequest wr){
        RequestMeta rm = new RequestMeta();
        Map<String,String> maphd = new Map<String,String>();
        HttpRequest req = new HttpRequest();
        Endpoint__mdt eapi = Endpoint__mdt.getInstance(wr.metaname);
        String eh = eapi?.Endpoint_Header__c;
        String cond = 'Endpoint_Header__c=:eh';
        String dpFields = SOQL_SOBJECT.getallfield('Endpoint_Header_List__mdt');
        SOQL_SOBJECT.SOQL_Param sp = new SOQL_SOBJECT.SOQL_Param();
        sp.sobjectName = 'Endpoint_Header_List__mdt';
        sp.condition = cond;
        sp.fields = dpFields;
        String dpquery = SOQL_SOBJECT.SOQL(sp);
        List<Endpoint_Header_List__mdt> listh = (List<Endpoint_Header_List__mdt>) database.query(dpquery);
        TimeZone tz = UserInfo.getTimeZone();
        String tzone = tz.getDisplayName().substring(4,10);
        String timestamp = String.valueOf(system.now()).replace(' ','T')+tzone;
        wr.timestamp = timestamp;
        req.setEndpoint(eapi.Domain__c+eapi.Directory__c);
        req.setMethod(eapi.Method__c);
        req.setTimeout(120000);
        for(Endpoint_Header_List__mdt ehl:listh){
            String val = '';
            if(ehl.Model__c == 'Signature'){
                Blob signature;
                String stringToSign;
                if(ehl.Function__c=='signWithCertificate'){
                    stringToSign = ehl.client_ID__c+'|'+timestamp;
                    signature = APILog2.signWithCertificate(ehl,stringToSign);
                }
                if(ehl.Function__c=='generateMac'){
                    stringToSign = APILog2.stringtoSignMac(eapi, ehl, wr);
                    signature = APILog2.generateMac(ehl,stringToSign);
                }
                rm.stringToSign = stringToSign;
                val = EncodingUtil.base64Encode(signature);
            }
            else {
                val = setval(ehl, wr);
            }
            if(ehl.Additional_Value__c==true){
                val = ehl.Value__c+' '+val;
            }
            req.setHeader(ehl.label__c, val);
            maphd.put(ehl.label__c, val);
        }
        if(wr.bodyblob!=null){
            req.setBodyAsBlob(wr.bodyblob);
        }
        if(String.isNotBlank(wr.bodyreq)){
            req.setBody(wr.bodyreq);
        }
        rm.eapi = eapi;
        rm.req = req;
        rm.maphd = maphd;
        return rm;
    }
   /**
     * @description Bar
     * @param e
     * @param we
     * @param returnJson
     */
	public static void insertErrorLog(Exception e,WrapperError we,String returnJson){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = e?.getMessage();
        dl.trace = e?.getStackTraceString();
        dl.typename = e?.getTypeName();
        dl.linenumber = string.valueOf(e?.getLineNumber()); 
        dl.errorcause = string.valueOf(e?.getCause()); 
        dl.responseBody = returnJson; 
        dl.iduser = UserInfo.getUserId();
        dl.typeApi = we?.typeApi;
        dl.header = String.valueOf(we?.mapheader);
        dl.classname = we.clsName;
        dl.urlEndpoint = we?.inEndpoint;
        dl.objnm = we?.objnm;
        dl.recid = we?.recid;
        if(dl.typeApi=='Inbound'){
            dl.header = String.valueof(we?.requestApi?.headers);
            if(e?.getTypeName()!='System.StringException' && we?.requestApi?.requestBody.size()<=131072){
                dl.body = we?.requestApi?.requestBody?.toString();
            }
            if(we?.requestApi?.requestBody.size()>131072){
                dl.recid = APILog2.generatefile(we?.requestApi?.requestBody);
            }
            dl.iprequest = we?.requestApi?.remoteAddress; 
            dl.statusCode = we?.respondApi?.statusCode;
            dl.responseHeader = String.valueOf(we?.respondApi?.headers);
        }
        if(dl.typeApi=='Outbound'){
            if(e?.getTypeName()!='System.StringException' && we?.req?.getBodyAsBlob().size()<=131072){
                dl.body = we?.req?.getBody();
            }
            if(we?.req?.getBodyAsBlob().size()>131072){
                dl.recid = APILog2.generatefile(we?.req?.getBodyAsBlob());
            }
            if(returnJson.length()>131072){
                dl.recid = APILog2.generatefile(Blob.valueOf(returnJson));
            }
            dl.iprequest = we?.urlCurrent; 
            dl.statusCode = we?.res?.getStatusCode();
            dl.responseStatus = we?.res?.getStatus();
            dl.responseHeader = String.valueOf(we?.res?.getHeaderKeys());
        }
        dl.stringtosign = we?.StringToSign;
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
    /**
     * @description setval
     * @param ehl Endpoint_Header_List__mdt
     * @param wr WrapperRequest
     * @return val
     */
    public static String setval(Endpoint_Header_List__mdt ehl,  WrapperRequest wr){
        String val = '';
        if(ehl.Model__c == 'SessionID'){
            val = userinfo.getSessionID();
        }
        else if(ehl.Model__c == 'Timestamp'){
            val = wr.timestamp;
        }
        else if(ehl.Model__c == 'ExternalID'){
            val = wr.ExternalID;
        }
        else if(ehl.Model__c == 'Token'){
            val = wr.token;
        }
        else{
            val = ehl.Value__c;
        }
        return val;
    }
}