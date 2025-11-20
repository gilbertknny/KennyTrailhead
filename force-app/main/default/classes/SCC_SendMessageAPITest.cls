/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Muh Syafiq Hidayatullah
**/
@isTest
private class SCC_SendMessageAPITest {

    @isTest
    static void testSendMessage_Success() {
        // Setup test data
        String conversationId = '12345';
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage request = prepareTestRequest();
        String ReqJson = JSON.serialize(request);
        system.debug('INI ADALAH REQJSON: '+ReqJson);
        Test.startTest();
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/Send/' + conversationId;
        req.requestBody = Blob.valueOf(ReqJson);
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendMessage());

        // Call the method
        SCC_SendMessageAPI.SendMessage();
        Test.stopTest();
        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
    }

    @isTest
    static void testSendMessage_MissingConversationId() {
        // Setup test data
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage request = prepareTestRequest();
        String ReqJson = JSON.serialize(request);
        system.debug('INI ADALAH REQJSON: '+ReqJson);
        Test.startTest();
        
        // Mock the request without conversationId
        RestRequest req = new RestRequest();
        req.requestURI = '';
        req.requestBody = Blob.valueOf(ReqJson);
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendMessageMissingConversationId());

        // Call the method and expect an exception
        try {
            SCC_SendMessageAPI.SendMessage();
            // System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assertEquals('Conversation ID is missing from the URL', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSendMessage_EmptyRequestBody() {
        // Setup test data
        String conversationId = '12345';
        Test.startTest();
        
        // Mock the request with an empty body
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/Send/' + conversationId;
        req.requestBody = Blob.valueOf(''); // Empty body
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendMessageMissingRequestBody());

        // Call the method and expect an exception
        try {
            SCC_SendMessageAPI.SendMessage();
            // System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assertEquals('Request body is empty', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSendMessage_ExceptionHandling() {
        // Setup test data
        String conversationId = '12345';
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage request = prepareTestRequest();
        String ReqJson = JSON.serialize(request);
        Test.startTest();
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/Send/' + conversationId;
        req.requestBody = Blob.valueOf(ReqJson);
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Simulate an exception in the SendMessage method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendMessageNotContainsTypeName());

        // Call the method
        SCC_SendMessageAPI.SendMessage();
        Test.stopTest();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        // Additional assertions can be added based on the expected error response
    }

    // Mock class to simulate HTTP callout responses
    private class MockHttpResponseSendMessage implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry> listCE = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
            SCC_MessageInAppAndWeb_Wrapper.ConversationEntry ce = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
            ce.id = 'testId';
            ce.clientTimestamp = 1234567890L;
            listCE.add(ce);

            SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
            customResponse.responseCode = '00';
            customResponse.responseMessage = 'This Conversation has been closed';
            customResponse.conversationId = '12345';
            customResponse.conversationEntries = listCE;
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            String responseBody = JSON.serialize(customResponse);
            response.setBody(responseBody);
            return response;
        }
    }

    private class MockHttpResponseSendMessageNotContainsTypeName implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry> listCE = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
            SCC_MessageInAppAndWeb_Wrapper.ConversationEntry ce = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
            ce.id = 'testId';
            ce.clientTimestamp = 1234567890L;
            listCE.add(ce);

            SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
            customResponse.responseCode = '';
            customResponse.responseMessage = 'This Conversation has been closed';
            customResponse.conversationId = '12345';
            customResponse.conversationEntries = listCE;
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            String responseBody = JSON.serialize(customResponse);
            response.setBody(responseBody);
            return response;
        }
    }

    private class MockHttpResponseSendMessageMissingConversationId implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(400);
            res.setBody('{"message": "Conversation ID is missing from the URL"}');
            return res;
        }
    }

    private class MockHttpResponseSendMessageMissingRequestBody implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(400);
            res.setBody('{"message": "RequestBody is missing"}');
            return res;
        }
    }

    // Separate method to prepare test request data
    private static SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage prepareTestRequest() {
        //  Buat StaticContent
        SCC_MessageInAppAndWeb_Wrapper.StaticContent staticContent = new SCC_MessageInAppAndWeb_Wrapper.StaticContent();
        staticContent.formatType = 'test-format-type';
        staticContent.text = 'test-text';
    
        //  Buat Message dan hubungkan dengan StaticContent
        SCC_MessageInAppAndWeb_Wrapper.Message message = new SCC_MessageInAppAndWeb_Wrapper.Message();
        message.inReplyToMessageId = 'test-inReplyToMessageId';
        message.id = 'test-messageId';
        message.messageType = 'test-messageType';
        message.staticContent = staticContent;
    
        //  Return objek RequestModelSendMessage
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage requestModel = new SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage();
        
        requestModel.esDeveloperName = 'Sabrina';
        requestModel.message = message;
        requestModel.isNewMessagingSession = true;
        requestModel.language = 'Indonesia';
    
        return requestModel;
    }
}