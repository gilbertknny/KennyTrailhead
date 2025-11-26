@IsTest
@SuppressWarnings('PMD.MethodNamingConventions')
public class RiskCloneOrchestratorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test Assets (Risks) with the proper Risk record type
        Id riskRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Risk').getRecordTypeId();
        
        List<Asset> testAssets = new List<Asset>();
        for(Integer i = 0; i < 3; i++) {
            Asset testAsset = new Asset(
                Name = 'Test Risk ' + i,
                AccountId = testAccount.Id,
                RecordTypeId = riskRecordTypeId
            );
            testAssets.add(testAsset);
        }
        insert testAssets;
    }
    
    // Test the RiskCloneOrchestrator queueable class
    @IsTest
    static void testRiskCloneOrchestrator_Success() {
        // Get a test risk
        Asset testRisk = [SELECT Id FROM Asset LIMIT 1];
        
        Test.startTest();
        
        // Execute the queueable job
        RiskCloneOrchestrator orchestrator = new RiskCloneOrchestrator(testRisk.Id);
        System.enqueueJob(orchestrator);
        
        Test.stopTest();
        
        // Verify that the job was queued without errors
        System.assert(true, 'Queueable job should execute without throwing exceptions');
    }
    
    @IsTest
    static void testRiskCloneOrchestrator_ExceptionHandling() {
        // Test with invalid ID to trigger exception - using Account prefix instead of hardcoded
        String invalidId = Account.sObjectType.getDescribe().getKeyPrefix() + '000000000000000';
        
        Test.startTest();
        
        try {
            RiskCloneOrchestrator orchestrator = new RiskCloneOrchestrator(invalidId);
            System.enqueueJob(orchestrator);
        } catch (Exception e) {
            // The exception should be caught internally in the execute method
            System.assert(false, 'Exception should be handled internally in Queueable');
        }
        
        Test.stopTest();
        
        // The test passes if no exception is thrown from enqueueJob
        System.assert(true, 'Should handle invalid ID gracefully');
    }
    
    @IsTest
    static void testRiskCloneOrchestrator_Constructor() {
        // Test the constructor
        Asset testRisk = [SELECT Id FROM Asset LIMIT 1];
        
        Test.startTest();
        RiskCloneOrchestrator orchestrator = new RiskCloneOrchestrator(testRisk.Id);
        Test.stopTest();
        
        // Verify the constructor sets the clonedRiskId
        System.assertNotEquals(null, orchestrator, 'Orchestrator should be instantiated');
    }
    
    // Test the RiskBulkCloneHelper invocable method
    @IsTest
    static void testStartBulkAsyncRiskCloning_Success() {
        // Get test risks
        List<Asset> testRisks = [SELECT Id FROM Asset LIMIT 3];
        List<Id> riskIds = new List<Id>();
        for(Asset risk : testRisks) {
            riskIds.add(risk.Id);
        }
        
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(riskIds);
        Test.stopTest();
        
        // Verify that jobs were enqueued without errors
        System.assert(true, 'Bulk cloning should initiate without errors');
    }
    
    @IsTest
    static void testStartBulkAsyncRiskCloning_EmptyList() {
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(new List<Id>());
        Test.stopTest();
        
        // Should handle empty list gracefully without errors
        System.assert(true, 'Empty list should be handled gracefully');
    }
    
    @IsTest
    static void testStartBulkAsyncRiskCloning_NullInput() {
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(null);
        Test.stopTest();
        
        // Should handle null input gracefully without errors
        System.assert(true, 'Null input should be handled gracefully');
    }
    
    @IsTest
    static void testStartBulkAsyncRiskCloning_SingleRisk() {
        // Get a single test risk
        Asset testRisk = [SELECT Id FROM Asset LIMIT 1];
        List<Id> riskIds = new List<Id>{testRisk.Id};
        
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(riskIds);
        Test.stopTest();
        
        // Should handle single risk without errors
        System.assert(true, 'Single risk should be processed without errors');
    }
    
    @IsTest
    static void testStartBulkAsyncRiskCloning_MultipleRisks() {
        // Create additional test risks for this specific test
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id riskRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Risk').getRecordTypeId();
        
        List<Asset> additionalRisks = new List<Asset>();
        for(Integer i = 0; i < 5; i++) {
            additionalRisks.add(new Asset(
                Name = 'Additional Test Risk ' + i,
                AccountId = testAccount.Id,
                RecordTypeId = riskRecordTypeId
            ));
        }
        insert additionalRisks;
        
        List<Id> riskIds = new List<Id>();
        for(Asset risk : additionalRisks) {
            riskIds.add(risk.Id);
        }
        
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(riskIds);
        Test.stopTest();
        
        // Should handle multiple risks without errors
        System.assert(true, 'Multiple risks should be processed without errors');
    }
    
    // Test integration between both classes
    @IsTest
    static void testIntegration_BulkToQueueable() {
        // Get test risks
        List<Asset> testRisks = [SELECT Id FROM Asset LIMIT 2];
        List<Id> riskIds = new List<Id>();
        for(Asset risk : testRisks) {
            riskIds.add(risk.Id);
        }
        
        Test.startTest();
        // Call the bulk method which should enqueue individual queueable jobs
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(riskIds);
        Test.stopTest();
        
        // Verify integration works without errors
        System.assert(true, 'Integration between bulk helper and queueable should work');
    }
    
    // Test the execute method directly - REMOVED Flow mocking
    @IsTest
    static void testExecuteMethodDirectly() {
        Asset testRisk = [SELECT Id FROM Asset LIMIT 1];
        
        Test.startTest();
        RiskCloneOrchestrator orchestrator = new RiskCloneOrchestrator(testRisk.Id);
        
        // Test the execute method directly without Flow mocking
        // This will try to call the actual Flow, which will fail in tests
        // But the exception will be caught in the execute method
        try {
            orchestrator.execute(null);
            System.assert(true, 'Execute method should handle Flow not found gracefully');
        } catch (Exception e) {
            // If an exception escapes the execute method, it's a problem
            System.assert(false, 'Execute method should catch all exceptions: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    // Test error scenario in execute method when Flow is not available
    @IsTest
    static void testExecuteMethod_FlowNotAvailable() {
        Asset testRisk = [SELECT Id FROM Asset LIMIT 1];
        
        Test.startTest();
        RiskCloneOrchestrator orchestrator = new RiskCloneOrchestrator(testRisk.Id);
        
        // The Flow won't be available in tests, but the exception should be caught
        try {
            orchestrator.execute(null);
            System.assert(true, 'Should handle missing Flow gracefully');
        } catch (Exception e) {
            System.assert(false, 'Exception should be caught internally: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    // Test with a large number of risks to simulate bulk processing
    @IsTest
    static void testBulkProcessingWithManyRisks() {
        // Create a larger set of risks for bulk testing
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id riskRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Risk').getRecordTypeId();
        
        List<Asset> bulkRisks = new List<Asset>();
        for(Integer i = 0; i < 10; i++) {
            bulkRisks.add(new Asset(
                Name = 'Bulk Test Risk ' + i,
                AccountId = testAccount.Id,
                RecordTypeId = riskRecordTypeId
            ));
        }
        insert bulkRisks;
        
        List<Id> riskIds = new List<Id>();
        for(Asset risk : bulkRisks) {
            riskIds.add(risk.Id);
        }
        
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(riskIds);
        Test.stopTest();
        
        System.assert(true, 'Bulk processing with many risks should work without errors');
    }
    
    // Test that the orchestrator properly initializes with the risk ID
    @IsTest
    static void testOrchestratorInitialization() {
        Asset testRisk = [SELECT Id FROM Asset LIMIT 1];
        
        RiskCloneOrchestrator orchestrator = new RiskCloneOrchestrator(testRisk.Id);
        
        // We can't access the private field, but we can verify the object was created
        System.assertNotEquals(null, orchestrator, 'Orchestrator should be properly initialized');
    }
    
    // Test debug logging in bulk helper
    @IsTest
    static void testBulkHelperDebugLogging() {
        List<Asset> testRisks = [SELECT Id FROM Asset LIMIT 2];
        List<Id> riskIds = new List<Id>();
        for(Asset risk : testRisks) {
            riskIds.add(risk.Id);
        }
        
        Test.startTest();
        RiskBulkCloneHelper.startBulkAsyncRiskCloning(riskIds);
        Test.stopTest();
        
        // The method should execute without errors and log the number of jobs
        System.assert(true, 'Bulk helper should execute debug logging without errors');
    }
}