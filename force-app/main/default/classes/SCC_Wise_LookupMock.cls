@IsTest
public with sharing class SCC_Wise_LookupMock {
    
    public class ResponseWiLookup implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responseWiLookup()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseProdukLookup implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responseProdukLookup()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseProgramLookup implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responseProgramLookup()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponsePromoLookup implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responsePromoLookup()));
            res.setStatusCode(200);
            return res;
        }
    }


    public class ResponseError implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody('{"data": " ", "status_code": "500", "errors": "Internal Server Error","status_desc":"error desc","message":"error message"}');
            res.setStatusCode(500);
            return res;
        }
    }

}