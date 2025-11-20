/**
 * @description       : CASA Mock
 * @author            : Femy
 * @group             : 
 * @last modified on  : 
 * @last modified by  : Femy
**/
@isTest
public with sharing class SCC_CASAMock {
    public class ResponseHoldAmount implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setResponseHoldAmount()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseUnholdAmount implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setResponseUnholdAmount()));
            res.setStatusCode(200);
            return res;
        }
    }
}