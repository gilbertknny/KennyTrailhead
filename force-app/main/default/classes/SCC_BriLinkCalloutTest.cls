/** @description
 * Test class for testing the SCC_BriLinkCallout and SCC_BriLinkWrapper classes.
 */
@isTest
private class SCC_BriLinkCalloutTest {

    /** @description
     * Inner class to mock the HTTP callout response.
     */
    public class MockHttpResponse implements HttpCalloutMock {
       /**
     * @description
     * Method: respond
     * Performs a callout to BRILINK API to retrieve profile data
     * based on either TID (Terminal ID) or MID (Merchant ID).
     * @param req The HTTPRequest object representing the request to the external service.
     * @return HTTPResponse The HTTPResponse object representing the mock response from the API.
     */
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"BRILINK_PROFILE":[{"TID":"123","alamat_agen":"Address 1","jenis_jaringan":"Network 1","jenis_usaha":"Business 1","kode_agen":"ABC123","kode_channel":"Channel 1","kode_merchant":"Merchant 1","kode_uker_pengelola":"Uker 1","limit_transaksi":"1000","mid":"MID123","modifikasi_oleh":"User 1","nama_agen":"Agent 1","nama_ibu_kandung":"Mother 1","nama_lengkap":"Full Name 1","nama_merchant":"Merchant Name 1","nomor_kartu_debit":"Debit Card 1","nomor_kontak_pab":"Contact 1","nomor_ktp":"KTP123","nomor_rekening":"Account Number 1","nomor_rekening_pelimpahan":"Transfer Account 1","nomor_rekening_pinjaman":"Loan Account 1","nomor_siup":"SIUP123","pic_uker":"PIC 1","region_office_pengelola":"Region 1","sharing_fee":"Fee 1","status":"Active","tanggal_dibuat":"2024-05-17","tanggal_lahir":"1990-01-01","tanggal_modifikasi":"2024-05-17","telepon":"Phone 1"}]}');
            return res;
        }
    }
/** @description
     * Test method for parsing JSON response in SCC_BriLinkWrapper class.
     */
    @isTest
    static void testParseMethod() {
        // Test null JSON input
        System.assertEquals(null, SCC_BriLinkWrapper.parse(null), 'Should return null for null input');

        // Test empty JSON input
        System.assertEquals(null, SCC_BriLinkWrapper.parse(''), 'Should return null for empty input');

        // Test valid JSON input
        String validJson = '{"BRILINK_PROFILE":[{"TID":"123","alamat_agen":"Address 1","jenis_jaringan":"Network 1","jenis_usaha":"Business 1","kode_agen":"ABC123","kode_channel":"Channel 1","kode_merchant":"Merchant 1","kode_uker_pengelola":"Uker 1","limit_transaksi":"1000","mid":"MID123","modifikasi_oleh":"User 1","nama_agen":"Agent 1","nama_ibu_kandung":"Mother 1","nama_lengkap":"Full Name 1","nama_merchant":"Merchant Name 1","nomor_kartu_debit":"Debit Card 1","nomor_kontak_pab":"Contact 1","nomor_ktp":"KTP123","nomor_rekening":"Account Number 1","nomor_rekening_pelimpahan":"Transfer Account 1","nomor_rekening_pinjaman":"Loan Account 1","nomor_siup":"SIUP123","pic_uker":"PIC 1","region_office_pengelola":"Region 1","sharing_fee":"Fee 1","status":"Active","tanggal_dibuat":"2024-05-17","tanggal_lahir":"1990-01-01","tanggal_modifikasi":"2024-05-17","telepon":"Phone 1"}]}';
        SCC_BriLinkWrapper wrapper = SCC_BriLinkWrapper.parse(validJson);

        System.assertNotEquals(null, wrapper, 'Should return a non-null object for valid input');
        System.assertNotEquals(null, wrapper.BRILINK_PROFILE, 'Should parse BRILINK_PROFILE list');
        System.assertEquals(1, wrapper.BRILINK_PROFILE.size(), 'Should parse BRILINK_PROFILE list with one element');

        SCC_BriLinkWrapper.BRILINK_PROFILE profile = wrapper.BRILINK_PROFILE[0];
        System.assertEquals('123', profile.TID, 'Should parse TID field');
        System.assertEquals('Address 1', profile.alamat_agen, 'Should parse alamat_agen field');
        // Add similar assertions for other fields
        // Example: System.assertEquals('Expected Value', profile.jenis_jaringan, 'Should parse jenis_jaringan field');
    }
/** @description
     * Test method to make callout with TID value in SCC_BriLinkWrapper class.
     */
    @isTest
    static void testMakeCalloutWithTID() {
        // Set up test data
        String tid = '123';
        String mid = null;

        // Set up mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Call the method to be tested
        SCC_BriLinkWrapper result = SCC_BriLinkCallout.makeCallout(tid, mid);

        // Verify the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('Invalid profile', result.errorMsg, 'Result should not be "Invalid profile"');
        System.assertNotEquals('No data found', result.errorMsg, 'Result should not be "No data found"');
        System.assertNotEquals('Error: 200 - OK', result.errorMsg, 'Result should not be "Error: 200 - OK"');
    }
/** @description
     * Test method to make callout with invalid value in SCC_BriLinkWrapper class.
     */
    @isTest
    static void testMakeCalloutWithInvalidProfile() {
        // Set up test data
        String tid = null;
        String mid = null;

        // Call the method to be tested
        SCC_BriLinkWrapper result = SCC_BriLinkCallout.makeCallout(tid, mid);

        // Verify the result
        System.assertEquals('Invalid profile', result.errorMsg, 'Result should be "Invalid profile"');
    }
    /** @description
     * Test method to make callout with  MID value in SCC_BriLinkWrapper class.
     */
    @isTest
static void testMakeCalloutWithMID() {
    // Set up test data
    String tid = null;
    String mid = 'AAA'; // Provide a valid MID

    // Set up mock HTTP callout response
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

    // Call the method to be tested
    SCC_BriLinkWrapper result = SCC_BriLinkCallout.makeCallout(tid, mid);

    // Verify the result
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertNotEquals('Invalid profile', result.errorMsg, 'Result should not be "Invalid profile"');
    System.assertNotEquals('No data found', result.errorMsg, 'Result should not be "No data found"');
    System.assertNotEquals('Error: 200 - OK', result.errorMsg, 'Result should not be "Error: 200 - OK"');
}

}