global with sharing class SCC_ScheduleRetry implements Schedulable{
    global void execute(SchedulableContext ctx) {
        String cond = '( Accountid=null and scc_account_number__c!=null and IsClosed__c=false) and createdby.name!='+'\'Migration'+'\' and createdby.name!='+'\'Bondan Hartawan'+'\'';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Case', cond, 'createddate', 'DESC', '');
        Database.executeBatch(new SCC_GetAccount(queries), 1);
        List<CronTrigger> ctlists = [SELECT Id, CronJobDetail.name, CronJobDetail.jobtype, NextFireTime, PreviousFireTime, State, StartTime, EndTime, 
                                             CronExpression, TimeZoneSidKey, OwnerId, LastModifiedById, CreatedById, CreatedDate, TimesTriggered 
                                             FROM CronTrigger 
                                             where CronJobDetail.name LIKE  '%SCC Schedule Retry%'];
        if(CTlists.size()>0){
            for(CronTrigger apxjob:CTlists){
                System.abortJob(apxJob.Id);
            }
        }
        Datetime nexttime = system.now().addhours(integer.valueOf(label.add_hours));
        SCC_ScheduleRetry sch = new SCC_ScheduleRetry();
        System.schedule('SCC Schedule Retry - '+nexttime, '0 '+nexttime.minute()+' '+nexttime.hour()+' * * ? *', sch);
    }
}