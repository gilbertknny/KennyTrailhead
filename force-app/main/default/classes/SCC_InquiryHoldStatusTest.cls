@isTest
private class SCC_InquiryHoldStatusTest {
    
    // Inner class to mock HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock response body
            String responseBody = '{"inquiryHoldStatus":{"holdDate":"0051120","holdType":"HG","holdRemark":"jaminan Pelaksanaan BG","holdAmt":"823820","responseMessage":"Transaction Successfully","responseCode":"00","errorCode":"AS-000"}}';
            
            // Create mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
            
            return res;
        }
    }
    
    @isTest
    static void testGetInquiryStatus() {
        // Test data
        String accountNumber = '002401000853304';
        
        // Set mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Call the method to be tested
        Test.startTest();
        SCC_InquiryStatusWrapper statusWrapper = SCC_InquiryHoldStatus.getInquiryStatus(accountNumber);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('', statusWrapper.saldoAkhirMutasi);
        System.assertEquals('HG', statusWrapper.holdType);
        System.assertEquals(823820, Integer.valueOf(statusWrapper.holdAmt));
        System.assertEquals('jaminan Pelaksanaan BG', statusWrapper.holdRemark);
    }
}