/**
* @description       : Brizzi Adjust Deposit Mock
* @last modified on  : 22/01/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_AdjustDeposit_Mock {
    public class AdjustDeposit implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.adjustDepositResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class AdjustDepositFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.adjustDepositResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}