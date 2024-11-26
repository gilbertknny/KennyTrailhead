@isTest
private class IncidentFilesControllerTest {
    
    @TestSetup
    static void makeData(){
        Incident testIncident = new Incident(
            Subject = 'Test Incident',
            Nomor_tiket_iRIS__c = 'TEST-001'
        );
        insert testIncident;
        
        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for(Integer i = 0; i < 3; i++) {
            ContentVersion cv = new ContentVersion(
                Title = 'Test Document ' + i,
                PathOnClient = 'TestDoc' + i + '.docx',
                VersionData = Blob.valueOf('Test Content ' + i)
            );
            testContentVersions.add(cv);
        }
        insert testContentVersions;
        
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :testContentVersions];
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument cd : contentDocuments) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                LinkedEntityId = testIncident.Id,
                ContentDocumentId = cd.Id,
                ShareType = 'V'
            );
            contentDocumentLinks.add(cdl);
        }
        insert contentDocumentLinks;
    }
    
    @isTest
    static void testGetIncidentFiles() {
        Incident testIncident = [SELECT Id FROM Incident WHERE Subject = 'Test Incident' LIMIT 1];
        
        Test.startTest();
        List<ContentDocument> resultFiles = IncidentFilesController.getIncidentFiles(testIncident.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultFiles, 'Result should not be null');
        System.assertEquals(3, resultFiles.size(), 'Should return 3 files');
        
        for(ContentDocument cd : resultFiles) {
            System.assert(cd.Title.startsWith('Test Document'), 'File title should start with "Test Document"');
            // System.assertEquals('word_x', cd.FileType, 'File type should be docx');
            System.assert(cd.ContentSize > 0, 'Content size should be greater than 0');
            System.assertNotEquals(null, cd.CreatedDate, 'Created date should not be null');
        }
    }
    
    @isTest
    static void testGetIncidentFilesNoFiles() {
        Incident newIncident = new Incident(
            Subject = 'New Incident',
            Nomor_tiket_iRIS__c = 'TEST-002'
        );
        insert newIncident;
        
        Test.startTest();
        List<ContentDocument> resultFiles = IncidentFilesController.getIncidentFiles(newIncident.Id);
        Test.stopTest();
        
        System.assertEquals(null, resultFiles, 'Result should be null for an Incident with no files');
    }
}