@istest
public with sharing class MonitoringSummary_GroupByDate_API_Test {
    @IsTest
    static void testGetByDateQueryTrue(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/MonitoringSummaryQueryByDate'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        MonitoringSummary_API_Wrapper.GetByDateRequestModel rcc = Object_Test.GetByDateRequestModel();
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        MonitoringSummary_GroupByDate_API.GetByDate();
        Test.stopTest();
    }

    @IsTest
    static void testGetByDateQueryFalse(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/MonitoringSummaryQueryByDate'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        MonitoringSummary_API_Wrapper.GetByDateRequestModel rcc = Object_Test.GetByDateRequestModel();
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        MonitoringSummary_GroupByDate_API.GetByDate();
        Test.stopTest();
    }
}