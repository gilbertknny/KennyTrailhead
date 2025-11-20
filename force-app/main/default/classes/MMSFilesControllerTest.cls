@isTest
private class MMSFilesControllerTest {
    
    @TestSetup
    static void makeData(){
        // Buat data SCC_Call_Type_Feature__c
        SCC_Call_Type_Feature__c ct = new SCC_Call_Type_Feature__c(
            Name = '8615', 
            Fitur_ID__c = '00621'
        );
        insert ct;

        // Buat Case baru
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Draft',
            Origin = 'MMS',
            SCC_Call_Type_Feature__c = ct.Id,
            SCC_Legacy_Ticket_ID__c = 'TTB000009999999',
            SCC_Amount__c = 832748237
        );
        insert testCase;

        // Buat ContentVersion dengan FirstPublishLocationId agar langsung terkait dengan Case
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestPdf.pdf',
            VersionData = Blob.valueOf('Test Content'),
            FirstPublishLocationId = testCase.Id // Menautkan file ke Case
        );
        insert cv;
    }

    @isTest
    static void testGetMMSFiles() {
        // Ambil Case yang sudah dibuat di @TestSetup
        Case testCase = [SELECT Id FROM Case WHERE SCC_Legacy_Ticket_ID__c = 'TTB000009999999' LIMIT 1];

        Test.startTest(); 
        List<ContentDocument> resultFiles = MMSFilesController.getMMSFiles(testCase.Id);
        Test.stopTest();

        // Pastikan hasil tidak null dan ada file yang dikembalikan
        //System.assertNotNull(resultFiles, 'Result should not be null');
        System.assert(resultFiles.size() > 0, 'There should be at least 1 file');

        for(ContentDocument cd : resultFiles) {
            System.assert(cd.Title.startsWith('Test Document'), 'File title should start with "Test Document"');
            System.assert(cd.ContentSize > 0, 'Content size should be greater than 0');
            System.assertNotEquals(null, cd.CreatedDate, 'Created date should not be null');
        }
    }
    
       @isTest
    static void testGetMMSFilesNoFiles() {
        SCC_Call_Type_Feature__c ct = new SCC_Call_Type_Feature__c(name = '8615', Fitur_ID__c = '00621');
        insert ct;
        Test.startTest();
        Case newCase = new Case(
            Subject = 'New Case',
            Status = 'Draft',
            Origin = 'MMS',
            SCC_Call_Type_Feature__c = ct.Id,
            SCC_Legacy_Ticket_ID__c = 'TTB000799999999',
            SCC_Amount__c = 832748237
        );
        insert newCase;
        
        List<ContentDocument> resultFiles = MMSFilesController.getMMSFiles(newCase.Id);
        Test.stopTest();
        
        System.assertEquals(null, resultFiles, 'Result should be null for a Case with no files');
    }
}