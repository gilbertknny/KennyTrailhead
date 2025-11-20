/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCC_BRINotif_Test {

    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8812');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.SCC_Status_Transaksi__c = 'Berhasil';
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
    static void sendWANotif() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BRINotifMock.WANotifResponse());
        SCC_BRINotif.sendWANotif(Object_Test.WANotifRequest());
        test.stopTest();
    }


    @isTest
    static void insertErrorLog() {
        // TO DO: implement unit test
        Test.startTest();
        SCC_BRINotif.insertErrorLog(null, new HttpRequest(), new HTTPResponse(), '');
        Test.stopTest();
    }

    @isTest
    static void testSetupWA(){
        Test.startTest();
        SSC_Call_Type__c ct = Object_Test.setCallType('8915');
        insert ct;
        Account acc = new Account();
        acc.name = 'Hafidz';
        acc.Phone = '08767676767676';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        insert acc;
        Case cs = Object_Test.setCase(ct.id);
        cs.SCC_Legacy_Ticket_ID__c = 'xxx';
        cs.AccountId = acc.id;
        cs.SCC_Cust_Phone1__c = '087867676767676';
        insert cs;
        SCC_BRINotif.setWANotifRequest(cs.id);
        Test.stopTest();
    }

    @isTest
    static void notification(){
        Account acc = new Account();
        acc.lastname = 'Hafidz';
        acc.PersonMobilePhone = '08767676767676';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert acc;
        Case cs = (Case) SOQL_SOBJECT.singleSobject('', 'Case', '', '', '', '1');
        cs.accountid = acc.id;
        cs.Cust_Current_Phone__c = '08767676767676';
        cs.SCC_Account_Number__c = '123456789012345';
        update cs;
        test.startTest();
        SCC_BRINotif.sendWANotifFuture(cs.id);
        test.stopTest();
    }
}