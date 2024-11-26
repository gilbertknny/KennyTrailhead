/** @description
 * Test class for testing the SCC_MerchantCallout class.
 */
@isTest
private class SCC_MerchantCalloutTest {

    
    // Mock HTTP response class
    private class MockHttpResponse implements HttpCalloutMock {
         /** @description
         * Respond method to return mock HTTP response.
         * @param req The HTTPRequest object.
         * @return The HTTPResponse object.
         */
        public HTTPResponse respond(HTTPRequest req) {
            // Creating a new HTTPResponse object
            HttpResponse res = new HttpResponse();
            // Setting status code
            res.setStatusCode(200);
            // Setting response body
            res.setBody('{"data":[{"trxDate":"2024-05-25","trxTime":"12:00:00"}]}');
            // Returning the response
            return res;
        }
    }

    // Test method to cover the makeCallout() method when tid is provided
    @isTest
    static void testMakeCalloutWithTid() {
        // Setting up the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the makeCallout method with tid
        Test.startTest();
        SCC_MerchantProfileByMIDWrapper response = SCC_MerchantCallout.makeCallout('test_tid', null);
        Test.stopTest();
        
        // Verifying the response
        System.assertEquals('Data tidak ditemukan', response.errorMessage);
    }

    // Test method to cover the makeCallout() method when mid is provided
    @isTest
    static void testMakeCalloutWithMid() {
        // Setting up the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the makeCallout method with mid
        Test.startTest();
        SCC_MerchantProfileByMIDWrapper response = SCC_MerchantCallout.makeCallout(null, 'test_mid');
        Test.stopTest();
        
        // Verifying the response
        System.assertEquals('Data tidak ditemukan', response.errorMessage);
    }

    // Test method to cover the makeCallout() method when neither tid nor mid is provided
    @isTest
    static void testMakeCalloutWithNoParameters() {
        // Setting up the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the makeCallout method with no parameters
        Test.startTest();
        SCC_MerchantProfileByMIDWrapper response = SCC_MerchantCallout.makeCallout(null, null);
        Test.stopTest();
        
        // Verifying the response
        System.assertEquals('Profile tidak valid', response.errorMessage);
    }

    // Test method to cover the getTransactionHistory() method
    @isTest
    static void testGetTransactionHistory() {
        // Setting up the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the getTransactionHistory method with valid parameters
        Test.startTest();
        SCC_TransactionHistoryWrapper response = SCC_MerchantCallout.getTransactionHistory('test_midOrMpan', 'test_tidOrStoreId', 'test_trxDate');
        Test.stopTest();
        
        // Verifying the response
        System.assertNotEquals(null, response);
        // Add additional assertions based on your wrapper class structure and expected data
    }

    // Test method to cover the getDetailTransaction() method
    @isTest
    static void testGetDetailTransaction() {
        // Setting up the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the getDetailTransaction method with valid parameters
        Test.startTest();
        SCC_DetailTransactionWrapper response = SCC_MerchantCallout.getDetailTransaction('test_midOrMpan', 'test_tidOrStoreId', 'test_trxDate', 'test_trxTime', 'test_appCodeOrReffNum');
        Test.stopTest();
        
        // Verifying the response and fields
        System.assertNotEquals(null, response);
        System.assertEquals(1, response.data.size());
        SCC_DetailTransactionWrapper.Data transactionData = response.data[0];
        System.assertEquals('2024-05-25', transactionData.trxDate);
        System.assertEquals('12:00:00', transactionData.trxTime);
        // Add assertions for other fields as needed
    }

    // Test method to cover the scenario when getTransactionHistory returns no data
    @isTest
    static void testGetTransactionHistoryNoData() {
        // Mocking HTTP response to simulate no data found
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the getTransactionHistory method with invalid parameters
        Test.startTest();
        SCC_TransactionHistoryWrapper response = SCC_MerchantCallout.getTransactionHistory('invalid_midOrMpan', 'invalid_tidOrStoreId', 'invalid_trxDate');
        Test.stopTest();
        
        // Verifying the response
        System.assertNotEquals(null, response);
        // Add additional assertions based on your wrapper class structure and expected data
    }

    // Test method to cover the scenario when getDetailTransaction returns no data
    @isTest
    static void testGetDetailTransactionNoData() {
        // Mocking HTTP response to simulate no data found
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Calling the getDetailTransaction method with invalid parameters
        Test.startTest();
        SCC_DetailTransactionWrapper response = SCC_MerchantCallout.getDetailTransaction('invalid_midOrMpan', 'invalid_tidOrStoreId', 'invalid_trxDate', 'invalid_trxTime', 'invalid_appCodeOrReffNum');
        Test.stopTest();
        
        // Verifying the response
        System.assertNotEquals(null, response);
        // Add additional assertions based on your wrapper class structure and expected data
    }
}