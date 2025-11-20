@isTest
public class TaskCantDelete_Test {

    @testSetup
    static void setup() {
        Profile nonSysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User nonSysAdminUser = new User(
            Username = 'nonsysadminuser@test.com',
            Alias = 'nsa',
            Email = 'nonsysadminuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonSysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = null,
            CommunityNickname = 'nonsysadminuser',
            Title = 'Standard User',
            IsActive = true
        );
        insert nonSysAdminUser;

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sysAdminUser = new User(
            Username = 'sysadminuser@test.com',
            Alias = 'sa',
            Email = 'sysadminuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = null,
            CommunityNickname = 'sysadminuser',
            Title = 'System Administrator',
            IsActive = true
        );
        insert sysAdminUser;

        Task task1 = new Task(
            Subject = 'Task for non-sysadmin user',
            OwnerId = nonSysAdminUser.Id,
            Status = 'Not Started'
        );
        insert task1;

        Task task2 = new Task(
            Subject = 'Task for sysadmin user',
            OwnerId = sysAdminUser.Id,
            Status = 'Not Started'
        );
        insert task2;
    }

    @isTest
    static void testNonSysAdminUserCannotDeleteTask() {
        User nonSysAdminUser = [SELECT Id FROM User WHERE Username = 'nonsysadminuser@test.com' LIMIT 1];

        System.runAs(nonSysAdminUser) {
            Task taskToDelete = [SELECT Id FROM Task WHERE OwnerId = :nonSysAdminUser.Id LIMIT 1];
            
            Test.startTest();
            Database.DeleteResult result = Database.delete(taskToDelete, false);
            Test.stopTest();

            System.assert(result.isSuccess() == false, 'Penghapusan tugas seharusnya gagal.');
        }
    }

    @isTest
    static void testSysAdminUserCanDeleteTask() {
        User sysAdminUser = [SELECT Id FROM User WHERE Username = 'sysadminuser@test.com' LIMIT 1];

		System.runAs(sysAdminUser) {
            Task taskToDelete = [SELECT Id FROM Task WHERE OwnerId = :sysAdminUser.Id LIMIT 1];
            
            Test.startTest();
            Database.DeleteResult result = Database.delete(taskToDelete, false);
            Test.stopTest();

            System.assert(result.isSuccess() == true, 'Penghapusan tugas seharusnya berhasil.');
        }
    }
}