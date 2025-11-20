@IsTest
public class SCC_GetCustomerDataByPhone_Test {

    @IsTest
    static void testGetCustomerDataByPhoneWithValidData() {
        // Set up mock data for Case and Account
        Account acc = new Account(Name = 'NUREKA', SCC_cifno__c = 'NNE2576', Phone = '082347379586');
        insert acc;
        
        Case caseRecord = new Case(AccountId = acc.Id, SCC_Cust_Phone1__c = '082347379586');
        insert caseRecord;

        // Set up the mock HTTP response
        String jsonResponse = '{"statusCode":200,"errorCode":"000","responseCode":"00","responseMessage":"Success","errors":null,"data":[{"cifno":"NNE2576","portofolioPerbankan":{"simpanan":[{"accountNumber":"122301000689306","product":"Giro Umum-IDR","productType":"GB","status":"1","openAccountDate":"2021-01-01"},{"accountNumber":"122301000936305","product":"Giro Umum-IDR","productType":"GB","status":"1","openAccountDate":"2021-01-02"}]}}]}';
        Test.setMock(HttpCalloutMock.class, new SCC_HttpMock(200, jsonResponse));
        
        String caseId = caseRecord.Id;

        Test.startTest();
        List<SCC_CustomerDataWrapper> result = SCC_GetCustomerDataByPhone.getCustomerDataByPhone(caseId);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
        System.assertEquals('122301000689306', result[0].accountNumber);
        System.assertEquals('Aktif', result[0].status);
        System.assertEquals('122301000936305', result[1].accountNumber);
        System.assertEquals('Aktif', result[1].status);
    }

    @IsTest
    static void testGetCustomerDataByPhoneWithMissingPhoneNumber() {
        // Set up mock data for Case without a phone number
        Account acc = new Account(Name = 'NUREKA', SCC_cifno__c = 'NNE2576');
        insert acc;
        
        Case caseRecord = new Case(AccountId = acc.Id);
        insert caseRecord;

        String caseId = caseRecord.Id;

        Test.startTest();
        try {
            List<SCC_CustomerDataWrapper> result = SCC_GetCustomerDataByPhone.getCustomerDataByPhone(caseId);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetCustomerDataByPhoneWithErrorResponse() {
        // Set up the mock HTTP response
        String errorResponse = '{"statusCode": 500, "message": "Mock HTTP error"}';
        Test.setMock(HttpCalloutMock.class, new SCC_HttpMock(500, errorResponse));
        
        Account acc = new Account(Name = 'Test Account', SCC_cifno__c = 'CIF123456', Phone = '1234567890');
        insert acc;
        
        Case caseRecord = new Case(AccountId = acc.Id, SCC_Cust_Phone1__c = '1234567890');
        insert caseRecord;

        String caseId = caseRecord.Id;

        Test.startTest();
        try {
            List<SCC_CustomerDataWrapper> result = SCC_GetCustomerDataByPhone.getCustomerDataByPhone(caseId);
            System.assert(true, 'Exception should have been thrown');
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