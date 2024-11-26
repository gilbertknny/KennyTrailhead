@istest
public with sharing class SCC_CaseQueryLegacyAPI_Test {
    @IsTest
    static void testlegacyCaseQueryTrue(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/legacyCaseQuery'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_LegacyCaseAPIWrapper.GetCaseRequestModel rcc = Object_Test.GetCaseRequestModel('');
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_CaseQueryLegacyAPI.GetCase();
        Test.stopTest();
    }

    @IsTest
    static void testlegacyCaseQueryFalse(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/legacyCaseQuery'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_LegacyCaseAPIWrapper.GetCaseRequestModel rcc = Object_Test.GetCaseRequestModel('txt=\'xxx\'');
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_CaseQueryLegacyAPI.GetCase();
        Test.stopTest();
    }
}