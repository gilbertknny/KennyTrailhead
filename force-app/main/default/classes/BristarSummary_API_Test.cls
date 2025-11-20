@isTest
private class BristarSummary_API_Test {
    @isTest
    static void testGetSummarySuccess() {

        BristarSummary_API_Wrapper.GetRequest_Model testRequest = new BristarSummary_API_Wrapper.GetRequest_Model();
        
        RestRequest req = new RestRequest();
        req.requestURI = '/bristarSummaryQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(testRequest));
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        BristarSummary_API.GetSummary();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode);
        System.assertNotEquals(null, res.responseBody);
    }
    
    @isTest
    static void testGetSummaryException() {

        RestRequest req = new RestRequest();
        req.requestURI = '/bristarSummaryQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('Invalid JSON');
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        BristarSummary_API.GetSummary();
        Test.stopTest();
        
        System.assertEquals(200, res.statusCode);
        System.assertNotEquals(null, res.responseBody);
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        
        System.debug('Full response: ' + res.responseBody.toString());
        System.debug('Response Map: ' + responseMap);
        System.debug('Response Code: ' + responseMap.get('responseCode'));
        
        System.assertEquals('119', responseMap.get('responseCode'), 'Unexpected response code');
        
        System.assert(responseMap.containsKey('responseMessage'), 'Response should contain a message');
        System.debug('Response Message: ' + responseMap.get('responseMessage'));
    }
    
    @isTest
    static void testInsertErrorLog() {
        Exception testException;
        try {
            Integer i = 1 / 0;
        } catch (Exception e) {
            testException = e;
        }
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String testReturnJson = '{"test": "value"}';
        
        Test.startTest();
        BristarSummary_API.InsertErrorLog(testException, req, res, testReturnJson);
        Test.stopTest();
    }
}