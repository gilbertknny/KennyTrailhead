/** @description
 * Test class for SCC_CardAndDigitalLandingCallout methods.
 */

@isTest
private class SCC_CardAndDigitalLandingCalloutTest {

   @isTest
   /** @description
     * Test method for testing getCustomerDataByPhone.
     */
static void testGetCustomerDataByPhone() {
    // Test data setup
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    Case testCase = new Case(Subject = 'Test Case', AccountId = testAccount.Id);
    insert testCase;

    String phoneNumber = '082135118489'; // Replace with a valid phone number related to your test data

    // Mock HTTP callout response with necessary structure
    String mockResponse = '{"response": {"customerData": [{"portofolio": {"creditCard": [{"status": "1", "productType": "Type A", "productDescription": "Description A", "product": "Product A", "cifno": "123", "cardNumber": "5188280280801904"}]}, "namaBelakang": "Doe", "namaTengah": "Middle", "namaDepan": "John"}]}}';
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

    // Call the method to test
    Test.startTest();
    List<SCC_CardlinkByPhoneWrapper> result = SCC_CardAndDigitalLandingCallout.getCustomerDataByPhone(phoneNumber, testCase.Id);
    Test.stopTest();

    // Assertions
    System.assertNotEquals(null, result, 'Result should not be null');
    for (SCC_CardlinkByPhoneWrapper wrapper : result) {
        System.assertNotEquals(null, wrapper.status, 'Status should not be null');
        System.assertNotEquals(null, wrapper.productType, 'Product Type should not be null');
        System.assertNotEquals(null, wrapper.productDescription, 'Product Description should not be null');
        System.assertNotEquals(null, wrapper.product, 'Product should not be null');
        System.assertNotEquals(null, wrapper.cifno, 'CIF Number should not be null');
        System.assertNotEquals(null, wrapper.cardNumber, 'Card Number should not be null');
    }
}

    @isTest
    /** @description
     * Test method for testing getCustomerDataByNIK.
     */
    static void testGetCustomerDataByNIK() {
        // Test data setup
        String nikNumber = '3275034101950023'; // Replace with a valid NIK number related to your test data

        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"CUSTPERSONAL": [{"namaNasabahLengkap": "John Doe", "nik": "123456", "tanggalLahir": "2000-01-01", "nomorAplikasiPengajuan": "123", "tanggalPengajuan": "2024-01-01", "channelPengajuan": "Channel A", "nomorKartuKredit": "123456", "progressPengajuan": "Completed"}]}'));
        
        // Call the method to test
        Test.startTest();
        List<SCC_CustPersWrapper> result = SCC_CardAndDigitalLandingCallout.getCustomerDataByNIK(nikNumber);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        for (SCC_CustPersWrapper wrapper : result) {
            System.assertNotEquals(null, wrapper.namaNasabahLengkap, 'Customer Name should not be null');
            System.assertNotEquals(null, wrapper.nik, 'NIK should not be null');
            // Add more assertions for other fields as needed
        }
    }


    // Existing test methods...

    @isTest
        /** @description
     * Test method for testing getPCTD.
     */

    static void testGetPCTD() {
        // Test data setup
        String cardNumber = '5188280280801904'; // Replace with a valid card number related to your test data

        // Mock HTTP callout response
        String mockResponse = '{"CPAHF": [{"jenisTransaksi": "Type A", "waktuSisaPenagihanMerchant": "Remaining Time", "nominalTransaksiMenggantung": "100", "tanggalTransaksiMenggantung": "2024-05-29", "deskripsiTransaksi": "Description A", "tanggalPostingTagihan": "2024-05-29", "akumulasiJumlahTransaksi": "200", "refferenceNumber": "123456", "kodeTransaksi": "ABC123", "tanggalPostingTransaksi": "2024-05-29", "approvalCode": "123456", "keteranganTransaksi": "Remarks", "nominalTransaksi": "100", "waktuTransaksi": "10:00:00", "tanggalTransaksi": "2024-05-29"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Call the method to test
        Test.startTest();
        SCC_PCTDWrapper result = SCC_CardAndDigitalLandingCallout.getPCTD(cardNumber);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.CPAHF, 'CPAHF list should not be null');
        System.assertEquals(1, result.CPAHF.size(), 'CPAHF list should have one entry');

        // Additional assertions for CPAHF object fields
        SCC_PCTDWrapper.CPAHF cahf = result.CPAHF[0];
        System.assertEquals('Type A', cahf.jenisTransaksi, 'Jenis Transaksi should match');
        System.assertEquals('Remaining Time', cahf.waktuSisaPenagihanMerchant, 'Waktu Sisa Penagihan Merchant should match');
        // Add assertions for other fields as needed
    }



    @isTest
     /** @description
     * Test method for testing getCardlinkByCardNumber.
     */
    static void testGetCardlinkByCardNumber() {
        // Prepare mock response
        String mockResponse = generateMockResponse();
        
        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        List<SCC_CardlinkByCardNumberWrapper.CustomerData> customerDataList = SCC_CardAndDigitalLandingCallout.getCardlinkByCardNumber('your_card_number_here');
        Test.stopTest();
        
       // Assertions
System.assertNotEquals(null, customerDataList, 'Customer data list should not be null');
for (SCC_CardlinkByCardNumberWrapper.CustomerData customerData : customerDataList) {
    System.assertNotEquals(null, customerData.namaDepan, 'First Name should not be null');
    System.assertNotEquals(null, customerData.namaBelakang, 'Last Name should not be null');
    System.assertNotEquals(null, customerData.alamatEmail, 'Email should not be null');
    // Add more assertions for other fields as needed
    List<SCC_CardlinkByCardNumberWrapper.CardHolderData> cardHolderDataList = customerData.cardHolderData;
    System.assertNotEquals(null, cardHolderDataList, 'CardHolderData list should not be null');
    for (SCC_CardlinkByCardNumberWrapper.CardHolderData cardHolderData : cardHolderDataList) {
        System.assertNotEquals(null, cardHolderData.namaCetakKartu, 'Card Holder Name should not be null');
        System.assertNotEquals(null, cardHolderData.tanggalTerakhirMaintenanceKartu, 'Last Maintenance Date should not be null');
        System.assertNotEquals(null, cardHolderData.customerNumber, 'Customer Number should not be null');
        System.assertNotEquals(null, cardHolderData.sisaLimitCicilanKartu, 'Remaining Installment Limit should not be null');
        System.assertNotEquals(null, cardHolderData.limitCicilanKartu, 'Installment Limit should not be null');
        System.assertNotEquals(null, cardHolderData.sisaLimitTarikTunaiKartu, 'Remaining Cash Withdrawal Limit should not be null');
        System.assertNotEquals(null, cardHolderData.limitTarikTunaiKartu, 'Cash Withdrawal Limit should not be null');
        System.assertNotEquals(null, cardHolderData.sisaLimitKartu, 'Remaining Limit should not be null');
        System.assertNotEquals(null, cardHolderData.tanggalJatuhTempo, 'Due Date should not be null');
        System.assertNotEquals(null, cardHolderData.tanggalCetakCycle, 'Cycle Print Date should not be null');
        System.assertNotEquals(null, cardHolderData.expiredKartu, 'Card Expiration Date should not be null');
        System.assertNotEquals(null, cardHolderData.limitKartuKredit, 'Credit Card Limit should not be null');
    }
}

    }
    // Helper methods, mock response generator, and HttpCalloutMock implementation

   /** @description
     * Generates a mock JSON response for testing getCardlinkByCardNumber method.
     * @return Mock JSON response as a String.
     */
static String generateMockResponse() {
    // Create a map to represent the JSON structure
    Map<String, Object> mockResponseMap = new Map<String, Object>{
        'response' => new Map<String, Object>{
            'customerData' => new List<Object>{
                new Map<String, Object>{
                    'namaDepan' => 'John',
                    'namaBelakang' => 'Doe',
                    'alamatEmail' => 'john.doe@example.com',
                    'cardHolderData' => new List<Object>{ // Ensure cardHolderData is populated
                        new Map<String, Object>{
                            'namaCetakKartu' => 'John Doe',
                            'tanggalTerakhirMaintenanceKartu' => '2024-05-28',
                            'customerNumber' => '123456',
                            'sisaLimitCicilanKartu' => '100',
                            'limitCicilanKartu' => '200',
                            'sisaLimitTarikTunaiKartu' => '50',
                            'limitTarikTunaiKartu' => '100',
                            'sisaLimitKartu' => '500',
                            'tanggalJatuhTempo' => '2024-06-01',
                            'tanggalCetakCycle' => '2024-05-01',
                            'expiredKartu' => '2025-05-28',
                            'limitKartuKredit' => '1000'
                        }
                    }
                }
            }
        }
    };
    
    // Serialize the map into JSON format
    String mockResponseJson = JSON.serialize(mockResponseMap);
    
    return mockResponseJson;
}
 /** @description
     * Mock HTTP response generator class for simulating HTTP callouts.
     */
    
    // Inner class to mock HTTP response
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private String mockResponse;
        /** @description
         * Constructor to initialize with mock response.
         * @param mockResponse Mock HTTP response body as a String.
         */
        public MockHttpResponseGenerator(String mockResponse) {
            this.mockResponse = mockResponse;
        }
        /** @description
         * Respond method to simulate HTTP response.
         * @param req HTTP request received.
         * @return HTTPResponse object containing the mock response.
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
    
}