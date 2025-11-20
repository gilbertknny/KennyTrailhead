@isTest
public class FileUploadControllerMMSTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"responseCode": "200", "responseData": {"data": "/file/path/on/mms"}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    static void setupTestData() {
        SCC_Call_Type_Feature__c ct = new SCC_Call_Type_Feature__c(name = '8615', Fitur_ID__c = '00621');
        insert ct;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Draft',
            Origin = 'MMS',
            SCC_Call_Type_Feature__c = ct.Id,
            SCC_Legacy_Ticket_ID__c = 'TTB000029999999',
            SCC_Amount__c = 832748237
        );
        insert testCase;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            FirstPublishLocationId = testCase.Id
        );
        insert cv;
    }
    
    @isTest
    static void testContentData() {
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        Test.startTest();
        FileUploadControllerMMS.contentDataWrapper result = FileUploadControllerMMS.contentData(cv.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testFileSize() {
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        Test.startTest();
        Integer size = FileUploadControllerMMS.fileSize(cd.Id);
        Test.stopTest();
        System.assertNotEquals(null, size, 'File size should not be null');
    }
    
    @isTest
    static void testUploadFile() {
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        Case cs = [SELECT Id FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        String response = FileUploadControllerMMS.uploadFile(cv.Id, cs.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
    }
    
    @isTest
    static void testDeleteFile() {
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        Test.startTest();
        FileUploadControllerMMS.deleteFile(cd.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocument WHERE Id = :cd.Id], 'File should be deleted');
    }
    
    @isTest
    static void testDeleteFiles() {
        List<ContentVersion> cvList = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test File'];
        List<String> cdIds = new List<String>();
        for(ContentVersion cv : cvList) {
            cdIds.add(cv.ContentDocumentId);
        }
        
        Test.startTest();
        FileUploadControllerMMS.deleteFiles(cdIds);
        Test.stopTest();
        
        List<ContentDocument> deletedDocs = [SELECT Id FROM ContentDocument WHERE Id IN :cdIds];
        System.assertEquals(0, deletedDocs.size(), 'All Content Documents should be deleted');
    }
    
    @isTest
    static void testUploadFilesToMMS() {
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        Case cs = [SELECT Id FROM Case LIMIT 1];
        List<String> cvIds = new List<String>{cv.Id};
        List<String> cdIds = new List<String>{cd.Id};
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        List<SCC_MMSFile.UploadResponse> responses = FileUploadControllerMMS.uploadFilesToMMS(cvIds, cdIds, cs.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, responses.size(), 'Responses should not be empty');
    }
}