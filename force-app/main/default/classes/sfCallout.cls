public class sfCallout {

    public class ParamIn {
        @InvocableVariable
        public String jsonBody;
     
        @InvocableVariable
        public String AgreementId;
    }
    
    @InvocableMethod (label = 'Send SfPayload to Callout' description = 'Send the payload')
    public static List<String> sendGoLiveData(List<ParamIn> PrmIn){
        List<String> retval = new List<String>();
        HTTPResponse res = fn_sendGoLiveData(prmIn[0].jsonBody,prmIn[0].AgreementId);
        
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        	retval.add(res.getBody());
        } else {
            throw new CalloutException('Error getting token: HTTP ' + res.getStatusCode() + ' - ' + res.getBody());
        }
        
        return retval;
    }
    
	public static HTTPResponse fn_sendGoLiveData (String jsBody, String AgrId){
        //PATCH : https://microservices.sit.bravo.bfi.co.id/krakend-gateway/sf/pbf/agreement/6b2ba251-c8c9-4547-881a-b7db5a534f5e
        String namedCredentialGateway = 'MasterDataNmCred'; //'DummyDataNmCred'; //--> https://microservices.sit.bravo.bfi.co.id
        String endpointService = '/krakend-gateway/sf/pbf/agreement/' + AgrId;
        String endpoint = 'callout:' + namedCredentialGateway + endpointService;
      	String cleanedBody = jsBody.replaceAll('[\\r\\n]+', ' ').replaceAll('[\\t]+', '  '); 
        
        try{
            // Create and configure HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('PATCH');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(60000); // Adjusted timeout
            req.setBody(cleanedBody);
            
            // Send HTTP request
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            // Log the HTTP response status and body
            System.debug('HTTP Response Status Code: ' + res.getStatusCode());
            System.debug('HTTP Response Body: ' + res.getBody());
            
            return res;
        } catch (Exception e) {
        	System.debug('Callout Exception: ' + e.getMessage());
            throw new CalloutException('Failed to call API Callout: ' + e.getMessage());
        }
    }
}