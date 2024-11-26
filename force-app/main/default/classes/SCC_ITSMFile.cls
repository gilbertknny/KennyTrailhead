public with sharing class SCC_ITSMFile {

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

    @InvocableMethod(label='Upload File to ITSM')
    public static List<SCC_ITSMFile.UploadResponse> uploadToITSM(List<SCC_ITSMFile.UploadRequest> requests) {
        List<SCC_ITSMFile.UploadResponse> responses = new List<SCC_ITSMFile.UploadResponse>();
        
        for (SCC_ITSMFile.UploadRequest req : requests) {
            System.debug('lcvid ' + req.lcvid);
            System.debug('lcdid ' + req.lcdid);
            System.debug('recId ' + req.recId); 
            List<ContentVersion> licv = [SELECT Id, ContentDocumentId, FileType, PathOnClient, VersionData FROM ContentVersion WHERE Id IN :req.lcvid AND ContentDocumentId IN :req.lcdid];
            System.debug('licv ' + licv);
            for (ContentVersion cv : licv) {
                System.debug('filetype ' + cv.FileType);
                SCC_Mime__mdt mm = SCC_Mime__mdt.getInstance(cv.FileType.toLowerCase());

                String contentType = SCC_ITSMWebserviceHelper.GetContentType();

                String resf = UploadtoITSM(cv.Id, contentType, req.recId); 
                SCC_ITSMFile.UploadResponse res = new SCC_ITSMFile.UploadResponse();
                res.response = resf; 
                responses.add(res);
            }
        }
        
        return responses;
    }

    public static String UploadtoITSM(String converid, String ctype, String recId) {
        String responseBody = ''; 
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String url_current = URL.getCurrentRequestUrl().toString().replace('Url:[delegate=','').substringBeforeLast(']');
        String classname = 'SCC_ITSMFile';
        String form64 = '';

        try {
            SCC_Endpoint_API__mdt metaApi = SCC_Endpoint_API__mdt.getInstance('ITSM_Upload');
            
            String endpoint = metaApi.Named_Credential__c + metaApi.Directory__c;
            // req.setEndpoint('https://putsreq.com/ayY3D0Vyk5zmPf7kNMVQ');
            req.setEndpoint(endpoint);
            req.setMethod(metaApi.Method__c);
            req.setTimeout(Integer.valueOf(metaApi.Timeout__c));
            req.setHeader('Content-Type', SCC_ITSMWebserviceHelper.GetContentType());
            req.setHeader('ApiKey', metaApi.ApiKey__c);
            req.setHeader('ACCEPT', '*/*');
            Blob headerValue = Blob.valueOf(metaApi.Username__c + ':' + metaApi.Password__c);
            String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
            req.setHeader('Authorization', authHeader);

            ContentVersion cv = [SELECT Id, PathOnClient, VersionData, FileType,FileExtension FROM ContentVersion WHERE Id = :converid LIMIT 1];
            SCC_Mime__mdt mm = SCC_Mime__mdt.getInstance(cv.FileExtension);
            System.debug('content version : ' + cv);
            System.debug('path on client : ' + cv.PathOnClient);
            System.debug('content type : ' + mm.Content_Type__c);
            System.debug('verison data :' + cv.VersionData);
            SCC_ITSMWebserviceHelper.WriteFileResult result = SCC_ITSMWebserviceHelper.WriteFile('', cv.PathOnClient, mm.Content_Type__c, cv.VersionData);
           
            form64 += SCC_ITSMWebserviceHelper.WriteBoundary();
            form64 += SCC_ITSMWebserviceHelper.WriteBodyParameter('ObjectID', recId); 
            form64 += SCC_ITSMWebserviceHelper.WriteBoundary();
            form64 += SCC_ITSMWebserviceHelper.WriteBodyParameter('ObjectType', metaApi.ObjectType__c);
            form64 += SCC_ITSMWebserviceHelper.WriteBoundary();
            form64 += result.Content;
            form64 += SCC_ITSMWebserviceHelper.WriteBoundary(result.EndingType);
            Blob formBlob = EncodingUtil.base64Decode(form64);
            req.setBodyAsBlob(formBlob);
            res = http.send(req);
            responseBody = res.getBody();

            if (metaApi.Save_Log__c == true) {
                insertErrorLog(null, req, res, new WrapperError(url_current, classname));
            }
            
        } catch (Exception e) {
            insertErrorLog(e, req, res, new WrapperError(url_current, classname));
            responseBody = 'ERROR : '+e.getMessage();
        }

        return responseBody; 
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