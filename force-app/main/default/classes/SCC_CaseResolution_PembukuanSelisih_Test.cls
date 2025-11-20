/**
* @description       : Pembukuan Selisih
* @last modified on  : 15/01/2025
* @last modified by  : Suherbing Septian
**/

@isTest
private class SCC_CaseResolution_PembukuanSelisih_Test {
    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8812');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        insert cs;
        SCC_Rekening_Koran__c rek = Object_Test.setRekeningKoran(cs.id);
        insert rek;
        SCC_Rekon__c rk = Object_Test.setRekon(cs.id);
        insert rk;
        SCC_Berita_Acara_Opname__c bao = Object_Test.setBeritaAcaraOpname(cs.id);
        insert bao;
        List<SCC_Queuetrans__c> listque = new List<SCC_Queuetrans__c>();
        for(integer i = 0;i<5;i++){
            SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
            listque.add(que);
        }
        insert listque;
    }

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        Case cs = [select id from case limit 1];
        test.startTest();
        System.enqueueJob(new SCC_CaseResolution_PembukuanSelisih(cs.id));
        test.stopTest();
    }
}