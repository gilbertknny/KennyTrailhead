@IsTest
public class SCC_RPACreateTicket_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            SCC_cifno__c = 'TEST123456'
        );
        insert testAccount;
        
        // Create test User for RPA
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User rpaUser = new User(
            Alias = 'rpatest',
            Email = 'rpatest@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'RPA Test User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'rpatest@test.salesforce.com'
        );
        insert rpaUser;
    }
    
    @IsTest
    static void testCreateCaseWithExistingAccount() {
        // Setup test data
        Account testAccount = [SELECT Id FROM Account WHERE SCC_cifno__c = 'TEST123456' LIMIT 1];
        
        // Prepare request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'SCC_Account_Number__c' => '1234567890',
            'Subject' => 'Test Case Subject',
            'Description' => 'Test Case Description',
            'Priority' => 'Medium',
            'Status' => 'New'
        };
        
        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RPACreateTicket/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        // Mock the external service call
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        SCC_RPACreateTicket.createCase();
        
        Test.stopTest();
        
        // Verify response
        String responseBody = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseBody);
        
        // Verify case was created
        List<Case> createdCases = [SELECT Id, Subject, AccountId FROM Case WHERE Subject = 'Test Case Subject'];
        System.assertEquals(1, createdCases.size());
    }
    
    @IsTest
    static void testCreateCaseWithNewAccount() {
        // Prepare request body with different account number
        Map<String, Object> requestBody = new Map<String, Object>{
            'SCC_Account_Number__c' => '9876543210',
            'Subject' => 'Test Case for New Account',
            'Description' => 'Test Case Description',
            'Priority' => 'High',
            'Status' => 'New'
        };
        
        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RPACreateTicket/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        // Mock the external service call
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNewAccount());
        
        SCC_RPACreateTicket.createCase();
        
        Test.stopTest();
        
        // Verify response
        String responseBody = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseBody);
    }
    
    @IsTest
    static void testCreateCaseWithBlankAccountNumber() {
        // Prepare request body with blank account number
        Map<String, Object> requestBody = new Map<String, Object>{
            'SCC_Account_Number__c' => '',
            'Subject' => 'Test Case Without Account',
            'Description' => 'Test Case Description',
            'Priority' => 'Low',
            'Status' => 'New'
        };
        
        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RPACreateTicket/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        SCC_RPACreateTicket.createCase();
        
        Test.stopTest();
        
        // Verify response
        String responseBody = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseBody);
    }
    
    @IsTest
    static void testCreateCaseWithException() {
        // Prepare invalid request body to trigger exception
        Map<String, Object> requestBody = new Map<String, Object>{
            'SCC_Account_Number__c' => '1234567890',
            'Subject' => null, // This might cause an exception depending on validation rules
            'Description' => 'Test Case Description',
            'Priority' => 'Invalid Priority', // Invalid picklist value
            'Status' => 'New'
        };
        
        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RPACreateTicket/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        // Mock the external service call
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        SCC_RPACreateTicket.createCase();
        
        Test.stopTest();
        
        // Verify error response
        String responseBody = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseBody);
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @IsTest
    static void testCreateCaseWithNullRequestBody() {
        // Mock REST request with null body
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RPACreateTicket/';
        req.httpMethod = 'POST';
        req.requestBody = null;
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        SCC_RPACreateTicket.createCase();
        
        Test.stopTest();
        
        // Verify error response
        String responseBody = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseBody);
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @IsTest
    static void testInsertErrorLogMethod() {
        // Test the insertErrorLog method directly
        SCC_RPAWrapper.InsertUpdateCaseResponseModel jres = new SCC_RPAWrapper.InsertUpdateCaseResponseModel();
        jres.responseCode = '200';
        jres.responseMessage = 'Success';
        
        SCC_RPAController.ErrorLog el = new SCC_RPAController.ErrorLog();
        el.classname = 'SCC_RPACreateTicket_Test';
        el.url = '/test/';
        
        Test.startTest();
        
        String result = SCC_RPACreateTicket.insertErrorLog(null, jres, el);
        
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.contains('200'));
    }
    
    @IsTest
    static void testInsertErrorLogWithException() {
        // Test the insertErrorLog method with exception
        SCC_RPAWrapper.InsertUpdateCaseResponseModel jres = new SCC_RPAWrapper.InsertUpdateCaseResponseModel();
        jres.responseCode = '500';
        jres.responseMessage = 'Error occurred';
        
        SCC_RPAController.ErrorLog el = new SCC_RPAController.ErrorLog();
        el.classname = 'SCC_RPACreateTicket_Test';
        el.url = '/test/';
        
        Exception testException = new DmlException('Test DML Exception');
        
        Test.startTest();
        
        String result = SCC_RPACreateTicket.insertErrorLog(testException, jres, el);
        
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.contains('500'));
    }
    
    // Mock HTTP Response Generator for existing account scenario
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Mock response with existing account data
            Map<String, Object> responseData = new Map<String, Object>{
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'cifno' => 'TEST123456',
                        'demografi' => new Map<String, Object>{
                            'customerName' => 'Test Customer',
                            'phoneNumber' => '081234567890',
                            'emailAddress' => 'test@example.com'
                        }
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    
    // Mock HTTP Response Generator for new account scenario
    public class MockHttpResponseGeneratorNewAccount implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Mock response with new account data
            Map<String, Object> responseData = new Map<String, Object>{
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'cifno' => 'NEW987654',
                        'demografi' => new Map<String, Object>{
                            'customerName' => 'New Test Customer',
                            'phoneNumber' => '081987654321',
                            'emailAddress' => 'newtest@example.com'
                        }
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
}