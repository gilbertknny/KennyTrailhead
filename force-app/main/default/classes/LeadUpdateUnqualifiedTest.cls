/**
 * @description       : Test class for LeadUpdateUnqualified controller.
 * @author            : Ishardan
 * @createdDate       : 17/10/2025
 * @lastModifiedBy    : Ishardan
 * @lastModifiedDate  : 17/10/2025
 * @testCoverage      : Covers positive and negative scenarios for markUnqualified method.
 */
@IsTest
private class LeadUpdateUnqualifiedTest {

    /**
     * @description  Test successful update of Lead status to 'Unqualified' with proper permissions.
     */
    @IsTest
    static void testMarkUnqualifiedSuccess() {
        // Create test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'tuser@example.com',
            EmailEncodingKey = 'UTF-8',
            FirstName='Name',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Jakarta',
            ProfileId = p.Id,
            Username = 'tuser' + DateTime.now().getTime() + '@example.com'
        );

        Lead testLead = new Lead(FirstName='Name',LastName = 'Lead A', Company = 'Aswata');
        insert testLead;

        Test.startTest();
        // Run as the created user
        System.runAs(testUser) {
             LeadUpdateUnqualified.markUnqualified(testLead.Id, false);
        }
        Test.stopTest();

        Lead updatedLead = [SELECT Status FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Unqualified', updatedLead.Status, 'Lead status should be updated to Unqualified.');
    }

    /**
     * @description  Test behavior when user lacks permission to update Status field.
     */
    @IsTest
    static void testMarkUnqualifiedNoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User restrictedUser = new User(
            Alias = 'ruser',
            Email = 'ruser@example.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'aNa',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Jakarta',
            ProfileId = p.Id,
            Username = 'ruser' + DateTime.now().getTime() + '@example.com'
        );

        Lead testLead = new Lead(FirstName = 'aNa',LastName = 'Lead B', Company = 'Aswata');
        insert testLead;

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            System.runAs(restrictedUser) {
                LeadUpdateUnqualified.markUnqualified(testLead.Id, true);
            }
        } catch (Exception e) { // catch all exceptions
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('permission') ||
                e.getMessage().contains('Script-thrown'),
                'Expected permission error message but got: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Expected AuraHandledException for restricted user');
    }

}