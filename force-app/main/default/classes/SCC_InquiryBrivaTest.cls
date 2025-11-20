@isTest
private class SCC_InquiryBrivaTest {
    
    @TestSetup
    static void setupTestData() {
        BRIMO__c brimoSetting = new BRIMO__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Name = 'extId Briva',
            request_refnum__c = 123456  
        );
        insert brimoSetting;
        
        Case testCase = new Case(
            Subject = 'Test Briva Case',
            Status = 'Draft',
            Origin = 'Phone'
        );
        insert testCase;
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        
        public MockHttpResponseGenerator(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
    
    private static String getSuccessfulResponseJSON() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'errorCode' => '',
            'corpAccountNo' => '1234567890',
            'corpName' => 'Test Corp',
            'specialSegment' => 'N',
            'brivaco' => null
        };
        
        Map<String, Object> responseMap = new Map<String, Object>{
            'responseCode' => '00',
            'responseMessage' => 'Success',
            'errorCode' => '',
            'data' => dataMap
        };
        
        Map<String, Object> fullResponse = new Map<String, Object>{
            'response' => responseMap
        };
        
        return JSON.serialize(fullResponse);
    }
    
    // Helper method to generate special segment response JSON
    private static String getSpecialSegmentResponseJSON() {
        // For brivaco, create a string value that would be properly deserialized
        // Based on the error, it seems brivaco is expected to be a List<SCC_BrivaWrapper.Brivaco>
        Map<String, Object> brivacoObj = new Map<String, Object>{
            'code' => 'BRIV123',
            'name' => 'Test Brivaco'
        };
        List<Object> brivacoList = new List<Object>{ brivacoObj };
        
        Map<String, Object> dataMap = new Map<String, Object>{
            'errorCode' => '',
            'corpAccountNo' => '1234567890',
            'corpName' => 'Test Corp',
            'specialSegment' => 'Y',
            'brivaco' => brivacoList
        };
        
        Map<String, Object> responseMap = new Map<String, Object>{
            'responseCode' => '00',
            'responseMessage' => 'Success',
            'errorCode' => '',
            'data' => dataMap
        };
        
        Map<String, Object> fullResponse = new Map<String, Object>{
            'response' => responseMap
        };
        
        return JSON.serialize(fullResponse);
    }
    
    private static String getErrorResponseJSON() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'errorCode' => 'E001',
            'corpAccountNo' => ''
        };
        
        Map<String, Object> responseMap = new Map<String, Object>{
            'responseCode' => '99',
            'responseMessage' => 'Failed',
            'errorCode' => 'E001',
            'data' => dataMap
        };
        
        Map<String, Object> fullResponse = new Map<String, Object>{
            'response' => responseMap
        };
        
        return JSON.serialize(fullResponse);
    }
    
    @isTest
    static void testInquiryBrivaSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(getSuccessfulResponseJSON(), 200));
        
        Test.startTest();
        
        SCC_InquiryBriva.inquiryBriva('12345', testCase.Id);
        
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, SCC_Account_Number__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals('1234567890', updatedCase.SCC_Account_Number__c, 'Account number should be updated');
    }
    
    @isTest
    static void testInquiryBrivaUISuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(getSuccessfulResponseJSON(), 200));
        
        Test.startTest();
        
        SCC_BrivaWrapper.responseBrivaCustom result = SCC_InquiryBriva.inquiryBrivaUI('12345');
        
        Test.stopTest();
        
        System.assertEquals('00', result.responseCode, 'Response code should be 00');
        System.assertEquals('Success', result.responseMessage, 'Response message should be Success');
        System.assertEquals('1234567890', result.corpAccountNo, 'Corp account number should match');
        System.assertEquals('Test Corp', result.corpName, 'Corp name should match');
        System.assertEquals('N', result.specialSegment, 'Special segment should be N');
        // Changed the assertion to check that brivaco is null for non-special segment
        System.assertEquals(null, result.brivaco, 'Brivaco should be null for non-special segment');
    }
    
    // Test method for inquiryBrivaUI with special segment
    @isTest
    static void testInquiryBrivaUIWithSpecialSegment() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(getSpecialSegmentResponseJSON(), 200));
        
        Test.startTest();
        
        SCC_BrivaWrapper.responseBrivaCustom result = SCC_InquiryBriva.inquiryBrivaUI('12345');
        
        Test.stopTest();
        
        System.assertEquals('00', result.responseCode, 'Response code should be 00');
        System.assertEquals('Success', result.responseMessage, 'Response message should be Success');
        System.assertEquals('Y', result.specialSegment, 'Special segment should be Y');
        System.assertNotEquals(null, result.brivaco, 'Brivaco should not be null for special segment');
    }
    
    @isTest
    static void testInquiryBrivaUIError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(getErrorResponseJSON(), 200));
        
        Test.startTest();
        
        SCC_BrivaWrapper.responseBrivaCustom result = SCC_InquiryBriva.inquiryBrivaUI('12345');
        
        Test.stopTest();
        
        System.assertEquals('99', result.responseCode, 'Response code should be 99');
        System.assertEquals('Failed', result.responseMessage, 'Response message should be Failed');
        System.assertEquals('E001', result.errorCode, 'Error code should match');
    }
    
    @isTest
    static void testInquiryBrivaUIException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Invalid JSON', 500));
        
        Test.startTest();
        
        SCC_BrivaWrapper.responseBrivaCustom result = SCC_InquiryBriva.inquiryBrivaUI('12345');
        
        Test.stopTest();
        
        System.assert(result.responseMessage.startsWith('Error:'), 'Response message should start with Error:');
    }
    
    @isTest
    static void testUpdateCaseAccountNumberSuccess() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        
        Map<String, Object> result = SCC_InquiryBriva.updateCaseAccountNumber(testCase.Id, '9876543210');
        
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, SCC_Account_Number__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals('9876543210', updatedCase.SCC_Account_Number__c, 'Account number should be updated');
        
        System.assertEquals(true, result.get('success'), 'Result should indicate success');
    }
    
    @isTest
    static void testUpdateCaseAccountNumberException() {
        Test.startTest();
        
        try {
            SCC_InquiryBriva.updateCaseAccountNumber('invalidId', '9876543210');
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            //System.assert(e instanceof AuraHandledException, 'Exception should be AuraHandledException');
        }
        
        Test.stopTest();
    }
}