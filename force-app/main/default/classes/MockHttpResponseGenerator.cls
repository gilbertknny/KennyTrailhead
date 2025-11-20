// Inner class to mock HTTP response
public class MockHttpResponseGenerator implements HttpCalloutMock {
    private String mockResponse;
    private Integer statusCode; // Added status code property
    
    public MockHttpResponseGenerator(String mockResponse, Integer statusCode) {
        this.mockResponse = mockResponse;
        this.statusCode = statusCode; // Initialize status code
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        res.setStatusCode(statusCode); // Set status code
        return res;
    }
}