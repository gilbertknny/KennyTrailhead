@IsTest
public class SCC_MerchantProfileByTIDWrapperTest {
    static testMethod void testParse() {
		String json = '{'+
		'  \"MERCHANT_PROFILE\": ['+
		'    {'+
		'      \"vendor_pemasang\": \"SKD-PT. SRIKANDI\",'+
		'      \"user_pemrakarsa\": \"234 - KC Bireun\",'+
		'      \"tipe_merchant\": \"01\",'+
		'      \"tipe\": \"\",'+
		'      \"telpon\": \"0811673433\",'+
		'      \"tanggal_update_data\": \"\",'+
		'      \"tanggal_pasang\": \"2014-12-30 17:00:00\",'+
		'      \"tanggal_modifikasi_terakhir\": \"\",'+
		'      \"tanggal_dibuat\": \"\",'+
		'      \"status_ticket\": \"\",'+
		'      \"status_pemasangan\": \"\",'+
		'      \"regional_office_pengelola\": \"A - Banda Aceh\",'+
		'      \"rc\": \"\",'+
		'      \"pn_pic_unit_kerja\": \"\",'+
		'      \"pic_merchant\": \"MAWARDI\",'+
		'      \"perangkat\": \"15311CT24508414-08111301620\",'+
		'      \"nomor_telepon_merchant\": \"08116773433\",'+
		'      \"nomor_rekening_penampungan\": \"020601010022307\",'+
		'      \"no_batch\": \"\",'+
		'      \"nama_pic_unit_kerja\": \"PT. SRIKANDI\",'+
		'      \"nama_merchant_qris\": \"\",'+
		'      \"nama_merchant_edc\": \"UD, INDAH BARU\",'+
		'      \"modifikasi_oleh\": \"\",'+
		'      \"mdr_unik\": \"00,00\",'+
		'      \"mdr_onus\": \"01,60\",'+
		'      \"mdr_offus\": \"01,80\",'+
		'      \"mdr_mastercard\": \"\",'+
		'      \"mdr_debit_pl\": \"00,15\",'+
		'      \"mdr_debit_npg\": \"01,00\",'+
		'      \"mcc_visa\": \"4812\",'+
		'      \"mcc_npg\": \"4812\",'+
		'      \"mcc_master\": \"4812\",'+
		'      \"kode_unit_kerja\": \"234 - KC Bireun\",'+
		'      \"kanwil\": \"Banda Aceh\",'+
		'      \"kantor_wilayah\": \"Banda Aceh\",'+
		'      \"jenis_usaha_merchant\": \"\",'+
		'      \"jenis_merchant\": \"RITEL\",'+
		'      \"email\": \"\",'+
		'      \"detail_edc\": \"\",'+
		'      \"detail\": \"\",'+
		'      \"data_promo\": \"\",'+
		'      \"code_reffnum\": \"\",'+
		'      \"channel_merchant\": \"\",'+
		'      \"alamat_merchant\": \"JALAN SULTAN MALIKUSSALEH NO., DS/KEL. LAINNYA, KOTA BIREUEN, BIREUEN KAB., NANGGROE ACEH D, 24251\",'+
		'      \"mid\": \"001054330000\",'+
		'      \"tid\": \"10005563\"'+
		'    }'+
		'  ]'+
		'}';
		SCC_MerchantProfileByTIDWrapper obj = SCC_MerchantProfileByTIDWrapper.parse(json);
		System.assert(obj != null);
	}
}