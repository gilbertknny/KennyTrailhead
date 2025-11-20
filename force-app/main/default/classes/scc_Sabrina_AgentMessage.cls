/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 26-02-2025
 * @last modified by  : Christian Vieri
**/

public class scc_Sabrina_AgentMessage {
    
    public static HttpResponse callSSEApi(String endpoint, String token) {
        try {
            // Create the HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('X-Org-Id', '00DMR0000001s6P');
            req.setTimeout(120000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            return res;
        } catch (Exception e) {
            System.debug('Error calling SSE API: ' + e.getMessage());
            throw e;
        }
    }
    
    public static Boolean isSSEApiAccessible(String endpoint, String token) {
        try {
            HttpResponse res = callSSEApi(endpoint, token);
            return res.getStatusCode() == 200;
        } catch (Exception e) {
            System.debug('Error checking SSE API accessibility: ' + e.getMessage());
            return false;
        }
    }

    public static void testSSEApiConnection(String endpoint, String token) {
        System.debug('Testing SSE API connection to: ' + endpoint);
        
        try {
            HttpResponse res = callSSEApi(endpoint, token);
            
            System.debug('Response Status Code: ' + res.getStatusCode());
            
            String responseBody = res.getBody();
            system.debug('response body:' + responseBody);
            if (res.getStatusCode() == 200) {
                System.debug('SSE API CONNECTION SUCCESSFUL');
            } else {
                System.debug('SSE API CONNECTION FAILED WITH STATUS CODE: ' + res.getStatusCode());
            }
            
        } catch (Exception e) {
            System.debug('SSE API CONNECTION ERROR: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }
}