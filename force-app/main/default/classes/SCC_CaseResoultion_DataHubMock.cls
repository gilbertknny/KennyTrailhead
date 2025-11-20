@isTest
public with sharing class SCC_CaseResoultion_DataHubMock {
    public class CustomerProfileResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CustomerProfileResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class SavingMutationResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.SavingMutationResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class DataMachineResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.DataMachineResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class DataMachineError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
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

    public class CardLinkCardNumberResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardLinkCardNumberResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardLinkPhoneNumberResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardLinkPhoneNumberResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardLinkCustomerNumberResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardLinkCustomerNumberResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardLinkNIKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardLinkNIKResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardLinkError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class BRILinkProfileResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setbriLinkProfileResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class BRILinkProfileError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MerchantProfileResposne implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.MerchantProfileResposne()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class MerchantProfileError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class DPLKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.DPLKResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class DPLKError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardActivityResposnse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardActivityResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardActivityError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse car = Object_Test.CardActivityResponse();
            car.data = null;
            car.statusCode = 400;
            res.setBody(JSON.serialize(car));
            res.setStatusCode(400);
            return res;
        }
    }

    public class PCTDResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.PCTDResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class PCTDError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse car = Object_Test.PCTDResponse();
            car.CPAHF = null;
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(car));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardApplicationResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardApplicationResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardApplicationError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(400);
            return res;
        }
    }

    public class BRIMolaResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.BRIMolaResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class BRIMolaError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(400);
            return res;
        }
    }

    public class CardResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.CardResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class CardError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"error":"expecting a value for non-nullable variable: \"phoneNumber\"","path":"$","code":"validation-failed"}');
            res.setStatusCode(400);
            return res;
        }
    }

    public class TrxMerchantResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.TrxMerchantResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class TrxMerchantError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{"statusCode":404,"errorCode":"030","responseCode":"03","responseMessage":"Data Not Found","errors":["data not found for multiple required objects: demography, portofolio"],"data":null}');
            res.setStatusCode(400);
            return res;
        }
    }

    public class HoldStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.HoldStatusResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class HoldStatusError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse xres =  Object_Test.HoldStatusResponse();
            xres.inquiryHoldStatus = null;
            res.setBody(JSON.serialize(xres));
            res.setStatusCode(400);
            return res;
        }
    }

    public class InquiryIbbizResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setInquiryIbbizResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class InquiryIbbizResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            List<SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponse> lres =  new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponse>{Object_Test2.setInquiryIbbizResponse()};
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(lres));
            res.setStatusCode(400);
            return res;
        }
    }

    public class InquiryBCCMResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setInquiryBCCMResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class InquiryPelacakanCCResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setInquiryPelacakanCCResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class InquiryCeriaResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setInquiryCeriaResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class PengajuanCCResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setPengajuanCCResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class LastTransationResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setLastTransactionResponse()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ReportTransactionBRIVAResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test2.setReportTransactionBRIVAResponse()));
            res.setStatusCode(200);
            return res;
        }
    }
}