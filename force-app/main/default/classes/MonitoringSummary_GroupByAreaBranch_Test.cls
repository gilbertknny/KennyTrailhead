@istest
public with sharing class MonitoringSummary_GroupByAreaBranch_Test {
    @IsTest
    static void testGetByAreaBranchQueryTrue(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/MonitoringSummaryQueryByAreaBranch'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        MonitoringSummary_API_Wrapper.GetByAreaRequestModel rcc = Object_Test.GetByAreaBranchRequestModel();
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        MonitoringSummary_GroupByAreaBranch_API.GetByAreaBranch();
        Test.stopTest();
    }

    @IsTest
    static void testGetByAreaBranchQueryFalse(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/MonitoringSummaryQueryByAreaBranch'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        MonitoringSummary_API_Wrapper.GetByAreaRequestModel rcc = Object_Test.GetByAreaBranchRequestModel();
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        MonitoringSummary_GroupByAreaBranch_API.GetByAreaBranch();
        Test.stopTest();
    }
}