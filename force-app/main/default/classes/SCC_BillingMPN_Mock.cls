/**
* @description       : Billing MPN Mock
* @last modified on  : 21/01/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_BillingMPN_Mock {
    public class BillingMPN implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_MPN.billingMPNResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class BillingMPNFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_MPN.billingMPNResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}