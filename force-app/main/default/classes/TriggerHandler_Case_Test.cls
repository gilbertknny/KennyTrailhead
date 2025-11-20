@isTest
public with sharing class TriggerHandler_Case_Test {
    @TestSetup
    static void setTestData(){
        User adminUser = createUser('System Administrator');
        insert adminUser;
        

        //Sales Cloud
        System.runAs(adminUser) {
            User testUserL1 = createUser('Contact Center User');
            insert testUserL1;      
            
            
            
        }
    }
    @isTest
    public static void testUpdateCase(){
        String errorMessage = '';

        User UserA = createUser('Contact Center User');
        UserA.LastName = 'Test User CCMaker A';
        insert UserA;

        User UserB = createUser('Contact Center User');
        UserA.LastName = 'Test User CCMaker B';
        insert UserB;

        Case cs = new case();
        cs.Subject = 'Case Manual Test';
        cs.Origin = 'Phone';
        cs.OwnerId = [SELECT Id FROM User WHERE LastName = 'Test User CCMaker A' LIMIT 1].Id;
        cs.Priority = 'Low';
        cs.Status = 'New';
        insert cs;

        Test.startTest();
        try{
            System.runAs(UserB){
                cs.Subject = 'Case Manual Test UserA';
                update cs;
            }
        }catch(Exception e){
            system.debug(e.getMessage());
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        system.assertEquals(true, errorMessage.contains('Anda bukan pemilik Case, hanya bisa mengubah remark.'));

    }
    public static User createUser(String profileName){
        Integer randomNumber = Integer.valueof((Math.random() * 10000000));
        Profile p = [SELECT Id
                     FROM Profile
                     WHERE Name = :profileName];
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