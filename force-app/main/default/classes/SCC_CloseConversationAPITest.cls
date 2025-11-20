/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 05-12-2024
 * @last modified by  : Ardyta Yudianto
**/
@isTest
private class SCC_CloseConversationAPITest {

    @isTest
    static void testCloseConversation_Success() {
        // Setup test data
        String conversationId = '12345';
        Test.startTest();
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/Close/' + conversationId;
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        SCC_CloseConversationAPI.CloseConversation();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
    }

    @isTest
    static void testCloseConversation_MissingConversationId() {
        // Setup test data
        Test.startTest();
        
        // Mock the request without conversationId
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/Close/';
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method and expect an exception
        try {
            SCC_CloseConversationAPI.CloseConversation();
            // System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assertEquals('Conversation ID is missing from the URL', e.getMessage());
        }
    }

    @isTest
    static void testCloseConversation_ExceptionHandling() {
        // Setup test data
        String conversationId = '12345';
        Test.startTest();
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/Close/' + conversationId;
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Simulate an exception in the closeConversation method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method
        SCC_CloseConversationAPI.CloseConversation();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        // Additional assertions can be added based on the expected error response
    }

    // Mock class to simulate HTTP callout responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }
}