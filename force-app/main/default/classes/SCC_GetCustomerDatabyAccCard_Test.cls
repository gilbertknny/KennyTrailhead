@IsTest
public class SCC_GetCustomerDatabyAccCard_Test {
    
    @IsTest
    static void testGetCustomerDataByAccCardWithAccountNumber() {
        // Set up the mock HTTP response
        String jsonResponse = '{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"NNE2576","demografi":{"NPWP":"027396944416000","PEP":"TIDAK","alamatDomisili":"NULL","alamatDomisili2":"NULL","alamatKantor":"NULL","alamatKantor2":"NULL","alamatSesuaiID":"JL.KH.HASYIM ASHARI NO.99 E","alamatSesuaiID2":"RT.02/02","alamatSuratMenyurat":"NULL","bidangPekerjaan":"NULL","bidangUsaha":"PERKEBUNAN","createdDate":"2022-04-06","email":"NULL","email1":"XXX@YAHOO.COM","email2":"NULL","email3":"NULL","gelarSebelumNama":"NULL","gelarSetelahNama":"NULL","handphone":"NULL","jabatan1":"PEMILIK, DIREKTUR","jabatan2":"NULL","jabatan3":"NULL","jenisIdentitas":"NP","jenisKelamin":"NULL","jenisPekerjaan":"NULL","kecamatanDomisili":"NULL","kecamatanKantor":"NULL","kecamatanSesuaiID":"CIPONDOH","kelurahanDomisili":"NULL","kelurahanKantor":"NULL","kelurahanSesuaiID":"CIPONDOH KEL","keteranganAgama":"NULL","kewarganegaraan":"WNA","kodeBidangUsaha":"1010","kodePosDomisili":"NULL","kodePosKantor":"NULL","kodePosSesuaiID":"15148","kotaDomisili":"NULL","kotaKantor":"NULL","kotaSesuaiID":"TANGERANG KOT.","lastModifiedDate":"2022-04-06","nama1":"BAYU HUSDAVIATA THAMRIN","nama2":"NULL","nama3":"NULL","namaGadisIbuKandung":"-","namaSesuaiIdentitas":"NUREKA","namaTempatBekerja":"NUREKA","nasabahPrioritas":"NULL","negara":"INDONESIA","noAktaPendirian":"68","noIdCorp":"300614604274","nomorIdentitas":"027396944416000","pendidikanTerakhir":"NULL","propinsiDomisili":"NULL","propinsiKantor":"NULL","propinsiSesuaiID":"BANTEN","rtDomisili":"NULL","rtKantor":"NULL","rtSesuaiID":"02","rwDomisili":"NULL","rwKantor":"NULL","rwSesuaiID":"02","statusPerkawinan":"NULL","tanggalAktaPendirian":"1979-04-27","tanggalLahir":"1979-04-27","tanggalTerbit":"2015-11-13","telepon":"NULL","telepon1":"082347379586","telepon2":"NULL","telepon3":"NULL","teleponKantor":"NULL","tempatLahir":"TANGERANG","tempatPendirian":"TANGERANG","tipeIdCorp":"TD","tipeNasabah":"O","tipeNasabahDesc":"ORGANISATION","umur":45},"portofolioPerbankan":{"cardlink":[{"cardNumber":"81463183678732","cifno":"NNE2576","product":"PIJAR","productDescription":"","productType":"CC","status":"1"}],"investasi":[{"accountNumber":"26389647887101","balance":0,"cifno":"NNE2576","product":"Junio","productDescription":"","productType":"IN","status":"1"}],"pinjaman":[{"accountNumber":"122301000204156","balance":0,"cifno":"NNE2576","product":"KMK RC RITEL","productDescription":"DL-202 KMK RC RITEL","productType":"DL"}],"simpanan":[{"accountNumber":"122301000689306","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"},{"accountNumber":"122301000936305","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"}]}}]}';
        Test.setMock(HttpCalloutMock.class, new SCC_HttpMock(200, jsonResponse));

        // Test with account number
        String accountNumber = '122301000936305';
        String debitNumber = null;

        Test.startTest();
        List<SCC_CustomerDataWrapper> result = SCC_GetCustomerDatabyAccCard.getCustomerDataByAccCard(accountNumber, debitNumber);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
        System.assertEquals('122301000689306', result[0].accountNumber);
        System.assertEquals('Aktif', result[0].status);
    }
    
    @IsTest
    static void testGetCustomerDataByAccCardWithDebitNumber() {
        // Set up the mock HTTP response
        String jsonResponse = '{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"N299993","demografi":{"NPWP":"","PEP":"TIDAK","alamatDomisili":"BRI ENTERPRISE DATA MANAGEMENT","alamatDomisili2":"DIVISION GD BRI JL JENDRAL","alamatKantor":"JL VETERAN MALANG","alamatKantor2":"MALANG","alamatSesuaiID":"PERUM NEW PURI KARTIKA ASRI","alamatSesuaiID2":"BLOK H1 5 RT 003 RW 010","alamatSuratMenyurat":"SESUAI ID","bidangPekerjaan":"JASA PENDIDIKAN TINGGI","bidangUsaha":"","createdDate":"2014-08-28","email":"ANDI.HAFIIDH@GMAIL.COM","email1":"","email2":"","email3":"","gelarSebelumNama":"","gelarSetelahNama":"","handphone":"6281232887996","jabatan1":"","jabatan2":"","jabatan3":"","jenisIdentitas":"KT","jenisKelamin":"LAKI-LAKI","jenisPekerjaan":"KARYAWAN","kecamatanDomisili":"KEDUNGKANDANG","kecamatanKantor":"LOWOKWARU","kecamatanSesuaiID":"KEDUNGKANDANG","kelurahanDomisili":"ARJOWINANGUN","kelurahanKantor":"KETAWANGGEDE KEL.","kelurahanSesuaiID":"ARJOWINANGUN","keteranganAgama":"ISLAM","kewarganegaraan":"WNI","kodeBidangUsaha":"0","kodePosDomisili":"10210","kodePosKantor":"65145","kodePosSesuaiID":"65132","kotaDomisili":"JAKARTA PUSAT","kotaKantor":"MALANG KOT.","kotaSesuaiID":"MALANG","lastModifiedDate":"2022-04-08","nama1":"","nama2":"","nama3":"","namaGadisIbuKandung":"SRI RESTUTI","namaSesuaiIdentitas":"ANDI HAFIIDH","namaTempatBekerja":"BRI ENTERPRISE DATA MANAG","nasabahPrioritas":"","negara":"INDONESIA","noAktaPendirian":"","noIdCorp":"","nomorIdentitas":"3573051807960001","pendidikanTerakhir":"SARJANA","propinsiDomisili":"JAWA TIMUR","propinsiKantor":"JAWA TIMUR","propinsiSesuaiID":"JAWA TIMUR","rtDomisili":"3","rtKantor":"01","rtSesuaiID":"3","rwDomisili":"10","rwKantor":"01","rwSesuaiID":"10","statusPerkawinan":"BELUM KAWIN","tanggalAktaPendirian":"","tanggalLahir":"1996-07-18","tanggalTerbit":"","telepon":"0217807532","telepon1":"","telepon2":"","telepon3":"","teleponKantor":"6281232887996","tempatLahir":"MALANG","tempatPendirian":"","tipeIdCorp":"","tipeNasabah":"P","tipeNasabahDesc":"PERSON","umur":27},"portofolioPerbankan":{"cardlink":[{"cardNumber":"281739821720","cifno":"N299993","product":"Cardlink","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"cardNumber":"5188280280801904","cifno":"N299993","product":"Cardlink","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}],"investasi":[{"accountNumber":"05542274747390","balance":85815904,"cifno":"N299993","product":"Tabungan","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"20499487416145","balance":34823263,"cifno":"N299993","product":"PIJAR","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"25966791579474","balance":43277889,"cifno":"N299993","product":"DPLK","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"32209509205882","balance":24995502,"cifno":"N299993","product":"BRI Visa Infinite","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"42982041187644","balance":89127667,"cifno":"N299993","product":"Reksadana Pasar Uang","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"44591191267153","balance":44527824,"cifno":"N299993","product":"Upgrade Nasabah Prioritas","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"61727325786460","balance":85147144,"cifno":"N299993","product":"LENTERA","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"75906963655120","balance":53310437,"cifno":"N299993","product":"Giro Valas","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"87260161486018","balance":79738988,"cifno":"N299993","product":"TabunganKu BRI","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}],"pinjaman":[{"accountNumber":"265157498260155","balance":21838373.85,"cifno":"N299993","product":"Simpanan Pelajar","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"},{"accountNumber":"495419344664802","balance":22976770.95,"cifno":"N299993","product":"WORLD ACCESS","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"},{"accountNumber":"695261966010218","balance":90151581.59,"cifno":"N299993","product":"BRI Visa Infinite","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"},{"accountNumber":"869336695399986","balance":12202484.83,"cifno":"N299993","product":"Britama","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"}],"simpanan":[{"accountNumber":"25444945962602","balance":95448847.23,"cifno":"N299993","product":"Faedah","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"28798996385753","balance":50123346.2,"cifno":"N299993","product":"SiMuda","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"33064807578970","balance":28378304.25,"cifno":"N299993","product":"Simpedes Impian","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"38996995126552","balance":97035303.05,"cifno":"N299993","product":"KPR","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"53330860480885","balance":55153893.06,"cifno":"N299993","product":"Cash Management System (CMS)","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"54426806271482","balance":30694374.42,"cifno":"N299993","product":"Faedah","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"95301004198509","balance":67090614.33,"cifno":"N299993","product":"Tabungan","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}]}}]}';
        Test.setMock(HttpCalloutMock.class, new SCC_HttpMock(200, jsonResponse));

        // Test with debit number
        String accountNumber = null;
        String debitNumber = '3821928373856192';

        Test.startTest();
        List<SCC_CustomerDataWrapper> result = SCC_GetCustomerDatabyAccCard.getCustomerDataByAccCard(accountNumber, debitNumber);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(7, result.size());
        System.assertEquals('25444945962602', result[0].accountNumber);
        System.assertEquals('Aktif', result[0].status);
    }

    @IsTest
    static void testGetCustomerDataByAccCardWithErrorResponse() {
        // Set up the mock HTTP response
        String errorResponse = '{"statusCode": 500, "message": "Mock HTTP error"}';
        Test.setMock(HttpCalloutMock.class, new SCC_HttpMock(500, errorResponse));

        // Test with both account number and debit number
        String accountNumber = '1234567890';
        String debitNumber = '0987654321';

        Test.startTest();
        try {
            List<SCC_CustomerDataWrapper> result = SCC_GetCustomerDatabyAccCard.getCustomerDataByAccCard(accountNumber, debitNumber);
            //System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('An error occurred while making the API call: Mock HTTP error', e.getMessage());
        }
        Test.stopTest();
    }


    // Helper class for mocking HTTP responses
    private class SCC_HttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public SCC_HttpMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}