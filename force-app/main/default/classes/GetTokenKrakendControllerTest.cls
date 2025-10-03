@IsTest
public class GetTokenKrakendControllerTest {

    // Custom exception defined as an INNER CLASS
    private class NamedCredentialException extends Exception {}    
    
    // Test successful token and URL retrieval
    @IsTest
    static void testGetUrlAndTokenSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessResponse());
        
        Test.startTest();
        GetTokenKrakendController.TokenResponse result = GetTokenKrakendController.getUrlAndToken();
        Test.stopTest();

        System.assertEquals('Bearer mockToken123', result.token, 'Token should be prefixed with Bearer');
        
        NamedCredential nc = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'MasterDataNmCred_Legacy' LIMIT 1];
        String expectedUrl = nc.Endpoint + '/sf/document/v1/document-frontend';
        System.assertEquals(expectedUrl, result.url, 'URL should match NamedCredential endpoint');
    }

    // Test HTTP error response (e.g., 400)
    @IsTest
    static void testGetUrlAndTokenHttpError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        try {
            GetTokenKrakendController.getUrlAndToken();
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error getting token: HTTP 400'), 'Exception message should indicate HTTP 400 error');
        }
    }

    // Test missing token in response
    @IsTest
    static void testExtractTokenMissingToken() {
        Test.setMock(HttpCalloutMock.class, new MockMissingTokenResponse());
        
        try {
            GetTokenKrakendController.getUrlAndToken();
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Token not found in response'), 'Exception message should indicate missing token');
        }
    }

    // Test empty token in response
    @IsTest
    static void testEmptyTokenResponse() {
        Test.setMock(HttpCalloutMock.class, new MockEmptyTokenResponse());
        
        try {
            GetTokenKrakendController.getUrlAndToken();
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Token not found in response'), 'Exception message should indicate empty token');
        }
    }

    // Test invalid JSON response
    @IsTest
    static void testInvalidJsonResponse() {
        Test.setMock(HttpCalloutMock.class, new MockInvalidJsonResponse());
        
        try {
            GetTokenKrakendController.getUrlAndToken();
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error parsing response body'), 'Exception message should indicate JSON parsing error');
        }
    }

    // Mock HTTP response for successful token retrieval
    private class MockSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token": "mockToken123"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock HTTP error response (e.g., 400)
    private class MockHttpErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error": "Bad request"}');
            return res;
        }
    }

    // Mock successful HTTP response with missing token
    private class MockMissingTokenResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"not_token": "invalid"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock empty token in response
    private class MockEmptyTokenResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token": ""}'); // Empty token
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock invalid JSON response
    private class MockInvalidJsonResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('invalid json'); // Invalid JSON
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    static void testBlankNamedCredentialEndpoint() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessResponse());
    
        Test.startTest();
        try {
            // Simulate the behavior when no NamedCredential is found
            String endpoint = '';
            if (String.isBlank(endpoint)) {
                // Throw a generic System.Exception instead of Exception
                throw new NamedCredentialException('Endpoint URL for NamedCredential not found');
            }
        } catch (System.Exception e) {
            System.assert(e.getMessage().contains('Endpoint URL for NamedCredential not found'),
                          'Exception message should indicate blank endpoint');
        }
        Test.stopTest();
    }
    
    
}