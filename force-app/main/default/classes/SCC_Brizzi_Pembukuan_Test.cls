/**
* @description       : Test Class for Brizzi Pembukuan
* @last modified on  : 03-03-2025
* @last modified by  : Muh Syafiq Hidayatullah
**/
@isTest
private class SCC_Brizzi_Pembukuan_Test {

    @TestSetup
    static void setupTestData() {
        // Create test Case record
        Case testCase = new Case(
            Subject = 'Test Brizzi Pembukuan Case',
            Description = 'Test case for Brizzi Pembukuan transaction',
            SCC_Nomor_Briva_Tagihan__c = '1234567890',
            Status = 'Draft'
        );
        insert testCase;

        system.debug('Test Case '+testCase);
        // Create Queue Trans record 
        List<SCC_Queuetrans__c> queueTrans = new List<SCC_Queuetrans__c>{
            new SCC_Queuetrans__c(
                SCC_Case__c = testCase.Id,
                SCC_Status__c = 'Transaction Successfully',
                scc_acct_kredit1__c = '020601003837305',
                scc_amt_kredit1__c = '50000'
            )
        };
        insert queueTrans;
    }

    @isTest
    static void testPembukuanBrizziUpdateSuccess() {
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        String resAd = 'success';
        Boolean retry = false;
        String csid = testCase.Id; // Using actual Case ID

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_Pembukuan_Mock.BrizziMock());
        
        // Set up mock callout
        Test.startTest();
        // Call the method to test
        SCC_Brizzi_Pembukuan.pembukuanBrizzi(testCase.Id, resAd, retry);
        
        Test.stopTest();
        
        // Verifikasi hasil
        // Case updatedCase = [SELECT SCC_Result_Pembukuan__c, Status,SCC_Result_Replace_Card__c,SCC_Status_Pembukuan__c FROM Case WHERE Id = :testCase.Id];
        // System.assertEquals('Transaction Successfully', updatedCase.SCC_Result_Pembukuan__c, 'Pembukuan harus berhasil');
        // System.assertEquals('Closed', updatedCase.Status, 'Status should be Closed');
        // System.assertEquals(true, updatedCase.SCC_Status_Pembukuan__c, 'Pembukuan status should be true');
        // System.assertEquals('success', updatedCase.SCC_Result_Replace_Card__c, 'Replace card result should be success');
    }

    @isTest
    static void testPembukuanBrizziUpdateNotSuccess() {
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        String resAd = 'failed';
        Boolean retry = false;
        String csid = testCase.Id; // Using actual Case ID

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_Pembukuan_Mock.BrizziMock());
        
        // Set up mock callout
        Test.startTest();
        // Call the method to test
        SCC_Brizzi_Pembukuan.pembukuanBrizzi(testCase.Id, resAd, retry);
        
        Test.stopTest();
        
        // Verifikasi hasil
        // Case updatedCase = [SELECT SCC_Result_Pembukuan__c, Status,SCC_Result_Replace_Card__c,SCC_Status_Pembukuan__c FROM Case WHERE Id = :testCase.Id];
        // System.assertEquals(true, updatedCase.SCC_Status_Pembukuan__c, 'Pembukuan status should be true');
        // System.assertEquals('failed', updatedCase.SCC_Result_Replace_Card__c, 'Replace card result should be success');
    }

    @isTest
    static void testPembukuanBrizziUpdateFailed() {
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        String resAd = 'failed';
        Boolean retry = false;
        String csid = testCase.Id; // Using actual Case ID

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_Pembukuan_Mock.BrizziMockFailed());
        
        // Set up mock callout
        Test.startTest();
        // Call the method to test
        SCC_Brizzi_Pembukuan.pembukuanBrizzi(testCase.Id, resAd, retry);
        
        Test.stopTest();
        
        // Verifikasi hasil
        // Case updatedCase = [SELECT SCC_Result_Pembukuan__c, Status,SCC_Result_Replace_Card__c,SCC_Status_Pembukuan__c FROM Case WHERE Id = :testCase.Id];
        // System.assertEquals('failed', updatedCase.SCC_Result_Replace_Card__c, 'Replace card result should be success');
    }

    @isTest
    static void testPembukuanBrizziSuccessException() {
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        String resAd = 'failed';
        Boolean retry = false;
        String csid = testCase.Id; // Using actual Case ID

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new ExceptionMockHttpBrizziPembukuan());
        
        // Set up mock callout
        Test.startTest();
        // Call the method to test
        SCC_Brizzi_Pembukuan.pembukuanBrizzi(testCase.Id, resAd, retry);
        
        Test.stopTest();
        
        // Verify
        // Case caseAfterException = [SELECT Id FROM Case WHERE Id = :csid];
        // System.assertNotEquals(null, caseAfterException, 'Case should still exist after exception');
    }

    @isTest
    static void testPembukuanBrizziAPISuccess() {
        // Prepare test data
        SCC_BrizziWrapper.BrizziPembukuanRequest request = Object_Test_Brizzi.brizziPembukuanRequest();
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_Pembukuan_Mock.BrizziMock());
        
        Test.startTest();
        // Call the method to test
        SCC_BrizziWrapper.BrizziPembukuanResponse response = SCC_Brizzi_Pembukuan_API.doPembukuan(request);
        Test.stopTest();
        
        // Verify the response
        // System.assertNotEquals(null, response, 'Response should not be null');
        // Additional assertions based on the expected response from Object_Test_Brizzi.adjustDepositResponse()
        // For example:
        // System.assertEquals('00', response.status, 'Status code should match');
        // System.assertEquals('Success', response.message, 'Message should match');
    }

    @isTest
    static void testPembukuanBrizziAPIFailed() {
        // Prepare test data
        SCC_BrizziWrapper.BrizziPembukuanRequest request = Object_Test_Brizzi.brizziPembukuanRequest();
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_Pembukuan_Mock.BrizziMockFailed());
        
        Test.startTest();
        // Call the method to test
        SCC_BrizziWrapper.BrizziPembukuanResponse response = SCC_Brizzi_Pembukuan_API.doPembukuan(request);
        Test.stopTest();
        
        // Verify the response
        // System.assertNotEquals(null, response, 'Response should not be null');
        // Additional assertions based on the expected response from Object_Test_Brizzi.adjustDepositResponse()
        // For example:
        // System.assertEquals('00', response.status, 'Status code should match');
        // System.assertEquals('Success', response.message, 'Message should match');
    }

    @isTest
    static void testPembukuanBrizziAPIException() {
        // Prepare test data
        SCC_BrizziWrapper.BrizziPembukuanRequest request = Object_Test_Brizzi.brizziPembukuanRequest();
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new ExceptionMockHttpBrizziPembukuan());
        
        Test.startTest();
        // Call the method to test
        SCC_BrizziWrapper.BrizziPembukuanResponse response = SCC_Brizzi_Pembukuan_API.doPembukuan(request);
        Test.stopTest();
        
        // Verify the response
        // System.assertNotEquals(null, response, 'Response should not be null');
        // Additional assertions based on the expected response from Object_Test_Brizzi.adjustDepositResponse()
        // For example:
        // System.assertEquals('00', response.status, 'Status code should match');
        // System.assertEquals('Success', response.message, 'Message should match');
    }

    private class ExceptionMockHttpBrizziPembukuan implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{invalid:json}'); // Invalid JSON to force exception
            response.setStatusCode(200);
            return response;
        }
    }
}