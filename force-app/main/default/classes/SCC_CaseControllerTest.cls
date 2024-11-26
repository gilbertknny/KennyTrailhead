@isTest
private class SCC_CaseControllerTest {
    @isTest
    static void testSaveCaseSuccess() {
        // Create a user with the necessary permission set
        User testUser = createUser('Standard User');
        insert testUser;

        // Ensure the permission set exists
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_CC_Maker' LIMIT 1];
        if (ps == null) {
            System.assert(false, 'Permission Set SCC_CC_Maker does not exist.');
        }

        // Assign the necessary permission set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;

        System.runAs(testUser) {
            Case testCase = new Case(
                Origin = 'Phone',
                SCC_Email__c = 'test@example.com',
                SCC_Cust_Phone1__c = '1234567890'
            );
            ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
            SCC_CaseController controller = new SCC_CaseController(stdController);

            Test.startTest();
            PageReference result = controller.saveCase();
            Test.stopTest();

            System.assertNotEquals(null, result.getUrl());
            System.assertEquals(ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity());
            System.assertEquals('Case created successfully.', ApexPages.getMessages()[0].getSummary());
        }
    }

    @isTest
    static void testRenderErrorForm() {
        // Create a user without the necessary permission set
        User testUser = createUser('Standard User');
        insert testUser;

        System.runAs(testUser) {
            Case testCase = new Case(
                Origin = 'Phone',
                SCC_Email__c = 'test@example.com',
                SCC_Cust_Phone1__c = '1234567890'
            );
            ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
            SCC_CaseController controller = new SCC_CaseController(stdController);

            Test.startTest();
            // Simulate the constructor logic
            // By default, the test user does not have the necessary permission sets
            Test.stopTest();

            // Verify the renderForm and renderErrorForm values
            System.assertEquals(false, controller.renderForm, 'The renderForm variable should be false');
            System.assertEquals(true, controller.renderErrorForm, 'The renderErrorForm variable should be true');
            System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
            System.assertEquals('Anda tidak mempunyai akses untuk membuat case', ApexPages.getMessages()[0].getSummary());
        }
    }

    public static User createUser(String profileName){
        Integer randomNumber = Integer.valueOf(Math.random() * 10000000);
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User();
        u.Alias = 'standt';
        u.Email = String.valueOf(randomNumber) + 'test@testorg.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.UserName = String.valueOf(randomNumber) + 'test@testorg.com';
        u.Division = 'Test User';
        return u;
    }
}