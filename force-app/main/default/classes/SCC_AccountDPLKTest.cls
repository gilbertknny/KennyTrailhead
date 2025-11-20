@isTest
private class SCC_AccountDPLKTest {
    @isTest
    static void testByIdNumber() {
        String sampleRequestBody = '{"TRX_DPLK":[{"nik":"7313062809890006","no_rekening":"00001203466","nomor_kartu_dplk":"20141658081203466","tanggal_transaksi":"2024-01-25","nomor_handphone":"0","nama_transaksi":"Fee Pengelolaan Bulanan","nama_nasabah":"ANDI ANUGRAH DEWA","kode_jenis_transaksi":"B","keterangan":"BiayaPengelolaanDanaRutin  peserta 00001203466","iscommitted":"T","id_transaksi":"104955856","branch_code":"0369"},{"nik":"7313062809890006","no_rekening":"00001203466","nomor_kartu_dplk":"20141658081203466","tanggal_transaksi":"2024-01-25","nomor_handphone":"0","nama_transaksi":"Fee Administrasi Bulanan","nama_nasabah":"ANDI ANUGRAH DEWA","kode_jenis_transaksi":"A","keterangan":"BiayaAdmRutin  peserta 00001203466","iscommitted":"T","id_transaksi":"104388727","branch_code":"0369"}],"SI_DPLK":[{"nik":"7313062809890006","nomor_rekening_bri":"5053-01-014398-53-2","nomor_kartu_dplk":"20141658081203466","total_saldo":"4191474.0","tgl_registrasi":"2014-12-28 01:26:10","tanggal_lahir":"1987-09-27","status_dplk":"A","sistem_pembayaran_iuran":"N","pengembangan":"1849401.0","pengalihan":"120000.0","nomor_handphone":"0","nomor_akun_dplk":"00001203466","no_pegawai_korporat":"172610","nama_nasabah":"ANDI ANUGRAH DEWA","kantor_pembukaan_cabang":"000","jenis_investasi":"A","iuran":"2342073.0","cif_dplk":"00000165808","anggota_korporat_individu":"T","alamat_email":"ANUGRAH.ANDI@CORP.BRI.CO.ID"},{"nik":"7313062809890006","nomor_rekening_bri":"5053-01-014398-53-2","nomor_kartu_dplk":"20141658081203466","total_saldo":"17040363.0","tgl_registrasi":"2014-12-28 01:26:10","tanggal_lahir":"1987-09-27","status_dplk":"A","sistem_pembayaran_iuran":"N","pengembangan":"7672072.0","pengalihan":"0.0","nomor_handphone":"0","nomor_akun_dplk":"00001203466","no_pegawai_korporat":"172610","nama_nasabah":"ANDI ANUGRAH DEWA","kantor_pembukaan_cabang":"000","jenis_investasi":"B","iuran":"9368291.0","cif_dplk":"00000165808","anggota_korporat_individu":"T","alamat_email":"ANUGRAH.ANDI@CORP.BRI.CO.ID"}]}';
        HttpCalloutMock mock = new HTTPMockFactory(200, 'OK', sampleRequestBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String idNumber = '123456789';
        String response = SCC_AccountDPLKCtrl.inquiryByIdNumber(idNumber);
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    @isTest
    static void testByAccountNumber() {
        String sampleRequestBody = '{"TRX_DPLK":[{"nik":"7313062809890006","no_rekening":"00001203466","nomor_kartu_dplk":"20141658081203466","tanggal_transaksi":"2024-01-25","nomor_handphone":"0","nama_transaksi":"Fee Pengelolaan Bulanan","nama_nasabah":"ANDI ANUGRAH DEWA","kode_jenis_transaksi":"B","keterangan":"BiayaPengelolaanDanaRutin  peserta 00001203466","iscommitted":"T","id_transaksi":"104955856","branch_code":"0369"},{"nik":"7313062809890006","no_rekening":"00001203466","nomor_kartu_dplk":"20141658081203466","tanggal_transaksi":"2024-01-25","nomor_handphone":"0","nama_transaksi":"Fee Administrasi Bulanan","nama_nasabah":"ANDI ANUGRAH DEWA","kode_jenis_transaksi":"A","keterangan":"BiayaAdmRutin  peserta 00001203466","iscommitted":"T","id_transaksi":"104388727","branch_code":"0369"}],"SI_DPLK":[{"nik":"7313062809890006","nomor_rekening_bri":"5053-01-014398-53-2","nomor_kartu_dplk":"20141658081203466","total_saldo":"4191474.0","tgl_registrasi":"2014-12-28 01:26:10","tanggal_lahir":"1987-09-27","status_dplk":"A","sistem_pembayaran_iuran":"N","pengembangan":"1849401.0","pengalihan":"120000.0","nomor_handphone":"0","nomor_akun_dplk":"00001203466","no_pegawai_korporat":"172610","nama_nasabah":"ANDI ANUGRAH DEWA","kantor_pembukaan_cabang":"000","jenis_investasi":"A","iuran":"2342073.0","cif_dplk":"00000165808","anggota_korporat_individu":"T","alamat_email":"ANUGRAH.ANDI@CORP.BRI.CO.ID"},{"nik":"7313062809890006","nomor_rekening_bri":"5053-01-014398-53-2","nomor_kartu_dplk":"20141658081203466","total_saldo":"17040363.0","tgl_registrasi":"2014-12-28 01:26:10","tanggal_lahir":"1987-09-27","status_dplk":"A","sistem_pembayaran_iuran":"N","pengembangan":"7672072.0","pengalihan":"0.0","nomor_handphone":"0","nomor_akun_dplk":"00001203466","no_pegawai_korporat":"172610","nama_nasabah":"ANDI ANUGRAH DEWA","kantor_pembukaan_cabang":"000","jenis_investasi":"B","iuran":"9368291.0","cif_dplk":"00000165808","anggota_korporat_individu":"T","alamat_email":"ANUGRAH.ANDI@CORP.BRI.CO.ID"}]}';
        HttpCalloutMock mock = new HTTPMockFactory(200, 'OK', sampleRequestBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String accountNumber = '123456789';
        String response = SCC_AccountDPLKCtrl.inquiryByAccountNumber(accountNumber);
        Test.stopTest();
        
        System.assertNotEquals(null, response);
    }
}