@isTest
private class SCC_UtilityClassIntegrationTest {
    @isTest
    static void testIsProduction() {
        // Test for Production org
        Test.startTest();
        System.assertEquals(true, SCC_UtilityClassIntegration.isProduction());
        Test.stopTest();

        // Test for Sandbox org
        Test.startTest();
        System.assertEquals(false, SCC_UtilityClassIntegration.isProduction());
        Test.stopTest();
    }

    @isTest
    static void testGetRecordTypeIdByName() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Test for existing record type
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        System.assertEquals(rtId, SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'Standard'));

        // Test for non-existing record type
        System.assertEquals(null, SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'Non Existing Record Type'));
        
        // Test for objectName not found scenario
        System.assertEquals(null, SCC_UtilityClassIntegration.getRecordTypeIdByName('NonExistingObject', 'Standard'));
    }
}