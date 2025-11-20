@isTest
private class SCC_CustomerProfileSearchbyPhone_Test {

    // Test method to cover positive scenario of initiateCalloutUsingMobileNumber
    @isTest
    static void testInitiateCalloutUsingMobileNumberPositive() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
        // Create test data: Account with associated Case
        Account testAccount = new Account(Name = 'Test Account', Phone = '082347379586', SCC_cifno__c = 'NNE2576');
        insert testAccount;

        Case testCase = new Case(AccountId = testAccount.Id, SCC_Cust_Phone1__c = '082347379586');
        insert testCase;

        // Call the method under test
        Test.startTest();
        SCC_CustomerProfileSearchbyPhone.SCC_CalloutResponse response = SCC_CustomerProfileSearchbyPhone.initiateCalloutUsingMobileNumber(testAccount.Id);
        Test.stopTest();

        // Assert the response
        System.assertEquals(true, response.success, 'Successfull Response');
        System.assertNotEquals(null, response.message, 'Success');
    }
	
    // Test method to cover positive scenario of initiateCalloutUsingMobileNumber
    @isTest
    static void testInitiateCalloutUsingMobileNumberNegartive() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
        // Create test data: Account with associated Case
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Case testCase = new Case(AccountId = testAccount.Id, SCC_Cust_Phone1__c = null);
        insert testCase;

        // Call the method under test
        Test.startTest();
        SCC_CustomerProfileSearchbyPhone.SCC_CalloutResponse response = SCC_CustomerProfileSearchbyPhone.initiateCalloutUsingMobileNumber(testAccount.Id);
        Test.stopTest();

        // Assert the response
        System.assertEquals(false, response.success, 'Negative Response');
        System.assertEquals('Phone Number is incorrect/blank to make an API call', response.message, 'Negative Response');
    }
    
     @isTest
    static void updateAccountTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
        Account testAccount = new Account(LastName = 'Test Account', SCC_cifno__c = 'ILU7358');
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert testAccount;
        SCC_CustomerProfileWrapper.Demografi dmg = new SCC_CustomerProfileWrapper.Demografi();
        dmg.tipeNasabah = 'P';
        dmg.email = 'test@gmail.com';  
        dmg.namaSesuaiIdentitas = 'Test LastName';
        dmg.tanggalLahir = '1979-04-27';
        Test.startTest(); 
        SCC_CustomerProfileSearchbyPhone.updateAccount(testAccount, dmg);
        Test.stopTest();

        Account updatedAccount = [SELECT Name, SCC_Tipe_Nasabah__c, PersonEmail, SCC_Primary_Email__c FROM Account WHERE Id = :testAccount.Id];
        
        // Assert the updated values
        System.assertEquals('Test LastName', updatedAccount.Name, 'Last Name should be updated');
        System.assertEquals('Individu', updatedAccount.SCC_Tipe_Nasabah__c, 'Tipe Nasabah should be Individu');
        System.assertEquals('test@gmail.com', updatedAccount.PersonEmail, 'PersonEmail should be updated');
        System.assertEquals('test@gmail.com', updatedAccount.SCC_Primary_Email__c, 'Primary Email should be updated');
    }
    
    @isTest
    static void updateAccountTest1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse1());
        Account testAccount = new Account(Name = 'Test Account', SCC_cifno__c = 'NNE2576');
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        insert testAccount;
        SCC_CustomerProfileWrapper.Demografi dmg = new SCC_CustomerProfileWrapper.Demografi();
        dmg.tipeNasabah = 'O';
        dmg.email = 'test@gmail.com';  
        dmg.namaSesuaiIdentitas = 'Test LastName';
        dmg.tanggalLahir = '1979-04-27';
        Test.startTest(); 
        SCC_CustomerProfileSearchbyPhone.updateAccount(testAccount, dmg);
        Test.stopTest();

        Account updatedAccount = [SELECT Name, SCC_Tipe_Nasabah__c, PersonEmail, SCC_Primary_Email__c FROM Account WHERE Id = :testAccount.Id];
        
        // Assert the updated values
        System.assertEquals('Test LastName', updatedAccount.Name, 'Last Name should be updated');
        System.assertEquals('Non-Individu', updatedAccount.SCC_Tipe_Nasabah__c, 'Tipe Nasabah should be Individu');
        System.assertEquals('test@gmail.com', updatedAccount.SCC_Primary_Email__c, 'Primary Email should be updated');
    }
   
    // Test method to cover negative scenario of initiateCalloutUsingMobileNumber where data not found
    @isTest
    static void testInitiateCalloutUsingMobileNumberDataNotFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpWithoutErrorResponse());
        // Create test data: Account without associated Case
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Call the method under test
        Test.startTest();
        SCC_CustomerProfileSearchbyPhone.SCC_CalloutResponse response = SCC_CustomerProfileSearchbyPhone.initiateCalloutUsingMobileNumber(testAccount.Id);
        Test.stopTest();

        // Assert the response
        System.assertEquals(false, response.success, 'Data not found');
        System.assertNotEquals(null, response.message, 'Data not found');
    }

     // Mock class for API error response
    private class MockHttpWithoutErrorResponse implements HttpCalloutMock {
        /**
         * @description HTTPResponse
         * @param req
         * @return HttpResponse res
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"ILU7358","demografi":{"NPWP":"","PEP":"TIDAK","alamatDomisili":"BRI ENTERPRISE DATA MANAGEMENT","alamatDomisili2":"DIVISION GD BRI JL JENDRAL","alamatKantor":"JL VETERAN MALANG","alamatKantor2":"MALANG","alamatSesuaiID":"PERUM NEW PURI KARTIKA ASRI","alamatSesuaiID2":"BLOK H1 5 RT 003 RW 010","alamatSuratMenyurat":"SESUAI ID","bidangPekerjaan":"JASA PENDIDIKAN TINGGI","bidangUsaha":"","createdDate":"2014-08-28","email":"","email1":"","email2":"","email3":"","gelarSebelumNama":"","gelarSetelahNama":"","handphone":"62811838302","jabatan1":"","jabatan2":"","jabatan3":"","jenisIdentitas":"KT","jenisKelamin":"LAKI-LAKI","jenisPekerjaan":"KARYAWAN","kecamatanDomisili":"KEDUNGKANDANG","kecamatanKantor":"LOWOKWARU","kecamatanSesuaiID":"KEDUNGKANDANG","kelurahanDomisili":"ARJOWINANGUN","kelurahanKantor":"KETAWANGGEDE KEL.","kelurahanSesuaiID":"ARJOWINANGUN","keteranganAgama":"ISLAM","kewarganegaraan":"WNI","kodeBidangUsaha":"0","kodePosDomisili":"10210","kodePosKantor":"65145","kodePosSesuaiID":"65132","kotaDomisili":"JAKARTA PUSAT","kotaKantor":"MALANG KOT.","kotaSesuaiID":"MALANG","lastModifiedDate":"2022-04-08","nama1":"JejeAN","nama2":"AgusAN","nama3":"AlifAN","namaGadisIbuKandung":"SRI RESTUTI","namaSesuaiIdentitas":"AGUNG BUDI MIAN","namaTempatBekerja":"BRI ENTERPRISE DATA MANAG","nasabahPrioritas":"","negara":"INDONESIA","noAktaPendirian":"","noIdCorp":"","nomorIdentitas":"3573051807960003","pendidikanTerakhir":"SARJANA","propinsiDomisili":"JAWA TIMUR","propinsiKantor":"JAWA TIMUR","propinsiSesuaiID":"JAWA TIMUR","rtDomisili":"3","rtKantor":"01","rtSesuaiID":"3","rwDomisili":"10","rwKantor":"01","rwSesuaiID":"10","statusPerkawinan":"BELUM KAWIN","tanggalAktaPendirian":"","tanggalLahir":"1996-07-18","tanggalTerbit":"","telepon":"62811838302","telepon1":"","telepon2":"","telepon3":"","teleponKantor":"62811838302","tempatLahir":"MALANG","tempatPendirian":"","tipeIdCorp":"","tipeNasabah":"P","tipeNasabahDesc":"PERSON","umur":27},"portofolioPerbankan":null}]}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class MockHttpWithoutErrorResponse1 implements HttpCalloutMock {
        /**
         * @description HTTPResponse
         * @param req
         * @return HttpResponse res
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"NNE2576","demografi":{"NPWP":"027396944416000","PEP":"TIDAK","alamatDomisili":"NULL","alamatDomisili2":"NULL","alamatKantor":"NULL","alamatKantor2":"NULL","alamatSesuaiID":"JL.KH.HASYIM ASHARI NO.99 E","alamatSesuaiID2":"RT.02/02","alamatSuratMenyurat":"NULL","bidangPekerjaan":"NULL","bidangUsaha":"PERKEBUNAN","createdDate":"2022-04-06","email":"NULL","email1":"XXX@YAHOO.COM","email2":"NULL","email3":"NULL","gelarSebelumNama":"NULL","gelarSetelahNama":"NULL","handphone":"NULL","jabatan1":"PEMILIK, DIREKTUR","jabatan2":"NULL","jabatan3":"NULL","jenisIdentitas":"NP","jenisKelamin":"NULL","jenisPekerjaan":"NULL","kecamatanDomisili":"NULL","kecamatanKantor":"NULL","kecamatanSesuaiID":"CIPONDOH","kelurahanDomisili":"NULL","kelurahanKantor":"NULL","kelurahanSesuaiID":"CIPONDOH KEL","keteranganAgama":"NULL","kewarganegaraan":"WNA","kodeBidangUsaha":"1010","kodePosDomisili":"NULL","kodePosKantor":"NULL","kodePosSesuaiID":"15148","kotaDomisili":"NULL","kotaKantor":"NULL","kotaSesuaiID":"TANGERANG KOT.","lastModifiedDate":"2022-04-06","nama1":"Adhi","nama2":"Judan","nama3":"Boas","namaGadisIbuKandung":"-","namaSesuaiIdentitas":"NUREKA","namaTempatBekerja":"NUREKA","nasabahPrioritas":"NULL","negara":"INDONESIA","noAktaPendirian":"68","noIdCorp":"300614604274","nomorIdentitas":"027396944416000","pendidikanTerakhir":"NULL","propinsiDomisili":"NULL","propinsiKantor":"NULL","propinsiSesuaiID":"BANTEN","rtDomisili":"NULL","rtKantor":"NULL","rtSesuaiID":"02","rwDomisili":"NULL","rwKantor":"NULL","rwSesuaiID":"02","statusPerkawinan":"NULL","tanggalAktaPendirian":"1979-04-27","tanggalLahir":"1979-04-27","tanggalTerbit":"2015-11-13","telepon":"081322922912","telepon1":"082347379586","telepon2":"NULL","telepon3":"NULL","teleponKantor":"NULL","tempatLahir":"TANGERANG","tempatPendirian":"TANGERANG","tipeIdCorp":"TD","tipeNasabah":"O","tipeNasabahDesc":"ORGANISATION","umur":45},"portofolioPerbankan":{"cardlink":[{"cardNumber":"81463183678732","cifno":"NNE2576","product":"PIJAR","productDescription":"","productType":"CC","status":"1"}],"investasi":[{"accountNumber":"26389647887101","balance":0,"cifno":"NNE2576","product":"Junio","productDescription":"","productType":"IN","status":"1"}],"pinjaman":[{"accountNumber":"122301000204156","balance":0,"cifno":"NNE2576","product":"KMK RC RITEL","productDescription":"DL-202 KMK RC RITEL","productType":"DL"}],"simpanan":[{"accountNumber":"122301000689306","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"},{"accountNumber":"122301000936305","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"}]}}]}]}');
            res.setStatusCode(200);
            return res;
        }
    }
   
}