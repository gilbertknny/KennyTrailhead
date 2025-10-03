@isTest
private class CreateOutOfOfficeRecordTest {
    /*

    @testSetup static void setup() {
        final integer strLength = 3;
        final Double dblMax = Math.pow(10,strLength) - 1; // Returns 999
        String aleaNumberN = String.valueOf(Math.Round(Math.Random() * dblMax)).leftPad(strLength,'0');
        System.debug(dblMax);
        
        // Insert a test user
        User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@test.com',
            Username = 'johndoe' + DateTime.now().getTime() + '@test.com',
            Alias = 'johndoe',
            CommunityNickname = 'johndoe',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }
    
    @isTest static void testCreateOutOfOfficeRecord() {
        // Insert a test OutOfOffice record
        OutOfOffice ooo = new OutOfOffice(
            StartDate = Date.today(),
            EndDate = Date.today().addDays(1),
            Message='My message',
            UserId = UserInfo.getUserId()
        );
        insert ooo;
        
        // Verify that a corresponding User record was updated
        User oof = [Select Id,isCuti__c from User where Id=:ooo.UserId];
        System.assertEquals(oof.Id,ooo.UserId);
        System.assertEquals(oof.isCuti__c, true);
    }
    */


}