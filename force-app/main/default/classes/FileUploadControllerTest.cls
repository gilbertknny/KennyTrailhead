@isTest
public class FileUploadControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test incident record
        Incident testIncident = new Incident(
            Subject = 'test subject',
            Nomor_tiket_iRIS__c = 'TEST-001'
        );
        insert testIncident;
        
        // Create test ContentVersion record
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            FirstPublishLocationId = testIncident.Id  // This will auto-create ContentDocumentLink
        );
        insert cv;
        
        // Get the published version
        cv = [SELECT Id, ContentDocumentId, Title, ContentSize, FileType 
              FROM ContentVersion 
              WHERE Id = :cv.Id];
    }
    
    @isTest
    static void testContentData() {
        // Get test ContentVersion
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        
        Test.startTest();
        FileUploadController.contentDataWrapper result = FileUploadController.contentData(cv.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Content data wrapper should not be null');
        System.assertNotEquals(null, result.fileSize, 'File size should not be null');
        //System.assertNotEquals(null, result.fileType, 'File type should not be null');
    }
    
    @isTest
    static void testFileSize() {
        // Get test ContentDocument
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        
        Test.startTest();
        Integer size = FileUploadController.fileSize(cv.ContentDocumentId);
        Test.stopTest();
        
        System.assertNotEquals(null, size, 'File size should not be null');
    }
    
    @isTest
    static void testUploadFile() {
        // Get test data
        Incident inc = [SELECT Id FROM Incident WHERE Nomor_tiket_iRIS__c = 'TEST-001' LIMIT 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        
        // Mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        String response = FileUploadController.uploadFile(cv.Id, inc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
    }
    
    @isTest
    static void testDeleteFile() {
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        
        Test.startTest();
        FileUploadController.deleteFile(cv.ContentDocumentId);
        Test.stopTest();
        
        List<ContentDocument> deletedDocs = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        System.assertEquals(0, deletedDocs.size(), 'Content Document should be deleted');
    }
    
    @isTest
    static void testUploadFiles() {
        // Get test data
        Incident inc = [SELECT Id FROM Incident WHERE Nomor_tiket_iRIS__c = 'TEST-001' LIMIT 1];
        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title = 'Test File'];
        List<String> cvIds = new List<String>();
        for(ContentVersion cv : cvList) {
            cvIds.add(cv.Id);
        }
        
        // Mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        List<String> responses = FileUploadController.uploadFiles(cvIds, inc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, responses, 'Responses should not be null');
    }
    
    @isTest
    static void testUploadFilesToITSM() {
        // Get test data
        Incident inc = [SELECT Id FROM Incident WHERE Nomor_tiket_iRIS__c = 'TEST-001' LIMIT 1];
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test File'];
        
        List<String> cvIds = new List<String>();
        List<String> cdIds = new List<String>();
        
        for(ContentVersion cv : cvList) {
            cvIds.add(cv.Id);
            cdIds.add(cv.ContentDocumentId);
        }
        
        // Mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        List<SCC_ITSMFile.UploadResponse> responses = FileUploadController.uploadFilesToITSM(cvIds, cdIds, inc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, responses, 'ITSM Upload responses should not be null');
    }
    
    @isTest
    static void testDeleteFiles() {
        List<ContentVersion> cvList = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test File'];
        List<String> cdIds = new List<String>();
        for(ContentVersion cv : cvList) {
            cdIds.add(cv.ContentDocumentId);
        }
        
        Test.startTest();
        FileUploadController.deleteFiles(cdIds);
        Test.stopTest();
        
        List<ContentDocument> deletedDocs = [SELECT Id FROM ContentDocument WHERE Id IN :cdIds];
        System.assertEquals(0, deletedDocs.size(), 'All Content Documents should be deleted');
    }
    
    // Mock HTTP Response Generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}