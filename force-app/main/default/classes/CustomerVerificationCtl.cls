public class CustomerVerificationCtl {



	public static String verificationCallout(){
		// Create a new HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api-close.dev.bri.co.id/gateway/apiCHMDatahub/1.0/inquiryCardlinkByCardNumber');
        request.setMethod('POST');
        // Set any request headers, parameters, and body as needed
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{ "cardNo": "5520023304979802" }');

        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);

        String responseString = '';
        return responseString;
	}
}