/** @description WebserviceAPI */
@RestResource(urlMapping='/webserviceAPI/*')
global without sharing class WebserviceAPI {
    /** @description ActionData */
	@HttpPost
    global static void actionData() {
        String returnJson = '';
        String meta = '';
        Map<String,Object> output = new Map<String,Object>();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        RequestLog rl;
        Integer statuscode = 200;
        requestApi.addHeader('Content-Type','application/json');
        try{
            meta = requestApi.params.get('meta');
            Endpoint__mdt eapi = Endpoint__mdt.getInstance(meta);
            if(eapi.Integration_Procedure__c == true){
                Map<String,Object> voutput = VlocityMapping.callIP(meta, requestApi?.requestBody?.toString());
                returnJson = JSON.serialize(voutput);
            }
            else if(meta=='SFAWT06_UploadFile'){
                returnJson = requestFile(requestApi,output);
            }
            else if(meta=='SFAWT06_UploadFileSIDIA'){
                returnJson = requestFileSIDIA(requestApi,output);
            }
            else{
                APILog.WrapperRequest wr = setWrapperRequest(requestApi?.requestBody?.toString() , null, meta);
                APILog.WrapperAPI wapi = APILog.getResponseAPI(wr);
                returnJson = wapi.res.getBody();
                statuscode = wapi.res.getStatusCode();
            }
            respondApi.responseBody = Blob.valueOf(returnJson);
            respondApi.statuscode = statuscode;
            rl = new RequestLog(requestApi,respondApi,returnJson);
            InsertErrorLog(null, rl);
        }
        catch(exception exc){
            output = new Map<String,Object>();
            output.put('success', false);
            output.put('message', exc.getMessage());
            respondApi.responseBody = Blob.valueOf(JSON.serialize(output));
            respondApi.statuscode = 400;
            rl = new RequestLog(requestApi,respondApi,returnJson);
            InsertErrorLog(exc, rl);
        }
    }
     /** @description insertErrorLog @param e @param rl */
    public static void insertErrorLog(Exception e, RequestLog rl){
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        APILog.WrapperError we = new APILog.WrapperError('','WebserviceAPI');
        we.inEndpoint = urlCurrent;//requestApi.requestURI; 
        we.requestApi = rl.requestApi;
        we.respondApi = rl.respondApi;
        we.typeApi = 'Inbound';
        APILog.InsertErrorLog(e, we, rl.returnJson);
    }
    /** @description RequestLog */
    public class RequestLog{
        /** @description RequestLog */
        public RestRequest requestApi {get;set;}
        /** @description RequestLog */ 
        public RestResponse respondApi {get;set;}
        /** @description RequestLog */ 
        public String returnJson {get;set;}
        /** @description RequestLog @param a @param b @param c */
        public RequestLog(RestRequest a, RestResponse b, String c){
            this.requestApi = a;
            this.respondApi = b;
            this.returnJson = c;
        }
    }
    /** @description setWrapperRequest @param bd @param bl @param metanm @return wr */
    public static APILog.WrapperRequest setWrapperRequest(String bd,Blob bl,String metanm){
        APILog.WrapperRequest wr = new APILog.WrapperRequest();
        if(String.isNotBlank(bd)){
            wr.bodyreq = bd;
        }
        if(bl!=null){
            wr.bodyblob = bl;
        }
        wr.clsName = 'WebserviceAPI';
        wr.metaname = metanm;
        return wr;
    }
    /** @description setWrapperRequest @param requestApi @param output @return json */
    public static String requestFile(RestRequest requestApi, Map<String,Object> output){
        Integer sizereq = requestApi?.requestBody?.size();
        Id recordId = NULL;
        if(sizereq < 6000000){
            Map<String,Object> mapjson = (Map<String,Object>) JSON.deserializeUntyped(requestApi?.requestBody?.toString());
            insertfile(mapjson);
        }
        else if(sizereq > 6000000 || sizereq <= 6789874){
            ID jobID = System.enqueueJob(new UploadFileQueueable(requestApi?.requestBody));
        }
        if(sizereq <= 6789874){
            output.put('success', true);
            output.put('message', 'Upload Success');
        }
        else{
            output.put('success', false);
            output.put('message', 'Upload Failed');
        }
        return JSON.serialize(output);
    }
    /** @description setWrapperRequest @param requestApi @param output @return json */
    public static String requestFileSIDIA(RestRequest requestApi, Map<String,Object> output){
        Map<String,Object> mapjson2 = new Map<String,Object>();
        RestRequest requestApi2;
        Map<String,Object> mapjson = (Map<String,Object>) JSON.deserializeUntyped(requestApi?.requestBody?.toString());
        mapjson2.put('LinkedEntityId__c',(String) mapjson.get('claim_number'));
        mapjson2.put('Title',(String) mapjson.get('document_name'));
        mapjson2.put('PathOnClient',(String) mapjson.get('document_name') +'.'+ (String) mapjson.get('mime_type'));
        mapjson2.put('VersionData',(String) mapjson.get('file'));
        mapjson2.put('ID_Type__c','OTHER');
        insertfile(mapjson2);
        output.put('success', true);
        output.put('claim_reg_number', (String) mapjson.get('claim_number'));
        return JSON.serialize(output);
    }
    /** @description setWrapperRequest @param mapjson */
    public static void insertfile(Map<String,Object> mapjson){
        Id recordId = NULL;
        String linkedEntityId = (String) mapjson.get('LinkedEntityId__c');
        String fieldtype = (String) mapjson.get('fieldtype__c');
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = (String) mapjson.get('PathOnClient'); // The files name, extension is very important here which will help the file in preview.
        conVer.Title = (String) mapjson.get('Title'); // Display name of the files
        conVer.VersionData = (Blob) EncodingUtil.base64Decode(String.valueOf(mapjson.get('VersionData'))); // converting your binary string to Blog
        conVer.ID_Type__c = (String) mapjson.get('ID_Type__c');
        conVer.SyncFile__c = true;
        if (!Schema.sObjectType.ContentVersion.isCreateable() || UserInfo.getName()=='Lintaswata') {
            insert conVer;
        }
        ContentVersion cv = [SELECT Id,ContentDocumentId,FileExtension, FileType FROM ContentVersion WHERE Id =:conVer?.Id];
        ContentDocumentLink cDe = new ContentDocumentLink();
        if(String.isBlank(fieldtype) || fieldtype=='Salesforce'){
            recordId = linkedEntityId;
        }
        else{
            Upload_File_Mapping__mdt ufm = Upload_File_Mapping__mdt.getInstance(fieldtype);
            SObject sobj = database.query('Select Id from '+String.escapeSingleQuotes(ufm.Object__c)+' where '+String.escapeSingleQuotes(ufm.Field__c)+' = : linkedEntityId');
            recordId = (String) sobj.get('Id');
        }
        cDe.ContentDocumentId = cv.ContentDocumentId;
        cDe.linkedEntityId = recordId; // you can use objectId,GroupId etc
        cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        if (!Schema.sObjectType.ContentDocumentLink.isCreateable() || UserInfo.getName()=='Lintaswata') {
            insert cDe; 
        }  
    }
}