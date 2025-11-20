public with sharing class SCC_MMSFile {
    public class UploadRequest {
        @InvocableVariable(required=true)
        public List<String> lcvid;

        @InvocableVariable(required=true)
        public List<String> lcdid;

        @InvocableVariable(required=true)
        public String recId; 
    }

    public class UploadResponse {
        @InvocableVariable
        public String response; 
    }

    @InvocableMethod(label='Upload File to MMS')
    public static List<SCC_MMSFile.UploadResponse> uploadToMMS(List<SCC_MMSFile.UploadRequest> requests) {
        List<SCC_MMSFile.UploadResponse> responses = new List<SCC_MMSFile.UploadResponse>();
        
        for (SCC_MMSFile.UploadRequest req : requests) {
            System.debug('lcvid ' + req.lcvid);
            System.debug('lcdid ' + req.lcdid);
            System.debug('recId ' + req.recId); 
            
            List<ContentVersion> licv = [SELECT Id, ContentDocumentId, FileType, PathOnClient, VersionData 
                                       FROM ContentVersion 
                                       WHERE Id IN :req.lcvid 
                                       AND ContentDocumentId IN :req.lcdid];
            
            System.debug('licv ' + licv);
            
            for (ContentVersion cv : licv) {
                System.debug('filetype ' + cv.FileType);
                String resf = UploadtoMMS(cv, req.recId); 
                SCC_MMSFile.UploadResponse res = new SCC_MMSFile.UploadResponse();
                res.response = resf; 
                responses.add(res);
            }
        }
        
        return responses;
    }

    public static String UploadtoMMS(ContentVersion cv, String recId) {
        String responseBody = ''; 
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String url_current = URL.getCurrentRequestUrl().toString().replace('Url:[delegate=','').substringBeforeLast(']');
        String classname = 'SCC_MMSFile';

        try {
            SCC_Endpoint_API__mdt metaApi = SCC_Endpoint_API__mdt.getInstance('MMS_Upload');
            String endpoint = metaApi.Named_Credential__c + metaApi.Directory__c;
            req.setEndpoint(endpoint);
            req.setMethod(metaApi.Method__c);
            req.setTimeout(Integer.valueOf(metaApi.Timeout__c));
            
            req.setHeader('Content-Type', SCC_MMSWebserviceHelper.GetContentType());
            // req.setHeader('ApiKey', metaApi.ApiKey__c);
            req.setHeader('ACCEPT', '*/*');
            
            Blob headerValue = Blob.valueOf(metaApi.Username__c + ':' + metaApi.Password__c);
            String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
            req.setHeader('Authorization', authHeader);

            String jsonBody = SCC_MMSWebserviceHelper.CreateJsonBody(
                recId,
                // metaApi.ObjectType__c,
                cv.PathOnClient,
                cv.VersionData
            );
            
            req.setBody(jsonBody);
            res = http.send(req);
            responseBody = res.getBody();

            if (metaApi.Save_Log__c == true) {
                insertErrorLog(null, req, res, new WrapperError(url_current, classname));
            }
            
        } catch (Exception e) {
            insertErrorLog(e, req, res, new WrapperError(url_current, classname));
            responseBody = 'ERROR : ' + e.getMessage();
        }

        return responseBody; 
    }

    public static void insertErrorLog(Exception exc, HttpRequest req, HttpResponse res, WrapperError we) {
        Map<String, String> maphdr = new Map<String, String>();
        maphdr.put('correlationID', res?.getHeader('correlationID'));
        if (res?.getHeaderKeys() != null) {
            for (String str : res.getHeaderKeys()) {
                maphdr.put(str, res.getHeader(str));
            }
        }
        
        String bd = req?.getBody();
        if(bd != null && bd.length() > 130000){
            bd = bd.substring(0, 130000);
        }
        
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = String.valueOf(exc?.getLineNumber());
        dl.errorcause = String.valueOf(exc?.getCause());
        dl.classname = we.cls_name;
        dl.body = bd;
        dl.iprequest = we.url_current;
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

    public class WrapperError {
        public String url_current { get; set; }
        public String cls_name { get; set; }
        
        public WrapperError(String url_current, String cls_name) {
            this.url_current = url_current;
            this.cls_name = cls_name;
        }
    }
}