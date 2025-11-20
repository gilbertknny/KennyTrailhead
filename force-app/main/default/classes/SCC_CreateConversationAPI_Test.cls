/**
 * @description       : Test class for SCC_CreateConversationAPI
 * @author            : Christian Vieri
 * @group             : Test
 * @last modified on  : 17-03-2025
**/
@isTest
private class SCC_CreateConversationAPI_Test {
    
    @isTest 
    static void testCreateConversation() {
        // Skip test when running in production to avoid issues with callouts
        if (!Test.isRunningTest()) {
            return;
        }
        
        // Create mock request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Conversation/Create/';
        request.httpMethod = 'POST';
        
        // Create test data for request body
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('customerId', 'TEST123');
        requestMap.put('accountId', '001XXXXXXXXXXXXXXX');
        requestMap.put('messageText', 'Test message');
        
        // Create mock chatbot data
        List<Map<String, Object>> chatbotList = new List<Map<String, Object>>();
        Map<String, Object> chatbot1 = new Map<String, Object>();
        chatbot1.put('sender', 'user');
        chatbot1.put('messageText', 'Hello');
        chatbotList.add(chatbot1);
        
        Map<String, Object> chatbot2 = new Map<String, Object>();
        chatbot2.put('sender', 'bot');
        chatbot2.put('messageText', 'Hi there');
        chatbotList.add(chatbot2);
        
        requestMap.put('chatbot', chatbotList);
        
        // Set the request body
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        
        // Set mock response
        RestResponse response = new RestResponse();
        
        // Set RestContext for testing
        RestContext.request = request;
        RestContext.response = response;
        
        // Create mock for the SCC_MessageInAppAndWeb_Ctrl callout
        Test.startTest();
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method to test
        SCC_CreateConversationAPI.CreateConversation();
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(200, response.statusCode);
        System.assertNotEquals(null, response.responseBody);
    }
    
    // Mock HTTP Callout class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"responseCode":"0000","responseMessage":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testCreateConversationException() {
        // Skip test when running in production to avoid issues with callouts
        if (!Test.isRunningTest()) {
            return;
        }
        
        // Create mock request with invalid data to trigger exception
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Conversation/Create/';
        request.httpMethod = 'POST';
        
        // Set invalid JSON to trigger deserialize exception
        request.requestBody = Blob.valueOf('{"invalid JSON format"}');
        
        // Set mock response
        RestResponse response = new RestResponse();
        
        // Set RestContext for testing
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        
        // Call the method to test
        SCC_CreateConversationAPI.CreateConversation();
        
        Test.stopTest();
        
        // Verify response
        System.assertEquals(200, response.statusCode);
        System.assertNotEquals(null, response.responseBody);
        // The response should contain error information
        String responseStr = response.responseBody.toString();
        System.assert(responseStr.contains('responseCode'));
    }
}