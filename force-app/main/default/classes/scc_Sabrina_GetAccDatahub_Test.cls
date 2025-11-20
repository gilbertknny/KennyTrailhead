/**
* @description       : Test Class for scc_Sabrina_GetAccDatahub
* @last modified on  : 03-04-2025
* @last modified by  : Muh Syafiq Hidayatullah
**/
@isTest
private class scc_Sabrina_GetAccDatahub_Test {

    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Customer',
            Phone = '0888888222221'
        );
        insert testAccount;
    }

    @IsTest
    static void testGetCustomerProfileByPhoneNumber() {
        
        // Setup test data
        String testPhoneNumber = '0888888222221';

        Test.startTest();
        
        scc_Sabrina_GetAccDatahub.RequestWrapper request = new scc_Sabrina_GetAccDatahub.RequestWrapper();
        request.phoneNumber = testPhoneNumber;

        // Insert request to lest
        List<scc_Sabrina_GetAccDatahub.RequestWrapper> requestList = new List<scc_Sabrina_GetAccDatahub.RequestWrapper>{request};
        
        // Create mock 
        Test.setMock(HttpCalloutMock.class, new MockHttpSabrinaGetAccDataHub());

        // Call the method
        List<scc_Sabrina_GetAccDatahub.ResponseWrapper> responseList = scc_Sabrina_GetAccDatahub.getCustomerProfileByPhoneNumber(requestList);

        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, responseList, 'Response list should not be null');
        System.assertEquals(1, responseList.size(), 'Should return exactly one response');
    }

    @IsTest
    static void testGetCustomerProfileByPhoneNumberNotFound() {
        
        // Setup test data
        String testPhoneNumber = '99999999';

        Test.startTest();
        
        scc_Sabrina_GetAccDatahub.RequestWrapper request = new scc_Sabrina_GetAccDatahub.RequestWrapper();
        request.phoneNumber = testPhoneNumber;

        // Insert request to lest
        List<scc_Sabrina_GetAccDatahub.RequestWrapper> requestList = new List<scc_Sabrina_GetAccDatahub.RequestWrapper>{request};
        
        // Create mock 
        Test.setMock(HttpCalloutMock.class, new MockHttpSabrinaGetAccDataHubError());

        // Call the method
        List<scc_Sabrina_GetAccDatahub.ResponseWrapper> responseList = scc_Sabrina_GetAccDatahub.getCustomerProfileByPhoneNumber(requestList);

        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, responseList, 'Response list should not be null');
        System.assertEquals(1, responseList.size(), 'Should return exactly one response');
    }

    @IsTest
    static void testGetCustomerProfileByPhoneNumberException() {
        
        // Setup test data
        String testPhoneNumber = null;

        Test.startTest();
        
        scc_Sabrina_GetAccDatahub.RequestWrapper request = new scc_Sabrina_GetAccDatahub.RequestWrapper();
        request.phoneNumber = testPhoneNumber;

        // Insert request to lest
        List<scc_Sabrina_GetAccDatahub.RequestWrapper> requestList = new List<scc_Sabrina_GetAccDatahub.RequestWrapper>{request};
        
        // Create mock 
        Test.setMock(HttpCalloutMock.class, new ExceptionMockHttpSabrinaGetAccDataHub());

        // Call the method
        List<scc_Sabrina_GetAccDatahub.ResponseWrapper> responseList = scc_Sabrina_GetAccDatahub.getCustomerProfileByPhoneNumber(requestList);

        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, responseList, 'Response list should not be null');
        System.assertEquals(1, responseList.size(), 'Should return exactly one response');
    }


    private class ExceptionMockHttpSabrinaGetAccDataHub implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{invalid:json}'); // Invalid JSON to force exception
            response.setStatusCode(200);
            return response;
        }
    }

    private class MockHttpSabrinaGetAccDataHub implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            scc_Sabrina_GetAccDatahub.ResponseWrapper res = new scc_Sabrina_GetAccDatahub.ResponseWrapper();
            res.accountId = 'this is sample response accountId';
            res.customerName = 'Test Customer';
            res.phone = '0888888222221';
            res.message = 'Success';

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json; charset=utf-8');
            response.setBody(JSON.serialize(res)); // Invalid JSON to force exception
            response.setStatusCode(200);
            return response;
        }
    }

    private class MockHttpSabrinaGetAccDataHubError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            scc_Sabrina_GetAccDatahub.ResponseWrapper res = new scc_Sabrina_GetAccDatahub.ResponseWrapper();
            res.accountId = null;
            res.customerName = 'No Customer Found';
            res.phone = 'No Phone Found';
            res.message = 'Failed';

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json; charset=utf-8');
            response.setBody(JSON.serialize(res)); // Invalid JSON to force exception
            response.setStatusCode(200);
            return response;
        }
    }
}