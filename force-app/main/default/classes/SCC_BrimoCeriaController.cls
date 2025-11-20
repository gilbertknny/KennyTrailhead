/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : Ardyta Yudianto
**/
public without sharing class SCC_BrimoCeriaController {
    public static SCC_BrimoCeriaWrapper.InsertFileResponseModel setResponseFile(SCC_BrimoCeriaWrapper.InsertFileRequestModel jreq) {
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = jreq.PathOnClient; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = jreq.Title; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(jreq.versionData); // converting your binary string to Blob
        insert conVer;

        ContentVersion cv = [SELECT Id, ContentDocumentId, FileExtension, FileType FROM ContentVersion WHERE Id = :conVer.Id];
        SCC_MIME__mdt mime = SCC_MIME__mdt.getInstance(cv.FileExtension);
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = cv.ContentDocumentId;
        cDe.LinkedEntityId = jreq.LinkedEntityId; // you can use objectId, GroupId etc
        cDe.ShareType = 'V'; // Inferred permission
        cDe.Visibility = 'AllUsers';
        insert cDe;

        ContentDistribution cd = new ContentDistribution();
        cd.Name = jreq.Title + ' public';
        cd.ContentVersionId = conVer.id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;

        ContentDistribution cdb = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.id];
        String urlconv = cdb.DistributionPublicUrl;
        String token = urlconv.substringAfterLast('/');
        String urlreplace = urlconv.replace('/' + token, '');
        String idrr = urlreplace.substringAfterLast('/');
        String urldepan = urlconv.substringBefore('/sfc');
        String urldepan1 = urldepan.replace('.my.salesforce.com', '.file.force.com');
        String urldl = urldepan + '/sfc/dist/version/download/?oid=' + UserInfo.getOrganizationId() + '&filename=' + jreq.PathOnClient + '&ids=' + cv.id + '&d=%2Fa%2F' + idrr + '%2F' + token + '&ctype=' + mime.Content_Type__c;
        String urlvw = urldepan1 + '/sfc/dist/version/renditionDownload/' + jreq.PathOnClient + '?rendition=ORIGINAL_' + cv.FileExtension + '&versionId=' + cv.id + '&d=%2Fa%2F' + idrr + '%2F' + token + '&oid=' + UserInfo.getOrganizationId() + '&ctype=' + mime.Content_Type__c;

        SCC_BrimoCeriaWrapper.InsertFileResponseModel jres = new SCC_BrimoCeriaWrapper.InsertFileResponseModel();
        SCC_Custom_API_Response_Code__mdt rc = SCC_Custom_API_Response_Code__mdt.getInstance('Success');
        jres.url = urldl;
        jres.responseCode = rc.Response_Code__c;
        jres.responseMessage = rc.masterlabel;
        return jres;
    }

    public static void insertErrorLog(Exception e, ErrorLog el) {
        SCC_API.WrapperError we = new SCC_API.WrapperError('', el?.classname);
        we.inEndpoint = el?.url; 
        we.requestApi = el?.requestApi;
        we.respondApi = el?.respondApi;
        we.clsName = el?.classname;
        we.dest = 'CHM';
        we.sorc = 'RPA';
        SCC_API.InsertErrorLogInbound(e, we, el.returnJson);
    }

    public class ErrorLog {
        public RestRequest requestApi { get; set; }
        public RestResponse respondApi { get; set; }
        public String returnJson { get; set; }
        public String classname { get; set; }
        public String url { get; set; }
    }
}