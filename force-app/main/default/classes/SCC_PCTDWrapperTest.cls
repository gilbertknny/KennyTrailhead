@isTest
public class SCC_PCTDWrapperTest {

    @isTest
    static void testParseMethod() {
        // Create sample JSON string representing pending credit transactions
        String jsonString = '{' +
            '"CPAHF": [' +
                '{' +
                    '"jenisTransaksi": "Purchase",' +
                    '"waktuSisaPenagihanMerchant": "3 days",' +
                    '"nominalTransaksiMenggantung": "100.00",' +
                    '"tanggalTransaksiMenggantung": "2024-05-28",' +
                    '"deskripsiTransaksi": "Pending transaction description",' +
                    '"tanggalPostingTagihan": "2024-05-29",' +
                    '"akumulasiJumlahTransaksi": "500.00",' +
                    '"refferenceNumber": "REF123456",' +
                    '"kodeTransaksi": "PUR-123",' +
                    '"tanggalPostingTransaksi": "2024-05-28",' +
                    '"approvalCode": "APPROVE123",' +
                    '"keteranganTransaksi": "Transaction remarks",' +
                    '"nominalTransaksi": "100.00",' +
                    '"waktuTransaksi": "10:00:00",' +
                    '"tanggalTransaksi": "2024-05-28"' +
                '}' +
            ']' +
        '}';

        // Parse the JSON string
        SCC_PCTDWrapper wrapper = SCC_PCTDWrapper.parse(jsonString);

        // Ensure the wrapper object is not null
        System.assertNotEquals(null, wrapper);

        // Ensure CPAHF list is not null and has at least one element
        System.assertNotEquals(null, wrapper.CPAHF);
        System.assertNotEquals(0, wrapper.CPAHF.size());

        // Ensure the properties of the first CPAHF object are set correctly
        SCC_PCTDWrapper.CPAHF cpahf = wrapper.CPAHF[0];
        System.assertEquals('Purchase', cpahf.jenisTransaksi);
        System.assertEquals('3 days', cpahf.waktuSisaPenagihanMerchant);
        System.assertEquals('100.00', cpahf.nominalTransaksiMenggantung);
        System.assertEquals('2024-05-28', cpahf.tanggalTransaksiMenggantung);
        System.assertEquals('Pending transaction description', cpahf.deskripsiTransaksi);
        System.assertEquals('2024-05-29', cpahf.tanggalPostingTagihan);
        System.assertEquals('500.00', cpahf.akumulasiJumlahTransaksi);
        System.assertEquals('REF123456', cpahf.refferenceNumber);
        System.assertEquals('PUR-123', cpahf.kodeTransaksi);
        System.assertEquals('2024-05-28', cpahf.tanggalPostingTransaksi);
        System.assertEquals('APPROVE123', cpahf.approvalCode);
        System.assertEquals('Transaction remarks', cpahf.keteranganTransaksi);
        System.assertEquals('100.00', cpahf.nominalTransaksi);
        System.assertEquals('10:00:00', cpahf.waktuTransaksi);
        System.assertEquals('2024-05-28', cpahf.tanggalTransaksi);
    }
}