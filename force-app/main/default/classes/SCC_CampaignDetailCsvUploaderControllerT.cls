/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 21-02-2025
 * @last modified by  : Ardyta Yudianto
**/
@IsTest
private class SCC_CampaignDetailCsvUploaderControllerT {
    @TestSetup
    static void setupTestData() {
        // Create test Campaign__c (Custom Object)
        Campaign__c testCampaign = new Campaign__c(
            Name = 'Test Campaign'
            // Add other required fields for Campaign__c if any
        );
        insert testCampaign;
    }
    
    @IsTest
    static void testSuccessfulCsvUpload() {
        try {
            // Get the test campaign
            Campaign__c testCampaign = [SELECT Id FROM Campaign__c WHERE Name = 'Test Campaign' LIMIT 1];
            
            // Prepare test CSV content with minimal required fields
            String csvContent = 'customer name;phone;email\n' +
                              'John Doe;1234567890;john@test.com';
            
            Test.startTest();
            SCC_CampaignDetailCsvUploaderController.uploadCsvFile(csvContent, testCampaign.Id);
            Test.stopTest();
            
            // Verify results
            List<Campaign_Detail__c> results = [
                SELECT Customer_Name__c, Phone__c, Email__c 
                FROM Campaign_Detail__c 
                WHERE Campaign__c = :testCampaign.Id
            ];
            
            System.assertEquals(1, results.size(), 'Should have created 1 Campaign Detail record');
            
            // Verify first record
            Campaign_Detail__c firstRecord = results[0];
            System.assertEquals('John Doe', firstRecord.Customer_Name__c);
            System.assertEquals('1234567890', firstRecord.Phone__c);
            System.assertEquals('john@test.com', firstRecord.Email__c);
        } catch(Exception e) {
            System.debug('Error in testSuccessfulCsvUpload: ' + e.getMessage());
            throw e;
        }
    }
    
    @IsTest
    static void testCsvUploadWithEmptyContent() {
        try {
            Campaign__c testCampaign = [SELECT Id FROM Campaign__c WHERE Name = 'Test Campaign' LIMIT 1];
            
            Test.startTest();
            SCC_CampaignDetailCsvUploaderController.uploadCsvFile('', testCampaign.Id);
            Test.stopTest();
            
            // Verify no records were created
            List<Campaign_Detail__c> results = [SELECT Id FROM Campaign_Detail__c WHERE Campaign__c = :testCampaign.Id];
            System.assertEquals(0, results.size(), 'Should not have created any Campaign Detail records');
        } catch(Exception e) {
            System.debug('Error in testCsvUploadWithEmptyContent: ' + e.getMessage());
            throw e;
        }
    }
    
    @IsTest
    static void testDownloadTemplateSuccess() {
        try {
            // Create test Static Resource
            StaticResource mockTemplate = new StaticResource(
                Name = 'TestTemplate',
                Body = Blob.valueOf('Test template content'),
                ContentType = 'text/csv'
            );
            
            Test.startTest();
            String result = SCC_CampaignDetailCsvUploaderController.downloadTemplate('JSM_LOP');
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Template content should not be null');
        } catch(Exception e) {
            System.debug('Error in testDownloadTemplateSuccess: ' + e.getMessage());
            throw e;
        }
    }
    
    // @IsTest
    // static void testDownloadTemplateError() {
    //     Test.startTest();
    //     try {
    //         String result = SCC_CampaignDetailCsvUploaderController.downloadTemplate('NonExistentTemplate');
    //         System.assert(false, 'Should have thrown an exception');
    //     } catch (AuraHandledException e) {
    //         System.assert(e.getMessage().contains('Error downloading template'),
    //                      'Should have thrown appropriate error message');
    //     }
    //     Test.stopTest();
    // }
    
    @IsTest
    static void testCsvUploadWithInvalidData() {
        try {
            Campaign__c testCampaign = [SELECT Id FROM Campaign__c WHERE Name = 'Test Campaign' LIMIT 1];
            
            // CSV with invalid numeric and date fields
            String csvContent = 'customer name;phone;nominal pengajuan;tanggal pengajuan\n' +
                              'Test Customer;1234567890;invalid_number;invalid_date';
            
            Test.startTest();
            SCC_CampaignDetailCsvUploaderController.uploadCsvFile(csvContent, testCampaign.Id);
            Test.stopTest();
            
            // Verify the record was created with valid fields only
            List<Campaign_Detail__c> results = [
                SELECT Customer_Name__c, Phone__c, Nominal_Pengajuan__c, Tanggal_Pengajuan__c
                FROM Campaign_Detail__c 
                WHERE Campaign__c = :testCampaign.Id
            ];
            
            System.assertEquals(1, results.size(), 'Should have created 1 Campaign Detail record');
            System.assertEquals('Test Customer', results[0].Customer_Name__c);
            System.assertEquals('1234567890', results[0].Phone__c);
            System.assertEquals(null, results[0].Nominal_Pengajuan__c, 'Invalid number should be null');
            System.assertEquals(null, results[0].Tanggal_Pengajuan__c, 'Invalid date should be null');
        } catch(Exception e) {
            System.debug('Error in testCsvUploadWithInvalidData: ' + e.getMessage());
            throw e;
        }
    }
}