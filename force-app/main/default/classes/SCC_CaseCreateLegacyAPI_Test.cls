@istest
public with sharing class SCC_CaseCreateLegacyAPI_Test {
    @TestSetup
    static void testsetup(){
        SSC_Call_Type__c ct = Object_Test.setCallType('3100');
        insert ct;
    }
    @IsTest
    static void testlegacyCaseCreationTrue(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/legacyCaseCreation'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc = Object_Test.CreateCaseRequestModel('3100', 'Joko', '12365473549978', 'MMS');
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_CaseCreateLegacyAPI.CreateCase();
        Test.stopTest();
    }

    @IsTest
    static void testlegacyCaseCreationFalse1(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/legacyCaseCreation'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc = Object_Test.CreateCaseRequestModel('', '', '', '');
        rcc.TglTransaksi = '1234';
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_CaseCreateLegacyAPI.CreateCase();
        Test.stopTest();
    }

    @IsTest
    static void testlegacyCaseCreationFalse2(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/legacyCaseCreation'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        SCC_CaseCreateLegacyAPI.CreateCase();
        Test.stopTest();
    }

    @IsTest
    static void testlegacyCaseCreationFalse3(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/legacyCaseCreation'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc = Object_Test.CreateCaseRequestModel('3100', 'Joko', '12365473549978', 'MMS');
        string testbody = json.serialize(rcc).toLowerCase();
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_CaseCreateLegacyAPI.CreateCase();
        Test.stopTest();
    }
}