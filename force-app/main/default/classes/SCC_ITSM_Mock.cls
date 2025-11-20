@isTest
public with sharing class SCC_ITSM_Mock {
    
    public class ResponseCreateTicketITSM implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){

            String ser = JSON.serialize(Object_Test_ITSM.responseCreate());
            ser = ser.replaceAll('data_context', '@odata.context');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json'); 
            res.setBody(ser);
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseReopenTicketITSM implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){

            String ser = JSON.serialize(Object_Test_ITSM.responseReopen());
            ser = ser.replaceAll('data_context', '@odata.context');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json'); 
            res.setBody(ser);
            res.setStatusCode(200);
            return res;
        } 
    }

    public class ResponseError implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json'); 
            res.setBody(JSON.serialize(Object_Test_ITSM.responseError()));
            res.setStatusCode(500);
            return res;
        }
    }
}