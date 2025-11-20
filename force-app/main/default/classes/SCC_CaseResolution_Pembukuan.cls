global without sharing class SCC_CaseResolution_Pembukuan implements Queueable, Database.AllowsCallouts{
    public String caseid {get;set;}
    global SCC_CaseResolution_Pembukuan(String caseid) {
        this.caseid = caseid;
    }
    global void execute(QueueableContext context) {
        SCC_CaseResolution_CHMSupport.PembukuanFuture(caseid);
    }
}