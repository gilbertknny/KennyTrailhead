trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Task> taskList = new List<Task>();
    List<Opportunity> oppsWon = [SELECT Id,StageName FROM Opportunity WHERE StageName = 'Closed Won' AND Id in : Trigger.new];
    for(Opportunity opp : oppsWon){
       taskList.add(New Task(Subject='Follow Up Test Task', WhatId = opp.Id));
    }
    
    if(taskList.size()>0){
        insert taskList;
    }
}