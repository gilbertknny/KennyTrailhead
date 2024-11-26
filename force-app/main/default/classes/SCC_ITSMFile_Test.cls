@isTest
public class SCC_ITSMFile_Test {
    
    @TestSetup
    static void setupTestData() {
        ContentVersion testCV = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert testCV;
    }
    
    @isTest
    static void testUploadToITSM() {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        setupMocks();
        
        Test.startTest();
        List<SCC_ITSMFile.UploadRequest> requests = new List<SCC_ITSMFile.UploadRequest>();
        SCC_ITSMFile.UploadRequest req = new SCC_ITSMFile.UploadRequest();
        req.lcvid = new List<String>{cv.Id};
        req.lcdid = new List<String>{cv.ContentDocumentId};
        req.recId = 'a0J5f000000XXXXEAA0';
        requests.add(req);
        
        List<SCC_ITSMFile.UploadResponse> responses = SCC_ITSMFile.uploadToITSM(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Expected one response');
        
        // Parse the JSON response and check the status
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responses[0].response);
        System.assertEquals('success', responseMap.get('status'), 'Expected success status in response');
    }
    
    @isTest
    static void testSCC_ITSMWebserviceHelper() {
        System.assertEquals('multipart/form-data; boundary=--------------------------898854222253855612822910', 
                            SCC_ITSMWebserviceHelper.GetContentType(), 
                            'Unexpected content type');
        
        System.assertNotEquals('', SCC_ITSMWebserviceHelper.WriteBoundary(), 'Boundary should not be empty');
        
        String bodyParam = SCC_ITSMWebserviceHelper.WriteBodyParameter('testKey', 'testValue');
        // System.assert(bodyParam.contains('testKey'), 'Body parameter should contain the key');
        // System.assert(bodyParam.contains('testValue'), 'Body parameter should contain the value');
        // System.assert(bodyParam.contains('Content-Disposition: form-data; name="testKey"'), 'Body parameter should contain the Content-Disposition');
        
        Blob testBlob = Blob.valueOf('Test file content');
        SCC_ITSMWebserviceHelper.WriteFileResult result = SCC_ITSMWebserviceHelper.WriteFile('file', 'test.txt', 'text/plain', testBlob);
        System.assertNotEquals('', result.Content, 'File content should not be empty');
        // System.assertEquals(SCC_ITSMWebserviceHelper.EndingType.None, result.EndingType, 'Unexpected ending type');
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public interface ISCC_Mime {
        String getContentType();
    }
    
    public interface ISCC_Endpoint_API {
        String getNamedCredential();
        String getDirectory();
        String getMethod();
        Integer getTimeout();
        String getApiKey();
        String getUsername();
        String getPassword();
        String getObjectType();
        Boolean getSaveLog();
    }
    
    public class MockSCC_Mime implements ISCC_Mime {
        private String contentType;
        
        public MockSCC_Mime(String contentType) {
            this.contentType = contentType;
        }
        
        public String getContentType() {
            return this.contentType;
        }
    }
    
    public class MockSCC_Endpoint_API implements ISCC_Endpoint_API {
        private String namedCredential;
        private String directory;
        private String method;
        private Integer timeout;
        private String apiKey;
        private String username;
        private String password;
        private String objectType;
        private Boolean saveLog;
        
        public MockSCC_Endpoint_API(String namedCredential, String directory, String method, Integer timeout, 
                                    String apiKey, String username, String password, String objectType, Boolean saveLog) {
            this.namedCredential = namedCredential;
            this.directory = directory;
            this.method = method;
            this.timeout = timeout;
            this.apiKey = apiKey;
            this.username = username;
            this.password = password;
            this.objectType = objectType;
            this.saveLog = saveLog;
        }
        
        public String getNamedCredential() { return this.namedCredential; }
        public String getDirectory() { return this.directory; }
        public String getMethod() { return this.method; }
        public Integer getTimeout() { return this.timeout; }
        public String getApiKey() { return this.apiKey; }
        public String getUsername() { return this.username; }
        public String getPassword() { return this.password; }
        public String getObjectType() { return this.objectType; }
        public Boolean getSaveLog() { return this.saveLog; }
    }
    
    private static void setupMocks() {
        ISCC_Mime mockMime = new MockSCC_Mime('application/pdf');
        
        ISCC_Endpoint_API mockEndpoint = new MockSCC_Endpoint_API(
            'https://example.com',
            '/upload',
            'POST',
            120000,
            'testApiKey',
            'testUser',
            'testPass',
            'Case',
            true
        );
    }
}