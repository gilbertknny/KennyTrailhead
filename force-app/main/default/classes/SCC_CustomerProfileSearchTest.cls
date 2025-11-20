@isTest
public class SCC_CustomerProfileSearchTest {

    @isTest
    static void testMakeCalloutWithAccountNumber() {
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpWithErrorResponse());
        // Setup mock data
        String accountNumber = '25444945962602';
        String debitCreditNumber = '';
        String idValue = '';
        String phoneNumber = '';
        String cifNo = 'NNE2576';


        // Call the method
        SCC_CustomerProfileSearch.makeCallout(accountNumber, debitCreditNumber, idValue, phoneNumber, cifNo);

    }

    @isTest
    static void testMakeCalloutWithPhoneNumber() {
        // Setup mock data
        Account testAccount = new Account(Name = 'Test Account', SCC_cifno__c = 'NNE2576');
        insert testAccount;
        
        String accountNumber = '';
        String debitCreditNumber = '';
        String idValue = '';
        String phoneNumber = '082347379586';
        String cifNo = 'NNE2576';

        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());

        // Call the method
        List<SCC_CustomerSearchResult> results = SCC_CustomerProfileSearch.makeCallout(accountNumber, debitCreditNumber, idValue, phoneNumber, cifNo);

        // Validate results
        System.assertEquals(1, results.size(), 'Expected one search result');
    }

    @isTest
    static void testMakeCalloutWithErrorResponse() {
        // Setup mock data
        String accountNumber = '';
        String debitCreditNumber = '';
        String idValue = '2771834990466627';
        String phoneNumber = '';
        String cifNo = '';

        // Set up mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
		
        // Call the method
        List<SCC_CustomerSearchResult> results = SCC_CustomerProfileSearch.makeCallout(accountNumber, debitCreditNumber, idValue, phoneNumber, cifNo);
    }

    // Mock class for successful API response
    private class MockHttpWithErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":400,"errorCode":"000","responseCode":"00","responseMessage":"Unsuccess","errors":null,"data":[{"cifno":"NNE2576","demografi":{"NPWP":"027396944416000","PEP":"TIDAK","alamatDomisili":"NULL","alamatDomisili2":"NULL","alamatKantor":"NULL","alamatKantor2":"NULL","alamatSesuaiID":"JL.KH.HASYIM ASHARI NO.99 E","alamatSesuaiID2":"RT.02/02","alamatSuratMenyurat":"NULL","bidangPekerjaan":"NULL","bidangUsaha":"PERKEBUNAN","createdDate":"2022-04-06","email":"NULL","email1":"XXX@YAHOO.COM","email2":"NULL","email3":"NULL","gelarSebelumNama":"NULL","gelarSetelahNama":"NULL","handphone":"NULL","jabatan1":"PEMILIK, DIREKTUR","jabatan2":"NULL","jabatan3":"NULL","jenisIdentitas":"NP","jenisKelamin":"NULL","jenisPekerjaan":"NULL","kecamatanDomisili":"NULL","kecamatanKantor":"NULL","kecamatanSesuaiID":"CIPONDOH","kelurahanDomisili":"NULL","kelurahanKantor":"NULL","kelurahanSesuaiID":"CIPONDOH KEL","keteranganAgama":"NULL","kewarganegaraan":"WNA","kodeBidangUsaha":"1010","kodePosDomisili":"NULL","kodePosKantor":"NULL","kodePosSesuaiID":"15148","kotaDomisili":"NULL","kotaKantor":"NULL","kotaSesuaiID":"TANGERANG KOT.","lastModifiedDate":"2022-04-06","nama1":"BAYU HUSDAVIATA THAMRIN","nama2":"NULL","nama3":"NULL","namaGadisIbuKandung":"-","namaSesuaiIdentitas":"NUREKA","namaTempatBekerja":"NUREKA","nasabahPrioritas":"NULL","negara":"INDONESIA","noAktaPendirian":"68","noIdCorp":"300614604274","nomorIdentitas":"027396944416000","pendidikanTerakhir":"NULL","propinsiDomisili":"NULL","propinsiKantor":"NULL","propinsiSesuaiID":"BANTEN","rtDomisili":"NULL","rtKantor":"NULL","rtSesuaiID":"02","rwDomisili":"NULL","rwKantor":"NULL","rwSesuaiID":"02","statusPerkawinan":"NULL","tanggalAktaPendirian":"1979-04-27","tanggalLahir":"1979-04-27","tanggalTerbit":"2015-11-13","telepon":"NULL","telepon1":"082347379586","telepon2":"NULL","telepon3":"NULL","teleponKantor":"NULL","tempatLahir":"TANGERANG","tempatPendirian":"TANGERANG","tipeIdCorp":"TD","tipeNasabah":"P","tipeNasabahDesc":"ORGANISATION","umur":45},"portofolioPerbankan":{"cardlink":[{"cardNumber":"81463183678732","cifno":"NNE2576","product":"PIJAR","productDescription":"","productType":"CC","status":"1"}],"investasi":[{"accountNumber":"26389647887101","balance":0,"cifno":"NNE2576","product":"Junio","productDescription":"","productType":"IN","status":"1"}],"pinjaman":[{"accountNumber":"122301000204156","balance":0,"cifno":"NNE2576","product":"KMK RC RITEL","productDescription":"DL-202 KMK RC RITEL","productType":"DL"}],"simpanan":[{"accountNumber":"122301000689306","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"},{"accountNumber":"122301000936305","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"}]}}]}');
            res.setStatusCode(400);
            return res;
        }
    }
	
    @isTest
    static void updateAccountTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
        Account testAccount = new Account(LastName = 'Test Account', SCC_cifno__c = 'NNE2576');
        //testAccount.RecordTypeId = SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'PersonAccount');
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert testAccount;
        SCC_CustomerProfileWrapper cpw = new SCC_CustomerProfileWrapper();
        SCC_CustomerProfileWrapper.Demografi dmg = new SCC_CustomerProfileWrapper.Demografi();
        dmg.tipeNasabah = 'P';
        dmg.email = 'test@gmail.com';  
        dmg.namaSesuaiIdentitas = 'Test LastName';
        Test.startTest(); 
        SCC_CustomerProfileSearch.updateAccount(testAccount, dmg);
        Test.stopTest();
    }
    
    @isTest
    static void updateAccountTest1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
        Account testAccount = new Account(Name = 'Test Account', SCC_cifno__c = 'NNE2576');
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        insert testAccount;
        SCC_CustomerProfileWrapper cpw = new SCC_CustomerProfileWrapper();
        SCC_CustomerProfileWrapper.Demografi dmg = new SCC_CustomerProfileWrapper.Demografi();
        dmg.tipeNasabah = 'O';
        dmg.email = 'test@gmail.com';  
        dmg.namaSesuaiIdentitas = 'Test LastName';
        Test.startTest(); 
        SCC_CustomerProfileSearch.updateAccount(testAccount, dmg);
        Test.stopTest();
    }
    // Mock class for API error response
    private class MockHttpWithoutErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"SAET840","demografi":{"NPWP":"NPWP","PEP":"PEP","alamatDomisili":"Gg. Bangka Raya No. 487Singkawang, KT 95038","alamatDomisili2":"Gang Erlangga No. 252Probolinggo, SS 90088","alamatKantor":"Jl. Rungkut Industri No. 165Bandar Lampung, JI 57196","alamatKantor2":"Gg. Stasiun Wonokromo No. 33Kotamobagu, SN 47552","alamatSesuaiID":"Jl. Rawamangun No. 6Probolinggo, SR 41790","alamatSesuaiID2":"Jalan Yos Sudarso No. 924Manado, KU 07147","alamatSuratMenyurat":"Gang Indragiri No. 73Binjai, Sumatera Utara 19279","bidangPekerjaan":"BIDANG_PEKERJAAN","bidangUsaha":"BIDANG_USAHA","createdDate":"TANGGAL_BUKA_CIF","email":"tugimanpermadi@example.net","email1":"EMAIL_PENGURUS_1","email2":"EMAIL_PENGURUS_2","email3":"EMAIL_PENGURUS_3","gelarSebelumNama":"Sutan","gelarSetelahNama":"S.Sos","handphone":"+62 (076) 232-9219","jabatan1":"JABATAN_PENGURUS_1","jabatan2":"JABATAN_PENGURUS_2","jabatan3":"JABATAN_PENGURUS_3","jenisIdentitas":"KT","jenisKelamin":"l","jenisPekerjaan":"KOMPUTER-ANALIS/PROGRMR/INTERNT/MIS/ENGI","kecamatanDomisili":"KECAMATAN_DOMISILI","kecamatanKantor":"KECAMATAN_KANTOR","kecamatanSesuaiID":"KECAMATAN_ID","kelurahanDomisili":"KELURAHAN_DOMISILI","kelurahanKantor":"KELURAHAN_KANTOR","kelurahanSesuaiID":"KELURAHAN_ID","keteranganAgama":"protestan","kewarganegaraan":"Mauritius","kodeBidangUsaha":"KODE_BIDANG_USAHA","kodePosDomisili":"82240","kodePosKantor":"83356","kodePosSesuaiID":"24349","kotaDomisili":"Mataram","kotaKantor":"Batam","kotaSesuaiID":"Padang","lastModifiedDate":"TANGGAL_MAINTENANCE_CIF","nama1":"JejeIN","nama2":"AgusIN","nama3":"AlifIN","namaGadisIbuKandung":"Jelita Pratiwi","namaSesuaiIdentitas":"Jati Hidayat","namaTempatBekerja":"Perum Halimah (Persero) Tbk","nasabahPrioritas":"PRIORITAS","negara":"Indonesia","noAktaPendirian":"NO_AKTA_PENDIRIAN","noIdCorp":"NO_ID_CORP","nomorIdentitas":"2771834990466627","pendidikanTerakhir":"DIPLOMA","propinsiDomisili":"Jambi","propinsiKantor":"Kalimantan Tengah","propinsiSesuaiID":"Bali","rtDomisili":"XV","rtKantor":"XII","rtSesuaiID":"XV","rwDomisili":"IX","rwKantor":"VI","rwSesuaiID":"XV","statusPerkawinan":"","tanggalAktaPendirian":"TANGGAL_AKTA_PENDIRIAN","tanggalLahir":"1947-09-08","tanggalTerbit":"TANGGAL_TERBIT_CORP","telepon":"+62 (90) 714 6804","telepon1":"TELEPON_PENGURUS_1","telepon2":"TELEPON_PENGURUS_2","telepon3":"TELEPON_PENGURUS_3","teleponKantor":"+62 (29) 549-7522","tempatLahir":"Banjarbaru","tempatPendirian":"TEMPAT_PENDIRIAN","tipeIdCorp":"TIPE_ID_CORP","tipeNasabah":"P","tipeNasabahDesc":"TIPE_NASABAH_DESC","umur":76},"portofolioPerbankan":{"cardlink":[],"investasi":[{"accountNumber":"91587974613236","balance":77879082,"cifno":"SAET840","product":"Tabungan Haji BRI Syariah","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}],"pinjaman":[],"simpanan":[]}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class MockHttpWithoutErrorResponse1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"NNE2576","demografi":{"NPWP":"027396944416000","PEP":"TIDAK","alamatDomisili":"NULL","alamatDomisili2":"NULL","alamatKantor":"NULL","alamatKantor2":"NULL","alamatSesuaiID":"JL.KH.HASYIM ASHARI NO.99 E","alamatSesuaiID2":"RT.02/02","alamatSuratMenyurat":"NULL","bidangPekerjaan":"NULL","bidangUsaha":"PERKEBUNAN","createdDate":"2022-04-06","email":"NULL","email1":"XXX@YAHOO.COM","email2":"NULL","email3":"NULL","gelarSebelumNama":"NULL","gelarSetelahNama":"NULL","handphone":"NULL","jabatan1":"PEMILIK, DIREKTUR","jabatan2":"NULL","jabatan3":"NULL","jenisIdentitas":"NP","jenisKelamin":"NULL","jenisPekerjaan":"NULL","kecamatanDomisili":"NULL","kecamatanKantor":"NULL","kecamatanSesuaiID":"CIPONDOH","kelurahanDomisili":"NULL","kelurahanKantor":"NULL","kelurahanSesuaiID":"CIPONDOH KEL","keteranganAgama":"NULL","kewarganegaraan":"WNA","kodeBidangUsaha":"1010","kodePosDomisili":"NULL","kodePosKantor":"NULL","kodePosSesuaiID":"15148","kotaDomisili":"NULL","kotaKantor":"NULL","kotaSesuaiID":"TANGERANG KOT.","lastModifiedDate":"2022-04-06","nama1":"Adhi","nama2":"Judan","nama3":"Boas","namaGadisIbuKandung":"-","namaSesuaiIdentitas":"NUREKA","namaTempatBekerja":"NUREKA","nasabahPrioritas":"NULL","negara":"INDONESIA","noAktaPendirian":"68","noIdCorp":"300614604274","nomorIdentitas":"027396944416000","pendidikanTerakhir":"NULL","propinsiDomisili":"NULL","propinsiKantor":"NULL","propinsiSesuaiID":"BANTEN","rtDomisili":"NULL","rtKantor":"NULL","rtSesuaiID":"02","rwDomisili":"NULL","rwKantor":"NULL","rwSesuaiID":"02","statusPerkawinan":"NULL","tanggalAktaPendirian":"1979-04-27","tanggalLahir":"1979-04-27","tanggalTerbit":"2015-11-13","telepon":"081322922912","telepon1":"082347379586","telepon2":"NULL","telepon3":"NULL","teleponKantor":"NULL","tempatLahir":"TANGERANG","tempatPendirian":"TANGERANG","tipeIdCorp":"TD","tipeNasabah":"O","tipeNasabahDesc":"ORGANISATION","umur":45},"portofolioPerbankan":{"cardlink":[{"cardNumber":"81463183678732","cifno":"NNE2576","product":"PIJAR","productDescription":"","productType":"CC","status":"1"}],"investasi":[{"accountNumber":"26389647887101","balance":0,"cifno":"NNE2576","product":"Junio","productDescription":"","productType":"IN","status":"1"}],"pinjaman":[{"accountNumber":"122301000204156","balance":0,"cifno":"NNE2576","product":"KMK RC RITEL","productDescription":"DL-202 KMK RC RITEL","productType":"DL"}],"simpanan":[{"accountNumber":"122301000689306","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"},{"accountNumber":"122301000936305","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"}]}}]}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}