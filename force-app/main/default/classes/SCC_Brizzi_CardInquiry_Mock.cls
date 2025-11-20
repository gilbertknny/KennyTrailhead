/**
* @description       : Brizzi Card Inquiry Mock
* @last modified on  : 21/01/2025
* @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_CardInquiry_Mock {
    public class CardInquiry implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.cardInquiryResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardInquiryFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Brizzi.cardInquiryResponseError()));
            res.setStatusCode(200);
            return res;
        }
    }
}