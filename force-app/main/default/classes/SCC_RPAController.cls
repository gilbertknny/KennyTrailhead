/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 18-06-2025
 * @last modified by  : Christian Vieri
**/
public with sharing class SCC_RPAController {
    public static SCC_RPAWrapper.InsertUpdateCaseResponseModel setResponse(String resnm){
        SCC_RPAWrapper.InsertUpdateCaseResponseModel jres = new SCC_RPAWrapper.InsertUpdateCaseResponseModel();
        SCC_Custom_API_Response_Code__mdt rc = SCC_Custom_API_Response_Code__mdt.getInstance(resnm);
        jres.Response = rc.Description__c;
        jres.responseCode = rc.Response_Code__c;
        jres.responseMessage = rc.masterlabel;
        return jres;
    }

    public static Case updateCase(String reqobj){
        Case cs = (Case) JSON.deserialize(reqobj, Case.class);
        system.debug(cs.ownerid);
        system.debug(cs.Returned_Case__c);
        System.debug('=== VALIDATION DEBUG ===');
        System.debug('User: ' + UserInfo.getName());
        System.debug('Has Bypass: ' + FeatureManagement.checkPermission('By_Pass_Validation_for_Migration'));
        System.debug('New Status: ' + cs.Status);
        System.debug('Closure Comments: ' + cs.SCC_Closure_Comments__c);
        if(cs.Id != null) {
            Case existingCase = [SELECT Status, RecordType.Name FROM Case WHERE Id = :cs.Id];
            System.debug('Current Status: ' + existingCase.Status);
            System.debug('Record Type: ' + existingCase.RecordType.Name);
        }
    
        if(cs.Returned_Case__c==true){
            system.debug('queue');
            QueueSobject qs = [SELECT Id, QueueId, SobjectType FROM QueueSobject where sobjecttype ='Case' and queue.developername =: label.Queue_CC_Telesales];
            cs.SCC_Next_Escalation_Level__c = 'SCC_Level1_Escalation_Team__c';
            cs.SCC_Reject_Maker__c = false;
            cs.SCC_Return_Datetime__c = System.now();
            cs.SCC_Returned_Date__c = System.now();
            cs.SCC_Sub_Escalation_Level__c = '';
            cs.Status = 'Working';
            cs.OwnerId = qs.QueueId;
        }
        else{
            system.debug('RPA');
            User us = SCC_RPAController.getRPAUser();
            cs.OwnerId = us.id;
        }
        system.debug(cs.ownerid);
        update cs;
        return cs;
    }

    public static SCC_RPAWrapper.InsertFileResponseModel setResponseFile(SCC_RPAWrapper.InsertFileRequestModel jreq,String type){
        String LinkedEntityId = jreq.LinkedEntityId;
        if(type=='TicketId'){
            Case cs = [select id from case where SCC_Legacy_Ticket_ID__c =: jreq.LinkedEntityId];
            LinkedEntityId = cs.id;
        }
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = jreq.PathOnClient; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = jreq.Title; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(jreq.versionData); // converting your binary string to Blog
        insert conVer;
        ContentVersion cv = [SELECT Id,ContentDocumentId,FileExtension, FileType FROM ContentVersion WHERE Id =:conVer.Id];
        SCC_MIME__mdt mime = SCC_MIME__mdt.getInstance(cv.FileExtension);
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = cv.ContentDocumentId;
        cDe.LinkedEntityId = LinkedEntityId; // you can use objectId,GroupId etc
        cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        ContentDistribution cd = new ContentDistribution();
        cd.Name = jreq.Title+' public';
        cd.ContentVersionId = conVer.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        ContentDistribution cdb = [select DistributionPublicUrl from ContentDistribution where id = :cd.id];
        String urlconv = cdb.DistributionPublicUrl;
        String token = urlconv.substringAfterLast('/');
        String urlreplace = urlconv.replace('/'+token, '');
        String idrr = urlreplace.substringAfterLast('/');
        String urldepan = urlconv.substringBefore('/sfc');
        String urldepan1 = urldepan.replace('.my.salesforce.com','.file.force.com');
        String urldl = urldepan+'/sfc/dist/version/download/?oid='+UserInfo.getOrganizationId()+'&filename='+jreq.PathOnClient+'&ids='+cv.id+'&d=%2Fa%2F'+idrr+'%2F'+token+'&ctype='+mime.Content_Type__c+'';
        String urlvw = urldepan1+'/sfc/dist/version/renditionDownload/'+jreq.PathOnClient+'?rendition=ORIGINAL_'+cv.FileExtension+'&versionId='+cv.id+'&d=%2Fa%2F'+idrr+'%2F'+token+'&oid='+UserInfo.getOrganizationId()+'&ctype='+mime.Content_Type__c+'';
        SCC_RPAWrapper.InsertFileResponseModel jres = new SCC_RPAWrapper.InsertFileResponseModel();
        SCC_Custom_API_Response_Code__mdt rc = SCC_Custom_API_Response_Code__mdt.getInstance('Success');
        jres.url = urldl;
        jres.responseCode = rc.Response_Code__c;
        jres.responseMessage = rc.masterlabel;
        return jres;
    }

    public static SCC_RPAWrapper.GetCaseResponseModelBulk setResponseListCase(SCC_RPAWrapper.GetCaseRequestModelBulk jreq){
        User us = SCC_RPAController.getRPAUser();
        String iduser = us.id;
        String ct = jreq.CaseTypeNumber;
        String mtd = '';
        String sts = 'Escalated';
        String cdd = 'CDD%'; //Queue
        String addfield = ',SCC_Call_Type__r.name';
        String cond = 'SCC_Call_type__r.external_id__c =: ct and status=:sts and (owner.name like :cdd or ownerid=:iduser)';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '50000');
        List<Case> listcs = Database.query(queries);
        if(!listcs.isEmpty()){
            for(Case cs : listcs){
                if(cs.OwnerId != us.id){
                    cs.OwnerId = us.id;
                }
            }
            update listcs;
            mtd = 'Success';
        }
        else{
            mtd = 'Data_Not_Found';
        }
        SCC_RPAWrapper.GetCaseResponseModelBulk jres = new SCC_RPAWrapper.GetCaseResponseModelBulk();
        SCC_Custom_API_Response_Code__mdt rc = SCC_Custom_API_Response_Code__mdt.getInstance(mtd);
        jres.TicketList = listcs;
        jres.responseCode = rc.Response_Code__c;
        jres.responseMessage = rc.masterlabel;
        return jres;
    }

    public static SCC_RPAWrapper.GetCaseResponseModelDetail setResponseDetailCase(SCC_RPAWrapper.GetCaseRequestModelDetail jreq){
        String idcs = jreq.TicketId;
        String mtd = '';
        String addfield = ',SCC_Call_Type__r.name';
        String cond = 'id =: idcs';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '1');
        List<Case> listcs = Database.query(queries);
        Case cs = null;
        if(!listcs.isEmpty()){
            cs = listcs[0];
            mtd = 'Success';
        }
        else{
            mtd = 'Data_Not_Found';
        }
        SCC_RPAWrapper.GetCaseResponseModelDetail jres = new SCC_RPAWrapper.GetCaseResponseModelDetail();
        SCC_Custom_API_Response_Code__mdt rc = SCC_Custom_API_Response_Code__mdt.getInstance(mtd);
        jres.TicketDetail = cs;
        jres.responseCode = rc.Response_Code__c;
        jres.responseMessage = rc.masterlabel;
        return jres;
    }

    public static User getRPAUser(){
        User us = [select id, name, profileid,userroleid from user where name = :label.User_RPA_Name];
        return us;
    }

    public static void insertErrorLog(Exception e,ErrorLog el){
        SCC_API.WrapperError we = new SCC_API.WrapperError('',el?.classname);
        we.inEndpoint = el?.url; 
        we.requestApi = el?.requestApi;
        we.respondApi = el?.respondApi;
        we.clsName = el?.classname;
        we.dest = 'CHM';
        we.sorc = 'RPA';
        SCC_API.InsertErrorLogInbound(e, we, el.returnJson);
    }

    Public class ErrorLog{
        public RestRequest requestApi {get;set;}
        public RestResponse respondApi {get;set;}
        public String returnJson {get;set;}
        public String classname {get;set;}
        public String url {get;set;}
    }
}