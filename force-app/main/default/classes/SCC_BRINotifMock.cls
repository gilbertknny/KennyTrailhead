@isTest
public with sharing class SCC_BRINotifMock {
    public class WANotifResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.WANotifResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
}