/**
* @description       : Brizzi Card Inquiry Mock
* @last modified on  : 21/01/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_TrxHistory_Mock {
    public class TrxHistory implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.trxHistoryResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class TrxHistoryFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.trxHistoryResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}