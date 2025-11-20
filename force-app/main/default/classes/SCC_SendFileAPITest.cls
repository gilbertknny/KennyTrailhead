/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Muh Syafiq Hidayatullah
**/
@isTest
private class SCC_SendFileAPITest {

    @isTest
    static void testSendFile_Success() {
        // Setup test data
        String conversationId = '12345';
        String fileName = 'BRI_Logo.png';
        String fileData = EncodingUtil.base64Encode(Blob.valueOf('This is a test file content.'));

        // Create a mock request body
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile request = prepareTestSendFileRequest();
        Map<String, Object> requestBody = new Map<String, Object>{
            'esDeveloperName' => request.esDeveloperName,
            'fileName' => fileName,
            'messageId' => request.message.id,
            'fileId' => request.message.fileId,
            'text' => request.message.text,
            'inReplyToMessageId' => request.message.inReplyToMessageId,
            'isNewMessagingSession' => request.isNewMessagingSession,
            'language' => request.language,
            'fileData' => fileData
        };

        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/SendFile/' + conversationId;
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Mock the SendFile method to return a successful response
        Test.setMock(HttpCalloutMock.class, new MockSendFileSuccess());

        // Call the method
        Test.startTest();
        SCC_SendFileAPI.SendFile();
        Test.stopTest();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
        // System.assert(Blob.valueOf('{"responseCode":"00","responseMessage":"File sent successfully","conversationId":"12345"}').toString() == RestContext.response.responseBody.toString(), 'Response body should match the expected success response');
    }

    @isTest
    static void testSendFile_MissingConversationId() {
        // Setup test data
        String fileName = 'BRI_Logo.png';
        String fileData = EncodingUtil.base64Encode(Blob.valueOf('This is a test file content.'));

        // Create a mock request body
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile request = prepareTestSendFileRequest();
        Map<String, Object> requestBody = new Map<String, Object>{
            'esDeveloperName' => request.esDeveloperName,
            'fileName' => fileName,
            'messageId' => request.message.id,
            'fileId' => request.message.fileId,
            'text' => request.message.text,
            'inReplyToMessageId' => request.message.inReplyToMessageId,
            'isNewMessagingSession' => request.isNewMessagingSession,
            'language' => request.language,
            'fileData' => fileData
        };

        // Mock the request without conversationId
        RestRequest req = new RestRequest();
        req.requestURI = '';
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendMessageMissingConversationId());

        // Call the method and expect an exception
        Test.startTest();
        try {
            SCC_SendFileAPI.SendFile();
            // System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assertEquals('Conversation ID is missing from the URL', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSendFile_MissingRequestBody() {
        // Setup test data
        String conversationId = '12345';

        // Mock the request without conversationId
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/SendFile/' + conversationId;
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSendMessageMissingRequestBody());

        // Call the method and expect an exception
        Test.startTest();
        try {
            SCC_SendFileAPI.SendFile();
            // System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assertEquals('Request body is empty', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSendFile_ExceptionHandling() {
        // Setup test data
        String conversationId = '12345';
        String fileName = 'BRI_Logo.png';
        String fileData = EncodingUtil.base64Encode(Blob.valueOf('This is a test file content.'));

        // Create a mock request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'esDeveloperName' => 'Sabrina',
            'fileName' => fileName,
            'messageId' => '8ff35018-cf00-4d0a-a7f7-78fb75062256',
            'fileId' => '079c1536-f83e-47f4-99c1-f21681b5fa97',
            'text' => 'Apakah ini logo BRI?',
            'inReplyToMessageId' => '6b7897f5-8705-47e4-b34a-219e7605f8c8',
            'isNewMessagingSession' => true,
            'language' => 'en',
            'fileData' => fileData
        };

        // Mock the request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Conversation/SendFile/' + conversationId;
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Simulate an exception in the SendFile method
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));

        // Call the method
        SCC_SendFileAPI.SendFile();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        // Additional assertions can be added based on the expected error response
    }

    // Mock class to simulate HTTP callout responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    private class MockSendFileSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry> listCE = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
            SCC_MessageInAppAndWeb_Wrapper.ConversationEntry ce = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
            ce.id = 'testId';
            ce.clientTimestamp = 1234567890L;
            listCE.add(ce);

            SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
            customResponse.responseCode = '00';
            customResponse.responseMessage = 'File sent successfully';
            customResponse.conversationId = '12345';
            customResponse.conversationEntries = listCE;
            HttpResponse response = new HttpResponse();
            response.setStatusCode(202);
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
    private static SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile prepareTestSendFileRequest() {
        SCC_MessageInAppAndWeb_Wrapper.MessageForSendFile message = new SCC_MessageInAppAndWeb_Wrapper.MessageForSendFile();
        message.inReplyToMessageId = 'test-inReplyToMessageId';
        message.id = 'test-messageForSendFileId';
        message.fileId = 'test-fileId';
        message.text = 'test-text';
    
        return new SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile(
            'Sabrina',
            message,
            true,
            'Indonesia'
        );
    }
}