@isTest
public with sharing class SCC_DroneCheckManualRecon_Test {
    @isTest
    static void testCheckManualRecon() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/droneCheckManualRecon'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_DroneAPIWrapper.CheckManualReconRequestModel rrm = SCC_Drone_Object_Test.CheckManualReconRequestModel();
        string testbody = json.serialize(rrm);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_DroneCheckManualRecon.GetCaseManualRecon();
        Test.stopTest();
    }

    @isTest
    static void testCheckManualReconFalse() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/droneCheckManualRecon'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_DroneAPIWrapper.CheckManualReconRequestModel rrm = SCC_Drone_Object_Test.CheckManualReconRequestModelFalse();
        string testbody = json.serialize(rrm);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_DroneCheckManualRecon.GetCaseManualRecon();
        Test.stopTest();
    }
    @isTest
    static void testCheckManualReconError() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/droneCheckManualRecons'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        SCC_DroneCheckManualRecon.GetCaseManualRecon();
        Test.stopTest();
    }
}