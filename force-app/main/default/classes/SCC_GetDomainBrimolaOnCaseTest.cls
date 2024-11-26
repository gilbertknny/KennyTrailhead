/**
 * Test Class: SCC_GetDomainBrimolaOnCaseTest
 * @description  This test class is designed to test the SCC_GetDomainBrimolaOnCase class 
 *              by simulating an HTTP callout using a mock response.
 * Author: Abhinav Sharma
 * Created Date: 2024-05-30
 */

@isTest
public without sharing class SCC_GetDomainBrimolaOnCaseTest {
    
    /**
     * @description Mock class for simulating HTTP callouts.
     */
    private class MyHttpCalloutMock implements HttpCalloutMock {
        /**
         * @description JSON response to mock the API response
         * @param req HTTPRequest
         * @return res HttpResponse
         */
        public HTTPResponse respond(HTTPRequest req) {
            String jsonString = '{'+
                                '  \"chmGraphql\": {'+
                                '    \"inquiryBrimolaPangkalan\": {'+
                                '      \"data\": {'+
                                '        \"BrilinkTrxByIdKeagenan\": {'+
                                '          \"data\": ['+
                                '            {'+
                                '              \"totalHarga\": \"1.980.000\",'+
                                '              \"tanggalOrder\": \"09 May 2024 11:41:00\",'+
                                '              \"statusBayar\": \"Sudah Dibayar\",'+
                                '              \"pangkalanName\": \"Pangkalan Child dari Admin Kanwil\",'+
                                '              \"orderId\": \"00005/000002/Dec/23\",'+
                                '              \"noBriva\": null,'+
                                '              \"jumlahTabung\": \"110\",'+
                                '              \"jenisPembayaran\": \"BRIVA\",'+
                                '              \"hargaTabung\": \"18.000\",'+
                                '              \"biayaAdmin\": \"0\",'+
                                '              \"agenName\": \"Child - PT AGEN ABADI DEV\"'+
                                '            }'+
                                '          ]'+
                                '        },'+
                                '        \"pangkalanId\": \"923749273982743\",'+
                                '        \"pangkalanName\": \"Pangkalan Child dari Admin Kanwil\",'+
                                '        \"corpClientBriva\": \"000002\",'+
                                '        \"corpBriva\": \"11244\",'+
                                '        \"agenNorek\": \"001901000029300\",'+
                                '        \"agenName\": \"Child - PT AGEN ABADI DEV\",'+
                                '        \"agenId\": \"000002\",'+
                                '        \"agenAlamat\": \"Jalan Bendungan Walahar\"'+
                                '      },'+
                                '      \"desc\": \"Success\",'+
                                '      \"rc\": \"00\"'+
                                '    }'+
                                '  }'+
                                '}';
            
            // Create and configure the HttpResponse object
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(jsonString);
            res.setStatusCode(200);
            res.setStatus('SUCCESS');
            return res;
        }
    }
    
    /**
     * @description Tests the getDomainBrimola method with a successful mock HTTP response.
     */
    @isTest
    static void testGetDomainBrimola_Success() {
        // Set the HTTP callout mock
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock());
        
        // Call the method to be tested
        SCC_ParentDomainBrimolaWrapper result = SCC_GetDomainBrimolaOnCase.getDomainBrimola('923749273982743','2024-01-01','2024-12-30');
        
        // Verify the results
        System.assertEquals('Child - PT AGEN ABADI DEV', result.agenName, 'Matched');
        System.assertEquals('Pangkalan Child dari Admin Kanwil', result.pangkalanName, 'Matched');
        // Add more assertions as necessary
    }
}