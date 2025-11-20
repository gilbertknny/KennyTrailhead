@isTest
public class SCC_MMSFile_Test {
    @TestSetup
    static void makeData(){
        SCC_Call_Type_Feature__c ct = new SCC_Call_Type_Feature__c(name = '8615', Fitur_ID__c = '00621');
        insert ct;
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Draft',
            Origin = 'MMS',
            SCC_Call_Type_Feature__c = ct.Id,
            SCC_Legacy_Ticket_ID__c = 'TTB000009999999',
            SCC_Amount__c = 832748237
            
        );
        insert testCase;
        
        // Create test ContentVersion record
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            FirstPublishLocationId = testCase.Id  // This will auto-create ContentDocumentLink
        );
        insert cv;
        
        // Get the published version
        ContentVersion cv2 = [SELECT Id, ContentDocumentId, Title, ContentSize, FileType 
              FROM ContentVersion 
              WHERE Id = :cv.Id];
        system.debug(cv2);
    }
    
    @isTest
    static void testUploadToMMS() {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        setupMocks();
        
        Test.startTest();
        List<SCC_MMSFile.UploadRequest> requests = new List<SCC_MMSFile.UploadRequest>();
        SCC_MMSFile.UploadRequest req = new SCC_MMSFile.UploadRequest();
        req.lcvid = new List<String>{cv.Id};
        req.lcdid = new List<String>{cv.ContentDocumentId};
        req.recId = 'a0J5f000000XXXXEAA0';
        requests.add(req);
        
        List<SCC_MMSFile.UploadResponse> responses = SCC_MMSFile.uploadToMMS(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Expected one response');
        
        // Parse the JSON response and check the status
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responses[0].response);
        System.assertEquals('success', responseMap.get('status'), 'Expected success status in response');
    }
    
    @isTest
    static void testGetContentType() {
        String contentType = SCC_MMSWebserviceHelper.GetContentType();
        System.assertEquals('application/json', contentType, 'Content type should be application/json');
    }

    @isTest
    static void testConvertFileToBase64() {
        Blob testBlob = Blob.valueOf('Test content');
        String base64String = SCC_MMSWebserviceHelper.ConvertFileToBase64(testBlob);
        System.assertNotEquals(null, base64String, 'Base64 string should not be null');
        System.assertEquals(EncodingUtil.base64Encode(testBlob), base64String, 'Base64 encoding mismatch');
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
        ISCC_Mime mockMime2 = new MockSCC_Mime('application/png');
        ISCC_Mime mockMime3 = new MockSCC_Mime('application/jpeg');
        ISCC_Mime mockMime4 = new MockSCC_Mime('application/jpg');
        
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