@istest
public with sharing class SCC_CaseResolution_EJOLMock {
    public class EJOL implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.EJLogResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class EJOLFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.EJLogResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}