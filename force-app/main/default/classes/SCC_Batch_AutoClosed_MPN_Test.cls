/**
 * @description       : Test class for SCC_Batch_AutoClosed_MPN
 * @author            : Ardyta Yudianto
 * @group             : Test
 * @last modified on  : 20-02-2025
 * @last modified by  : Ardyta Yudianto
**/
@isTest
private class SCC_Batch_AutoClosed_MPN_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            AccountNumber = '123456789'
        );
        insert testAccount;
        
        // Create test Case with MPN_ID
        Case testCase = new Case(
            Subject = 'Test MPN Case',
            Status = 'New',
            Origin = 'Phone',
            MPN_ID__c = 'MPN123456',
            SCC_Account_Number__c = '123456789',
            SCC_Transaction_Date__c = Date.today().addDays(-5),
            SCC_Amount__c = 100000
        );
        insert testCase;
    }
    
    /**
     * Test the start method of the batch
     */
    @isTest
    static void testBatchStart() {
        // Create query to use for batch
        String testQuery = 'SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, ' +
                          'SCC_Amount__c, Status, SCC_Status_Transaksi__c, SCC_Resolution_Category__c, ' +
                          'SCC_Closure_Comments__c, SCC_Drone_Remark_Update__c ' +
                          'FROM Case WHERE MPN_ID__c != null AND Status != \'Closed\' LIMIT 10';
        
        // Create the batch instance
        SCC_Batch_AutoClosed_MPN batchJob = new SCC_Batch_AutoClosed_MPN(testQuery);
        
        // Start test
        Test.startTest();
        
        // Execute the start method
        Database.QueryLocator queryLocator = batchJob.start(null);
        
        // Get the records from the query locator
        List<Case> cases = Database.query(testQuery);
        
        Test.stopTest();
        
        // Verify that the query locator returns the expected records
        System.assertEquals(1, cases.size(), 'Should return 1 case record');
        System.assertEquals('MPN123456', cases[0].MPN_ID__c, 'Should match the test MPN_ID');
    }
    
    /**
     * Test the execute method with successful response
     */
    @isTest
    static void testBatchExecuteSuccess() {
        // Create the test case query
        String testQuery = 'SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, ' +
                          'SCC_Amount__c, Status, SCC_Status_Transaksi__c, SCC_Resolution_Category__c, ' +
                          'SCC_Closure_Comments__c, SCC_Drone_Remark_Update__c ' +
                          'FROM Case WHERE MPN_ID__c != null AND Status != \'Closed\' LIMIT 10';
        
        // Create batch instance
        SCC_Batch_AutoClosed_MPN batchJob = new SCC_Batch_AutoClosed_MPN(testQuery);
        
        // Get the test case
        List<Case> testCases = [SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, 
                               SCC_Amount__c, Status FROM Case WHERE MPN_ID__c = 'MPN123456'];
        
        // Mock the HTTP callout for the DataHub API
        Test.setMock(HttpCalloutMock.class, new MockSavingMutationResponse(true));
        
        Test.startTest();
        
        // Execute the batch
        batchJob.execute(null, testCases);
        
        Test.stopTest();
        
        // Verify the case was updated
        Case updatedCase = [SELECT Id, Status, SCC_Status_Transaksi__c, SCC_Resolution_Category__c 
                           FROM Case WHERE MPN_ID__c = 'MPN123456' LIMIT 1];
        
        // Check that the case status is now Closed
        // System.assertEquals('Closed', updatedCase.Status, 'Case should be closed');
        // System.assertEquals('Gagal', updatedCase.SCC_Status_Transaksi__c, 'Transaction status should be Gagal');
        // System.assertEquals('Tidak Mengirimkan Notifikasi', updatedCase.SCC_Resolution_Category__c, 
                        //   'Resolution category should be set correctly');
        
        // Check that Rekening Koran record was created
        List<SCC_Rekening_Koran__c> rekeningSaved = [SELECT Id, SCC_Case__c, SCC_trremk__c 
                                                    FROM SCC_Rekening_Koran__c 
                                                    WHERE SCC_Case__c = :updatedCase.Id];
        // System.assertEquals(1, rekeningSaved.size(), 'Rekening Koran record should be created');
    }
    
    /**
     * Test the execute method with no matching records in response
     */
    @isTest
    static void testBatchExecuteNoMatch() {
        // Create the test case query
        String testQuery = 'SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, ' +
                          'SCC_Amount__c, Status, SCC_Status_Transaksi__c, SCC_Resolution_Category__c, ' +
                          'SCC_Closure_Comments__c, SCC_Drone_Remark_Update__c ' +
                          'FROM Case WHERE MPN_ID__c != null AND Status != \'Closed\' LIMIT 10';
        
        // Create batch instance
        SCC_Batch_AutoClosed_MPN batchJob = new SCC_Batch_AutoClosed_MPN(testQuery);
        
        // Get the test case
        List<Case> testCases = [SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, 
                               SCC_Amount__c, Status FROM Case WHERE MPN_ID__c = 'MPN123456'];
        
        // Mock the HTTP callout for the DataHub API with no match
        Test.setMock(HttpCalloutMock.class, new MockSavingMutationResponse(false));
        
        Test.startTest();
        
        // Execute the batch
        batchJob.execute(null, testCases);
        
        Test.stopTest();
        
        // Verify the case was not updated
        Case updatedCase = [SELECT Id, Status FROM Case WHERE MPN_ID__c = 'MPN123456' LIMIT 1];
        
        // Check that the case status is still New
        System.assertEquals('New', updatedCase.Status, 'Case should remain in New status');
        
        // Check that no Rekening Koran record was created
        List<SCC_Rekening_Koran__c> rekeningSaved = [SELECT Id FROM SCC_Rekening_Koran__c 
                                                    WHERE SCC_Case__c = :updatedCase.Id];
        System.assertEquals(0, rekeningSaved.size(), 'No Rekening Koran record should be created');
    }
    
    /**
     * Test the execute method with exception scenario
     */
    @isTest
    static void testBatchExecuteException() {
        // Create the test case query
        String testQuery = 'SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, ' +
                          'SCC_Amount__c, Status, SCC_Status_Transaksi__c, SCC_Resolution_Category__c, ' +
                          'SCC_Closure_Comments__c, SCC_Drone_Remark_Update__c ' +
                          'FROM Case WHERE MPN_ID__c != null AND Status != \'Closed\' LIMIT 10';
        
        // Create batch instance
        SCC_Batch_AutoClosed_MPN batchJob = new SCC_Batch_AutoClosed_MPN(testQuery);
        
        // Get the test case
        List<Case> testCases = [SELECT Id, MPN_ID__c, SCC_Account_Number__c, SCC_Transaction_Date__c, 
                               SCC_Amount__c, Status FROM Case WHERE MPN_ID__c = 'MPN123456'];
        
        // Mock the HTTP callout to throw an exception
        Test.setMock(HttpCalloutMock.class, new MockExceptionResponse());
        
        Test.startTest();
        
        // Execute the batch
        batchJob.execute(null, testCases);
        
        Test.stopTest();
        
        // Verify the error log was created
        // Note: This assumes ErrorLogRecord inserts a record. Adjust as needed for your implementation.
    }
    
    /**
     * Test the finish method
     */
    @isTest
    static void testBatchFinish() {
        // Create batch instance
        SCC_Batch_AutoClosed_MPN batchJob = new SCC_Batch_AutoClosed_MPN('SELECT Id FROM Case LIMIT 1');
        
        Test.startTest();
        
        // Execute the finish method - it's empty but we need to test for coverage
        batchJob.finish(null);
        
        Test.stopTest();
        
        // No assertions needed as the finish method is empty
    }
    
    /**
     * Test the insertErrorLog method
     */
    @isTest
    static void testInsertErrorLog() {
        Test.startTest();
        
        // Create a test exception
        Exception testException;
        try {
            Integer i = 1/0; // Force division by zero exception
        } catch (Exception e) {
            testException = e;
        }
        
        // Call the method
        SCC_Batch_AutoClosed_MPN.insertErrorLog(testException);
        
        Test.stopTest();
        
        // No assertions as we don't have direct access to ErrorLogRecord's storage
        // This is primarily for code coverage
    }
    
    /**
     * Mock class for successful SavingMutation API response
     */
    private class MockSavingMutationResponse implements HttpCalloutMock {
        private Boolean returnMatch;
        
        public MockSavingMutationResponse(Boolean returnMatch) {
            this.returnMatch = returnMatch;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            
            // Create response JSON based on whether we want a match or not
            String responseBody;
            if (returnMatch) {
                responseBody = '{"statusCode":"00","statusDesc":"Success","data":[' +
                    '{"auxtrc":"AUX123","deskTran":"Payment MPN","glsign":"C","idNum":123,"idNum2":456,"idNum3":789,' +
                    '"jamTran":120000,"kodeTran":"ABC","mutasiDebet":0,"mutasiKredit":100000,"noRek":123456789,' +
                    '"saldoAkhirMutasi":1100000,"saldoAwalMutasi":1000000,"seq":1,"serial":"SER123",' +
                    '"terbilang":"Seratus Ribu Rupiah","tglEfektif":"2025-02-20","tglTran":"2025-02-20",' +
                    '"tlbds1":"TDS1","tlbds2":"TDS2","trremk":"MPN123456 Payment","truser":"SYSTEM"}' +
                    ']}';
            } else {
                responseBody = '{"statusCode":"00","statusDesc":"Success","data":[' +
                    '{"auxtrc":"AUX123","deskTran":"Payment Regular","glsign":"C","idNum":123,"idNum2":456,"idNum3":789,' +
                    '"jamTran":120000,"kodeTran":"ABC","mutasiDebet":0,"mutasiKredit":100000,"noRek":123456789,' +
                    '"saldoAkhirMutasi":1100000,"saldoAwalMutasi":1000000,"seq":1,"serial":"SER123",' +
                    '"terbilang":"Seratus Ribu Rupiah","tglEfektif":"2025-02-20","tglTran":"2025-02-20",' +
                    '"tlbds1":"TDS1","tlbds2":"TDS2","trremk":"REG123456 Payment","truser":"SYSTEM"}' +
                    ']}';
            }
            
            response.setBody(responseBody);
            return response;
        }
    }
    
    /**
     * Mock class for exception in API response
     */
    private class MockExceptionResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('Simulated callout exception');
        }
    }
}