/**
* @description       : Pembukuan Selisih
* @last modified on  : 15/01/2025
* @last modified by  : Suherbing Septian
**/

global with sharing class SCC_CaseResolution_PembukuanSelisih implements Queueable, Database.AllowsCallouts{
    public String caseid {get;set;}
    global SCC_CaseResolution_PembukuanSelisih(String caseid) {
        this.caseid = caseid;
    }
    global void execute(QueueableContext context) {
        SCC_CaseResolution_CHMSupport.PembukuanSelisih(caseid);
    }
}