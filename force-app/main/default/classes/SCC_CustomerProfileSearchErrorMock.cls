@isTest
public class SCC_CustomerProfileSearchErrorMock implements HttpCalloutMock {
    /**
     * @description HTTPResponse
     * @param req
     * @return HttpResponse res
     */
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake error response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"statusCode":500, "message":"Internal Server Error"}');
        res.setStatusCode(500);
        return res;
    }
}