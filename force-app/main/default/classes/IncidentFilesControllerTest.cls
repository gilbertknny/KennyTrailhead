@isTest
private class IncidentFilesControllerTest {
    
    @TestSetup
    static void makeData(){
        Incident testIncident = new Incident(
            Subject = 'Test Incident',
            Nomor_tiket_iRIS__c = 'TEST-001'
        );
        insert testIncident;
        
        // Buat ContentVersion dengan FirstPublishLocationId agar langsung terkait dengan Case
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestPdf.pdf',
            VersionData = Blob.valueOf('Test Content'),
            FirstPublishLocationId = testIncident.Id // Menautkan file ke Case
        );
        insert cv;
    }
    
    @isTest
    static void testGetIncidentFiles() {
        Incident testIncident = [SELECT Id FROM Incident WHERE Subject = 'Test Incident' LIMIT 1];
        
        Test.startTest();
        List<ContentDocument> resultFiles = IncidentFilesController.getIncidentFiles(testIncident.Id);
        Test.stopTest();
        
        //System.assertNotEquals(null, resultFiles, 'Result should not be null');
        System.assert(resultFiles.size() > 0, 'There should be at least 1 file');
        
        for(ContentDocument cd : resultFiles) {
            System.assert(cd.Title.startsWith('Test Document'), 'File title should start with "Test Document"');
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