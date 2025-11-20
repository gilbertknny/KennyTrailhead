@isTest
private class SCC_CustPersonalWrapperTest {

    @isTest
    static void testParse() {
        // Test JSON string representing customer personal data
        String json = '{"CUSTPERSONAL": [{"progressPengajuan": "Pending", "nomorKartuKredit": "1234567890123456", "channelPengajuan": "Online", "tanggalPengajuan": "2024-05-28", "nomorAplikasiPengajuan": "APP123456", "tanggalLahir": "1990-01-01", "nik": "1234567890", "namaNasabahLengkap": "John Doe"}]}';

        // Parse the JSON string
        SCC_CustPersonalWrapper wrapper = SCC_CustPersonalWrapper.parse(json);

        // Verify that the wrapper object is not null
        System.assertNotEquals(null, wrapper);

        // Verify that the CUSTPERSONAL list is not null and contains one item
        System.assertNotEquals(null, wrapper.CUSTPERSONAL);
        System.assertEquals(1, wrapper.CUSTPERSONAL.size());

        // Verify the values of the parsed CUSTPERSONAL object
        SCC_CustPersonalWrapper.CUSTPERSONAL custPersonal = wrapper.CUSTPERSONAL[0];
        System.assertEquals('Pending', custPersonal.progressPengajuan);
        System.assertEquals('1234567890123456', custPersonal.nomorKartuKredit);
        System.assertEquals('Online', custPersonal.channelPengajuan);
        System.assertEquals('2024-05-28', custPersonal.tanggalPengajuan);
        System.assertEquals('APP123456', custPersonal.nomorAplikasiPengajuan);
        System.assertEquals('1990-01-01', custPersonal.tanggalLahir);
        System.assertEquals('1234567890', custPersonal.nik);
        System.assertEquals('John Doe', custPersonal.namaNasabahLengkap);
    }
}