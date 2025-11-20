@isTest
private class SCC_BriLinkWrapperTest {

    @isTest
    static void testParseValidJson() {
        // Given
        String validJson = '{"BRILINK_PROFILE":[{"TID":"123","alamat_agen":"Some address","jenis_jaringan":"Network","jenis_usaha":"Business","kode_agen":"ABC","kode_channel":"Channel","kode_merchant":"Merchant","kode_uker_pengelola":"Uker","limit_transaksi":"1000","mid":"456","modifikasi_oleh":"Modifier","nama_agen":"Agent","nama_ibu_kandung":"Mother","nama_lengkap":"Full Name","nama_merchant":"Merchant Name","nomor_kartu_debit":"789","nomor_kontak_pab":"Contact","nomor_ktp":"ID123","nomor_rekening":"Account123","nomor_rekening_pelimpahan":"TransferAccount","nomor_rekening_pinjaman":"LoanAccount","nomor_siup":"SIUP123","pic_uker":"Pic","region_office_pengelola":"Region","sharing_fee":"Fee","status":"Active","tanggal_dibuat":"2024-05-28","tanggal_lahir":"1990-01-01","tanggal_modifikasi":"2024-05-28","telepon":"1234567890"}]}';
        
        // When
        SCC_BriLinkWrapper result = SCC_BriLinkWrapper.parse(validJson);

        // Then
        System.assertEquals('123', result.BRILINK_PROFILE[0].TID);
        System.assertEquals('Some address', result.BRILINK_PROFILE[0].alamat_agen);
        // Add assertions for other fields if needed
    }

    @isTest
    static void testParseNullJson() {
        // Given
        String nullJson = null;

        // When
        SCC_BriLinkWrapper result = SCC_BriLinkWrapper.parse(nullJson);

        // Then
        System.assert(result == null);
    }

    // Add more test cases as needed to cover other scenarios
}