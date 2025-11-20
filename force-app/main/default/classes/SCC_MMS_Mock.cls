@isTest
global class SCC_MMS_Mock {

    global class ResponseCreateTicketMMSSuccess implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"rc":"00","desc":"Success","msg":"Ticket created successfully","data":{"id_tiket":123456,"id_tiket_bricare":"BRI12345"}}');
            return res;
        }
    }

    global class ResponseCreateTicketMMSError implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"rc":"99","desc":"Error","msg":null,"data":null}');
            return res;
        }
    }
}