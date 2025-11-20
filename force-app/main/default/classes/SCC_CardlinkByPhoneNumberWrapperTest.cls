@isTest
private class SCC_CardlinkByPhoneNumberWrapperTest {

    @isTest
    static void testParse() {
        // Test JSON string representing card data by phone number
        String json = '{"response": {"customerData": [{"portofolio": {"saving": [{"status": "Active", "productType": "Saving", "productDescription": "Regular Savings Account", "product": "Regular Savings", "cifno": "123456", "balance": 1000.0, "acctno": "SAV123456"}], "loan": [], "investasi": [], "creditCard": [{"status": "Active", "productType": "Credit Card", "productDescription": "Gold Credit Card", "product": "Gold Card", "cifno": "123456", "cardNumber": "1234 5678 9012 3456"}]}, "additionalData": [], "cardHolderData": [], "alamatEmail": "john.doe@example.com", "alamatRumahBelakang": "", "alamatRumahDepan": "123 Main St", "alamatKantorBelakang": "", "alamatKantorTengah": "", "alamatKantorDepan": "", "jabatanKerja": "Manager", "jenisKelamin": "Male", "sisaLimitCicilanNasabah": "", "limitCicilanNasabah": "", "sisaLimitTarikTunaiNasabah": "", "limitTarikTunaiNasabah": "", "sisaLimitNasabah": "", "nomorNpwp": "1234567890", "nomorNik": "1234567890", "namaKerabatTidakSerumah": "", "nomorTelephoneKantor": "123-456-7890", "nomorTelephoneRumah": "123-456-7890", "nomorTelephoneKerabatTidakSerumah": "", "nomorHandphoneTerdaftar": "123-456-7890", "namaBelakang": "Doe", "namaTengah": "", "namaDepan": "John"}]}}';

        // Parse the JSON string
        SCC_CardlinkByPhoneNumberWrapper wrapper = SCC_CardlinkByPhoneNumberWrapper.parse(json);

        // Verify that the wrapper object is not null
        System.assertNotEquals(null, wrapper);

        // Verify that the response object is not null
        System.assertNotEquals(null, wrapper.response);

        // Verify that the customerData list is not null and contains one item
        System.assertNotEquals(null, wrapper.response.customerData);
        System.assertEquals(1, wrapper.response.customerData.size());

        // Verify the values of the parsed CustomerData object
        SCC_CardlinkByPhoneNumberWrapper.CustomerData customerData = wrapper.response.customerData[0];
        System.assertEquals('john.doe@example.com', customerData.alamatEmail);
        System.assertEquals('123 Main St', customerData.alamatRumahDepan);
        System.assertEquals('Manager', customerData.jabatanKerja);
        System.assertEquals('Male', customerData.jenisKelamin);
        System.assertEquals('1234567890', customerData.nomorNpwp);
        System.assertEquals('1234567890', customerData.nomorNik);
        System.assertEquals('123-456-7890', customerData.nomorTelephoneKantor);
        System.assertEquals('123-456-7890', customerData.nomorTelephoneRumah);
        System.assertEquals('123-456-7890', customerData.nomorHandphoneTerdaftar);
        System.assertEquals('Doe', customerData.namaBelakang);
        System.assertEquals('John', customerData.namaDepan);

        // Verify the values of the parsed Saving object
        SCC_CardlinkByPhoneNumberWrapper.Saving saving = customerData.portofolio.saving[0];
        System.assertEquals('Active', saving.status);
        System.assertEquals('Saving', saving.productType);
        System.assertEquals('Regular Savings Account', saving.productDescription);
        System.assertEquals('Regular Savings', saving.product);
        System.assertEquals('123456', saving.cifno);
        System.assertEquals(1000.0, saving.balance);
        System.assertEquals('SAV123456', saving.acctno);

        // Verify the values of the parsed CreditCard object
        SCC_CardlinkByPhoneNumberWrapper.CreditCard creditCard = customerData.portofolio.creditCard[0];
        System.assertEquals('Active', creditCard.status);
        System.assertEquals('Credit Card', creditCard.productType);
        System.assertEquals('Gold Credit Card', creditCard.productDescription);
        System.assertEquals('Gold Card', creditCard.product);
        System.assertEquals('123456', creditCard.cifno);
        System.assertEquals('1234 5678 9012 3456', creditCard.cardNumber);
    }
}