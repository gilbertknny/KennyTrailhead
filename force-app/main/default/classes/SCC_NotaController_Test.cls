@isTest
public class SCC_NotaController_Test {
    @testSetup
    static void setupTestData() {
        Case testCase = new Case(
            SCC_Terminal_ID__c = 'TID12345',
            SCC_Transaction_Date__c = Date.today(),
            Description = 'Test case description'
        );
        insert testCase;

        SCC_Nota_Manual__c testNota = new SCC_Nota_Manual__c(
            Case__c = testCase.Id,
            SCC_Nama_Nasabah__c = 'Test Nasabah',
            SCC_Branchcode__c = '123',
            SCC_No_Rekening__c = '4567890',
            SCC_No_Kartu__c = '9876543210',
            SCC_Keterangan__c = 'Test Keterangan',
            SCC_Rekening_Titipan__c = 'RekTitipan123',
            SCC_Rekening_Fee__c = 'RekFee123',
            SCC_Jumlah_Kredit__c = 1000,
            SCC_Jumlah_Debit__c = 500,
            SCC_Total__c = 1500,
            SCC_No_Telepon__c = '08123456789',
            SCC_Jenis_Transaksi__c = '1111'
        );
        insert testNota;
    }

    @isTest
    static void testSCC_NotaController() {
        Case testCase = [SELECT Id, CreatedDate FROM Case LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/SCC_NotaPage?id=' + testCase.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);

        SCC_NotaController controller = new SCC_NotaController(sc);

        System.assertNotEquals(null, controller.caseId);
        System.assertEquals('123', controller.BRANCH_CODE);
        System.assertEquals('Test Nasabah', controller.NAMA_NASABAH);
        System.assertEquals('08123456789', '08123456789');
        System.assertEquals('1111', controller.JENISTRX);
        System.assertEquals('4567890', controller.NOREK);
        System.assertEquals('9876543210', controller.NOMOR_KARTU);
        System.assertEquals('TID12345', controller.TID);
        System.assertEquals('Test case description', controller.KETERANGAN1);
        System.assertEquals('RekTitipan123', controller.REKTITIPAN);
        System.assertEquals('RekFee123', controller.REKFEE);
        System.assertEquals(1000, controller.AMOUNTKREDIT);
        System.assertEquals(500, controller.AMOUNTDEBIT);
        System.assertEquals(1500, controller.TOTAL);
        System.assertEquals(testCase.CreatedDate.format('dd-MM-yyyy'), controller.CreatedDate);
    }
}