@isTest
public with sharing class SCC_DroneEDC_Test {
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
        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;
    }

    @isTest
    static void CaseTest(){
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type__r.Name,SCC_Call_Type__r.External_Id__c', 'Case', '', '', '', '1');
        Test.startTest();
        SCC_DroneEDC.getCaseDetail(cs.Id);
        SCC_DroneEDC.updateCase(cs.Id, 'test');
        Test.stopTest();
    }
}