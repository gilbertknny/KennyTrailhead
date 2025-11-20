/**
* @description       : Test Class for BrizziCalloutQueueable
* @last modified on  : 03-04-2025, 15-09-2025
* @last modified by  : Suherbing Septian
**/
@isTest
private class SCC_BrizziCalloutQueueable_Test {

    // Test setup method to create test data
    @testSetup
    static void setupTestData() {
        // Create test Case record
        Case testCase = new Case(
            Subject = 'Test Brizzi Pembukuan Case',
            Description = 'Test case for Brizzi Pembukuan transaction',
            SCC_Nomor_Briva_Tagihan__c = '1234567890',
            Status = 'Draft',
            SCC_Brizzi_Card_Number__c = '082523523523523',
            SCC_Notes__c = '{\n  \"Bank Tujuan\": \"BANK BCA\",\n  \"Nomor Pembayaran\": \"00520000001500\",\n  \"Pemilik Rekening\": \"01-01-CHIP-GOOD               \",\n  \"Waktu Transaksi\": \"2025-09-10 00:07:06\",\n  \"Remark\": \"RTGS841645056834NBMB119501002373504 5134095135531841 ESB:NBMB:000IE00K:841645056834\",\n  \"Keterangan Tambahan\": \"Aselolee\"\n}'
        );
        insert testCase;

        Adjust_Deposit__c ad = Object_Test_Brizzi.setAdjustDeposit(testCase.id);
        insert ad;

        Brizzi_Card__c bc = Object_Test_Brizzi.setChangeCard(testCase.id);
        bc.Nomor_Kartu_Brizzi__c = '082523523523523';
        bc.Saldo__c = '5000';
        bc.Saldo_Deposit__c = '5000';
        insert bc;

        system.debug('Test Case '+testCase);
        // Create Queue Trans record 
        List<SCC_Queuetrans__c> queueTrans = new List<SCC_Queuetrans__c>{
            new SCC_Queuetrans__c(
                SCC_Case__c = testCase.Id,
                SCC_Status__c = 'Transaction Successfully',
                scc_acct_kredit1__c = '020601003837305',
                scc_amt_kredit1__c = '50000'
            )
        };
        insert queueTrans;
    }

    @isTest
    static void testPembukuanUlangBrizziOperation() {
        // Get test record ID
        Id testCase = [SELECT Id FROM Case LIMIT 1].Id;
        
        Test.startTest();
        SCC_BrizziCalloutQueueable queueable = new SCC_BrizziCalloutQueueable(testCase, 'Pembukuan Ulang Brizzi');
        Id jobId = System.enqueueJob(queueable);
        queueable.execute(null);
        
        Test.stopTest();
    }

    @isTest
    static void adjustDepositBrizzi() {
        Id testCase = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        SCC_BrizziCalloutQueueable queueable = new SCC_BrizziCalloutQueueable(testCase, 'Adjust Deposit');
        Id jobId = System.enqueueJob(queueable);
        queueable.execute(null);
        
        Test.stopTest();
    }

    @isTest
    static void replaceCard() {
        Id testCase = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        SCC_BrizziCalloutQueueable queueable = new SCC_BrizziCalloutQueueable(testCase, 'Replace Card Invoc');
        Id jobId = System.enqueueJob(queueable);
        queueable.execute(null);
        
        Test.stopTest();
    }

    @isTest
    static void updateBillingNumber() {
        Id testCase = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        SCC_BrizziCalloutQueueable queueable = new SCC_BrizziCalloutQueueable(testCase, 'BillingMPN');
        Id jobId = System.enqueueJob(queueable);
        queueable.execute(null);
        
        Test.stopTest();
    }

    @isTest
    static void testPembukuanOperation() {
        Id testCase = [SELECT Id FROM Case LIMIT 1].Id;
        
        Test.startTest();
        SCC_BrizziCalloutQueueable queueable = new SCC_BrizziCalloutQueueable(testCase, 'pembukuan');
        Id jobId = System.enqueueJob(queueable);
        queueable.execute(null);
        Test.stopTest();
    }
}