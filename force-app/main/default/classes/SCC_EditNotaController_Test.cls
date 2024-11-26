@isTest
public class SCC_EditNotaController_Test {

    @isTest
    static void testGetNotaManual() {
        // Setup test case
        Case testCase = new Case(
            Subject = 'Test Case'
        );
        insert testCase;

        // Setup test nota manual
        SCC_Nota_Manual__c testNotaManual = new SCC_Nota_Manual__c(
            SCC_Jenis_Transaksi__c = '1111',
            SCC_No_Rekening__c = 'Test Account Number',
            SCC_No_Telepon__c = '123456789',
            SCC_Nama_Nasabah__c = 'Test Name',
            SCC_No_Kartu__c = '1234-5678-9123',
            SCC_Branchcode__c = '001',
            SCC_Keterangan__c = 'Test Keterangan',
            SCC_Rekening_Titipan__c = 'Titipan',
            SCC_Jumlah_Debit__c = 1000,
            SCC_Rekening_Fee__c = 'Fee Rekening',
            SCC_Jumlah_Fee__c = 10,
            SCC_Jumlah_Kredit__c = 1000,
            SCC_Rekening_Nasabah__c = 'Nasabah Rekening',
            Case__c = testCase.Id
        );
        insert testNotaManual;

        // Test getting nota manual
        Test.startTest();
        SCC_Nota_Manual__c returnedNotaManual = SCC_EditNotaController.getNotaManual(testCase.Id);
        Test.stopTest();

        // Asserts
        System.assertNotEquals(null, returnedNotaManual, 'SCC_Nota_Manual__c object should be retrieved');
        System.assertEquals('1111', returnedNotaManual.SCC_Jenis_Transaksi__c, 'SCC_Jenis_Transaksi__c should match');
        System.assertEquals('Test Account Number', returnedNotaManual.SCC_No_Rekening__c, 'SCC_No_Rekening__c should match');
    }

    @isTest
    static void testUpdateNotaManualFromForm() {
        // Setup test case
        SCC_Call_Type_Feature__c ct = new SCC_Call_Type_Feature__c(name='8812');
        insert ct;
        Case testCase = new Case(
            Subject = 'Test Case',
            SCC_Call_Type_Feature__c = ct.Id
        );
        insert testCase;

        // Setup test nota manual
        SCC_Nota_Manual__c testNotaManual = new SCC_Nota_Manual__c(
            SCC_Jenis_Transaksi__c = '1111',
            SCC_No_Rekening__c = 'Test Account Number',
            SCC_No_Telepon__c = '123456789',
            SCC_Nama_Nasabah__c = 'Test Name',
            SCC_No_Kartu__c = '1234-5678-9123',
            SCC_Branchcode__c = '001',
            SCC_Keterangan__c = 'Test Keterangan',
            SCC_Rekening_Titipan__c = 'Titipan',
            SCC_Jumlah_Debit__c = 1000,
            SCC_Rekening_Fee__c = 'Fee Rekening',
            SCC_Jumlah_Fee__c = 10,
            SCC_Jumlah_Kredit__c = 1000,
            SCC_Rekening_Nasabah__c = 'Nasabah Rekening',
            Case__c = testCase.Id
        );
        insert testNotaManual;

        // Setup test queue trans
        SCC_Queuetrans__c testQueueTrans = new SCC_Queuetrans__c(
            scc_case__c = testCase.Id,
            scc_amt_debet1__c = '0',
            scc_amt_kredit1__c = '0'
        );
        insert testQueueTrans;

        // Update nota manual
        testNotaManual.SCC_No_Rekening__c = 'Updated Account Number';
        testNotaManual.SCC_Jumlah_Debit__c = 2000;
        testNotaManual.SCC_Jumlah_Kredit__c = 2000;

        Test.startTest();
        SCC_Nota_Manual__c updatedNotaManual = SCC_EditNotaController.updateNotaManualFromForm(testNotaManual);
        Test.stopTest();

        // Retrieve updated nota manual
        SCC_Nota_Manual__c retrievedNotaManual = [SELECT SCC_No_Rekening__c, SCC_Jumlah_Debit__c, SCC_Jumlah_Kredit__c FROM SCC_Nota_Manual__c WHERE Id = :updatedNotaManual.Id];

        // Asserts
        System.assertNotEquals(null, updatedNotaManual, 'SCC_Nota_Manual__c object should be updated');
        System.assertEquals('Updated Account Number', retrievedNotaManual.SCC_No_Rekening__c, 'SCC_No_Rekening__c should be updated');
        System.assertEquals(2000, retrievedNotaManual.SCC_Jumlah_Debit__c, 'SCC_Jumlah_Debit__c should be updated');
        System.assertEquals(2000, retrievedNotaManual.SCC_Jumlah_Kredit__c, 'SCC_Jumlah_Kredit__c should be updated');

        // Retrieve updated queue trans
        SCC_Queuetrans__c updatedQueueTrans = [SELECT scc_amt_debet1__c, scc_amt_kredit1__c FROM SCC_Queuetrans__c WHERE Id = :testQueueTrans.Id];

        // Asserts
        System.assertEquals('2000', updatedQueueTrans.scc_amt_debet1__c, 'scc_amt_debet1__c should be updated');
        System.assertEquals('2000', updatedQueueTrans.scc_amt_kredit1__c, 'scc_amt_kredit1__c should be updated');
    }
    
    @isTest
    static void testUpdateNotaManualFailed() {
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
        SCC_Nota_Manual__c testNotaManual = new SCC_Nota_Manual__c(
            SCC_Jenis_Transaksi__c = 'Test',
            SCC_No_Rekening__c = 'Test Account Number',
            Case__c = testCase.Id
        );
        
        Test.startTest();
        SCC_Nota_Manual__c resultNotaManual;
        try {
            resultNotaManual = SCC_EditNotaController.updateNotaManualFromForm(testNotaManual);
        } catch (Exception error) {
            System.assertNotEquals(null, error, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), error.getTypeName(), 'AuraHandledException is expected');
            System.assertNotEquals(null, error.getMessage(), 'Nota Manual should be inserted first');
        }
        Test.stopTest();
    }
}