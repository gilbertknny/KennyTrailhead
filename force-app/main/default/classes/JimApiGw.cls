@RestResource(urlMapping='/apigw/*')
global class JimApiGw {
    global static JimFlow myFlow = new JimFlow();

    @HttpPost 
    global static void doPost() {
        String requestURI = RestContext.request.requestURI;
        System.debug('requestURI = ' + requestURI);
        String flowName = requestURI.substring(requestURI.lastIndexOf('/')+1);
        if(flowName == null || flowName == '' || flowName == 'apigw') {
            flowName = 'Lead_Expose_Agent';
        }
        System.debug('flowName = ' + flowName);

        RestResponse res = RestContext.response;
        try {
            Map<String, Object> req = 
                (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.ToString());
            System.debug('req = ' + req);
            
            //Flow.Interview.Lead_Expose_Agent myFlow = new Flow.Interview.Lead_Expose_Agent(req);     
            myFlow.createInterview(flowName, req);
            myFlow.start();
            
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(String.valueOf(myFlow.getVariableValue('response_message')));
            res.statusCode = Integer.valueOf(myFlow.getVariableValue('response_status'));
        } catch (Exception e) {
            System.debug('e = ' + e);
            res.statusCode = 400;
            res.addHeader('Content-Type', 'application/json');
            String strJsonErr = '{"errors": [{ "statusCode": "'+res.statusCode+'", "message": "Invalid JSON format. Check the syntax of body payload. '+e.getMessage()+'" }],"isSuccess": false,"outputValues": null,"version": 1}';
            res.responseBody = Blob.valueOf(strJsonErr);
        }
    }
}