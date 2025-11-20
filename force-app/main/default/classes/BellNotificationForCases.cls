/**
* @description       : Queue Notification to Leader Every Hour
* @last modified on  : 18/11/2024
* @last modified by  : Alvin Vigo
**/

public class BellNotificationForCases implements Database.batchable<sObject>,schedulable{ 
    Set<Id> queueId = new Set<Id>();
    
    @testVisible
    private static boolean isTest = false;
    
    public BellNotificationForCases(){
        List<AggregateResult> abc = [SELECT OwnerId, Count(Id) CaseCount FROM Case WHERE Owner.Type = 'Queue' Group By OwnerId];
        for(AggregateResult a: abc){
            queueId.add((Id)a.get('ownerId')); 
        }
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,DeveloperName  FROM Group WHERE Type = \'Queue\' AND Id IN:queueId');
    }
    
    public void execute(Database.BatchableContext bc,List<Group> scope){
        for(Group groupRecord : scope){
            Map<String, Object> params = new Map<String, Object>();
            params.put('queueId', groupRecord.Id);
            params.put('queueName', groupRecord.DeveloperName);
            Flow.Interview.SSC_Scheduled_Queue_Notification bellNotification = new Flow.Interview.SSC_Scheduled_Queue_Notification(params);
            bellNotification.start();
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    public void execute(SchedulableContext SC) {
        if(isTest){
            Database.executeBatch(new BellNotificationForCases(),200);
        }
        else {
       		 Database.executeBatch(new BellNotificationForCases(),1);     
        }   
    }
}