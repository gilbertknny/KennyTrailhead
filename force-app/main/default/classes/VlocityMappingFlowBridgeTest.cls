@IsTest
public with sharing class VlocityMappingFlowBridgeTest {
    
    // Test data setup method
    @TestSetup
    static void setupTestData() {
        // This class doesn't require specific test data since it's a bridge class
        // but we can create any necessary records if VlocityMapping has dependencies
    }
    
    // Test successful IP call with valid input
    @IsTest
    static void testSuccessfulIpCall() {
        // Create mock request
        VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
        request.ipName = 'TestIP';
        request.jsonInput = '{"testField":"testValue"}';
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{request};
        
        // Mock the VlocityMapping.callIP method if needed
        // Since it's a static method, we might need to use Test.setMock if it makes callouts
        // or refactor to use dependency injection for better testability
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals(null, responses[0].errorMessage, 'Should not have error message');
        // Note: We can't assert the exact resultJson without mocking VlocityMapping.callIP
    }
    
    // Test with null requests list
    @IsTest
    static void testNullRequests() {
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(null);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals('No input provided', responses[0].errorMessage, 'Should return no input error');
        System.assertEquals(null, responses[0].resultJson, 'Result JSON should be null');
    }
    
    // Test with empty requests list
    @IsTest
    static void testEmptyRequests() {
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>();
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals('No input provided', responses[0].errorMessage, 'Should return no input error');
        System.assertEquals(null, responses[0].resultJson, 'Result JSON should be null');
    }
    
    // Test with blank IP name
    @IsTest
    static void testBlankIpName() {
        VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
        request.ipName = ''; // Blank IP name
        request.jsonInput = '{"testField":"testValue"}';
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{request};
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals('ipName is required', responses[0].errorMessage, 'Should return IP name required error');
        System.assertEquals(null, responses[0].resultJson, 'Result JSON should be null');
    }
    
    // Test with null IP name
    @IsTest
    static void testNullIpName() {
        VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
        request.ipName = null; // Null IP name
        request.jsonInput = '{"testField":"testValue"}';
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{request};
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals('ipName is required', responses[0].errorMessage, 'Should return IP name required error');
        System.assertEquals(null, responses[0].resultJson, 'Result JSON should be null');
    }
    
    // Test with blank JSON input (should default to {})
    @IsTest
    static void testBlankJsonInput() {
        VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
        request.ipName = 'TestIP';
        request.jsonInput = ''; // Blank JSON input
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{request};
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals(null, responses[0].errorMessage, 'Should not have error message for blank JSON input');
        // The method should handle blank JSON by defaulting to '{}'
    }
    
    // Test with null JSON input (should default to {})
    @IsTest
    static void testNullJsonInput() {
        VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
        request.ipName = 'TestIP';
        request.jsonInput = null; // Null JSON input
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{request};
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        System.assertEquals(null, responses[0].errorMessage, 'Should not have error message for null JSON input');
        // The method should handle null JSON by defaulting to '{}'
    }
    
    // Test exception handling
    @IsTest
    static void testExceptionHandling() {
        VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
        request.ipName = 'TestIP';
        request.jsonInput = '{"testField":"testValue"}';
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{request};
        
        // If VlocityMapping.callIP might throw exceptions in certain scenarios,
        // we could mock that behavior here if the method was mockable
        // For now, we rely on the fact that the try-catch will handle any exceptions
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        // We can't force an exception without refactoring, but we verify the structure is correct
    }
    
    // Test bulk operations (multiple requests - though the method only uses the first one)
    @IsTest
    static void testMultipleRequests() {
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>();
        
        // Create multiple requests
        for (Integer i = 0; i < 5; i++) {
            VlocityMappingFlowBridge.Request request = new VlocityMappingFlowBridge.Request();
            request.ipName = 'TestIP' + i;
            request.jsonInput = '{"index":"' + i + '"}';
            requests.add(request);
        }
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        // The method should always return exactly one response (using the first request)
        System.assertEquals(1, responses.size(), 'Should return exactly one response regardless of input list size');
        System.assertEquals(null, responses[0].errorMessage, 'Should process without errors');
    }
    
    // Test that only the first request is processed (as per the design)
    @IsTest
    static void testOnlyFirstRequestProcessed() {
        VlocityMappingFlowBridge.Request firstRequest = new VlocityMappingFlowBridge.Request();
        firstRequest.ipName = 'FirstIP';
        firstRequest.jsonInput = '{"first":true}';
        
        VlocityMappingFlowBridge.Request secondRequest = new VlocityMappingFlowBridge.Request();
        secondRequest.ipName = 'SecondIP';
        secondRequest.jsonInput = '{"second":true}';
        
        List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>{
            firstRequest, secondRequest
        };
        
        Test.startTest();
        List<VlocityMappingFlowBridge.Response> responses = VlocityMappingFlowBridge.invoke(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return exactly one response');
        // The response should be based on the first request only
    }
}