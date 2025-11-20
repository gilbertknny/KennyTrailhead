public with sharing class SCC_OpenIDAuthCtrl {
    // catch the callback from the OpenID provider
    public PageReference callback() {
        // get the OpenID provider's response
        String response = ApexPages.currentPage().getParameters().get('response');
        // get the OpenID provider's endpoint
        String endpoint = ApexPages.currentPage().getParameters().get('endpoint');
        // get the OpenID provider's error
        String error = ApexPages.currentPage().getParameters().get('error');
        // get the OpenID provider's error description
        String error_description = ApexPages.currentPage().getParameters().get('error_description');
        // get the OpenID provider's error uri
        String error_uri = ApexPages.currentPage().getParameters().get('error_uri');
        // get the OpenID provider's state
        String state = ApexPages.currentPage().getParameters().get('state');
        // get the OpenID provider's code
        String code = ApexPages.currentPage().getParameters().get('code');
        // get the OpenID provider's iss
        String iss = ApexPages.currentPage().getParameters().get('iss');
        // get the OpenID provider's id_token
        String id_token = ApexPages.currentPage().getParameters().get('id_token');
        // get the OpenID provider's access_token
        String access_token = ApexPages.currentPage().getParameters().get('access_token');
        // get the OpenID provider's token_type
        String token_type = ApexPages.currentPage().getParameters().get('token_type');
        // get the OpenID provider's expires_in
        String expires_in = ApexPages.currentPage().getParameters().get('expires_in');
        // get the OpenID provider's scope
        String scope = ApexPages.currentPage().getParameters().get('scope');
        // get the OpenID provider's refresh_token
        String refresh_token = ApexPages.currentPage().getParameters().get('refresh_token');
        // get the OpenID provider's prompt
        String prompt = ApexPages.currentPage().getParameters().get('prompt');
        // get the OpenID provider's session_state
        String session_state = ApexPages.currentPage().getParameters().get('session_state');
        // get the OpenID provider's nonce
        String nonce = ApexPages.currentPage().getParameters().get('nonce');
        // get the OpenID provider's response_mode
        String response_mode = ApexPages.currentPage().getParameters().get('response_mode');
        // get the OpenID provider's client_id
        String client_id = ApexPages.currentPage().getParameters().get('client_id');
        // get the OpenID provider's redirect_uri

        // log the OpenID provider's state
        System.debug('state: ' + state);
        // log the OpenID provider's code
        System.debug('code: ' + code);
        // log the OpenID provider's iss
        System.debug('iss: ' + iss);
        // log the OpenID provider's client_id
        System.debug('client_id: ' + client_id);

        // make a callout to get access_token
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            String authEndpoint = 'callout:BRI_IAM_ForgeRock/access_token?grant_type=authorization_code&code='+code+'&redirect_uri=https://bankbri--sitest.sandbox.my.salesforce.com/services/authcallback/SSO_SIT_Test&client_id=IVUrPHZvV1xNO0dpS29gcmo6YkdwWghJ&client_secret=P@ssw0rd';
            System.debug('authEndpoint: ' + authEndpoint);
            req.setEndpoint(authEndpoint);
            req.setMethod('POST');
            req.setTimeout(15000);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            res = http.send(req);
            System.debug('Connected successfully!');
            System.debug('Response: ' + res.getBody());
        }
        catch(exception exc){
            System.debug('Connection failed!');
            system.debug(exc.getmessage());
            System.debug('Response Body: ' + res.getBody());
        }

        return null;
    }
}