@isTest
public class SCC_SavingStatementTest {

    
    @isTest
    static void testGetSavingStatementSuccess() {
        Test.startTest();
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        // Call the method and capture the result
        String accountNumber = '390301037982533';
        String startDate = '2023-01-01';
        String endDate = '2023-01-31';
        List<SCC_SavingStateWrapper> result = SCC_SavingStatement.getSavingStatement(accountNumber, startDate, endDate);

        Test.stopTest();

        // Validate the result
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(1, result.size(), 'The result size should be 1');

        SCC_SavingStateWrapper mutasi = result[0];
        System.assertEquals(accountNumber, String.valueOf(mutasi.noRek), 'Account number should match');
        System.assertEquals('Transfer Ke ASRENI via EDC', mutasi.remarkCustom, 'Remark should match');
    }

    @isTest
    static void testGetSavingStatementError() {
        Test.startTest();
        // Mock the HTTP callout to throw an exception
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());

        // Call the method and verify the exception
        try {
            List<SCC_SavingStateWrapper> result = SCC_SavingStatement.getSavingStatement('94804640381788', '2023-01-01', '2023-01-31');
            System.assertEquals(null, result, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('An error occurred while making the API call: Error occurred during callout', e.getMessage(), 'Exception should be thrown');
        }

        Test.stopTest();
    }

    // Mock for successful HTTP callout
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        /**
         * @description respond
         * @param req
         * @return res
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": [{"remarkCustom": "Transfer Ke ASRENI via EDC","tlbds2": "","tlbds1": "FROM390301037982533 TO390301011429531EDC","serial": "0","auxtrc": "8506","trremk": "EDC  DIKI TO ASRENI","terbilang": "","glsign": "Db","truser": "0852502", "saldoAkhirMutasi": 215000, "mutasiKredit": 0, "mutasiDebet": 200000, "saldoAwalMutasi": 415000,"deskTran": "EDC  DIKI TO ASRENI  FROM390301037982533 TO390301011429531EDC","kodeTran": "2", "jamTran": 101357, "tglEfektif": "2023-10-29T00:00:00Z", "tglTran": "2023-10-29T00:00:00Z", "noRek": "390301037982533","idNum": 2, "seq": 2411508, "idNum2": 0, "idNum3": 0} ], "errors": null,  "responseMessage": "Success",  "responseCode": "00",  "errorCode": "000",  "statusCode": 200}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock for erroneous HTTP callout
    private class HttpCalloutMockImplError implements HttpCalloutMock {
        /**
         * @description respond
         * @param req
         * @return res
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"statusCode":500,"errorCode":"050","responseCode":"05","responseMessage":"error getting data","errors":["mssql: Invalid object name."],"data":null}');
            return res;
        }
    }
}