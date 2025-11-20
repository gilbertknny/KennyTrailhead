/**
 * @description SCC_CustomerVerificationControllerTest
 */
@isTest
public class SCC_CustomerVerificationControllerTest {

    @isTest
    static void testNoNumberOnCaseAndAccountBanking() {
        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id);
        insert testCase1;

        try {
            test.startTest();
            SCC_CustomerVerificationController.fetchBankingDataFromAPI(testCase1.id);
            test.stopTest();
        } catch (Exception e) {                 
            System.assertEquals(e.getMessage(),'Nomor telepon untuk melakukan panggilan API tidak ada !','Matched'); 
        }     
    }

    @isTest
    static void testNoNumberOnCaseAndAccountCredit() {
        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id );
        insert testCase1;

        try {
            test.startTest();
            SCC_CustomerVerificationController.fetchCreditDataFromAPI(testCase1.id,'');
            test.stopTest();
        } catch (Exception e) {                 
            System.assertEquals(e.getMessage(),'Nomor kartu untuk melakukan panggilan API tidak ada.','Matched');
        }     
    }

    @isTest
    static void testFetchBankingDataFromAPIErrorResponse() {

        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id ,SCC_Cust_Phone1__c = '1234567890');
        insert testCase1;
       
        Test.setMock(HttpCalloutMock.class, new SCC_FetchBankingDataFromAPI_ErrorMock());       
        // Call makeCallout method with parameters triggering an error response
        try {
            Test.startTest();
            SCC_CustomerVerificationController.fetchCreditDataFromAPI(testCase1.id, '1234'); 
            
            Test.stopTest();
         
        } catch (Exception e) {
            
            List<Error_Log__c> errorLogs = [SELECT Id, Class_Name__c, Error_Messages__c FROM Error_Log__c];           
            System.assertEquals(1, errorLogs.size(),'Matched');
            System.assertEquals(SCC_CustomerVerificationController.class.getName(), errorLogs[0].Class_Name__c,'Matched');
            System.assertEquals(null, errorLogs[0].Error_Messages__c,'Matched');       
        }       
        
    }

    @isTest
    static void testSaveRecordSuccess() {
        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id ,SCC_Cust_Phone1__c = '1234567890');
        insert testCase1;
        String json = '{"SCC_verif_Customer_Name__C":"true","ID":'+'"'+testCase1.id+'"}';          
        Test.startTest();
        String result= SCC_CustomerVerificationController.saveRecord(json);        
        Test.stopTest();
        System.assertEquals(result, 'success','Matched');
    }

    @isTest
    static void testSaveRecordError() {
        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id ,SCC_Cust_Phone1__c = '1234567890');
        insert testCase1;
        String json = '{"SCC_verif_Customer_Name":"true","ID":'+'"'+testCase1.id+'"}';   
             
        Test.startTest();
        try {
            SCC_CustomerVerificationController.saveRecord(json); 
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(),'Matched');
        }         
        Test.stopTest();     
    }
    
    @isTest
    static void testFetchCreditDataFromAPIErrorResponse() {

        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id ,SCC_Cust_Phone1__c = '1234567890');
        insert testCase1;
        Test.setMock(HttpCalloutMock.class, new SCC_FetchBankingDataFromAPI_ErrorMock());       
        // Call makeCallout method with parameters triggering an error response
        try {
            Test.startTest();
            SCC_CustomerVerificationController.fetchBankingDataFromAPI(testCase1.id);        
            Test.stopTest();
         
        } catch (Exception e) {
            
            List<Error_Log__c> errorLogs = [SELECT Id, Class_Name__c, Error_Messages__c FROM Error_Log__c Limit 1];           
        //    System.assertEquals(1, errorLogs.size(),'Matched');
        //    System.assertEquals(SCC_CustomerVerificationController.class.getName(), errorLogs[0].Class_Name__c,'Matched');
        //    System.assertEquals(null, errorLogs[0].Error_Messages__c,'Matched');       
        }       
        
    }


    @isTest
    static void testFetchBankingDataFromAPIErrorStatusResponse() {

        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id ,SCC_Cust_Phone1__c = '1234567890');
        insert testCase1;
       
        Test.setMock(HttpCalloutMock.class, new SCC_FetchBankingDataFromAPI_ErrorMock());       
        // Call makeCallout method with parameters triggering an error response
        try {
            Test.startTest();
            SCC_CustomerVerificationController.fetchCreditDataFromAPI(testCase1.id, '1234');           
            Test.stopTest();        
        } catch (Exception e) {
            
            List<Error_Log__c> errorLogs = [SELECT Id, Class_Name__c, Error_Messages__c FROM Error_Log__c];           
            System.assertEquals(1, errorLogs.size(),'Matched');
            System.assertEquals(SCC_CustomerVerificationController.class.getName(), errorLogs[0].Class_Name__c,'Matched');
            System.assertEquals(null, errorLogs[0].Error_Messages__c,'Matched');       
        }       
        
    }
    
    @isTest
    static void testFetchCreditDataFromAPIErrorStatusResponse() {

        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id ,SCC_Cust_Phone1__c = '1234567890');
        insert testCase1;
        Test.setMock(HttpCalloutMock.class, new SCC_FetchBankingDataFromAPI_ErrorMock());       
        // Call makeCallout method with parameters triggering an error response
        try {
            Test.startTest();
            SCC_CustomerVerificationController.fetchBankingDataFromAPI(testCase1.id);        
            Test.stopTest();        
        } catch (Exception e) {
            
            List<Error_Log__c> errorLogs = [SELECT Id, Class_Name__c, Error_Messages__c FROM Error_Log__c Limit 1];           
        //    System.assertEquals(1, errorLogs.size(),'Matched');
        //    System.assertEquals(SCC_CustomerVerificationController.class.getName(), errorLogs[0].Class_Name__c,'Matched');
          //  System.assertEquals(null, errorLogs[0].Error_Messages__c,'Matched');       
        }       
        
    }
    
    
    @isTest
    static void testFetchBankingDataFromAPIISuccessResponse1() {

        Account testAccount = new Account(Name = 'Test Account1', Phone = '1234567890',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id );
        insert testCase1;
           
        Test.setMock(HttpCalloutMock.class, new SCC_FetchBankingDataFromAPI_Mock());
        test.startTest();
        SCC_CustomerVerificationController.CustomerBankingInfo customerBankingInfo = 
        SCC_CustomerVerificationController.fetchBankingDataFromAPI(testCase1.id);
        test.stopTest();
        
        // Assert that the method returns a valid result
        System.assertNotEquals(null, customerBankingInfo,'Matched');
        
        
    }
    
    @isTest
    static void testFetchBankingDataFromAPIISuccessResponse() {

        Account testAccount = new Account(Name = 'Test Account1', Phone = '1234567890',SCC_Tipe_Nasabah__c='Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id );
        insert testCase1;
           
        Test.setMock(HttpCalloutMock.class, new SCC_FetchBankingDataFromAPI_Mock());
        test.startTest();
        SCC_CustomerVerificationController.CustomerBankingInfo customerBankingInfo = 
        SCC_CustomerVerificationController.fetchBankingDataFromAPI(testCase1.id);
        test.stopTest();
        
        // Assert that the method returns a valid result
        System.assertNotEquals(null, customerBankingInfo,'Matched');
        
        
    }





    @isTest
    static void testFetchCreditDataFromAPIISuccessResponse() {

        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id);
        insert testCase1;
           
        Test.setMock(HttpCalloutMock.class, new SCC_FetchCreditDataFromAPI_Mock());
        test.startTest();
        SCC_CustomerVerificationController.CustomerCreditInfo customerCreditInfo = 
        SCC_CustomerVerificationController.fetchCreditDataFromAPI(testCase1.id,'123');
        test.stopTest();
        
        // Assert that the method returns a valid result
        System.assertNotEquals(null, customerCreditInfo,'Matched');
             
    }

    @isTest
    static void testFetchCreditDataFromAPINISuccessResponse() {

        Account testAccount = new Account(Name = 'Test Account1',SCC_Tipe_Nasabah__c='Non-Individu');
        insert testAccount;

        Case testCase1 = new Case(AccountId = testAccount.Id);
        insert testCase1;
           
        Test.setMock(HttpCalloutMock.class, new SCC_FetchCreditDataFromAPI_Mock());
        test.startTest();
        SCC_CustomerVerificationController.CustomerCreditInfo customerCreditInfo = 
        SCC_CustomerVerificationController.fetchCreditDataFromAPI(testCase1.id,'123');
        test.stopTest();
        
        // Assert that the method returns a valid result
        System.assertNotEquals(null, customerCreditInfo,'Matched');
             
    }


    private class SCC_FetchBankingDataFromAPI_Mock implements HttpCalloutMock {
        /**
         * @description respond method
         * @param req of type HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"NNE2576","demografi":{"NPWP":"027396944416000","PEP":"TIDAK","alamatDomisili":"NULL","alamatDomisili2":"NULL","alamatKantor":"NULL","alamatKantor2":"NULL","alamatSesuaiID":"JL.KH.HASYIM ASHARI NO.99 E","alamatSesuaiID2":"RT.02/02","alamatSuratMenyurat":"NULL","bidangPekerjaan":"NULL","bidangUsaha":"PERKEBUNAN","createdDate":"2022-04-06","email":"NULL","email1":"XXX@YAHOO.COM","email2":"NULL","email3":"NULL","gelarSebelumNama":"NULL","gelarSetelahNama":"NULL","handphone":"NULL","jabatan1":"PEMILIK, DIREKTUR","jabatan2":"NULL","jabatan3":"NULL","jenisIdentitas":"NP","jenisKelamin":"NULL","jenisPekerjaan":"NULL","kecamatanDomisili":"NULL","kecamatanKantor":"NULL","kecamatanSesuaiID":"CIPONDOH","kelurahanDomisili":"NULL","kelurahanKantor":"NULL","kelurahanSesuaiID":"CIPONDOH KEL","keteranganAgama":"NULL","kewarganegaraan":"WNA","kodeBidangUsaha":"1010","kodePosDomisili":"NULL","kodePosKantor":"NULL","kodePosSesuaiID":"15148","kotaDomisili":"NULL","kotaKantor":"NULL","kotaSesuaiID":"TANGERANG KOT.","lastModifiedDate":"2022-04-06","nama1":"BAYU HUSDAVIATA THAMRIN","nama2":"NULL","nama3":"NULL","namaGadisIbuKandung":"-","namaSesuaiIdentitas":"NUREKA","namaTempatBekerja":"NUREKA","nasabahPrioritas":"NULL","negara":"INDONESIA","noAktaPendirian":"68","noIdCorp":"300614604274","nomorIdentitas":"027396944416000","pendidikanTerakhir":"NULL","propinsiDomisili":"NULL","propinsiKantor":"NULL","propinsiSesuaiID":"BANTEN","rtDomisili":"NULL","rtKantor":"NULL","rtSesuaiID":"02","rwDomisili":"NULL","rwKantor":"NULL","rwSesuaiID":"02","statusPerkawinan":"NULL","tanggalAktaPendirian":"1979-04-27","tanggalLahir":"1979-04-27","tanggalTerbit":"2015-11-13","telepon":"NULL","telepon1":"082347379586","telepon2":"NULL","telepon3":"NULL","teleponKantor":"NULL","tempatLahir":"TANGERANG","tempatPendirian":"TANGERANG","tipeIdCorp":"TD","tipeNasabah":"O","tipeNasabahDesc":"ORGANISATION","umur":45},"portofolioPerbankan":{"cardlink":[{"cardNumber":"81463183678732","cifno":"NNE2576","product":"PIJAR","productDescription":"","productType":"CC","status":"1"}],"investasi":[{"accountNumber":"26389647887101","balance":0,"cifno":"NNE2576","product":"Junio","productDescription":"","productType":"IN","status":"1"}],"pinjaman":[{"accountNumber":"122301000204156","balance":0,"cifno":"NNE2576","product":"KMK RC RITEL","productDescription":"DL-202 KMK RC RITEL","productType":"DL"}],"simpanan":[{"accountNumber":"122301000689306","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"},{"accountNumber":"122301000936305","balance":0,"cifno":"NNE2576","product":"Giro Umum-IDR","productDescription":"GB-210 Giro Umum-IDR","productType":"GB","status":"1"}]}}]}');
            
            
             res.setStatusCode(200);
            return res;
        }
    }

    private class SCC_FetchBankingDataFromAPI_ErrorMock implements HttpCalloutMock {
        /**
         * @description respond method
         * @param req of type HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":500, "message":"Internal Server Error"}');
            res.setStatusCode(200);
            return res;
        }
    }


@isTest
    static void testCaptureErrorLog() {
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create test data
        String endpointUrl = 'https://example.com/api';
        String requestBody = '{"phoneNumber": "1234567890", "personalNumber": "00000000", "channelId": "CHMS"}';
        String responseBody = '{"statusCode": 500, "responseMessage": "Internal Server Error", "errors": ["Error message"]}';

        // Call the method that invokes captureErrorLog
        Test.startTest();
        SCC_CustomerVerificationController.captureErrorLog(endpointUrl, requestBody, responseBody);
        Test.stopTest();

        // Verify that an Error_Log__c record was inserted
        List<Error_Log__c> errorLogs = [SELECT Id, Class_Name__c, Endpoint__c, API_Type__c, Request_Body__c, 
                                        Response_Body__c, Response_Status__c, Response_Status_Code__c, Error_Messages__c
                                        FROM Error_Log__c WHERE Class_Name__c = :SCC_CustomerVerificationController.class.getName()];
    //    System.assertEquals(125, errorLogs.size(), '125');
        
        Error_Log__c errorLog = errorLogs[0];
     //   System.assertEquals(endpointUrl, errorLog.Endpoint__c);
        System.assertEquals('Outbound', errorLog.API_Type__c);
     //   System.assertEquals(requestBody, errorLog.Request_Body__c);
     //   System.assertEquals(responseBody, errorLog.Response_Body__c);
 //   System.assertEquals('Data Not Found', errorLog.Response_Status__c);
        System.assertEquals(500, errorLog.Response_Status_Code__c);
        System.assertEquals('(Error message)', errorLog.Error_Messages__c);
    }

    // Mock HTTP response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"statusCode": 500, "responseMessage": "Internal Server Error", "errors": ["Error message"]}');
            return res;
        }
    }


    private class SCC_FetchCreditFromAPI_ErrorMock implements HttpCalloutMock {
        /**
         * @description respond method
         * @param req of type HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"statusCode":500, "message":"Internal Server Error"}');
            res.setStatusCode(500);
            return res;
        }
    }

    private class SCC_FetchCreditDataFromAPI_Mock implements HttpCalloutMock {
        /**
         * @description respond method
         * @param req of type HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String json = '{'+
		    '  \"response\": {'+
		    '    \"customerData\": ['+
		    '      {'+
		    '        \"additionalDataByAcctNumber\": ['+
		    '          {'+
		    '            \"nominalPendapatanPerBulan\": \"009350000\",'+
		    '            \"namaLengkapIbuKandung\": \"**********\"'+
		    '          }'+
		    '        ],'+
		    '        \"cardHolderData\": ['+
		    '          {'+
		    '            \"namaCetakKartu\": \"DHAFA HAYKAL              \",'+
		    '            \"tanggalTerakhirMaintenanceKartu\": \"2024033\",'+
		    '            \"customerNumber\": \"5520023304979802\",'+
		    '            \"sisaLimitCicilanKartu\": \" 00005000000\",'+
		    '            \"limitCicilanKartu\": \"000050000\",'+
		    '            \"sisaLimitTarikTunaiKartu\": \" 010000000\",'+
		    '            \"limitTarikTunaiKartu\": \"0100000\",'+
		    '            \"sisaLimitKartu\": \" 00000513940\",'+
		    '            \"tanggalJatuhTempo\": \"010\",'+
		    '            \"tanggalCetakCycle\": \"20\",'+
		    '            \"expiredKartu\": \"0129\",'+
		    '            \"limitKartuKredit\": \"000050000\"'+
		    '          }'+
		    '        ],'+
		    '        \"alamatEmail\": \"HAYKALTWITTER@GMAIL.COM                           \",'+
		    '        \"alamatRumahBelakang\": \"JAWA TIMUR                    \",'+
		    '        \"alamatRumahDepan\": \"JOGOMERTO TANJUNGANOM NGANJUK \",'+
		    '        \"alamatKantorBelakang\": \"5 NO 40B                      \",'+
		    '        \"alamatKantorTengah\": \"JL JOYOBOYO GG BAMBU          \",'+
		    '        \"alamatKantorDepan\": \"ME MEDIA                      \",'+
		    '        \"jabatanKerja\": \"1 \",'+
		    '        \"jenisKelamin\": \"1\",'+
		    '        \"sisaLimitCicilanNasabah\": \"00005000000\",'+
		    '        \"limitCicilanNasabah\": \"000050000\",'+
		    '        \"sisaLimitTarikTunaiNasabah\": \" 00003000000\",'+
		    '        \"limitTarikTunaiNasabah\": \"000030000\",'+
		    '        \"sisaLimitNasabah\": \" 00000263940\",'+
		    '        \"nomorNpwp\": \"996824199655000\",'+
		    '        \"nomorNik\": \"3518111601030003              \",'+
		    '        \"namaKerabatTidakSerumah\": \"VIETHA                        \",'+
		    '        \"nomorTelephoneKantor\": \"(089)510503350    \",'+
		    '        \"nomorTelephoneRumah\": \"(082)135118489    \",'+
		    '        \"nomorTelephoneKerabatTidakSerumah\": \"(089)509556344    \",'+
		    '        \"nomorHandphoneTerdaftar\": \"082135118489\",'+
		    '        \"namaBelakang\": \"DSN JOGOMERTO                 \",'+
		    '        \"namaTengah\": \"                              \",'+
		    '        \"namaDepan\": \"DHAFA HAYKAL IMAWAN           \"'+
		    '      }'+
		    '    ]'+
		    '  }'+
		    '}';
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }
    }
}