/**
 * @description       : Test Class for SCC_PhoneNumberWrapper
 * @last modified on  : 03-06-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_PhoneNumberWrapper_Test {

    @isTest
    static void testAdditionalData() {
        String validJson = '{ "namaLengkapIbuKandung": "Amalia", "nominalPendapatanPerBulan": "5000000","anotherField": { "nestedField": "value" },"namaLengkapAyahKandung": "Jon" }';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.AdditionalData addData = new SCC_PhoneNumberWrapper.AdditionalData(parser);
    }

    @IsTest
    static void testParseValidJson() {
        String validJson = '{ "response": { "customerData": [{ "namaDepan": "John", "namaBelakang": "Doe" }] },'+
        '"otherField": "another"'+
        '}';
        
        SCC_PhoneNumberWrapper result = SCC_PhoneNumberWrapper.parse(validJson);
    }

    @isTest
    static void testCustomerData() {
        String validJson = '{' +
            '"namaDepan": "Depan",' +
            '"namaTengah": "Tengah",' +
            '"namaBelakang": "Belakang",' +
            '"nomorHandphoneTerdaftar": "081234567890",' +
            '"nomorTelephoneKerabatTidakSerumah": "0219876543",' +
            '"nomorTelephoneRumah": "0213456789",' +
            '"nomorTelephoneKantor": "0215551234",' +
            '"namaKerabatTidakSerumah": "Jane Doe",' +
            '"nomorNik": "1234567890123456",' +
            '"nomorNpwp": "987654321098765",' +
            '"sisaLimitNasabah": "10000000",' +
            '"limitTarikTunaiNasabah": "5000000",' +
            '"sisaLimitTarikTunaiNasabah": "3000000",' +
            '"limitCicilanNasabah": "7000000",' +
            '"sisaLimitCicilanNasabah": "4000000",' +
            '"jenisKelamin": "Laki-laki",' +
            '"jabatanKerja": "Manager",' +
            '"alamatKantorDepan": "Jl. Kantor Depan",' +
            '"alamatKantorTengah": "RT 01 RW 01",' +
            '"alamatKantorBelakang": "Jakarta Selatan",' +
            '"alamatRumahDepan": "Jl. Rumah Depan",' +
            '"alamatRumahBelakang": "Bekasi",' +
            '"alamatEmail": "john.doe@example.com",' +
            '"cardHolderData": [ { "cardNumber": "1234", "cardType": "Visa" }, { "cardNumber": "5678", "cardType": "MasterCard" } ],' +
            '"additionalData": [ { "namaLengkapIbuKandung": "Jane Smith", "nominalPendapatanPerBulan": "15000000" } ],' +
            '"otherField": "Other"' +
            '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.CustomerData customerData = new SCC_PhoneNumberWrapper.CustomerData(parser);
    }
    
    @IsTest
    static void testResponseCustomerData() {
        String validJson = '{ "customerData": [ { "namaDepan": "Satu", "nomorHandphoneTerdaftar": "081234567890", "otherField": "another" }, { "namaDepan": "Dua", "nomorHandphoneTerdaftar": "081987654321" } ],'+
        '"other":"value"'+
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Response response = new SCC_PhoneNumberWrapper.Response(parser);
    }
    @IsTest
    static void testCardHolderData() {
        String validJson = '{' +
            '"limitKartuKredit": "50000000",' +
            '"expiredKartu": "2025-12-31",' +
            '"tanggalCetakCycle": "2023-08-15",' +
            '"tanggalJatuhTempo": "2023-09-01",' +
            '"sisaLimitKartu": "30000000",' +
            '"limitTarikTunaiKartu": "10000000",' +
            '"sisaLimitTarikTunaiKartu": "5000000",' +
            '"limitCicilanKartu": "20000000",' +
            '"sisaLimitCicilanKartu": "15000000",' +
            '"customerNumber": "CSNUM123456",' +
            '"tanggalTerakhirMaintenanceKartu": "2023-07-01",' +
            '"namaCetakKartu": "Ahmad",' +
            '"otherField": "Another Value"' +
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.CardHolderData response = new SCC_PhoneNumberWrapper.CardHolderData(parser);
    }
    @IsTest
    static void testLoanData() {
        String validJson = '{' +
            '"acctno": "123456789",' +
            '"balance": 100000.75,' +
            '"cifno": "CIF12345",' +
            '"product": "Home Loan",' +
            '"productDescription": "A home loan product",' +
            '"productType": "Type",' +
            '"status": "Active",' +
            '"otherField": "Another Value"' +
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Loan response = new SCC_PhoneNumberWrapper.Loan(parser);
    }
    @IsTest
    static void testInvestasi() {
        String validJson = '{' +
            '"acctno": "INV123456789",' +
            '"balance": 150000,' +
            '"cifno": "CIF98765",' +
            '"product": "Investment Fund",' +
            '"productDescription": "A high-yield investment product",' +
            '"productType": "Equity",' +
            '"status": "Active",' +
            '"otherField": "Another Value"' +
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Investasi response = new SCC_PhoneNumberWrapper.Investasi(parser);
    }

    @IsTest
    static void testCreditCard() {
        String validJson = '{' +
            '"cardNumber": "1234-5678-9012-3456",' +
            '"cifno": "CIF123456",' +
            '"product": "Platinum Card",' +
            '"productDescription": "A premium credit card product",' +
            '"productType": "Credit Card",' +
            '"status": "Active",' +
            '"otherField": "Another Value"' +
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.CreditCard response = new SCC_PhoneNumberWrapper.CreditCard(parser);
    }
    @IsTest
    static void testPortofolioCreditCard() {
        String validJson = '{ "creditCard": [ { "namaDepan": "Satu", "nomorHandphoneTerdaftar": "081234567890", "otherField": "another" }, { "namaDepan": "Dua", "nomorHandphoneTerdaftar": "081987654321" } ],'+ 
        '"other":"Data"'+
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Portofolio response = new SCC_PhoneNumberWrapper.Portofolio(parser);
    }
    @IsTest
    static void testPortofolioInvestasi() {
        String validJson = '{ "investasi": [ { "namaDepan": "Satu", "nomorHandphoneTerdaftar": "081234567890", "otherField": "another" }],'+ 
        '"other":"Data"'+
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Portofolio response = new SCC_PhoneNumberWrapper.Portofolio(parser);
    }
    @IsTest
    static void testPortofolioSaving() {
        String validJson = '{ "saving": [ { "namaDepan": "Satu", "nomorHandphoneTerdaftar": "081234567890", "otherField": "another" }],'+ 
        '"other":"Data"'+
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Portofolio response = new SCC_PhoneNumberWrapper.Portofolio(parser);
    }
    @IsTest
    static void testPortofolioLoan() {
        String validJson = '{ "loan": [ { "namaDepan": "Satu", "nomorHandphoneTerdaftar": "081234567890", "otherField": "another" }],'+ 
        '"other":"Data"'+
        '}';

        System.JSONParser parser = System.JSON.createParser(validJson);
        SCC_PhoneNumberWrapper.Portofolio response = new SCC_PhoneNumberWrapper.Portofolio(parser);
    }
}