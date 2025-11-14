/**
 * TestClass for Trigger_Task & TriggerHandler_Task
 * TC : GS
 * DATE : 10/10/25
 */

@IsTest(SeeAllData=false)
public class TriggerHandler_Task_Test {
	@TestSetup
    static void setTestData(){
        Lead l = new Lead();
        l.FirstName = 'ABC';
        l.LastName = 'Test';
        insert l;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
            Lead l = [SELECT Id FROM Lead LIMIT 1];
            
            Test.startTest();
            Task t = new Task();
            t.Subject = 'Test';
            t.Status = 'Open';
            t.WhoId = l.Id;
            insert t;
            t = [SELECT Id,StartDate__c FROM Task WHERE id =: t.Id];
            system.assertNotEquals(t.StartDate__c,NULL);
            
            Task t2 = new Task();
            t2.Subject = 'Test2';
            t2.Status = 'Completed';
            insert t2;
            t2 = [SELECT Id,IsCompleted__c FROM Task WHERE id =: t2.Id];
            system.assertEquals(t2.IsCompleted__c,TRUE);
            
            t.TargetResponseInMins__c = 1440;
            update t;
            
            t.Status = 'In Progress';
            update t;
            
            t.Status = 'On Hold';
            update t;
            t = [SELECT Id,PauseDate__c FROM Task WHERE id =: t.Id];
            system.assertNotEquals(t.PauseDate__c,NULL);
            
            t.Status = 'In Progress';
            update t;
            t = [SELECT Id,StoppedTimeInMins__c FROM Task WHERE id =: t.Id];
            system.assertNotEquals(t.StoppedTimeInMins__c,NULL);
            
            t.Status = 'Completed';
            update t;
            t = [SELECT Id,IsCompleted__c FROM Task WHERE id =: t.Id];
            system.assertEquals(t.IsCompleted__c,TRUE);
            
            delete t;
            
            Test.stopTest();
        }
    }
}