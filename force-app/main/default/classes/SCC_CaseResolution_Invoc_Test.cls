@isTest
public with sharing class SCC_CaseResolution_Invoc_Test {
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
    static void testClass(){
        Case cs = [select id from case limit 1];
        test.startTest();
        List<SCC_CaseResolution_Invoc.flowInputvalues> listfi = new List<SCC_CaseResolution_Invoc.flowInputvalues>();
        SCC_CaseResolution_Invoc.flowInputvalues fi = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi.csid = cs.id;
        fi.source = 'CHM Support';
        fi.tipe ='Pembukuan';
        SCC_CaseResolution_Invoc.flowInputvalues fi1 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi1.source = 'CHM Support';
        fi1.tipe ='User';
        SCC_CaseResolution_Invoc.flowInputvalues fi2 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi2.csid = cs.id;
        fi2.source = 'BRI Notification';
        fi2.tipe ='Whatsapp Notification';
        SCC_CaseResolution_Invoc.flowInputvalues fi3 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi3.csid = cs.id;
        fi3.source = 'Rekon';
        fi3.tipe ='Flag Data Rekon';
        SCC_CaseResolution_Invoc.flowInputvalues fi4 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi4.csid = cs.id;
        fi4.source = 'Rekon';
        fi4.tipe ='Auto Closed Rekon';
        SCC_CaseResolution_Invoc.flowInputvalues fi5 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi5.csid = cs.id;
        fi5.source = 'CHM Support';
        fi5.tipe ='TID';
        SCC_CaseResolution_Invoc.flowInputvalues fi6 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi6.csid = cs.id;
        fi6.source = 'CHM Support';
        fi6.tipe ='PembukuanSelisih';
        listfi.add(fi);
        listfi.add(fi1);
        listfi.add(fi2);
        listfi.add(fi3);
        listfi.add(fi4);
        listfi.add(fi5);
        listfi.add(fi6);
        SCC_CaseResolution_Invoc.Invocablevoid(listfi);
        test.stopTest();
    }

    @isTest
    static void testClassMPN(){
        Case cs = [select id from case limit 1];
        test.startTest();
        List<SCC_CaseResolution_Invoc.flowInputvalues> listfi = new List<SCC_CaseResolution_Invoc.flowInputvalues>();
        SCC_CaseResolution_Invoc.flowInputvalues fi4 = new SCC_CaseResolution_Invoc.flowInputvalues();
        fi4.csid = cs.id;
        fi4.source = 'Rekon';
        fi4.tipe ='MPN';
        listfi.add(fi4);
        SCC_CaseResolution_Invoc.Invocablevoid(listfi);
        test.stopTest();
    }
}