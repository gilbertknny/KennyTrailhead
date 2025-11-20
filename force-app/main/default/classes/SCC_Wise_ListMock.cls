@isTest
public with sharing class SCC_Wise_ListMock {

    public class ResponseWorkingInstruction implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responseWi()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseProduk implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responseProduk()));
            return res;
        }
    }

    public class ResponseProgram implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responseProgram()));
            return res;
        }
    }

    public class ResponsePromo implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application-bribrain/json;charset=utf-8');
            res.setBody(JSON.serialize(Object_Test_Wise.responsePromo()));
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