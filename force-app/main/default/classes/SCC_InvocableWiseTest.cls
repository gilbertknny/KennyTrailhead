@isTest
private class SCC_InvocableWiseTest {
    
    @isTest
    static void testInvocablevoid() {
        // Arrange
        Test.startTest();
        
        // Act
        SCC_InvocableWise.Invocablevoid();
        
        // Assert
        // Verify debug logs contain first name
        System.assert(ApexPages.getMessages().isEmpty(), 'There should be no error messages');
        
        // Since we can't directly assert debug logs, we can verify that the method executed without errors
        // and the queueable job was enqueued
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'SCC_Wise1st'
        ];
        System.assertEquals(1, jobs.size(), 'One job should be enqueued');
        
        Test.stopTest();
    }
    
    @isTest
    static void testProcessWise() {
        // Arrange
        Test.startTest();
        
        // Act - calling the private method through the public method
        SCC_InvocableWise.Invocablevoid();
        
        // Assert
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'SCC_Wise1st'
        ];
        System.assertEquals(1, jobs.size(), 'One job should be enqueued');
        
        Test.stopTest();
    }
}