global without sharing class ScheduleHoliday_APPK implements Schedulable{
    global void execute(SchedulableContext ctx) {
        String schedulename = 'Schedule Holiday APPK';
        Date nextrun = system.today().addDays(1);
        String cond = 'isclosed = false and (SCC_Call_Type__c !=null OR Pengisian_Form_APPK__c = true)';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Case', cond, 'createddate', 'Desc', '');
        Database.executeBatch(new BatchHoliday_APPK(queries), 10);
        List<CronTrigger> ctlists = [SELECT Id, CronJobDetail.name, CronJobDetail.jobtype, NextFireTime, PreviousFireTime, State, StartTime, EndTime, 
                                             CronExpression, TimeZoneSidKey, OwnerId, LastModifiedById, CreatedById, CreatedDate, TimesTriggered 
                                             FROM CronTrigger 
                                             where CronJobDetail.name =: schedulename];
        if(CTlists.size()>0){
            for(CronTrigger apxjob:CTlists){
                System.abortJob(apxJob.Id);
            }
        }
        Datetime nexttime = system.now().addhours(integer.valueOf(label.add_hours));
        ScheduleHoliday_APPK sch = new ScheduleHoliday_APPK();
        System.schedule(schedulename, '0 0 1 '+nextrun.day()+' '+nextrun.month()+' ? '+nextrun.year(), sch);
    }
}