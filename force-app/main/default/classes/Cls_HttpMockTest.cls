global class Cls_HttpMockTest implements HttpCalloutMock{
	global HTTPResponse respond (HTTPRequest req) {
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","data":{"ticket_no":"12345"}}');
		res.setStatusCode(200);
		return res;
	}
}