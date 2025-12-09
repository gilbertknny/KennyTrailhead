/**
 * @description       : Test class for ReCaptchaController to verify reCAPTCHA token validation logic.
 * @author            : Ishardan
 * @createdDate       : 17/10/2025
 * @lastModifiedBy    : Ishardan
 * @lastModifiedDate  : 17/10/2025
 * @testCoverage      : Covers positive and negative scenarios for isReCaptchaValid method.
 */
@IsTest
private class ReCaptchaControllerTest {

    /**
     * @description  Mock class that simulates HTTP responses from the Google reCAPTCHA API.
     *               Used to test callout logic without performing real HTTP requests.
     */
    private class ReCaptchaHttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        /**
         * @description  Constructor for initializing mock HTTP response data.
         * @param statusCode  The HTTP status code to simulate (e.g., 200, 500).
         * @param responseBody  The mock response body to return from the callout.
         */
        public ReCaptchaHttpMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        /**
         * @description  Responds to an HTTP request with a simulated HTTP response object.
         * @param req  The HTTP request object from the controller.
         * @return     A mock HttpResponse containing predefined status and body.
         */
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setStatus('OK');
            res.setBody(responseBody);
            return res;
        }
    }

    /**
     * @description  Test method for validating successful reCAPTCHA token verification.
     *               Ensures that the method returns a success response when the API mock returns 200.
     */
    @IsTest
    static void testValidReCaptchaToken() {
        String mockBody = '{"success": true, "score": 0.9, "action": "submit"}';
        Test.setMock(HttpCalloutMock.class, new ReCaptchaHttpMock(200, mockBody));

        // Create a mock user to run the test under user context
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser_' + System.currentTimeMillis() + '@example.com'
        );

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = ReCaptchaController.isReCaptchaValid('mockToken123');
            Test.stopTest();

            System.assertEquals(
                true,
                result.get('success'),
                'Expected reCAPTCHA validation to return success = true'
            );
        }
    }
}