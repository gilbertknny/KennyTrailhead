@isTest
public class SSC_FetchCustomerFinancialInfoTest {
    @testSetup
    static void setupTestData() {
        // Create Account
        Account account = new Account(Name = 'Test Account', Phone = '1234567890', SCC_cifno__c = 'CIF12345');
        insert account;

        // Create Case
        Case caseRecord = new Case(AccountId = account.Id, SCC_Cust_Phone1__c = '0987654321');
        insert caseRecord;
    }

    @isTest
    static void testGetCalloutPhoneNoWithCasePhone() {
        // Get Account ID
        Account account = [SELECT Id FROM Account LIMIT 1];

        // Test getCalloutPhoneNo
        Test.startTest();
        String phoneNo = SSC_FetchCustomerFinancialInformation.getCalloutPhoneNo(account.Id);
        Test.stopTest();

        // Assert
     //   System.assertEquals('1234567890', phoneNo);
    }

    @isTest
    static void testGetCalloutPhoneNoWithAccountPhone() {
        // Create Account without Case
        Account account = new Account(Name = 'Test Account 2', Phone = '1112223333', SCC_cifno__c = 'CIF67890');
        insert account;

        // Test getCalloutPhoneNo
        Test.startTest();
        String phoneNo = SSC_FetchCustomerFinancialInformation.getCalloutPhoneNo(account.Id);
        Test.stopTest();

        // Assert
        System.assertEquals('1112223333', phoneNo);
    }

    @isTest
    static void testFetchDataFromAPI() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new SCC_CustomerFinancialWrapperMock());

        // Get Account ID
        Account account = [SELECT Id FROM Account LIMIT 1];

        // Test fetchDataFromAPI
        Test.startTest();
        List<SCC_CustomerFinancialWrapper.Data> dataList = SSC_FetchCustomerFinancialInformation.fetchDataFromAPI('1234567890', account.Id);
        Test.stopTest();

    }

    @isTest
    static void testCaptureErrorLog() {
        // Test captureErrorLog
        Test.startTest();
        SSC_FetchCustomerFinancialInformation.captureErrorLog('https://example.com', 'Outbound', '{}', '{"responseMessage":"Error","statusCode":500}');
        Test.stopTest();

        // Assert
        List<Error_Log__c> errorLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(1, errorLogs.size());
    }
    
    private class SCC_CustomerFinancialWrapperMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"N299993","demografi":{"NPWP":"","PEP":"TIDAK","alamatDomisili":"BRI ENTERPRISE DATA MANAGEMENT","alamatDomisili2":"DIVISION GD BRI JL JENDRAL","alamatKantor":"JL VETERAN MALANG","alamatKantor2":"MALANG","alamatSesuaiID":"KANTOR BRI","alamatSesuaiID2":"BLOK DH1","alamatSuratMenyurat":"SESUAI ID","bidangPekerjaan":"JASA PENDIDIKAN TINGGI","bidangUsaha":"","createdDate":"2014-08-28","email":"ANDI.HAFIIDH07@GMAIL.COM","email1":"","email2":"","email3":"","gelarSebelumNama":"","gelarSetelahNama":"","handphone":"6281232887996","jabatan1":"","jabatan2":"","jabatan3":"","jenisIdentitas":"KT","jenisKelamin":"LAKI-LAKI","jenisPekerjaan":"KARYAWAN","kecamatanDomisili":"KEDUNGKANDANG","kecamatanKantor":"LOWOKWARU","kecamatanSesuaiID":"KEDUNGKANDANG","kelurahanDomisili":"ARJOWINANGUN","kelurahanKantor":"KETAWANGGEDE KEL.","kelurahanSesuaiID":"ARJOWINANGUN","keteranganAgama":"ISLAM","kewarganegaraan":"WNI","kodeBidangUsaha":"0","kodePosDomisili":"10210","kodePosKantor":"65145","kodePosSesuaiID":"65132","kotaDomisili":"JAKARTA PUSAT","kotaKantor":"MALANG KOT.","kotaSesuaiID":"MALANG","lastModifiedDate":"2022-04-08","nama1":"Adhi","nama2":"Judan","nama3":"Boas","namaGadisIbuKandung":"SRI RESTUTI","namaSesuaiIdentitas":"ANDI HAFIIDH","namaTempatBekerja":"BRI ENTERPRISE DATA MANAG","nasabahPrioritas":"","negara":"INDONESIA","noAktaPendirian":"","noIdCorp":"","nomorIdentitas":"3573051807960001","pendidikanTerakhir":"SARJANA","propinsiDomisili":"JAWA TIMUR","propinsiKantor":"JAWA TIMUR","propinsiSesuaiID":"JAWA TIMUR","rtDomisili":"3","rtKantor":"01","rtSesuaiID":"3","rwDomisili":"10","rwKantor":"01","rwSesuaiID":"10","statusPerkawinan":"BELUM KAWIN","tanggalAktaPendirian":"","tanggalLahir":"1991-07-18","tanggalTerbit":"","telepon":"0217807532","telepon1":"","telepon2":"","telepon3":"","teleponKantor":"0217808178","tempatLahir":"MALANG","tempatPendirian":"","tipeIdCorp":"","tipeNasabah":"P","tipeNasabahDesc":"PERSON","umur":32},"portofolioPerbankan":{"cardlink":[{"cardNumber":"281739821720","cifno":"N299993","product":"Cardlink","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"cardNumber":"5188280280801904","cifno":"N299993","product":"Cardlink","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}],"investasi":[{"accountNumber":"05542274747390","balance":85815904,"cifno":"N299993","product":"Tabungan","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"20499487416145","balance":34823263,"cifno":"N299993","product":"PIJAR","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"25966791579474","balance":43277889,"cifno":"N299993","product":"DPLK","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"32209509205882","balance":24995502,"cifno":"N299993","product":"BRI Visa Infinite","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"42982041187644","balance":89127667,"cifno":"N299993","product":"Reksadana Pasar Uang","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"44591191267153","balance":44527824,"cifno":"N299993","product":"Upgrade Nasabah Prioritas","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"61727325786460","balance":85147144,"cifno":"N299993","product":"LENTERA","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"75906963655120","balance":53310437,"cifno":"N299993","product":"Giro Valas","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"87260161486018","balance":79738988,"cifno":"N299993","product":"TabunganKu BRI","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}],"pinjaman":[{"accountNumber":"265157498260155","balance":21838373.85,"cifno":"N299993","product":"Simpanan Pelajar","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"},{"accountNumber":"495419344664802","balance":22976770.95,"cifno":"N299993","product":"WORLD ACCESS","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"},{"accountNumber":"695261966010218","balance":90151581.59,"cifno":"N299993","product":"BRI Visa Infinite","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"},{"accountNumber":"869336695399986","balance":12202484.83,"cifno":"N299993","product":"Britama","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE"}],"simpanan":[{"accountNumber":"002401000853304","balance":0,"cifno":"N299993","product":"SiMuda","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"020601003205508","balance":0,"cifno":"N299993","product":"SiMuda","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"039001020927506","balance":0,"cifno":"N299993","product":"Tabungan","productDescription":"PRODUCT_DESCRIPTION","productType":"","status":"1"},{"accountNumber":"25444945962602","balance":95448847.23,"cifno":"N299993","product":"Faedah","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"28798996385753","balance":50123346.2,"cifno":"N299993","product":"SiMuda","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"33064807578970","balance":28378304.25,"cifno":"N299993","product":"Simpedes Impian","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"38996995126552","balance":97035303.05,"cifno":"N299993","product":"KPR","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"53330860480885","balance":55153893.06,"cifno":"N299993","product":"Cash Management System (CMS)","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"54426806271482","balance":30694374.42,"cifno":"N299993","product":"Faedah","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"},{"accountNumber":"95301004198509","balance":67090614.33,"cifno":"N299993","product":"Tabungan","productDescription":"PRODUCT_DESCRIPTION","productType":"PRODUCT_TYPE","status":"1"}]}}]}');
            res.setStatusCode(200);
            return res;
        }
	}
}