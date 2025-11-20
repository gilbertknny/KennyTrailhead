/**
 * @description Test class for the SCC_GetCardDetails class.
 */
@IsTest
public class SCC_GetCardDetails_Test {

    /**
     * @description Test method for getCardData method.
     */
    @IsTest
    static void testGetCardData1() {
        // Set up the mock response
        String jsonResponse = '{"chmGraphql":{"inquiryCardData":{"responseCode":"00","responseDesc":"SUKSES","status":"200","data":{"accNo":"020601225297535","cardNo":"6013011600257488","type":"MS","name":"ISMAIL MARZUKI","activeDate":"2024-07-03","expDate":"2806","issueDate":"2023-06-07","cardStatus":"BL","lastMaint":"2024-07-08","userMaint":"0206046","statusDesc":"Kartu Blokir","blockDate":"2024-07-08","userBlock":"0206046","historyAccount":{"responseData":{"data ":[{"accNo":"020601225297535","activeDate":"2024-06-21","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600257470","cardStatus":"BL","expDate":"2805","issueDate":"2023-06-07","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":"2024-03-21","typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-07-03","blockDate":"2024-07-08","branchCode":"0206","cardNo":"6013011600257488","cardStatus":"BL","expDate":"2806","issueDate":"2023-06-07","lastMaint":"2024-07-08","mbNo":"","mbStatus":"","renewalDate":"2024-05-03","typeCode":"00","userBlock":"0206046"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263387","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263502","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263544","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-07-03","branchCode":"0206","cardNo":"6013011600263569","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-07-03","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263734","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":null,"blockDate":"2024-06-21","branchCode":"0206","cardNo":"6013011600306509","cardStatus":"BL","expDate":"2906","issueDate":"2024-06-11","lastMaint":"2024-06-21","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"}]}}}}}}}}';

        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody(jsonResponse);
        mockResponse.setStatusCode(200);

        HttpCalloutMock mock = new HttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        SCC_CardData result = SCC_GetCardDetails.getCardData('6013011600257488');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals('6013-0116-0025-7488', result.cardNo, 'Card number should be formatted correctly.');
        System.assertEquals('MS', result.type, 'Card type should be MS.');
        System.assertEquals('ISMAIL MARZUKI', result.name, 'Name should be ISMAIL MARZUKI');
        System.assertEquals('BL', result.cardStatus, 'Card status should be BL.');
        System.assertEquals('Kartu Blokir', result.statusDesc, 'Status description should be Kartu Blokir');
        System.assertEquals('2024-07-08', result.lastMaint, 'Last maintenance date should be 2024-07-08');
        System.assertEquals('0206046', result.userMaint, 'User maintenance should be Admin.');
        System.assertEquals('06/28', result.expDateCard, 'Expiration date should be formatted as 06/28.');
        System.assertEquals('2024-07-03', result.activeDateCard, 'Active date should be 2024-07-03');
    }
    

    /**
     * @description Test method for getHistoryData method.
     */
    @IsTest
    static void testGetCardData() {
        // Set up the mock response
        String jsonResponse = '{"chmGraphql":{"inquiryCardData":{"responseCode":"00","responseDesc":"SUKSES","status":"200","data":{"accNo":"020601225297535","cardNo":"6013011600257488","type":"MS","name":"ISMAIL MARZUKI","activeDate":"2024-07-03","expDate":"2806","issueDate":"2023-06-07","cardStatus":"BL","lastMaint":"2024-07-08","userMaint":"0206046","statusDesc":"Kartu Blokir","blockDate":"2024-07-08","userBlock":"0206046","historyAccount":{"responseData":{"data ":[{"accNo":"020601225297535","activeDate":"2024-06-21","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600257470","cardStatus":"BL","expDate":"2805","issueDate":"2023-06-07","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":"2024-03-21","typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-07-03","blockDate":"2024-07-08","branchCode":"0206","cardNo":"6013011600257488","cardStatus":"BL","expDate":"2806","issueDate":"2023-06-07","lastMaint":"2024-07-08","mbNo":"","mbStatus":"","renewalDate":"2024-05-03","typeCode":"00","userBlock":"0206046"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263387","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263502","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263544","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-07-03","branchCode":"0206","cardNo":"6013011600263569","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-07-03","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":"2024-06-27","blockDate":"2024-06-27","branchCode":"0206","cardNo":"6013011600263734","cardStatus":"BL","expDate":"2812","issueDate":"2023-12-04","lastMaint":"2024-06-27","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"},{"accNo":"020601225297535","activeDate":null,"blockDate":"2024-06-21","branchCode":"0206","cardNo":"6013011600306509","cardStatus":"BL","expDate":"2906","issueDate":"2024-06-11","lastMaint":"2024-06-21","mbNo":"","mbStatus":"","renewalDate":null,"typeCode":"00","userBlock":"0206526"}]}}}}}}}}';

        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody(jsonResponse);
        mockResponse.setStatusCode(200);

        HttpCalloutMock mock = new HttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        List<SCC_CardData> result = SCC_GetCardDetails.getHistoryData('6013011600257488');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals('6013-0116-0025-7470', result[0].cardNoHis, 'Card number should be formatted correctly.');
        System.assertEquals('BL', result[0].cardStatusHis, 'Card status should be BL.');
        System.assertEquals('2024-06-27', result[0].lastMaintHis, 'Last maintenance date should be 2024-07-08');
        System.assertEquals('05/28', result[0].expDate, 'Expiration date should be formatted as 05/28.');
        System.assertEquals('2024-06-21', result[0].activeDate, 'Active date should be 2024-07-03');
    }

    /**
     * @description Helper class for mocking HTTP callouts.
     */
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private HttpResponse response;

        /**
         * @description HttpCalloutMockImpl method for mocking HTTP response.
         * @param response HttpCalloutMockImpl response to be returned.
         */
        public HttpCalloutMockImpl(HttpResponse response) {
            this.response = response;
        }

        /**
         * @description HttpResponse method for mocking response.
         * @param req
         * @return HttpResponse response.
         *
         */
        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}