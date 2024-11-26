@isTest
public class TaskTestClass {
	
    @isTest
    public static void taskTest(){
        User testUser = createUser('System Administrator');
        insert testUser;
        
         Account acc = new Account(LastName = 'Test');
        
        Task tsk = new Task();
        tsk.subject = 'Task Test';
        tsk.OwnerId=UserInfo.getUserId();
        tsk.ActivityDate=system.today().addDays(5);
        tsk.WhatId=acc.Id;
                  
        
        System.runAs(testUser) {
               insert tsk;
               delete tsk;
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