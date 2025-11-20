@isTest
public with sharing class SCC_BrimoMock {
    public class ResponseInquiryUserBrimo implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setResponseInquiryUserBrimo()));
            res.setStatusCode(200);
            return res;
        }
    }
    public class ResponseInquiryOnboardingBrimo implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setResponseInquiryOnboardingBrimo()));
            res.setStatusCode(200);
            return res;
        }
    }
    public class ResponseDeleteUserBrimo implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setResponseDeleteUserBrimo()));
            res.setStatusCode(200);
            return res;
        }
    }
}