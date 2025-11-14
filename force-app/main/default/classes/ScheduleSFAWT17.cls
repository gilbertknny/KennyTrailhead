/** @description ScheduleSFAWT17 */
public with sharing class ScheduleSFAWT17 implements Schedulable {
    /** @description ScheduleSFAWT17 @param ctx */
    public void execute(SchedulableContext ctx){
        String schedulename = 'ScheduleSFAWT17';
        ScheduleSFAWT17.executeSFAWT17();
        ScheduleSFAWT17.deleteSchedule(schedulename);
        Integer nd = 1;
        Datetime td = System.now();
        Integer h = td.hour();
        Schedule__c mysc = Schedule__c.getInstance('Account');
        List<String> listime = mysc.Schedule_Time__c .split(';');
        Integer min = 23;
        Integer nt ;
        for(String x : listime){
            Integer y = Integer.valueOf(x);
            if(y < min){
                min = y ;
            }

            if(y > h){
                nt = y;
                nd = 0;
                break;
            }           
        }
        if(nd==1){
            nt = Integer.valueOf(min);
            td = td.addDays(1);
        }
        mysc.Last_Schedule__c = Decimal.valueOf(h);
        if(Schema.sObjectType.Schedule__c.isUpdateable()){
            update mysc;
        }
        String cronexp = '0 0 '+nt+' '+td.day()+' '+td.month()+' ? '+td.year();
        ScheduleSFAWT17 sch = new ScheduleSFAWT17();
        System.schedule(schedulename, cronexp, sch);
    }
    /** @description ScheduleSFAWT17  */
    public static void executeSFAWT17(){
        Map<Integer,Id> mapcurr = new Map<Integer,Id>();
        Integer curr = 0;
        Integer i = 0;
        List<Account> listacc = new List<Account>();
        listacc = [Select id from account where IsSchedule__c = true WITH SECURITY_ENFORCED];
        for(Account acc:listacc){
            mapcurr.put(i,acc.id);
            i++;
        }
        ID jobID = System.enqueueJob(new SFAWT17Queueable(curr,mapcurr));
    }
    /** @description ScheduleSFAWT17 @param schedulename */
    public static void deleteSchedule(String schedulename){
        List<CronTrigger> ctlists = [SELECT Id, CronJobDetail.name, CronJobDetail.jobtype, NextFireTime, PreviousFireTime, State, StartTime, EndTime, 
                                                CronExpression, TimeZoneSidKey, OwnerId, LastModifiedById, CreatedById, CreatedDate, TimesTriggered 
                                            FROM CronTrigger 
                                            where CronJobDetail.name =: schedulename WITH SECURITY_ENFORCED];
        if(!CTlists.isempty()){
            for(CronTrigger apxjob:CTlists){
                System.abortJob(apxJob.Id);
            }
        }
    }
}