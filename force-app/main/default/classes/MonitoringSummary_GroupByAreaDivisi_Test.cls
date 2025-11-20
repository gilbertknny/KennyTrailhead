@istest
public with sharing class MonitoringSummary_GroupByAreaDivisi_Test {
    @IsTest
    static void testGetByAreaDivisiQueryTrue(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/MonitoringSummaryQueryByAreaDivisi'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        MonitoringSummary_API_Wrapper.GetByAreaRequestModel rcc = Object_Test.GetByAreaDivisiRequestModel();
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        MonitoringSummary_GroupByAreaDivisi_API.GetByAreaDivisi();
        Test.stopTest();
    }

    @IsTest
    static void testGetByAreaDivisiQueryFalse(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/MonitoringSummaryQueryByAreaDivisi'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        MonitoringSummary_API_Wrapper.GetByAreaRequestModel rcc = Object_Test.GetByAreaDivisiRequestModel();
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        MonitoringSummary_GroupByAreaDivisi_API.GetByAreaDivisi();
        Test.stopTest();
    }
}