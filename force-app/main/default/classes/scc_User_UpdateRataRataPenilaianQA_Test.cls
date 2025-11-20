/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 23-12-2024
 * @last modified by  : Christian Vieri
**/
@isTest
public class scc_User_UpdateRataRataPenilaianQA_Test {

    @isTest
    static void testQueueUpdateUserRatings() {
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 2; i++) {
            testUsers.add(new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Email = 'test' + i + '@example.com',
                Username = 'test' + i + '_' + System.currentTimeMillis() + '@example.com', 
                Alias = 'tst' + i,
                CommunityNickname = 'TestUser' + i,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
            ));
        }
        insert testUsers;

        List<scc_User_UpdateRataRataPenilaianQA.Request> requests = new List<scc_User_UpdateRataRataPenilaianQA.Request>();
        for (User user : testUsers) {
            scc_User_UpdateRataRataPenilaianQA.Request req = new scc_User_UpdateRataRataPenilaianQA.Request();
            req.userId = user.Id;
            req.ratingThisMonth = 4.5;
            req.ratingCurrentMonth = 4.0;
            requests.add(req);
        }

        Test.startTest();
        scc_User_UpdateRataRataPenilaianQA.queueUpdateUserRatings(requests);
        Test.stopTest();

        List<User> updatedUsers = [SELECT Rata_rata_penilaian_Bulan_Berjalan__c, Rata_rata_penilaian_Bulan_Ini__c FROM User WHERE Id IN :testUsers
        ];

        for (User user : updatedUsers) {
            System.assertEquals('4.0', user.Rata_rata_penilaian_Bulan_Berjalan__c, 'Current Month rating mismatch');
            System.assertEquals('4.5', user.Rata_rata_penilaian_Bulan_Ini__c, 'This Month rating mismatch');
        }
    }
}