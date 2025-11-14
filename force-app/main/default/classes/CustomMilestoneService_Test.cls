@IsTest(SeeAllData=false)
public class CustomMilestoneService_Test {
	@TestSetup
    static void setTestData(){
        Case cs = new Case();
        cs.Subject = 'Test';
        insert cs;
        
        Task t = new Task();
        t.WhatId = cs.Id;
        t.TaskSubtype = 'TASK';
        t.Status = 'Open';
        insert t;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
        	Case cs = [SELECT Id FROM Case LIMIT 1];
            Test.startTest();
        	List<CustomMilestoneService.CustomMilestoneWrapper> listdata = CustomMilestoneService.getCustomMilestonesWithDetails(cs.Id);
            system.assertNotEquals(listdata.size(),0);
            Test.stopTest();
        }
    }
}