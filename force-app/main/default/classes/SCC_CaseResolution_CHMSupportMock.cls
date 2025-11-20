@isTest
public with sharing class SCC_CaseResolution_CHMSupportMock {
    public class InquiryRoleUserCHMResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.InquiryRoleUserCHMResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class TerminalIDResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.TerminalIDResponse('1000')));
            res.setStatusCode(200);
            return res;
        }
    }

    public class TerminalIDListResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.TerminalIDListResponse('1000')));
            res.setStatusCode(200);
            return res;
        }
    }

    public class PaymentResolutionServiceResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.PaymentResolutionServiceResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class GenerateTokenCHMSResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.GenerateTokenCHMSResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class ResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }
}