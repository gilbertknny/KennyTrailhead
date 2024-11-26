@IsTest
public class SCC_MachineDataByAddressTest {
    
    @IsTest
    static void testGetAddressSuggestions() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new SCC_MachineDataByAddressMock());
        
        // Call the method
        String testAddress = '123 Test St';
        List<SCC_MachineDataWrapper> result = SCC_MachineDataByAddress.getAddressSuggestions(testAddress);
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Result should have 2 items');
        
        // Validate the content of the result
        System.assertEquals('TID123', result[0].tid, 'First item TID should be TID123');
        System.assertEquals('123 Test St', result[0].alamatMesin, 'First item address should be 123 Test St');
        System.assertEquals('Contact001', result[0].kontakId, 'First item contact ID should be Contact001');
        
        System.assertEquals('TID456', result[1].tid, 'Second item TID should be TID456');
        System.assertEquals('456 Test Ave', result[1].alamatMesin, 'Second item address should be 456 Test Ave');
        System.assertEquals('Contact002', result[1].kontakId, 'Second item contact ID should be Contact002');
    }
    
    // Mock HTTP response class
    private class SCC_MachineDataByAddressMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"machineDataByAddress":[{"tid":"TID123","alamatMesin":"123 Test St","kontakId":"Contact001"},{"tid":"TID456","alamatMesin":"456 Test Ave","kontakId":"Contact002"}]}');
            return res;
        }
    }
}