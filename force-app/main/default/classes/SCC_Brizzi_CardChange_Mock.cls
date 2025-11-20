/**
* @description       : Brizzi Card Change Mock
* @last modified on  : 21/01/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_CardChange_Mock {
    public class ChangeCard implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.cardChangeResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ChangeCardFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.cardChangeResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}