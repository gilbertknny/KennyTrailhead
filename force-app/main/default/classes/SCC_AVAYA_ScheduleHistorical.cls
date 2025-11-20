global with sharing class SCC_AVAYA_ScheduleHistorical implements Schedulable{
    global void execute(SchedulableContext ctx) {
        SCC_AVAYA.setReportHistorical();
        String reportname = 'AVAYA_Schedule_Historical';
        AVAYA_Report__mdt ar = AVAYA_Report__mdt.getInstance(reportname);
        SCC_AVAYA.removeAvayaReport(reportname);
        Datetime nexttime = system.now().addMinutes(Integer.valueOf(ar.run_every__c));
        SCC_AVAYA_ScheduleHistorical sch = new SCC_AVAYA_ScheduleHistorical();
        System.schedule(reportname, '0 '+nexttime.minute()+' '+nexttime.hour()+' '+nexttime.day()+' '+nexttime.month()+' ? '+nexttime.year(), sch);
    }
}