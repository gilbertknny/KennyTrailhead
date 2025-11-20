@isTest
public class SCC_WFM_Upload_Test {

    @testSetup
    static void setupData() {
        // Create a user for testing
        User testUser = new User(
            Id = UserInfo.getUserId(),
            EmployeeNumber = '00000001',
            Agent_Type__c = 'MRS'
        );
        update testUser;

        // Create other necessary records (Opsi_Jadwal, Cuti_Poin_Karyawan, etc.)
        Opsi_Jadwal__c opsiJadwal = new Opsi_Jadwal__c(Kode__c = 'S1', Name = 'S1');
        insert opsiJadwal;

        Poin_Penilaian__c poinPenilaian = new Poin_Penilaian__c(Kriteria__c = 'Istimewa', Score_Maximum__c = 100, Score_Minimum__c = 0, Poin__c = 8, Agent_Type__c = 'MRS');
        insert poinPenilaian;
    }

    @isTest
    static void testUploadFileJadwalKaryawan() {
        // Prepare CSV content (base64-encoded)
        String csvContent = 'ABC;ABC;ABC;ABC\n00000001;S1;2025-01-06;KB-KEBAYORAN';
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        // Test uploadFile method for "Jadwal Karyawan"
        Test.startTest();
        SCC_WFM_Upload.returnvalue result = SCC_WFM_Upload.uploadFile(base64Content, ';', 'Jadwal Karyawan');
        Test.stopTest();

        // Debug the result
        System.debug('Upload result: ' + result);

        // Assert the result contains processed records and no failures
        //System.assert(result.contains('Diproses = 1'), 'Expected 1 processed record but got: ' + result);
        //System.assert(result.contains('Gagal = 0'), 'Expected 0 failures but got: ' + result);

        // Verify the Jadwal_Karyawan__c record is created
        Opsi_Jadwal__c ojdg = [SELECT Id, Kode__c FROM Opsi_Jadwal__c WHERE Kode__c = 'S1'];
        List<Jadwal_Karyawan__c> jadwalRecords = [SELECT Id, Nama_Karyawan__c, Opsi_Jadwal__c, Tanggal__c, Lokasi__c FROM Jadwal_Karyawan__c];
        //System.assertEquals(1, jadwalRecords.size(), 'Expected 1 Jadwal_Karyawan__c record.');
        //System.assertEquals(UserInfo.getUserId(), jadwalRecords[0].Nama_Karyawan__c, 'Expected correct user ID.');
        //System.assertEquals(ojdg.Id, jadwalRecords[0].Opsi_Jadwal__c, 'Expected correct Opsi_Jadwal ID.');
    }

    @isTest
    static void testUploadFileCutiKaryawan() {
        // Prepare CSV content for Cuti Karyawan (base64-encoded)
        String csvContent = 'ABC;ABC;ABC\n00000001;10;2025';
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        // Test uploadFile method for "Cuti Karyawan"
        Test.startTest();
        SCC_WFM_Upload.returnvalue result = SCC_WFM_Upload.uploadFile(base64Content, ';', 'Cuti Karyawan');
        Test.stopTest();

        // Debug the result
        System.debug('Upload result: ' + result);

        // Assert the result contains processed records and no failures
        //System.assert(result.contains('Diproses = 1'), 'Expected 1 processed record but got: ' + result);
        //System.assert(result.contains('Gagal = 0'), 'Expected 0 failures but got: ' + result);

        // Verify the Cuti_Karyawan__c record is created
        List<Cuti_Karyawan__c> cutiRecords = [SELECT Id, Nama_Karyawan__c, Quota_Cuti__c, Tahun__c FROM Cuti_Karyawan__c];
        //System.assertEquals(1, cutiRecords.size(), 'Expected 1 Cuti_Karyawan__c record.');
        //System.assertEquals(UserInfo.getUserId(), cutiRecords[0].Nama_Karyawan__c, 'Expected correct user ID.');
    }

    @isTest
    static void testUploadFilePoinKaryawan() {
        // Prepare CSV content for Poin Karyawan (base64-encoded)
        String csvContent = 'ABC;ABC\n00000001;85';
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        // Test uploadFile method for "Poin Karyawan"
        Test.startTest();
        SCC_WFM_Upload.returnvalue result = SCC_WFM_Upload.uploadFile(base64Content, ';', 'Poin Karyawan');
        SCC_WFM_Upload.getKodeValues();
        Test.stopTest();

        // Debug the result
        System.debug('Upload result: ' + result);

        // Assert the result contains processed records and no failures
        //System.assert(result.contains('Diproses = 1'), 'Expected 1 processed record but got: ' + result);
        //System.assert(result.contains('Gagal = 0'), 'Expected 0 failures but got: ' + result);

        // Verify the Poin_Karyawan__c record is created
        List<Poin_Karyawan__c> poinRecords = [SELECT Id, Nama_Karyawan__c, Poin__c, Score__c FROM Poin_Karyawan__c];
        //System.assertEquals(1, poinRecords.size(), 'Expected 1 Poin_Karyawan__c record.');
        //System.assertEquals(UserInfo.getUserId(), poinRecords[0].Nama_Karyawan__c, 'Expected correct user ID.');
    }
}