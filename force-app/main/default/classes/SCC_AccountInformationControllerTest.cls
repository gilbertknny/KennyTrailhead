@IsTest
public class SCC_AccountInformationControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Test Account',
            SCC_cifno__c = '123456789',
            SCC_Address__c = '123 Test St',
            SCC_Jenis_Nasabah__c = 'Prioritas',
            SCC_TanggalLahir__c = '1990-01-01',
            SCC_Tipe_Nasabah__c = 'Individu',
            Phone = '123-456-7890',
            SCC_Primary_Email__c = 'test@example.com',
            SCC_Facebook__c = 'TestFacebook',
            SCC_Instagram__c = 'TestInstagram',
            SCC_X__c = 'TestX'
        );
        insert testAccount;
    }
    
    @IsTest
    static void testGetAccountData() {
        // Get the Id of the test Account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Test the getAccountData method
        Test.startTest();
        Account result = SCC_AccountInformationController.getAccountData(testAccount.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, result, 'Account data should not be null');
        System.assertEquals(testAccount.Id, result.Id, 'Account Id should match');
        System.assertEquals('Test Account', result.Name, 'Account Name should match');
    }
    
    @IsTest
    static void testGetAccountData_InvalidId() {
        // Test the getAccountData method with an invalid Id
        Test.startTest();
        try {
            SCC_AccountInformationController.getAccountData(null);
            System.assert(false, 'Exception should have been thrown for null Id');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateAccountFields() {
        // Get the Id of the test Account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Test the updateAccountFields method
        Test.startTest();
        SCC_AccountInformationController.updateAccountFields(testAccount.Id, 'NewInstagram', 'NewFacebook', 'NewX');
        Test.stopTest();
        
        // Verify the results
        Account updatedAccount = [SELECT SCC_Instagram__c, SCC_Facebook__c, SCC_X__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('NewInstagram', updatedAccount.SCC_Instagram__c, 'Instagram should be updated');
        System.assertEquals('NewFacebook', updatedAccount.SCC_Facebook__c, 'Facebook should be updated');
        System.assertEquals('NewX', updatedAccount.SCC_X__c, 'X should be updated');
    }
    
    @IsTest
    static void testUpdateAccountFields_InvalidId() {
        // Test the updateAccountFields method with an invalid Id
        Test.startTest();
        try {
            SCC_AccountInformationController.updateAccountFields(null, 'NewInstagram', 'NewFacebook', 'NewX');
            System.assert(false, 'Exception should have been thrown for null Id');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateAccountFields_NoFieldsToUpdate() {
        // Get the Id of the test Account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Test the updateAccountFields method with no fields to update
        Test.startTest();
        try {
            SCC_AccountInformationController.updateAccountFields(testAccount.Id, '', '', '');
            System.assert(false, 'Exception should have been thrown for no fields to update');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}