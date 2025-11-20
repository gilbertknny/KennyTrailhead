@isTest
private class SCC_UserSyncTest {

    @isTest
    static void testSync() {
        String agentProfileName = Label.Agent_Profile_Name;
        
        Test.startTest();
        // create a user
        User newUser = new User();
        newUser.FirstName = 'Test';
        newUser.LastName = 'User';
        newUser.Email = 'test@user.co.id';
        newUser.Username = 'test@user.co.id';
        newUser.Alias = 'test';
        newUser.FederationIdentifier = '10002813';
        newUser.EmployeeNumber = '10002813';
        newUser.IsActive = true;
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'Asia/Jakarta';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = :agentProfileName]?.Id;

        insert newUser;
        SCC_UserSyncScheduler sync = new SCC_UserSyncScheduler();
        sync.syncUser();
        Test.stopTest();
    }
}