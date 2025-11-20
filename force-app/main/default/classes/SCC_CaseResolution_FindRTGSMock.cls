/**
* @description       : Find RTGS Mock
* @last modified on  : 16/01/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_CaseResolution_FindRTGSMock {
    public class FindRTGS implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_RTGS.findRTGSResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class FindRTGSFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_RTGS.findRTGSResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}