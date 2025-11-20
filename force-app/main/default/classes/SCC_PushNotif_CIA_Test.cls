/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 22-11-2024
 * @last modified by  : Christian Vieri
**/
@IsTest
public class SCC_PushNotif_CIA_Test {

    @IsTest
    static void testCallBRIMOAPIQueueable() {
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new SCC_PushNotif_CIA_Test.MockHttpResponseGenerator());
        
        // Create test data
        List<SCC_PushNotif_CIA.BRIMOStatusRequest> testRequests = new List<SCC_PushNotif_CIA.BRIMOStatusRequest>();
        
        SCC_PushNotif_CIA.BRIMOStatusRequest request = new SCC_PushNotif_CIA.BRIMOStatusRequest();
        request.accountNumber = '1234567890';
        request.troubleTicketId = 'TT123456';
        request.ticketStatus = 'Resolved';
        request.requestRefNum = '123456789012';
        
        testRequests.add(request);

        // Call the method to test
        Test.startTest();
        SCC_PushNotif_CIA.callBRIMOAPIQueueable(testRequests);
        Test.stopTest();
    }

    // Mock HTTP callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "status": "success" }');
            res.setStatusCode(200);
            return res;
        }
    }
}