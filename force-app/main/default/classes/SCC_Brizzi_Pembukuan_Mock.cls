/**
* @description       : Brizzi Card Inquiry Mock
* @last modified on  : 11/02/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_Pembukuan_Mock {
    public class BrizziMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.brizziPembukuanResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class BrizziMockFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.brizziPembukuanResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}