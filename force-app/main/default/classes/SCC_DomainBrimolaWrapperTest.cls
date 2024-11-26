/**
 * Test Class: SCC_DomainBrimolaWrapperTest
 * @description  This test class verifies the functionality of the SCC_DomainBrimolaWrapper class,
 *              specifically the parsing of JSON data into an instance of the class.
 * Author: Abhinav Sharma
 * Created Date: 2024-05-30
 */

@isTest
public without sharing class SCC_DomainBrimolaWrapperTest { 
    
    /**
     * @description Tests the parsing of a JSON string into an SCC_DomainBrimolaWrapper instance.
     */
    @isTest
     static void testParse() {
        // Sample JSON string representing the API response
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

        // Deserialize JSON string into SCC_DomainBrimolaWrapper instance
        SCC_DomainBrimolaWrapper wrapper = SCC_DomainBrimolaWrapper.parse(jsonString);

        // Assert that the wrapper is not null, meaning parsing was successful
        System.assertNotEquals(null, wrapper, 'Not Null');

        // Additional assertions to validate specific fields if needed
        System.assertEquals('Pangkalan Child dari Admin Kanwil', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.pangkalanName,'Matched');
        System.assertEquals('000002', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.corpClientBriva,'Matched');
        System.assertEquals('11244', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.corpBriva,'Matched');
        System.assertEquals('001901000029300', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.agenNorek,'Matched');
        System.assertEquals('Child - PT AGEN ABADI DEV', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.agenName,'Matched');
        System.assertEquals('000002', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.agenId,'Matched');
        System.assertEquals('Jalan Bendungan Walahar', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.agenAlamat,'Matched');
        
        // Validate the transactions
        System.assertNotEquals(null, wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data,'Matched');
        System.assertEquals(1, wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data.size(),'Matched');
        System.assertEquals('1.980.000', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].totalHarga,'Matched');
        System.assertEquals('09 May 2024 11:41:00', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].tanggalOrder,'Matched');
        System.assertEquals('Sudah Dibayar', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].statusBayar,'Matched');
        System.assertEquals('Pangkalan Child dari Admin Kanwil', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].pangkalanName,'Matched');
        System.assertEquals('00005/000002/Dec/23', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].orderId,'Matched');
        System.assertEquals(null, wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].noBriva,'Matched');
        System.assertEquals('110', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].jumlahTabung,'Matched');
        System.assertEquals('BRIVA', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].jenisPembayaran,'Matched');
        System.assertEquals('18.000', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].hargaTabung,'Matched');
        System.assertEquals('0', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].biayaAdmin,'Matched');
        System.assertEquals('Child - PT AGEN ABADI DEV', wrapper.chmGraphql.inquiryBrimolaPangkalan.data.BrilinkTrxByIdKeagenan.data[0].agenName,'Matched');
    }
}