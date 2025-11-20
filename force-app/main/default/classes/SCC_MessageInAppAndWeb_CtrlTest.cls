/**
 * @description       : TestClass for SCC_MessageInAppAndWeb_Ctrl
 * @author            : 
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Muh Syafiq Hidayatullah
**/
@isTest
private class SCC_MessageInAppAndWeb_CtrlTest {
    
    @isTest
    static void testGetCurrentUserId() {
        Test.startTest();
        String sessionId = SCC_MessageInAppAndWeb_Ctrl.getSession();
        Test.stopTest();
        // Assertion: Pastikan sessionId tidak null atau kosong
        System.assertNotEquals(sessionId, null, 'Session ID should not be null');
        System.assertNotEquals(sessionId, '', 'Session ID should not be empty');

        // Debug untuk melihat hasil
        System.debug('Session ID: ' + sessionId);    
    }

    @IsTest
    static void testGetAccessToken() {
        // Setup Mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetAccessToken());

        Test.startTest();
        // Call the method
        String getToken = SCC_MessageInAppAndWeb_Ctrl.GetAccessToken();
        Test.stopTest();

        // Assertion
        System.assertNotEquals(getToken, null, 'Access Token should not be null');
        System.assertNotEquals(getToken, '', 'Access Token should not be empty');
        System.assertEquals('test-token-12345', getToken, 'Access Token should match expected value');
    }
    private class MockHttpResponseGetAccessToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"accessToken": "test-token-12345"}');
            return response;
        }
    }

    @IsTest
    static void testGetAccessTokenFailed() {
        // Setup Mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetAccessTokenFailed());
        
        Test.startTest();
        try {
            // Call the method
            String getToken = SCC_MessageInAppAndWeb_Ctrl.GetAccessToken();
            System.assert(false, 'Expected an exception to be thrown, but it was not.');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Failed to obtain access token'), 'Exception message should indicate failure to obtain token');
        }
        Test.stopTest();
    }
    private class MockHttpResponseGetAccessTokenFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"error": "Invalid request"}');
            return response;
        }
    }

    @isTest
    static void testGetAccessTokenException() {
        // Setup Mock
        Test.setMock(HttpCalloutMock.class, new ExceptionMockHttpResponseGetAccessToken());
        
        // Act & Assert
        Test.startTest();
        try {
            String getToken = SCC_MessageInAppAndWeb_Ctrl.GetAccessToken();
            System.assert(false, 'Expected an exception to be thrown, but it was not.');
        } catch (CalloutException e) {
            // Verify the exception is properly caught and re-thrown
            System.assert(e.getMessage().contains('Simulated exception'), 'The original exception message should be propagated');
        }
        Test.stopTest();
    }
    
    private class ExceptionMockHttpResponseGetAccessToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            throw new CalloutException('Simulated exception during HTTP callout');
        }
    }

    @IsTest
    static void testGetConversationIdFromUrl() {
        // Setup Data
        String requestUri = 'ini/adalah/contoh/requestUri';

        Test.startTest();
        // Call the method to test
        String getIdFromUri = SCC_MessageInAppAndWeb_Ctrl.getConversationIdFromUrl(requestUri);
        Test.stopTest();

        // Assertion
        System.assertEquals('requestUri', getIdFromUri, 'Should return "requestUri"');
    }

    @IsTest
    static void testGetConversationIdFromUrlNull() {
        // Setup Data
        String requestUri = '/';

        Test.startTest();
        // Call the method to test
        String getIdFromUri = SCC_MessageInAppAndWeb_Ctrl.getConversationIdFromUrl(requestUri);
        Test.stopTest();

        // Assertion
        System.assertEquals(null, getIdFromUri, 'Should return empty string');
    }

    @isTest
    static void testGetConversationIdFromUrlEmpty() {
        // Arrange
        String requestUri = '';
        
        // Call the method to test
        Test.startTest();
        String getIdFromUri = SCC_MessageInAppAndWeb_Ctrl.getConversationIdFromUrl(requestUri);
        Test.stopTest();
        
        // Assert
        System.assertEquals('', getIdFromUri, 'Should return null for an empty string');
    }

    @isTest
    static void testGetConversationIdFromUrl_WithQueryParams() {
        // Arrange
        String requestUri = 'https://example.com/path/to/0dwMR000001jjziYAA?param1=value1&param2=value2';
        
        // Call the method to test
        Test.startTest();
        String getIdFromUri = SCC_MessageInAppAndWeb_Ctrl.getConversationIdFromUrl(requestUri);
        Test.stopTest();
        
        // Assert
        System.assertEquals('0dwMR000001jjziYAA?param1=value1&param2=value2', getIdFromUri, 'Should include query parameters in the extracted ID');
    }

    @IsTest
    static void testCreateConversationCallout() {
        // Setup Data
        String chatbotConversation = 'chatBotConversation';
        SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation request = prepareTestRequest();
        // Setup Mock
        Test.setMock(HttpCalloutMock.class, new CombinedMockHttpCallout());
        Test.startTest();
        // Call the method
        String response;
        try {
            // Assertion
            response = SCC_MessageInAppAndWeb_Ctrl.CreateConversationCallout(request, chatbotConversation);
            System.assertNotEquals(null, response, 'Response tidak boleh null.');
            System.assert(response.contains('"responseCode":"00"'), 'Response harus mengandung responseCode 00.');
            System.assert(response.contains('"conversationId":"12345"'), 'Response harus berisi conversationId yang valid.');
            System.assert(response.contains('"responseMessage":"Conversation created successfully with ID"'), 'Response harus berisi pesan sukses.');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Failed to create conversation'), 'Exception harus berisi pesan gagal.');
        }
        Test.stopTest();
    }
    // Separate method to prepare test request data
    private static SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation prepareTestRequest() {
        
        Map<String, String> routingAttribute = new Map<String, String>{
            'priority' => 'high',
            'channel' => 'whatsapp',
            'phone' => '6238493'
        };

        return new SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation(
            '12345',                            // conversationId
            routingAttribute,                   // routingAttributes
            'Sabrina'                           // esDeveloperName
        );
    }

    private class CombinedMockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            String endpoint = request.getEndpoint().toLowerCase();
            
            // Debug the actual endpoint being called
            System.debug('Mock received request for endpoint: ' + request.getEndpoint());
            System.debug('Request method: ' + request.getMethod());
            
            // More flexible matching for access token endpoints
            if (endpoint.contains('acess_token') || endpoint.contains('get_acess') || 
                endpoint.contains('sabrina_get') || endpoint.contains('token')) {
                // Mock response for getting access token - notice we return 200 for this
                response.setStatusCode(200);
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"accessToken": "test-token-12345"}');
                System.debug('Mock returning access token response');
            } 
            // More flexible matching for conversation creation
            else if (endpoint.contains('create_conversation') || endpoint.contains('sabrina_create')) {
                // Mock response for creating conversation
                response.setStatusCode(201);
                response.setHeader('Content-Type', 'application/json');
                
                List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry> listCE = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
                SCC_MessageInAppAndWeb_Wrapper.ConversationEntry ce = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
                ce.id = 'testId';
                ce.clientTimestamp = 1234567890L;
                listCE.add(ce);

                SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
                customResponse.responseCode = '00';
                customResponse.responseMessage = 'Conversation created successfully with ID';
                customResponse.conversationId = '12345';
                customResponse.conversationEntries = listCE;
                
                response.setBody(JSON.serialize(customResponse));
                System.debug('Mock returning conversation creation response');
            }
            else {
                // If we get here, log it clearly for debugging
                System.debug('ERROR: Mock received unrecognized endpoint: ' + endpoint);
                response.setStatusCode(404);
                response.setBody('{"error": "Unsupported endpoint in test mock: ' + endpoint + '"}');
            }
            
            return response;
        }
    }

    @IsTest(SeeALLData=True)
    static void testSendMessage_Success() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage request = prepareTestSendMessageRequest();
        // Setup Mock Callout
        Test.setMock(HttpCalloutMock.class, new MockSendMessageSuccess());
        Test.startTest();
        // Call the method
        String response;
        try {
            // Assertions jika tidak ada exception
            response = SCC_MessageInAppAndWeb_Ctrl.SendMessage(request, ci);
            System.assertNotEquals(null, response, 'Response tidak boleh null.');
            System.assert(response.contains('"responseCode":"00"'), 'Response harus mengandung responseCode 00.');
            // System.assert(response.contains('"conversationId":"12345"'), 'Response harus berisi conversationId yang valid.');
            System.assert(response.contains('"responseMessage":"Message sent successfully"'), 'Response harus berisi pesan sukses.');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Failed to create conversation'), 'Exception harus berisi pesan gagal.');
        } 
        Test.stopTest();
    }
    // Separate method to prepare test request data
    private static SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage prepareTestSendMessageRequest() {
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
    private class MockSendMessageSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry> listCE = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
            SCC_MessageInAppAndWeb_Wrapper.ConversationEntry ce = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
            ce.id = 'testId';
            ce.clientTimestamp = 1234567890L;
            listCE.add(ce);

            SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
            customResponse.responseCode = '00';
            customResponse.responseMessage = 'Message sent successfully';
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

    @IsTest(SeeALLData=True)
    static void testSendMessage_Failed() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage request = prepareTestSendMessageRequest();
        // Setup Mock Callout
        Test.setMock(HttpCalloutMock.class, new MockSendMessageFailed());
        Test.startTest();
        // Call the method
        String response;
        Boolean exceptionThrown = false;
        try {
            // Call the method
            response = SCC_MessageInAppAndWeb_Ctrl.SendMessage(request, ci);
        } catch (CalloutException e) {
            exceptionThrown = true;
            System.debug('Caught CalloutException: ' + e.getMessage());
            System.assert(e.getMessage().contains('Failed to send message'), 'Pesan error harus mengandung "Failed to send message"');
        }
        Test.stopTest();
        System.assertEquals(true, exceptionThrown, 'Seharusnya terjadi CalloutException.');
    }
    private class MockSendMessageFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"error": "Internal Server Error"}');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    @IsTest(SeeALLData=True)
    static void testSendFile_Success() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile request = prepareTestSendFileRequest();
        String sampleText = 'Ini adalah contoh data Blob';
        Blob fileData = Blob.valueOf(sampleText);
        String fileName = 'test-file-name';

        Test.setMock(HttpCalloutMock.class, new MockSendFileSuccess());
        Test.startTest();
        // Call the method
        String sendFile = SCC_MessageInAppAndWeb_Ctrl.SendFile(ci, request, fileData, fileName);
        Test.stopTest();
        // Deserialize response
        SCC_MessageInAppAndWeb_Wrapper.ResponseModel response = (SCC_MessageInAppAndWeb_Wrapper.ResponseModel) JSON.deserialize(sendFile, SCC_MessageInAppAndWeb_Wrapper.ResponseModel.class);

        // Assertions
        System.assertNotEquals(response, null, 'Response tidak boleh null');
        System.assertEquals('00', response.responseCode, 'Response code harus 00');
        System.assertEquals('File sent successfully', response.responseMessage, 'Pesan sukses harus sesuai');
        // System.assertEquals(conversationId, response.conversationId, 'ConversationId harus sesuai');
        System.assert(response.conversationEntries != null && !response.conversationEntries.isEmpty(), 'conversationEntries harus ada');

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

    @IsTest(SeeALLData=True)
    static void testSendFile_Failed() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile request = prepareTestSendFileRequest();
        String sampleText = 'Ini adalah contoh data Blob';
        Blob fileData = Blob.valueOf(sampleText);
        String fileName = 'test-file-name';

        Test.setMock(HttpCalloutMock.class, new MockSendFileFailed());
        Test.startTest();
        // Call the method
        String response;
        Boolean exceptionThrown = false;
        try {
            // Call the method
            response = SCC_MessageInAppAndWeb_Ctrl.SendFile(ci, request, fileData, fileName);
        } catch (CalloutException e) {
            exceptionThrown = true;
            System.debug('Caught CalloutException: ' + e.getMessage());
            System.assert(e.getMessage().contains('Failed to send file'), 'Pesan error harus mengandung "Failed to send message"');
        }
        Test.stopTest();
        System.assertEquals(true, exceptionThrown, 'Seharusnya terjadi CalloutException.');
    }
    private class MockSendFileFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"error": "Internal Server Error"}');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    @IsTest(SeeALLData=True)
    static void testGetMessage() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;

        // Setup Mock Callout
        Test.setMock(HttpCalloutMock.class, new MockGetMessageSuccess());
        Test.startTest();
        // Call Method
        String getMessage = SCC_MessageInAppAndWeb_Ctrl.GetMessage(ci);
        Test.stopTest();
    }

    private class MockGetMessageSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            SCC_MessageInAppAndWeb_Wrapper.Sender sender = new SCC_MessageInAppAndWeb_Wrapper.Sender();
            sender.appType = 'test-appType';
            sender.role = 'test-role';
            sender.subject = 'test-subject';

            List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM> listCEGM = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM>();
            SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM ceGM = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM();
            ceGM.clientDuration = 30;
            ceGM.clientTimestamp = 1234567890L;
            ceGM.identifier = 'test-Identifier';
            ceGM.messageText = 'test-message-text';
            ceGM.sender = sender;
            ceGM.serverReceivedTimestamp = 1234567999L;
            listCEGM.add(ceGM);

            SCC_MessageInAppAndWeb_Wrapper.ResponseModelGM customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModelGM();
            customResponse.responseCode = '00';
            customResponse.responseMessage = 'Success';
            customResponse.conversationId = '12345';
            customResponse.conversationEntries = listCEGM;
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            String responseBody = JSON.serialize(customResponse);
            response.setBody(responseBody);
            return response;
        }
    }
    
    @IsTest(SeeALLData=True)
    static void testGetMessageFailed() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;

        // Setup Mock Callout
        Test.setMock(HttpCalloutMock.class, new MockGetMessageFailed());
        Test.startTest();
        // Call Method
        try {
            String getMessage = SCC_MessageInAppAndWeb_Ctrl.GetMessage(ci);
            // Assertion 
            System.assertNotEquals(null, getMessage, 'Response should not be null');
        } catch (Exception e) {
            System.debug('Test exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    private class MockGetMessageFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{ Invalid JSON }');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    @IsTest(SeeALLData=True)
    static void testCloseConversation_Success() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        // Setup the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCloseConversation());
        // Testing
        Test.startTest();
        // Call the method
        String response = SCC_MessageInAppAndWeb_Ctrl.closeConversation(ci);
        Test.stopTest();
        System.assertNotEquals(null, response, 'Response tidak boleh null.');
        System.assert(response.contains('"responseCode":"00"'), 'Response harus mengandung responseCode 00.');
        System.assert(response.contains('"responseMessage":"This Conversation has been closed"'), 'Response harus mengandung pesan sukses.');
    
    }
    private class MockHttpResponseCloseConversation implements HttpCalloutMock {
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
            response.setStatusCode(204);
            String responseBody = JSON.serialize(customResponse);
            response.setBody(responseBody);
            return response;
        }
    }

    @IsTest(SeeALLData=True)
    static void testCloseConversation_Failed() {
        // Setup Data
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        // Setup the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCloseConversationFailed());
        // Testing
        Test.startTest();
        // Call the method
        String response;
        Boolean exceptionThrown = false;
        try {
            // Call the method
            response = SCC_MessageInAppAndWeb_Ctrl.closeConversation(ci);
        } catch (CalloutException e) {
            exceptionThrown = true;
            System.debug('Caught CalloutException: ' + e.getMessage());
            System.assert(e.getMessage().contains('Failed to Close conversation'), 'Pesan error harus mengandung "Failed to send message"');
        }
        Test.stopTest();
        System.assertEquals(true, exceptionThrown, 'Seharusnya terjadi CalloutException.');
    }
    private class MockHttpResponseCloseConversationFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"error": "Internal Server Error"}');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    @IsTest(SeeALLData=True)
    static void testUpdateAccessToken_Success() {
        // Setup Data
        String conversationId = null;
        String token = null;
        // Query
        Brimo__c sabrina = [SELECT Id, token__c FROM Brimo__c WHERE Token__c !=: token LIMIT 1];
        String accessToken = sabrina.token__c;
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        // Testing
        Test.startTest();
        // Call the method
        SCC_MessageInAppAndWeb_Ctrl.UpdateAccessToken(accessToken, ci);
        Test.stopTest();
    }

    @IsTest(SeeALLData=True)
    static void testUpdateAccessToken_Failed() {
        // Setup Data
        String token = null;
        // Query
        Brimo__c sabrina = [SELECT Id, token__c FROM Brimo__c WHERE Token__c !=: token LIMIT 1];
        String accessToken = sabrina.token__c;
        // Testing
        Test.startTest();
        // Call the method
        try {
            SCC_MessageInAppAndWeb_Ctrl.UpdateAccessToken(accessToken, null);
            System.assert(false, 'Seharusnya QueryException terjadi.');
        } catch (DmlException e) {
            System.debug('Expected DmlException: ' + e.getMessage());
            System.assert(e.getMessage().contains('Failed to update access token'));
        }
        Test.stopTest();
    }

    @IsTest(SeeALLData=True)
    static void testUpdateChatbotConv_Success() {
        // Setup Data
        String chat = 'testChat';
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        // Testing
        Test.startTest();
        // call the method
        SCC_MessageInAppAndWeb_Ctrl.updateChatbotConv(chat, ci);
        Test.stopTest();
    }

    @IsTest
    static void testUpdateChatbotConv_Failed() {
        // Setup Data
        String chat = 'testChat';
        // Testing
        Test.startTest();
        // call the method
        try {
            SCC_MessageInAppAndWeb_Ctrl.updateChatbotConv(chat, null);
            System.assert(false, 'Seharusnya QueryException terjadi.');
        } catch (DmlException e) {
            System.debug('Expected DmlException: ' + e.getMessage());
            System.assert(e.getMessage().contains('Failed to update access token'));
        }
        Test.stopTest();
    }

    @isTest(SeeALLData=True)
    static void testGetATfromMessagingSession_Success() {
        // Create Data Sample
        String conversationId = null;
        // Query
        Conversation conversationIdentifier = [SELECT Id, ConversationIdentifier FROM Conversation WHERE ConversationIdentifier !=: conversationId LIMIT 1];
        String ci = conversationIdentifier.ConversationIdentifier;
        // Testing
        Test.startTest();
        // Call the Method
        String accessToken = SCC_MessageInAppAndWeb_Ctrl.getATfromMessagingSession(ci);
        Test.stopTest();
        // Assertion
        MessagingSession afterSession = [SELECT Id, access_token__c FROM MessagingSession WHERE ConversationId = :conversationIdentifier.Id LIMIT 1];
        System.assertEquals(afterSession.access_token__c, accessToken, 'Should return the expected access token');
    }

    @isTest
    static void testGetATfromMessagingSession_Failed() {
        // Testing
        Test.startTest();
        // Call the Method
        try {
            String accessToken = SCC_MessageInAppAndWeb_Ctrl.getATfromMessagingSession(null);
            System.assert(false, 'Seharusnya QueryException terjadi.');
        } catch (DmlException e) {
            System.debug('Expected DmlException: ' + e.getMessage());
            System.assert(e.getMessage().contains('Failed to get access token'));
        }
        Test.stopTest();
    }

    @IsTest
    static void testReturnCustomAPI() {
        // Setup Data
        List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry> conversationEntries = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
        SCC_MessageInAppAndWeb_Wrapper.ConversationEntry ce = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
        ce.id = 'testId';
        ce.clientTimestamp = 1234567890L;
        conversationEntries.add(ce);

        SCC_MessageInAppAndWeb_Wrapper.ResponseModel responseModel = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
        responseModel.conversationEntries = conversationEntries;
        responseModel.conversationId = '12345';
        responseModel.responseCode = '00';
        responseModel.responseMessage = 'testResponseMessage';

        Test.startTest();
        String response = SCC_MessageInAppAndWeb_Ctrl.returnCustomAPI(responseModel);
        Test.stopTest();
    }

    @IsTest
    static void testInsertErrorLog() {
        // Setup data
        Exception testException;
        try {
            List<Integer> numbers = new List<Integer>();
            Integer num = numbers[0]; // Simulasi exception 
        } catch (Exception e) {
            testException = e;
        }
        RestRequest testRequest = new RestRequest();
        testRequest.requestBody = Blob.valueOf('{"key": "value"}');
        testRequest.remoteAddress = '192.168.1.1-Remote-Address';
        testRequest.headers.put('Authorization', 'Bearer dummyToken');

        RestResponse testResponse = new RestResponse();
        testResponse.statusCode = 500;

        String returnJson = '{"error": "Test error"}';
        String className = 'InsertErrorLogTest';
        String urlEndpoint = 'https://api.test/endpoint/test';
        String typeAPI = 'POST';

        Test.startTest();
        // Call the method
        SCC_MessageInAppAndWeb_Ctrl.InsertErrorLog(testException, testRequest, testResponse, returnJson, className, urlEndpoint, typeAPI);
        Test.stopTest();

        // Assertion
        System.assert(true, 'Test passed, no errors during execution.');
    }
}