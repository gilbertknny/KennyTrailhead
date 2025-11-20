@isTest
public class SCC_IntegrationUtilityMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('correlationID', '123456789');
        res.setBody('{"statusCode":200, "data":[{"demografi":{"namaSesuaiIdentitas":"Test User"}}]}');
        res.setStatusCode(200);
        return res;
    }
}