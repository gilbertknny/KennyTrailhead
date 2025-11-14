/**
 * Controller for LWC "milestoneTracker"
 * TC : GS
 * DATE : 10/10/25
 */

public without sharing class CustomMilestoneService { 
    public class CustomMilestoneWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public Boolean hasCaseType { get; set; }
        @AuraEnabled
        public Boolean milestoneStarted { get; set; }
        @AuraEnabled
        public String milestoneName { get; set; }
        @AuraEnabled
        public String teamName { get; set; }
        @AuraEnabled
        public Boolean isViolated { get; set; }
        @AuraEnabled
        public Boolean isCompleted { get; set; }
        @AuraEnabled
        public Datetime targetDate { get; set; }
        @AuraEnabled
        public String elapsedTimeInMins { get; set; }
        @AuraEnabled
        public Integer targetResponseInMins { get; set; }
        @AuraEnabled
        public String timeSinceTargetInMins { get; set; }
        @AuraEnabled
        public String timeRemainingInMins { get; set; }
        @AuraEnabled
        public Boolean isStop { get; set; }
        @AuraEnabled
        public Boolean isActive { get; set; }
        @AuraEnabled
        public Integer targetDay { get; set; }
        
        public CustomMilestoneWrapper(String id, Boolean hasCaseType, Boolean milestoneStarted, String milestoneName, String teamName, Boolean isViolated, Boolean isCompleted, Datetime targetDate, String elapsedTimeInMins, Integer targetResponseInMins, String timeSinceTargetInMins,  String timeRemainingInMins, Boolean isStop, Boolean isActive, Integer targetDay) {
            this.id = id;
            this.hasCaseType = hasCaseType;
            this.milestoneStarted= milestoneStarted;
            this.milestoneName = milestoneName;
            this.teamName = teamName;
            this.isViolated = isViolated;
            this.isCompleted = isCompleted;
            this.targetDate = targetDate;
            this.elapsedTimeInMins = elapsedTimeInMins;
            this.targetResponseInMins = targetResponseInMins;
            this.timeSinceTargetInMins = timeSinceTargetInMins;
            this.timeRemainingInMins = timeRemainingInMins;
            this.isStop = isStop;
            this.isActive = isActive;
            this.targetDay = targetDay;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CustomMilestoneWrapper> getCustomMilestonesWithDetails(Id recordId) {   
        system.debug(LoggingLevel.WARN,'recordId:'+recordId);
        List<CustomMilestoneWrapper> msWrapper = new List<CustomMilestoneWrapper>();
        List<Task> listtask = [SELECT Id,StartDate__c,Business_Hours__c,TargetDate__c,TargetResponseInMins__c,Status,
                               IsViolated__c,IsCompleted__c,CompletionDate__c,ElapsedTimeInMins__c,StoppedTimeInMins__c,
                               ActualElapsedTimeInMins__c,Milestone_Name__c,Subject,PauseDate__c
                               FROM Task 
                               WHERE WhatId =:recordId
                               AND StartDate__c != NULL
                               AND TaskSubtype = 'TASK' WITH SECURITY_ENFORCED
                               ORDER BY createddate DESC]; //TaskSubtype != 'CALL'
        Map<String, Task> mapTask = new Map<String, Task>();
        for(Task t:listtask){
            mapTask.put(t.Id,t);
            
        }
        for(Task t:listtask){     
            msWrapper.addAll(addMilestoneNew(mapTask.get(t.Id),true,true,t.Subject,NULL,NULL));
        }
        system.debug(LoggingLevel.WARN,'msWrapper:'+msWrapper);
        system.debug(LoggingLevel.WARN,'msWrapper-size():'+msWrapper.size());
        
        return msWrapper;
    }
    
    public static List<CustomMilestoneWrapper> addMilestoneNew(Task t,
                                                             Boolean hasCaseType,
                                                             Boolean showMilestone,
                                                             String milestoneName,
                                                             Integer slaMilestone,
                                                             String milestoneTeam)
    {
        List<CustomMilestoneWrapper> msWrapper = new List<CustomMilestoneWrapper>();
        Integer totalElapsedTime = 0;
        Integer elapsedSecond = 0;
        Integer allElapsedTime = 0;
        Integer iTargetMins = 0;
        DateTime dtTarget;
        Integer violatedMins = 0;
        Integer violatedSecond = 0;
        Boolean isStopped = FALSE;
        
        if(t != null){
            Id businessHourId = t.Business_Hours__c;
            DateTime dtNow = DateTime.Now();
            Boolean fgBusinessHour = false;
            if(businessHourId != null && isStopped == false){
                fgBusinessHour = BusinessHours.isWithin(BusinessHourId, dtNow);
                if(fgBusinessHour == false){isStopped = true;}
                else{isStopped = false;}
            }
            if(businessHourId != null){
                totalElapsedTime = (Integer)(BusinessHours.diff(BusinessHourId,t.StartDate__c,dtNow))/1000/60;
                Integer iStop = Integer.valueOf(t.StoppedTimeInMins__c);
                if(iStop == NULL){iStop = 0;}
                totalElapsedTime = totalElapsedTime-iStop;
                
                if(t.IsCompleted__c == TRUE){totalElapsedTime = Integer.valueOf(t.ActualElapsedTimeInMins__c);}
                if(milestoneName == NULL){milestoneName = t.Milestone_Name__c;}
                
                Boolean isViolated = t.IsViolated__c;
                if(totalElapsedTime > t.TargetResponseInMins__c && t.IsCompleted__c == FALSE){
                    isViolated = TRUE;
                    totalElapsedTime = (Integer)(BusinessHours.diff(BusinessHourId,t.TargetDate__c,dtNow))/1000/60;
                    totalElapsedTime = totalElapsedTime-iStop;
                }
                
                if(dtTarget == null){dtTarget = t.TargetDate__c;}
                if(slaMilestone == null){slaMilestone = Integer.valueOf(t.TargetResponseInMins__c);}
                
                if(t.Status == 'On Hold'){
                    isStopped = TRUE;
                    totalElapsedTime = (Integer)(BusinessHours.diff(BusinessHourId,t.StartDate__c,t.PauseDate__c))/1000/60;
                    totalElapsedTime = totalElapsedTime-iStop;
                }
                
                String elapsedTimeInMins = String.ValueOf(totalElapsedTime) + ':' + elapsedSecond;
                String strTimeTarget = elapsedTimeInMins;//cm.TimeSinceTargetInMins; //COMPLETED
                String strTime = '00:00';//cm.TimeRemainingInMins;  
                
                msWrapper.add(new CustomMilestoneWrapper(t.id,
                    								   hasCaseType,
                                                       true,
                                                       milestoneName,
                                                       milestoneTeam,
                                                       isViolated,
                                                       t.IsCompleted__c,
                                                       dtTarget,
                                                       elapsedTimeInMins,
                                                       slaMilestone, //cm.TargetResponseInMins,
                                                       strTimeTarget,
                                                       strTime,
                                                       isStopped,
                                                       false,
                                                       0));
            }
        }
        return msWrapper;
    }
}