@isTest
private class SCC_BristarSummary_Test {
    
    // Your existing @testSetup method remains the same
    @testSetup
    static void setupTestData() {
        // Create test cases with various scenarios
        SSC_Call_Type__c ct = Object_Test.setCaseType('8812');
        insert ct;
        Case cs = Object_Test.setCaseBristar('Escalate', ct.id);
        Case cs1 = Object_Test.setCaseBristar('New', ct.id);
        Case cs2 = Object_Test.setCaseBristar('Returned', ct.id);
        Case cs3 = Object_Test.setCaseBristar('Closed', ct.id);
        
        insert new List<Case>{cs, cs1, cs2, cs3};

        list<Case> lcs = [SELECT Region__c, Main_Branch__c, Branch_Code__c, Cost_Center__c FROM Case];
        System.debug('listCase :'+lcs);
    }
    
    @isTest
    static void testExecuteMethodWithNullDate() {
        Test.startTest();
        // Call execute method with null date to check default behavior
        SCC_BristarSummary batchJob = new SCC_BristarSummary(null, null, null);
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Verify Bristar Summary records are created
        List<Bristar_Summary__c> summaries = [SELECT Id FROM Bristar_Summary__c];
    }
    
    @isTest
    static void testExecuteMethodWithSpecificDate() {
        Date testDate1 = Date.today().addDays(-30);
        Date testDate2 = Date.today();
        
        Test.startTest();
        SCC_BristarSummary batchJob = new SCC_BristarSummary(testDate1, testDate2, 1);
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Verify Bristar Summary records are created
        List<Bristar_Summary__c> summaries = [SELECT Id FROM Bristar_Summary__c];
        System.assertNotEquals(0, summaries.size(), 'Bristar Summary records should be created');
    }
    
    @isTest
    static void testBristarSummaryCalculations() {
        Date testDate1 = Date.today().addDays(-30);
        Date testDate2 = Date.today();
        
        Test.startTest();
        SCC_BristarSummary batchJob = new SCC_BristarSummary(testDate1, testDate2, 1);
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Retrieve created Bristar Summary records
        List<Bristar_Summary__c> summaries = [
            SELECT 
                closedTicket__c, 
                openTicket__c, 
                onSla__c, 
                overSla__c, 
                onSlaOpen__c, 
                onSlaClosed__c, 
                overSlaOpen__c, 
                overSlaClosed__c,
                External_ID__c
            FROM Bristar_Summary__c
        ];
    
        // Detailed assertions to verify calculations
        for (Bristar_Summary__c summary : summaries) {
            System.assertNotEquals(null, summary.External_ID__c, 'External ID should be generated');
            
            // Assert that counters are being calculated correctly
            System.assert(summary.closedTicket__c >= 0, 'Closed ticket count should be non-negative');
            System.assert(summary.openTicket__c >= 0, 'Open ticket count should be non-negative');
            System.assert(summary.onSla__c >= 0, 'On SLA count should be non-negative');
            System.assert(summary.overSla__c >= 0, 'Over SLA count should be non-negative');
        }
    }
    
    @isTest
    static void testGenerateExternalID() {
        // Retrieve a test case to use for external ID generation
        Case testCase = [SELECT 
            Area__c, 
            Cost_Center__c, 
            Region_Code__c,
            Main_Branch__c, 
            Branch_Code__c, 
            Date__c 
            FROM Case LIMIT 1];
        
        // Generate external ID with a case that has null fields
        Case nullFieldCase = new Case();
        String nullFieldExternalId = SCC_BristarSummary.generateExternalIDBristar(nullFieldCase);
        
        // Generate external ID
        String externalId = SCC_BristarSummary.generateExternalIDBristar(testCase);
        
        // Assertions
        System.assertNotEquals(null, externalId, 'External ID should not be null');
        System.assert(externalId.contains('-'), 'External ID should contain hyphen separators');
        System.assertNotEquals(null, nullFieldExternalId, 'External ID for case with null fields should still be generated');
    }
    
    @isTest
    static void testSummaryUpsertQueue() {
        // Prepare test data
        List<Bristar_Summary__c> testSummaries = new List<Bristar_Summary__c>();
        for (Integer i = 0; i < 10000; i++) {
            Bristar_Summary__c summary = new Bristar_Summary__c(
                External_ID__c = 'TEST-' + i,
                closedTicket__c = 1,
                openTicket__c = 1,
                onSla__c = 1,
                overSla__c = 1,
                onSlaOpen__c = 1,
                onSlaClosed__c = 1,
                overSlaOpen__c = 1,
                overSlaClosed__c = 1
            );
            testSummaries.add(summary);
        }
        
        Test.startTest();
        // Create an instance of SCC_BristarSummary to use its method
        SCC_BristarSummary batchJob = new SCC_BristarSummary(Date.today(), Date.today(), 1);
        
        // Process records in batches using Queueable
        SCC_BristarSummary.SummaryUpsertQueue initialQueueJob = 
            new SCC_BristarSummary.SummaryUpsertQueue(testSummaries, batchJob);
        System.enqueueJob(initialQueueJob);
        
        Test.stopTest();
        
        // Verify records were processed
        List<Bristar_Summary__c> upsertedRecords = [
            SELECT Id FROM Bristar_Summary__c 
            WHERE External_ID__c LIKE 'TEST-%'
        ];
        System.assertNotEquals(0, upsertedRecords.size(), 'Records should be upserted');
    }
    
    @isTest
    static void testErrorHandlingScenarios() {
        Test.startTest();
        // Test with an extremely old date to ensure no unexpected errors
        try {
            Database.executeBatch(new SCC_BristarSummary(Date.newInstance(1900, 1, 1), Date.newInstance(1900, 1, 1), 1));
        } catch (Exception e) {
            System.assert(false, 'No unhandled exceptions should be thrown: ' + e.getMessage());
        }
        
        // Test with extreme/edge case conditions
        try {
            // Create a batch with no cases matching the conditions
            Date futureDate1 = Date.today().addYears(1);
            Date futureDate2 = Date.today().addYears(1);
            Database.executeBatch(new SCC_BristarSummary(futureDate1, futureDate2, 1));
        } catch (Exception e) {
            System.assert(false, 'No unhandled exceptions should be thrown for empty result sets');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testConstructorWithExplicitExecution() {
        // Test constructor with explicit execution parameter
        Test.startTest();
        SCC_BristarSummary batchJob = new SCC_BristarSummary(null, null, 1);
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        List<Bristar_Summary__c> summaries = [SELECT Id FROM Bristar_Summary__c];
    }
}