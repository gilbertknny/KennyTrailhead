@istest
public without sharing class SCC_RPA_Test {
    @TestSetup
    static void testsetup(){
        SSC_Call_Type__c ct = Object_Test.setCallType('1703');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
    }

    @IsTest
    static void createCase(){
        SSC_Call_Type__c ct = [select id from SSC_Call_Type__c limit 1];
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPACreateTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        Case cs = Object_Test.setCase(ct.id);
        string testbody = json.serialize(cs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPACreateTicket.CreateCase();
        Test.stopTest();
    }
    
    @IsTest
    static void createCaseError(){
        SSC_Call_Type__c ct = [select id from SSC_Call_Type__c limit 1];
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPACreateTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        string testbody = json.serialize(cs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPACreateTicket.CreateCase();
        Test.stopTest();
    }

    @IsTest
    static void updateTicket(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAUpdateTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        cs.scc_remark__c = 'test';
        string testbody = json.serialize(cs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAUpdateTicket.UpdateCase();
        Test.stopTest();
    }

    @IsTest
    static void updateTicket2(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAUpdateTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        cs.Returned_Case__c = true;
        cs.scc_remark__c = 'test';
        string testbody = json.serialize(cs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAUpdateTicket.UpdateCase();
        Test.stopTest();
    }

    @IsTest
    static void updateTicketError(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAUpdateTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        Case cs = new Case();
        cs.scc_remark__c = 'test';
        string testbody = json.serialize(cs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAUpdateTicket.UpdateCase();
        Test.stopTest();
    }

    @IsTest
    static void uploadFile(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAUploadFile'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_RPAWrapper.InsertFileRequestModel fl = new SCC_RPAWrapper.InsertFileRequestModel();
        fl.LinkedEntityId = cs.id;
        fl.PathOnClient = 'file.pdf';
        fl.Title = 'file';
        fl.versionData = Blob.valueOf('xxxx').toString();
        string testbody = json.serialize(fl);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAUploadFile.UploadFile();
        Test.stopTest();
    }

    @IsTest
    static void uploadFileError(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAUploadFile'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_RPAWrapper.InsertFileRequestModel fl = new SCC_RPAWrapper.InsertFileRequestModel();
        fl.LinkedEntityId = 'xxxx';
        fl.PathOnClient = 'file.pdf';
        fl.Title = 'file';
        fl.versionData = 'xxxx';
        string testbody = json.serialize(fl);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAUploadFile.UploadFile();
        Test.stopTest();
    }

    @IsTest
    static void getLisTicket(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAGetListTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        SCC_RPAWrapper.GetCaseRequestModelBulk gcs = new SCC_RPAWrapper.GetCaseRequestModelBulk();
        gcs.CaseTypeNumber = '4703';
        string testbody = json.serialize(gcs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAGetDataList.GetData();
        Test.stopTest();
    }

    @IsTest
    static void getLisTicketError(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAGetListTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAGetDataList.GetData();
        Test.stopTest();
    }

    @IsTest
    static void getDetailTicket(){
        SSC_Call_Type__c ct = Object_Test.setCallType('4703');
        insert ct;
        Case cs = Object_Test.setCase(ct.id);
        insert cs;
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAGetDetailTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_RPAWrapper.GetCaseRequestModelDetail gcs = new SCC_RPAWrapper.GetCaseRequestModelDetail();
        gcs.TicketId = cs.id;
        string testbody = json.serialize(gcs);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAGetDataDetail.GetData();
        Test.stopTest();
    }

    @IsTest
    static void getDetailTicketError(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/RPAGetDetailTicket'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        SCC_RPAGetDataDetail.GetData();
        Test.stopTest();
    }
}