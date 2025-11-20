public with sharing class SCC_BriLinkInformation {
    
    public class ResponseWrapper {
        // Define properties corresponding to the response JSON
        public String userId;
        public String id;
        public String title;
        public String body;
        
        public ResponseWrapper(String userId, String id, String title, String body) {
            this.userId = userId;
            this.id = id;
            this.title = title;
            this.body = body;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ResponseWrapper> performCallout(String url, String requestBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        List<ResponseWrapper> responseList = new List<ResponseWrapper>();
        
        if (res.getStatusCode() == 200) {
            // Parse the JSON response
            List<Object> jsonResponse = (List<Object>) JSON.deserializeUntyped(res.getBody());
            
            // Iterate through the JSON response and populate wrapper class objects
            for (Object obj : jsonResponse) {
                Map<String, Object> jsonObj = (Map<String, Object>) obj;
                
                // Perform null checks before accessing JSON properties
                String userId = String.valueOf(jsonObj.get('userId'));
                String id = String.valueOf(jsonObj.get('id'));
                String title = String.valueOf(jsonObj.get('title'));
                String body = String.valueOf(jsonObj.get('body'));
                
                // Create ResponseWrapper object and add to the list
                responseList.add(new ResponseWrapper(userId, id, title, body));
            }
        } else {
            // Handle error response (optional)
        }
        return responseList;
    }
}