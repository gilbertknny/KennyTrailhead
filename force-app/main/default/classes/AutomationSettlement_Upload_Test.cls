@isTest
public class AutomationSettlement_Upload_Test {
    
    @isTest
    static void testUpdateCaseAfterUpload() {
        // Create a test case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Attachment_Settlement__c = false
        );
        insert testCase;
        
        // Start the test
        Test.startTest();
        
        // Call the method to update the case
        AutomationSettlement_Upload.updateCaseAfterUpload(testCase.Id);
        
        // Stop the test
        Test.stopTest();
        
        // Query the updated case
        Case updatedCase = [SELECT Id, Attachment_Settlement__c FROM Case WHERE Id = :testCase.Id];
        
        // Assert that the Attachment_Settlement__c field was updated to true
        System.assertEquals(true, updatedCase.Attachment_Settlement__c, 'Attachment_Settlement__c should be true after update');
    }
    
    @isTest
    static void testUpdateCaseAfterUploadWithException() {
        // Start the test
        Test.startTest();
        
        // Try to update a non-existent case
        try {
            AutomationSettlement_Upload.updateCaseAfterUpload('005000000000000');
            System.assert(false, 'An exception should have been thrown');
        } catch (AuraHandledException e) {
            // Assert that an exception was thrown (we don't check the specific message)
            System.assert(true, 'Exception was thrown as expected');
        }
        
        // Stop the test
        Test.stopTest();
    }
}