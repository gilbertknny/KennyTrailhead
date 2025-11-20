/**
 * @description       : 
 * @author            : Suherbing Septian
 * @created date      : 15-09-2025
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Suherbing Septian
**/

@isTest
private class SCC_CaseResolution_RTGS_Ctrl_Test {
    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8222');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        cs.SCC_Notes__c = '{\n  \"Bank Tujuan\": \"BANK BCA\",\n  \"Nomor Rekening\": \"00520000001500\",\n  \"Pemilik Rekening\": \"01-01-CHIP-GOOD               \",\n  \"Waktu Transaksi\": \"2025-09-10 00:07:06\",\n  \"Remark\": \"RTGS841645056834NBMB119501002373504 5134095135531841 ESB:NBMB:000IE00K:841645056834\",\n  \"Keterangan Tambahan\": \"Aselolee\"\n}';
        insert cs;

        // Buat custom setting BRIMO__c
        BRIMO__c brimoSetting = new BRIMO__c(
            Name = 'extId RTGS',
            request_refnum__c = 1000
        );
        insert brimoSetting;
    }

    @isTest
    static void searchRtgs() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_FindRTGSMock.FindRTGS());
        SCC_CaseResolution_RTGS_Ctrl.searchRtgs('08322532523322','08322532523322',cs.id);
        SCC_CaseResolution_RTGS_Ctrl.updateCaseRemittance(cs.id,'08322532523321','08322532523321');
        SCC_CaseResolution_RTGS_Ctrl.extractBillingNumber(cs.SCC_Notes__c);
        Test.stopTest();
    }

    @isTest
    static void testFailureUpdate() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_CaseResolution_RTGS_Ctrl.updateCaseRemittance(null, '08322532523321', '08322532523321');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testFailureExtract() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_CaseResolution_RTGS_Ctrl.extractBillingNumber(null);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testDummyLabel() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        SCC_CaseResolution_RTGS_Ctrl.useDummyResponseInTest = true;
        SCC_CaseResolution_RTGS_Ctrl.searchRtgs('08322532523322','08322532523322',cs.id);
        Test.stopTest();
    }
}