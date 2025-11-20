public class SCC_TestCallout {
    public void testCallout() {
        // test callout to an endpoint
        String endpoint = 'callout:ClosedDev/gateway/apiCams/3.0/card/112233';
        String method = 'GET';
        String body = '';
        // make HTTP send using named credential
        String username = 'CHM';
        String password = '1e5e0ce2-6a03-462d-ac92-d5a5da58ea69';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);

        HttpRequest req = new HttpRequest();
        // set endpoint using named credential
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('X-CHANNEL-ID', 'CHMS');
        // req.setHeader('Authorization', authorizationHeader);
        req.setTimeout(120000);
        // req.setHeader('Accept', 'application/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Response: ' + res.getBody());
    }
}