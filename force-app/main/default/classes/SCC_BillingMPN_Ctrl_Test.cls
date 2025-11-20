/**
 * @description       : Test class for SCC_BillingMPN_Ctrl
 * @last modified on  : 24-02-2025
 * @last modified by  : Ardyta Yudianto
 */
@isTest
private class SCC_BillingMPN_Ctrl_Test {
    
    @TestSetup
    static void setupTestData() {
        SSC_Call_Type__c ct = Object_Test.setCallType('8810');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        cs.SCC_Notes__c = '{\n  \"Bank Tujuan\": \"BANK BCA\",\n  \"Nomor Pembayaran\": \"00520000001500\",\n  \"Pemilik Rekening\": \"01-01-CHIP-GOOD               \",\n  \"Waktu Transaksi\": \"2025-09-10 00:07:06\",\n  \"Remark\": \"RTGS841645056834NBMB119501002373504 5134095135531841 ESB:NBMB:000IE00K:841645056834\",\n  \"Keterangan Tambahan\": \"Aselolee\"\n}';
        insert cs;
    }
    
    @isTest
    static void searchBillingMPN() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BillingMPN_Mock.BillingMPN());
        SCC_BillingMPN_Ctrl.searchBillingMPN('08322532523322','IDR',cs.id);
        SCC_BillingMPN_Ctrl.updateBillingNumber(cs.id);
        SCC_BillingMPN_Ctrl.updateCaseMPNId(cs.id,'08322532523322','08322532523322');
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateCaseMPNId_Failur() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_BillingMPN_Ctrl.updateCaseMPNId(null, 'MPN123456789', 'MPN123456789');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testExtractNumber_Failur() {
        Exception caughtException = null;
        Test.startTest();
        try {
            SCC_BillingMPN_Ctrl.extractBillingNumber(null);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }
}