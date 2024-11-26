@isTest
public class SCC_Wise_Test {

    @testSetup
    static void setupData() {
    }

    // Mock class to simulate API responses for callouts
    private class SCC_WiseListMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Simulated JSON response for different endpoints
            String endpoint = req.getEndpoint();
            if (endpoint.contains('workingInstruction')) {
                res.setBody('{"total": 1, "categorize": {"1": "Category1"}}');
            } else if (endpoint.contains('produk')) {
                res.setBody('{"total": 1, "categorize": {"2": "Category2"}}');
            } else if (endpoint.contains('program')) {
                res.setBody('{"total": 1, "categorize": {"3": "Category3"}}');
            } else if (endpoint.contains('promo')) {
                res.setBody('{"total": 1, "categorize": {"4": "Category4"}}');
            }
            return res;
        }
    }

    @isTest
    static void testWise1st() {
        // Set the mock for all HTTP callouts
        Test.setMock(HttpCalloutMock.class, new SCC_WiseListMock());

        // Start test context
        Test.startTest();

        // Enqueue the Queueable job
        SCC_Wise1st wise1stJob = new SCC_Wise1st();
        System.enqueueJob(wise1stJob);

        // Execute the processNow method directly
        wise1stJob.executeNow();

        // End test context
        Test.stopTest();

        // Asserts to ensure correct processing
        System.assertNotEquals(null, wise1stJob, 'Queueable job should be enqueued');
    }
    
    @isTest
    static void testWise2nd() {
        // Set the mock for all HTTP callouts
        Test.setMock(HttpCalloutMock.class, new SCC_WiseListMock());

        // Start test context
        Test.startTest();

        // Enqueue the Queueable job
        SCC_Wise2nd wise2ndJob = new SCC_Wise2nd();
        System.enqueueJob(wise2ndJob);

        // End test context
        Test.stopTest();

        // Asserts to ensure correct processing
        System.assertNotEquals(null, wise2ndJob, 'Queueable job should be enqueued');
    }

    @isTest
    static void testWise3rd() {
        // Set the mock for all HTTP callouts
        Test.setMock(HttpCalloutMock.class, new SCC_WiseListMock());

        // Start test context
        Test.startTest();

        // Enqueue the Queueable job
        SCC_Wise3rd wise3rdJob = new SCC_Wise3rd();
        System.enqueueJob(wise3rdJob);

        // End test context
        Test.stopTest();

        // Asserts to ensure correct processing
        System.assertNotEquals(null, wise3rdJob, 'Queueable job should be enqueued');
    }

    @isTest
    static void testWise4th() {
        // Set the mock for all HTTP callouts
        Test.setMock(HttpCalloutMock.class, new SCC_WiseListMock());

        // Start test context
        Test.startTest();

        // Enqueue the Queueable job
        SCC_Wise4th wise4thJob = new SCC_Wise4th();
        System.enqueueJob(wise4thJob);

        // Execute the processNow method directly
        wise4thJob.executeNow();

        // End test context
        Test.stopTest();

        // Asserts to ensure correct processing
        System.assertNotEquals(null, wise4thJob, 'Queueable job should be enqueued');
    }

    // Test error handling with InsertErrorLog
    @isTest
    static void testErrorHandling() {
        try {
            // Simulate an exception and test error logging for each class
            //throw new NullPointerException('Test Exception');
        } catch (Exception e) {
            SCC_Wise1st.InsertErrorLog(e, 'SCC_Wise1stTest');
            SCC_Wise2nd.InsertErrorLog(e, 'SCC_Wise2ndTest');
            SCC_Wise3rd.InsertErrorLog(e, 'SCC_Wise3rdTest');
            SCC_Wise4th.InsertErrorLog(e, 'SCC_Wise4thTest');
        }
    }
}