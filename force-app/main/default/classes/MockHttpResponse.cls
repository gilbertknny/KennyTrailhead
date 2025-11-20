// Mock HTTP response class
public class MockHttpResponse implements HttpCalloutMock {
    // Implementing the respond method
    public HTTPResponse respond(HTTPRequest req) {
        // Creating a new HTTPResponse object
        HttpResponse res = new HttpResponse();
        // Setting status code
        res.setStatusCode(200);
        // Setting response body
        String responseBody = '{"status":"success"}';
        res.setBody(responseBody);
        // Returning the response
        return res;
    }
}