@isTest
public with sharing class SCC_Rekon_Test {
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

    @IsTest
    static void searchRekonTokenEdc() {
        
        Case cs = [select id from case limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseTokenRekonEdc());
        SCC_Rekon.searchRekonTokenEdc(Object_Test.requestRekonTokenEdc(), 'rekon', cs.Id);
        Test.stopTest();
    }

    @isTest
    static void searchBAO() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseBeritaAcaraOpname());
        SCC_Rekon.SearchBAO(Object_Test.RequestBeritaAcaraOpname());
        Test.stopTest();
    }

    @isTest
    static void flagDataRekon() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseFlagDataRekon());
        SCC_Rekon.FlagDataRekon(Object_Test.RequestFlagDataRekon());
        Test.stopTest();
    }

    @isTest
    static void flagDataRekonFuture() {
        // TO DO: implement unit test
        Test.startTest();
        Case cs = [select id from case limit 1];
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseFlagDataRekon());
        SCC_RekonWrapper.ResponseRekonResult dat = Object_Test.ResponseRekonResult(200000,'Unmatch','Sedang Dikerjakan','2022-07-09T17:00:00.000Z');
        SCC_Rekon__c rek = Object_Test.setRekon(cs.id,dat);
        List<SCC_Rekon__c> listrek = new List<SCC_Rekon__c>();
        listrek.add(rek);
        SCC_Rekon.FlagDataRekonFuture(listrek,cs.id,'2024-01-01');
        Test.stopTest();
    }

    @isTest
    static void searchRekonError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseError());
        SCC_Rekon.SearchRekon(Object_Test.RequestRekon(), '8812');
        SCC_Rekon.SearchRekon(Object_Test.RequestRekon(), '8915');
        Test.stopTest();
    }

    @isTest
    static void searchBAOError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseError());
        SCC_Rekon.SearchBAO(Object_Test.RequestBeritaAcaraOpname());
        Test.stopTest();
    }

    @isTest
    static void flagDataRekonError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseError());
        SCC_Rekon.FlagDataRekon(Object_Test.RequestFlagDataRekon());
        Test.stopTest();
    }

    @isTest
    static void searchRekonToken() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.RekonTokenResponse());
        SCC_Rekon.searchRekonToken(Object_Test3.setRekonTokenRequest(),'','');
        Test.stopTest();
    }
}