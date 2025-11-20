global with sharing class ScheduleCutiTahunan implements Schedulable{
    global void execute(SchedulableContext ctx) {
        Integer thn = system.now().year()-1;
        String cond = 'Tahun__c>='+thn;
        String allfield = SOQL_SOBJECT.getallfield('Cuti_Karyawan__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Cuti_Karyawan__c', cond, 'createddate', 'ASC', '');
        Database.executeBatch(new BatchUpdateCuti(queries), 100);
        List<CronTrigger> ctlists = [SELECT Id, CronJobDetail.name, CronJobDetail.jobtype, NextFireTime, PreviousFireTime, State, StartTime, EndTime, 
                                             CronExpression, TimeZoneSidKey, OwnerId, LastModifiedById, CreatedById, CreatedDate, TimesTriggered 
                                             FROM CronTrigger 
                                             where CronJobDetail.name LIKE  '%ScheduleCutiTahunan%'];
        if(CTlists.size()>0){
            for(CronTrigger apxjob:CTlists){
                System.abortJob(apxJob.Id);
            }
        }
        Datetime nexttime = system.now().addhours(integer.valueOf(label.add_hours));
        ScheduleCutiTahunan sch = new ScheduleCutiTahunan();
        System.schedule('ScheduleCutiTahunan', '0 0 0 1 1 ? *', sch);
    }
}