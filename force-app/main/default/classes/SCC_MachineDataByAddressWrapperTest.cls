@IsTest
public class SCC_MachineDataByAddressWrapperTest {
    static testMethod void testParse() {
		String json = '{'+
		'  \"machineDataByAddress\": ['+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Rajabasa Raya, Rajabasa, Bandar Lampung City, Lampung, Indonesia\",'+
		'      \"nomorMesin\": \"56DW508921\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"520033\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Bandar Jaya, Bengkalis Regency, Riau, Indonesia\",'+
		'      \"nomorMesin\": \"Y817012169\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"540013\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"J893+JG6, Sukarame, Bandar Lampung City, Lampung, Indonesia\",'+
		'      \"nomorMesin\": \"56DW509511\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"520017\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"J893+JG6, Sukarame, Bandar Lampung City, Lampung, Indonesia\",'+
		'      \"nomorMesin\": \"Y817012960\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"540022\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Jl. Dr. Rehatta, Kp. Baru, Banda, Kabupaten Maluku Tengah, Maluku, Indonesia\",'+
		'      \"nomorMesin\": \"56HG604670\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"91376\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"J883+RF8, Sukarame, Bandar Lampung City, Lampung 35131, Indonesia\",'+
		'      \"nomorMesin\": \"YB76202872\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"94585\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Bandar Jaya, Lahat, Lahat Regency, South Sumatra 31412, Indonesia\",'+
		'      \"nomorMesin\": \"56HG607993\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"341054\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Bandar Ratu, Kota Mukomuko, Mukomuko Regency, Bengkulu 38714, Indonesia\",'+
		'      \"nomorMesin\": \"YB76202827\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"650971\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Bandar Jaya, Lahat, Lahat Regency, South Sumatra 31414, Indonesia\",'+
		'      \"nomorMesin\": \"56HG607918\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"90815\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Karang Maritim, Panjang, Bandar Lampung City, Lampung 35243, Indonesia\",'+
		'      \"nomorMesin\": \"56HG604741\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"51257\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Jl. Yos Sudarso No.34, Pidada, Kec. Panjang, Kota Bandar Lampung, Lampung 35241, Indonesia\",'+
		'      \"nomorMesin\": \"YB76000864\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"550290\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Gedong Meneng, Kec. Rajabasa, Kota Bandar Lampung, Lampung 35141, Indonesia\",'+
		'      \"nomorMesin\": \"Y817010579\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"451609\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Jl. Ki Maja No.39, Kedaton, Kec. Kedaton, Kota Bandar Lampung, Lampung 35132, Indonesia\",'+
		'      \"nomorMesin\": \"56DW509491\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"520020\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"4454+CV, Bandar Sungai, Sabak Auh, Siak Regency, Riau 28771, Indonesia\",'+
		'      \"nomorMesin\": \"Y817012309\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"550870\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Bandar Pulau Pekan, Bandar Pulau, Asahan Regency, North Sumatra 21274, Indonesia\",'+
		'      \"nomorMesin\": \"Y817012570\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"57155\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Jl. Pulau Sebesi, Sukarame, Kec. Sukarame, Kota Bandar Lampung, Lampung 35131, Indonesia\",'+
		'      \"nomorMesin\": \"56HG603138\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"51180\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Jl. Soekarno Hatta, Rajabasa Raya, Kec. Rajabasa, Kota Bandar Lampung, Lampung, Indonesia\",'+
		'      \"nomorMesin\": \"56DW508883\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"520034\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Jl. Pagar Alam No.64, Kedaton, Kec. Kedaton, Kota Bandar Lampung, Lampung 35132, Indonesia\",'+
		'      \"nomorMesin\": \"56HG608311\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"94583\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \" Segala Mider, Tanjungkarang Barat, Bandar Lampung City, Lampung 35125, Indonesia\",'+
		'      \"nomorMesin\": \"56DW508941\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"520039\"'+
		'    },'+
		'    {'+
		'      \"kontakId\": \"\",'+
		'      \"status\": \"UP TUNAI\",'+
		'      \"alamatMesin\": \"Jl. Pramuka No.9, Rajabasa, Kec. Rajabasa, Kota Bandar Lampung, Lampung 35151, Indonesia\",'+
		'      \"nomorMesin\": \"56DW508894\",'+
		'      \"jenisMesin\": \"ATM\",'+
		'      \"tid\": \"520047\"'+
		'    }'+
		'  ]'+
		'}';
		SCC_MachineDataByAddressWrapper obj = SCC_MachineDataByAddressWrapper.parse(json);
		System.assert(obj != null);
	}
}