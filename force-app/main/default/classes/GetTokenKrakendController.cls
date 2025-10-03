public with sharing class GetTokenKrakendController {
    // Class to represent the response containing token and URL
    public class TokenResponse {
        @AuraEnabled
        public String token;
        @AuraEnabled
        public String url;

        public TokenResponse(String token, String url) {
            this.token = token;
            this.url = url;
        }
    }

	/*
    @AuraEnabled
    public static TokenResponse getUrlAndToken() {
        TokenResponse  retval = new TokenResponse('testToken', 'testUrl');
        return retval;
    }
	*/

    @AuraEnabled
    public static TokenResponse getUrlAndToken() {
        String namedCredentialGateway = 'MasterDataNmCred_Legacy';
        String endpointGenerateToken = '/path-token/obtain';
        String endpointUploadDocument = '/sf/document/v1/document-frontend';        
        String endpoint = 'callout:PBFGatewaySITNamedCredential' + endpointGenerateToken;
      
        try {
            // Create and configure HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');

            //Set Key hardcode
            //req.setHeader('X-Apikey', 'SALESFORCE_INGRESS_123'); 

            req.setBody('{"path": "' + endpointUploadDocument + '"}');
            req.setTimeout(60000); // Adjusted timeout


            // Send HTTP request
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Log the HTTP response status and body
            System.debug('HTTP Response Status Code: ' + res.getStatusCode());
            System.debug('HTTP Response Body: ' + res.getBody());

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                String token = 'Bearer ' + extractTokenFromResponse(res.getBody());
                String url = getNamedCredentialAuthenticationUrl(namedCredentialGateway) + endpointUploadDocument;
                //String url = baseUrl + endpointUploadDocument;

                return new TokenResponse(token, url);
            } else {
                throw new CalloutException('Error getting token: HTTP ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Callout Exception: ' + e.getMessage());
            throw new CalloutException('Failed to get token and URL: ' + e.getMessage());
        }
    }

    private static String extractTokenFromResponse(String responseBody) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            String token = (String) responseMap.get('token');
            if (String.isNotBlank(token)) {
                return token;
            }
            throw new CalloutException('Error: Token not found in response');
        } catch (Exception e) {
            throw new CalloutException('Error parsing response body: ' + e.getMessage());
        }
    }

    private static String getNamedCredentialAuthenticationUrl(String namedCredentialDeveloperName) {
    try {
        if (String.isBlank(namedCredentialDeveloperName)) {
            throw new IllegalArgumentException('Named Credential Developer Name cannot be blank');
        }

        // Query NamedCredential based on DeveloperName
        NamedCredential namedCredential = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = :namedCredentialDeveloperName LIMIT 1];

        // Declare a variable to store the URL
        String url = '';

        if (namedCredential != null) {
            // Fetch the Endpoint URL from NamedCredential
            url = namedCredential.Endpoint;
        } else {
            System.debug('Named Credential not found');
        }

        // Return the URL or throw an error if not found
        if (String.isBlank(url)) {
            throw new CalloutException('Endpoint URL for NamedCredential not found.');
        }

        return url;

    } catch (Exception e) {
        System.debug('Error fetching NamedCredential authentication URL: ' + e.getMessage());
        throw new CalloutException('Failed to fetch NamedCredential authentication URL: ' + e.getMessage());
    }
}
}