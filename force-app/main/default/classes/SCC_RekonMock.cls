@isTest
public with sharing class SCC_RekonMock {
    public class ResponseRekon implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.ResponseRekon()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseBeritaAcaraOpname implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.ResponseBeritaAcaraOpname()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseFlagDataRekon implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.ResponseFlagDataRekon()));
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