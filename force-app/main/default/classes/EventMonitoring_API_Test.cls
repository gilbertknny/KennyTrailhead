@IsTest
private class EventMonitoring_API_Test {
    
    @TestSetup
    static void setupTestData() {
    }

    public class MockCustomMetadata {
        public String masterLabel;
        public String responseCode;  
    
        public MockCustomMetadata(String label, String code) {
            this.masterLabel = label;
            this.responseCode = code;  
        }
    }

    // Method to set up mock custom metadata
    private static Map<String, MockCustomMetadata> setupMockMetadata() {
        Map<String, MockCustomMetadata> mockMap = new Map<String, MockCustomMetadata>();
        mockMap.put('IllegalArgumentException', new MockCustomMetadata('IllegalArgumentException', '400'));
        mockMap.put('General_Error', new MockCustomMetadata('General_Error', '500'));
        return mockMap;
    }
    
    @IsTest
    static void testGetEventMonitoringSuccess() {
        // Prepare test data
        EventMonitoring_API_Wrapper.GetRequest_Model testRequest = new EventMonitoring_API_Wrapper.GetRequest_Model();
        // Set properties for testRequest
        
        String jsonRequest = JSON.serialize(testRequest);
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        EventMonitoring_API.GetEventMonitoring();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(200, res.statusCode);
        System.assertNotEquals(null, res.responseBody);
        
        // Add more specific assertions based on expected behavior
    }
    
    @IsTest
    static void testGetEventMonitoringExceptionWithKnownType() {
        // Set up mock metadata
        Map<String, MockCustomMetadata> mockMaprc = setupMockMetadata();
        
        // Prepare test data
        EventMonitoring_API_Wrapper.GetRequest_Model testRequest = new EventMonitoring_API_Wrapper.GetRequest_Model();
        // Set properties for testRequest
        
        String jsonRequest = JSON.serialize(testRequest);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        // Mock the exception
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('IllegalArgumentException'));
        EventMonitoring_API.GetEventMonitoring();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        // System.assert(responseBody.contains('"responseCode":"400"')); // Known exception type
        // System.assert(responseBody.contains('"responseMessage":"IllegalArgumentException"'));
    }
    
    @IsTest
    static void testGetEventMonitoringExceptionWithUnknownType() {
        // Set up mock metadata
        Map<String, MockCustomMetadata> mockMaprc = setupMockMetadata();
        
        // Prepare test data
        EventMonitoring_API_Wrapper.GetRequest_Model testRequest = new EventMonitoring_API_Wrapper.GetRequest_Model();
        // Set properties for testRequest
        
        String jsonRequest = JSON.serialize(testRequest);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        // Mock the exception
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('UnknownException'));
        EventMonitoring_API.GetEventMonitoring();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        // System.assert(responseBody.contains('"responseCode":"500"')); // General error code
        // System.assert(responseBody.contains('"responseMessage":"UnknownException"'));
    }
    
    // @IsTest
    // static void testInsertErrorLog() {
    //     Exception testException = new IllegalArgumentException('Test Exception');
    //     RestRequest req = new RestRequest();
    //     RestResponse res = new RestResponse();
    //     String testReturnJson = '{"test": "json"}';
        
    //     Test.startTest();
    //     EventMonitoring_API.InsertErrorLog(testException, req, res, testReturnJson);
    //     Test.stopTest();
    // }

    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private String exceptionType;
        
        public MockHttpResponseGenerator(String exceptionType) {
            this.exceptionType = exceptionType;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            throw new MyCustomException(exceptionType);
        }
    }

    // Custom exception class for testing
    public class MyCustomException extends Exception {}

    // Add these new test methods at the end of your class
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{invalid_json}');
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        EventMonitoring_API.GetEventMonitoring();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('responseCode'));
        System.assert(responseBody.contains('responseMessage'));
        
        Test.stopTest();
    }

    @isTest
    static void testDifferentExceptionTypes() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        // Test case 1: NullPointerException
        req.requestBody = null;
        EventMonitoring_API.GetEventMonitoring();
        
        // Test case 2: JSONException with different message
        req.requestBody = Blob.valueOf('{"malformed": "json"');
        EventMonitoring_API.GetEventMonitoring();
        
        // Test case 3: Custom exception scenario
        req.requestBody = Blob.valueOf('{"startDate": "invalid_date"}');
        EventMonitoring_API.GetEventMonitoring();
        
        Test.stopTest();
    }

    @isTest
    static void testInsertErrorLog() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('test body');
        req.headers.put('Test-Header', 'test value');
        
        RestResponse res = new RestResponse();
        res.statusCode = 400;
        
        Exception testException = new NullPointerException();
        try {
            String s = null;
            s.length();
        } catch (Exception e) {
            testException = e;
        }
        
        Test.startTest();
        EventMonitoring_API.InsertErrorLog(
            testException,
            req,
            res,
            'test return json'
        );
        Test.stopTest();
    }
}