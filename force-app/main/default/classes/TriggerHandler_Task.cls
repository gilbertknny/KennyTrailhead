/**
 * Class for Trigger Task
 * TC : GS
 * DATE : 10/10/25
 */

public with sharing class TriggerHandler_Task extends TriggerHandler{
    public override void beforeInsert(){ 
        List<BusinessHours> listBH = [SELECT Id FROM BusinessHours WHERE isDefault = TRUE WITH SECURITY_ENFORCED LIMIT 1];
        for(Task data : (List<Task>) Trigger.new) {
            string milestonename = 'SLA1';
            if(data.Milestone__c != null){
                milestonename = data.Milestone__c;
            }
            if(data.Status == 'Open' || data.Status == 'Draft' || data.Status == 'In Progress'){
                data.Milestone_Name__c = milestonename;
                Decimal dDuration = Decimal.valueOf(Label.SLA_Duration);
                Transaction_Milestone__mdt tm = Transaction_Milestone__mdt.getInstance(milestonename);
                if(tm != null){
                    listBH = [SELECT Id FROM BusinessHours WHERE Name =:tm.Business_Hours__c WITH SECURITY_ENFORCED];
                    dDuration = tm.Duration__c;
                }
                if(listBH.size()>0){
                    BusinessHours bH = listBH[0];
                    Integer iDuration = Integer.valueOf(dDuration)*1000*60;//minute
                    data.StartDate__c = DateTime.Now();
                    data.Business_Hours__c = BH.Id;
                    data.TargetDate__c = BusinessHours.add(BH.id,data.StartDate__c,iDuration);
                    data.TargetResponseInMins__c = dDuration;
                    data.PauseDate__c = NULL;
                    data.ActivityDate = data.TargetDate__c.date();
                }
            }else if(data.Status == 'Completed'){
                data.Milestone_Name__c = milestonename;
                Transaction_Milestone__mdt tm = Transaction_Milestone__mdt.getInstance(milestonename);
                listBH = [SELECT Id FROM BusinessHours WHERE Name =:tm.Business_Hours__c WITH SECURITY_ENFORCED];
                if(listBH.size()>0){
                    BusinessHours bH = listBH[0];
                    Integer iDuration = Integer.valueOf(tm.Duration__c)*1000*60; //minute
                    data.StartDate__c = DateTime.Now();
                    data.Business_Hours__c = BH.Id;
                    data.TargetDate__c = BusinessHours.add(BH.id,data.StartDate__c,iDuration);
                    data.TargetResponseInMins__c = tm.Duration__c;
                    data.CompletionDate__c = DateTime.Now();
                    data.ElapsedTimeInMins__c = (BusinessHours.diff(data.Business_Hours__c,data.StartDate__c,data.CompletionDate__c))/1000/60; //minute
                    if(data.StoppedTimeInMins__c == NULL){
                        data.StoppedTimeInMins__c = 0;
                    }
                    data.ActualElapsedTimeInMins__c = data.ElapsedTimeInMins__c - data.StoppedTimeInMins__c;
                    data.PauseDate__c = NULL; 
                    data.ActivityDate = Date.Today();
                }
            }
        }
    }
    
    public override void afterInsert(){ 
        Set<Id> leadIds = new Set<Id>();
        for(Task data : (List<Task>) Trigger.new) {
            //Added by fikri, for update task Counter in lead object
            if (data.WhoId != null && String.valueOf(data.WhoId).startsWith('00Q')) {
                leadIds.add(data.WhoId);
            }
        }
        
        if (!leadIds.isEmpty()) {
            Map<Id, Integer> counts = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT WhoId, COUNT(Id) cnt
                FROM Task
                WHERE WhoId IN :leadIds WITH SECURITY_ENFORCED
                GROUP BY WhoId
            ]) {
                counts.put((Id)ar.get('WhoId'), (Integer)ar.get('cnt'));
            }
            
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Id lid : leadIds) {
                leadsToUpdate.add(new Lead(
                    Id = lid,
                    Task_Counter__c = counts.containsKey(lid) ? counts.get(lid) : 0
                ));
            }
            List<Database.SaveResult> sr = Database.update(leadsToUpdate);
        }
    }
    
    public override void beforeUpdate(){
        for(Task data : (List<Task>) Trigger.new) {
            Task olddata = (Task) Trigger.oldMap.get(data.id); 
            if(olddata.TargetResponseInMins__c != data.TargetResponseInMins__c && data.TargetResponseInMins__c != null){
                Integer iDuration = Integer.valueOf(data.TargetResponseInMins__c)*1000*60;
                data.TargetDate__c = BusinessHours.add(data.Business_Hours__c,data.StartDate__c,iDuration);
                data.PauseDate__c = NULL;
                data.ActivityDate = data.TargetDate__c.date();
            }else if(olddata.Status != data.Status){
                if(data.Status == 'Open' || data.Status == 'Draft' || data.Status == 'In Progress'){
                    /*if(olddata.Status == 'Draft' || olddata.Status == 'Open' || olddata.Status == 'In Progress'){
                        string milestonename = 'SLA1';
                        List<BusinessHours> listBH = [SELECT Id FROM BusinessHours WHERE isDefault = TRUE LIMIT 1];
                        Decimal dDuration = Decimal.valueOf(Label.SLA_Duration);
                        Transaction_Milestone__mdt tm = Transaction_Milestone__mdt.getInstance(milestonename);
                        if(tm != null){
                            listBH = [SELECT Id FROM BusinessHours WHERE Name =:tm.Business_Hours__c];
                            dDuration = tm.Duration__c;
                        }
                        if(listBH.size()>0){
                            BusinessHours BH = listBH[0];
                            Integer iDuration = Integer.valueOf(dDuration)*1000*60; //minute
                            data.StartDate__c = DateTime.Now();
                            data.Business_Hours__c = BH.Id;
                            data.TargetDate__c = BusinessHours.add(BH.id,data.StartDate__c,iDuration);
                            data.TargetResponseInMins__c = dDuration;
                            data.PauseDate__c = NULL;
                            data.ActivityDate = data.TargetDate__c.date();
                        }
                    }else*/
                    if(olddata.Status == 'On Hold' && data.StoppedTimeInMins__c == NULL){ data.StoppedTimeInMins__c = 0; }
                    if(olddata.Status == 'On Hold'){
                        data.StoppedTimeInMins__c = data.StoppedTimeInMins__c+(BusinessHours.diff(data.Business_Hours__c,data.PauseDate__c,DateTime.Now()))/1000/60; //minute
                        data.PauseDate__c = NULL;
                    }
                }else if(data.Status == 'On Hold' && data.PauseDate__c == NULL){
                    data.PauseDate__c = DateTime.Now();
                }else if(data.Status == 'Completed'){
                    data.CompletionDate__c = DateTime.Now();
                    data.ElapsedTimeInMins__c = (BusinessHours.diff(data.Business_Hours__c,data.StartDate__c,data.CompletionDate__c))/1000/60; //minute
                    if(data.StoppedTimeInMins__c == NULL){
                        data.StoppedTimeInMins__c = 0;
                    }
                    data.ActualElapsedTimeInMins__c = data.ElapsedTimeInMins__c - data.StoppedTimeInMins__c;
                    data.PauseDate__c = NULL;    
                    data.ActivityDate = Date.Today();
                }
            }
        } 
    }
    
    public override void afterDelete(){
        Set<Id> leadIds = new Set<Id>();
        
        // Collect all Lead IDs from deleted tasks
        for (Task t : (List<Task>) Trigger.old) {
            if (t.WhoId != null && String.valueOf(t.WhoId).startsWith('00Q')) {
                leadIds.add(t.WhoId);
            }
        }
        
        if (!leadIds.isEmpty()) {
            // Query current task counts after deletion
            Map<Id, AggregateResult> counts = new Map<Id, AggregateResult>(
                [SELECT WhoId, COUNT(Id) cnt
                 FROM Task
                 WHERE WhoId IN :leadIds WITH SECURITY_ENFORCED
                 GROUP BY WhoId]
            );
            
            List<Lead> leadsToUpdate = new List<Lead>();
            
            for (Id leadId : leadIds) {
                Decimal count = counts.containsKey(leadId) ? (Decimal)counts.get(leadId).get('cnt') : 0;
                leadsToUpdate.add(new Lead(Id = leadId, Task_Counter__c = count));
            }
            
            if (!leadsToUpdate.isEmpty()) {
                List<Database.SaveResult> sr = Database.update(leadsToUpdate);
            }
        }
    }
    
}