@isTest
public class SCC_CardlinkByCardNumberWrapperTest {

    @isTest
    static void testParseMethod() {
        // Create sample JSON string representing customer data
        String jsonString = '{' +
            '"response": {' +
                '"customerData": [' +
                    '{' +
                        '"additionalDataByAcctNumber": [{' +
                            '"nominalPendapatanPerBulan": "5000",' +
                            '"namaLengkapIbuKandung": "Jane Doe"' +
                        '}],' +
                        '"cardHolderData": [{' +
                            '"namaCetakKartu": "John Doe",' +
                            '"tanggalTerakhirMaintenanceKartu": "2024-05-28",' +
                            '"customerNumber": "123456789",' +
                            '"sisaLimitCicilanKartu": "500",' +
                            '"limitCicilanKartu": "1000",' +
                            '"sisaLimitTarikTunaiKartu": "200",' +
                            '"limitTarikTunaiKartu": "500",' +
                            '"sisaLimitKartu": "100",' +
                            '"tanggalJatuhTempo": "2024-06-30",' +
                            '"tanggalCetakCycle": "2024-05-01",' +
                            '"expiredKartu": "2025-05-31",' +
                            '"limitKartuKredit": "1000"' +
                        '}],' +
                        '"alamatEmail": "john.doe@example.com",' +
                        '"alamatRumahBelakang": "Back home address",' +
                        '"alamatRumahDepan": "Front home address",' +
                        '"alamatKantorBelakang": "Back office address",' +
                        '"alamatKantorTengah": "Middle office address",' +
                        '"alamatKantorDepan": "Front office address",' +
                        '"jabatanKerja": "Software Engineer",' +
                        '"jenisKelamin": "Male",' +
                        '"sisaLimitCicilanNasabah": "1000",' +
                        '"limitCicilanNasabah": "2000",' +
                        '"sisaLimitTarikTunaiNasabah": "300",' +
                        '"limitTarikTunaiNasabah": "500",' +
                        '"sisaLimitNasabah": "200",' +
                        '"nomorNpwp": "1234567890",' +
                        '"nomorNik": "1234567890123456",' +
                        '"namaKerabatTidakSerumah": "Jane Smith",' +
                        '"nomorTelephoneKantor": "987654321",' +
                        '"nomorTelephoneRumah": "123456789",' +
                        '"nomorTelephoneKerabatTidakSerumah": "555555555",' +
                        '"nomorHandphoneTerdaftar": "999999999",' +
                        '"namaBelakang": "Doe",' +
                        '"namaTengah": "Adam",' +
                        '"namaDepan": "John"' +
                    '}' +
                ']' +
            '}' +
        '}';

        // Parse the JSON string
        SCC_CardlinkByCardNumberWrapper wrapper = SCC_CardlinkByCardNumberWrapper.parse(jsonString);

        // Ensure the wrapper object is not null
        System.assertNotEquals(null, wrapper);

        // Ensure Response object is not null
        System.assertNotEquals(null, wrapper.response);

        // Ensure customerData list is not null and has at least one element
        System.assertNotEquals(null, wrapper.response.customerData);
        System.assertNotEquals(0, wrapper.response.customerData.size());

        // Ensure the properties of the first CustomerData object are set correctly
        SCC_CardlinkByCardNumberWrapper.CustomerData customerData = wrapper.response.customerData[0];
        System.assertEquals('john.doe@example.com', customerData.alamatEmail);
        System.assertEquals('Back home address', customerData.alamatRumahBelakang);
        System.assertEquals('Front home address', customerData.alamatRumahDepan);
        System.assertEquals('Back office address', customerData.alamatKantorBelakang);
        System.assertEquals('Middle office address', customerData.alamatKantorTengah);
        System.assertEquals('Front office address', customerData.alamatKantorDepan);
        System.assertEquals('Software Engineer', customerData.jabatanKerja);
        System.assertEquals('Male', customerData.jenisKelamin);
        System.assertEquals('1000', customerData.sisaLimitCicilanNasabah);
        System.assertEquals('2000', customerData.limitCicilanNasabah);
        System.assertEquals('300', customerData.sisaLimitTarikTunaiNasabah);
        System.assertEquals('500', customerData.limitTarikTunaiNasabah);
        System.assertEquals('200', customerData.sisaLimitNasabah);
        System.assertEquals('1234567890', customerData.nomorNpwp);
        System.assertEquals('1234567890123456', customerData.nomorNik);
        System.assertEquals('Jane Smith', customerData.namaKerabatTidakSerumah);
        System.assertEquals('987654321', customerData.nomorTelephoneKantor);
        System.assertEquals('123456789', customerData.nomorTelephoneRumah);
        System.assertEquals('555555555', customerData.nomorTelephoneKerabatTidakSerumah);
        System.assertEquals('999999999', customerData.nomorHandphoneTerdaftar);
        System.assertEquals('Doe', customerData.namaBelakang);
        System.assertEquals('Adam', customerData.namaTengah);
        System.assertEquals('John', customerData.namaDepan);
    }

    @isTest
    static void testResponseClass() {
        // Create a Response object
        SCC_CardlinkByCardNumberWrapper.Response response = new SCC_CardlinkByCardNumberWrapper.Response();
        
        // Ensure the customerData list is initially null
        System.assertEquals(null, response.customerData);
        
        // Create a list of CustomerData objects
        List<SCC_CardlinkByCardNumberWrapper.CustomerData> customerDataList = new List<SCC_CardlinkByCardNumberWrapper.CustomerData>();
        response.customerData = customerDataList;
        
        // Ensure the customerData list is not null after assignment
        System.assertNotEquals(null, response.customerData);
        System.assertEquals(0, response.customerData.size());
    }
  @isTest
    static void testCardHolderDataClass() {
        // Create a CardHolderData object
        SCC_CardlinkByCardNumberWrapper.CardHolderData cardHolderData = new SCC_CardlinkByCardNumberWrapper.CardHolderData();
        
        // Ensure all attributes are initially null
        System.assertEquals(null, cardHolderData.namaCetakKartu);
        System.assertEquals(null, cardHolderData.tanggalTerakhirMaintenanceKartu);
        // Add assertions for other attributes...

        // Set attribute values
        cardHolderData.namaCetakKartu = 'John Doe';
        cardHolderData.tanggalTerakhirMaintenanceKartu = '2024-05-28';
        // Set values for other attributes...
        cardHolderData.customerNumber = '123456789'; // Customer number
        cardHolderData.sisaLimitCicilanKartu = '500'; // Remaining installment limit of the card
        cardHolderData.limitCicilanKartu = '1000'; // Installment limit of the card
        cardHolderData.sisaLimitTarikTunaiKartu = '200'; // Remaining cash withdrawal limit of the card
        cardHolderData.limitTarikTunaiKartu = '500'; // Cash withdrawal limit of the card
        cardHolderData.sisaLimitKartu = '100'; // Remaining limit of the card
        cardHolderData.tanggalJatuhTempo = '2024-06-30'; // Due date
        cardHolderData.tanggalCetakCycle = '2024-05-01'; // Cycle print date
        cardHolderData.expiredKartu = '2025-05-31'; // Card expiration date
        cardHolderData.limitKartuKredit = '1000'; // Credit card limit
        
        // Ensure attribute values are set correctly
        System.assertEquals('John Doe', cardHolderData.namaCetakKartu);
        System.assertEquals('2024-05-28', cardHolderData.tanggalTerakhirMaintenanceKartu);
        // Add assertions for other attributes...
        System.assertEquals('123456789', cardHolderData.customerNumber); // Customer number
        System.assertEquals('500', cardHolderData.sisaLimitCicilanKartu); // Remaining installment limit of the card
        System.assertEquals('1000', cardHolderData.limitCicilanKartu); // Installment limit of the card
        System.assertEquals('200', cardHolderData.sisaLimitTarikTunaiKartu); // Remaining cash withdrawal limit of the card
        System.assertEquals('500', cardHolderData.limitTarikTunaiKartu); // Cash withdrawal limit of the card
        System.assertEquals('100', cardHolderData.sisaLimitKartu); // Remaining limit of the card
        System.assertEquals('2024-06-30', cardHolderData.tanggalJatuhTempo); // Due date
        System.assertEquals('2024-05-01', cardHolderData.tanggalCetakCycle); // Cycle print date
        System.assertEquals('2025-05-31', cardHolderData.expiredKartu); // Card expiration date
        System.assertEquals('1000', cardHolderData.limitKartuKredit); // Credit card limit
    }


    @isTest
    static void testCustomerDataClass() {
        // Create a CustomerData object
        SCC_CardlinkByCardNumberWrapper.CustomerData customerData = new SCC_CardlinkByCardNumberWrapper.CustomerData();
        
        // Ensure all attributes are initially null
        System.assertEquals(null, customerData.alamatEmail);
        System.assertEquals(null, customerData.alamatRumahBelakang);
        // Add assertions for other attributes...

        // Set attribute values
        customerData.alamatEmail = 'john.doe@example.com';
        customerData.alamatRumahBelakang = 'Back home address';
        // Set values for other attributes...

        // Ensure attribute values are set correctly
        System.assertEquals('john.doe@example.com', customerData.alamatEmail);
        System.assertEquals('Back home address', customerData.alamatRumahBelakang);
        // Add assertions for other attributes...
    }
    @isTest
    static void testAdditionalDataByAcctNumberClass() {
        // Create an AdditionalDataByAcctNumber object
        SCC_CardlinkByCardNumberWrapper.AdditionalDataByAcctNumber additionalData = new SCC_CardlinkByCardNumberWrapper.AdditionalDataByAcctNumber();
        
        // Ensure all attributes are initially null
        System.assertEquals(null, additionalData.nominalPendapatanPerBulan);
        System.assertEquals(null, additionalData.namaLengkapIbuKandung);
        
        // Set attribute values
        additionalData.nominalPendapatanPerBulan = '5000';
        additionalData.namaLengkapIbuKandung = 'Jane Doe';
        
        // Ensure attribute values are set correctly
        System.assertEquals('5000', additionalData.nominalPendapatanPerBulan);
        System.assertEquals('Jane Doe', additionalData.namaLengkapIbuKandung);
    }

    // Similar tests can be written for other inner classes like CardHolderData and CustomerData
}