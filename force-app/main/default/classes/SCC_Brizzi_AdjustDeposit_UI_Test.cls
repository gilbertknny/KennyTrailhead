/**
 * @description       : Test class for SCC_Brizzi_AdjustDeposit_UI
 * @last modified on  : 17-09-2025
 * @last modified by  : Suherbing Septian
 */
@isTest
private class SCC_Brizzi_AdjustDeposit_UI_Test {
    @testSetup
    static void setupData() {
        SSC_Call_Type__c ct = Object_Test.setCallType('8713');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        insert cs;
        Adjust_Deposit__c ad = Object_Test_Brizzi.setAdjustDeposit(cs.id);
        ad.Nominal_Adjust__c = '50000';
        insert ad;
        Brizzi_Card__c bc = Object_Test_Brizzi.setChangeCard(cs.id);
        insert bc;
    }

    @isTest
    static void adjustDeposit() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_AdjustDeposit_Mock.AdjustDeposit());
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_CardInquiry_Mock.CardInquiry());
        SCC_Brizzi_AdjustDeposit_UI.getCardInfo(cs.id);
        SCC_Brizzi_AdjustDeposit_UI.retryAdjust(cs.id);
        SCC_Brizzi_AdjustDeposit_UI.adjustDepositBrizzi(cs.id);
        SCC_Brizzi_AdjustDeposit_UI.adjustDeposit(cs, '8789273822', 50000, true);
        SCC_Brizzi_AdjustDeposit_UI.getCaseDetails(cs.id);
        SCC_Brizzi_AdjustDeposit_UI.getBrizziCardInquiry(cs);
        SCC_Brizzi_AdjustDeposit_UI.getListAdjustment(cs.id,'23425');
        Test.stopTest();
    }

    @isTest
    static void adjustDepositBrizzi() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_AdjustDeposit_Mock.AdjustDeposit());
        SCC_Brizzi_AdjustDeposit_UI.adjustDepositBrizzi(cs.id);
        Test.stopTest();
    }

    @isTest
    static void adjustDepositQueuetrans1() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Adjust_Deposit__c ad = (Adjust_Deposit__c) SOQL_SOBJECT.SingleSobject('', 'Adjust_Deposit__c', '', '', '', '1');

        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;

        cs.SCC_Notes__c = 'test';
        cs.SCC_Result_Pembukuan__c = 'Successfully';
        update cs;

        ad.Status_Adjust__c = false;
        update ad;

        Test.startTest();
        Case cs2 = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        SCC_Brizzi_AdjustDeposit_UI.useDummyResponseInTest = true;
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_AdjustDeposit_Mock.AdjustDeposit());
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_CardInquiry_Mock.CardInquiry());
        SCC_Brizzi_AdjustDeposit_UI.retryAdjust(cs2.id);
        SCC_Brizzi_AdjustDeposit_UI.adjustDeposit(cs2, '8789273822', 50000, true);
        SCC_Brizzi_AdjustDeposit_UI.getCaseDetails(cs2.id);
        SCC_Brizzi_AdjustDeposit_UI.getBrizziCardInquiry(cs2);
        Test.stopTest();
    }

    @isTest
    static void adjustDepositQueuetrans2() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Adjust_Deposit__c ad = (Adjust_Deposit__c) SOQL_SOBJECT.SingleSobject('', 'Adjust_Deposit__c', '', '', '', '1');

        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;

        cs.SCC_Notes__c = 'test';
        cs.SCC_Result_Pembukuan__c = 'Unsuccessfully';
        update cs;

        ad.Status_Adjust__c = false;
        update ad;

        Test.startTest();
        Case cs2 = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        SCC_Brizzi_AdjustDeposit_UI.useDummyResponseInTest = true;
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_AdjustDeposit_Mock.AdjustDeposit());
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_CardInquiry_Mock.CardInquiry());
        SCC_Brizzi_AdjustDeposit_UI.retryAdjust(cs2.id);
        SCC_Brizzi_AdjustDeposit_UI.adjustDeposit(cs2, '8789273822', 50000, true);
        SCC_Brizzi_AdjustDeposit_UI.getCaseDetails(cs2.id);
        SCC_Brizzi_AdjustDeposit_UI.getBrizziCardInquiry(cs2);
        Test.stopTest();
    }

    @isTest
    static void adjustDepositQueuetrans3() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Adjust_Deposit__c ad = (Adjust_Deposit__c) SOQL_SOBJECT.SingleSobject('', 'Adjust_Deposit__c', '', '', '', '1');

        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;

        cs.SCC_Notes__c = 'test';
        cs.SCC_Result_Pembukuan__c = 'Successfully';
        update cs;

        ad.Status_Adjust__c = false;
        update ad;

        Test.startTest();
        Case cs2 = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        SCC_Brizzi_AdjustDeposit_UI.useDummyResponseInTest = true;
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_AdjustDeposit_Mock.AdjustDeposit());
        SCC_Brizzi_AdjustDeposit_UI.adjustDepositBrizzi(cs2.id);
        Test.stopTest();
    }

    @isTest
    static void adjustDepositQueuetrans4() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Adjust_Deposit__c ad = (Adjust_Deposit__c) SOQL_SOBJECT.SingleSobject('', 'Adjust_Deposit__c', '', '', '', '1');

        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;

        cs.SCC_Notes__c = 'test';
        cs.SCC_Result_Pembukuan__c = 'Unsuccessfully';
        update cs;

        ad.Status_Adjust__c = false;
        update ad;

        Test.startTest();
        Case cs2 = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        SCC_Brizzi_AdjustDeposit_UI.useDummyResponseInTest = true;
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_AdjustDeposit_Mock.AdjustDeposit());
        SCC_Brizzi_AdjustDeposit_UI.adjustDepositBrizzi(cs2.id);
        Test.stopTest();
    }

    @isTest
    static void updateData() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        SCC_Brizzi_AdjustDeposit_UI.insertDataAdjustment(cs, '1231231', 5000, 5500, 6000, true);
        Test.stopTest();
    }

    @isTest
    static void testDummyLabel() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',Maker__r.EmployeeNumber,Signer__r.EmployeeNumber', 'Case', '', '', '', '1');
        Test.startTest();
        SCC_Brizzi_AdjustDeposit_UI.useDummyResponseInTest = true;
        SCC_Brizzi_AdjustDeposit_UI.retryAdjust(cs.id);
        SCC_Brizzi_AdjustDeposit_UI.adjustDeposit(cs, '8789273822', 50000, true);
        SCC_Brizzi_AdjustDeposit_UI.getBrizziCardInquiry(cs);
        Test.stopTest();
    }

    @isTest
    static void testFailureAdjustDepositBrizzi() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_Brizzi_AdjustDeposit_UI.adjustDepositBrizzi(null);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testFailureAdjustDeposit() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_Brizzi_AdjustDeposit_UI.insertDataAdjustment(null, null, null, null, 6000, true);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }
}