/**
 * @description       : Custom Lookup Test
 * @author            : Fikri
 * @last modified on  : 11-28-2025
 * @last modified by  : Ahmad Yazid Munif
**/
@IsTest (seeAllData=false)
private class customLookup_Controller_Test {

    @TestSetup
    static void setupData() {
        // Create required Master_Data__c hierarchy
        Aswata_TestDataFactory.createLocationHierarchy();

        // Create exchange rate record
        Aswata_TestDataFactory.createExchangeRate('IDR', 1);
        Aswata_TestDataFactory.createExchangeRate('USD', 16500);
        
        //Create Master Data Coverage and Detail Insured
        Aswata_TestDataFactory.createMasterData('Coverage', 'Coverage');
        //Aswata_TestDataFactory.createMasterData('Detail Insured', 'Asset');
        
    }

    @IsTest
    static void testSearch_CityLookup() {
        Schema.Location city = [SELECT Id, Name FROM Location WHERE RecordType.Name = 'City' LIMIT 1];
        Schema.Location province = [SELECT Id FROM Location WHERE RecordType.Name = 'Province' LIMIT 1];

        String showData = '[{"param1":"ProvinceName","param2":"Province__c"}]';

        Test.startTest();
        List<customLookup_Controller.LookupResult> results = customLookup_Controller.searchRecords(
            'Location',
            'Name, City_ID__c, Province__r.Name, Country__r.Name',
            'Jakarta',
            'City',
            province.Id,
            null,
            null,
            showData,
            null
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'City lookup should return records');
        System.assert(results[0].Name.contains('Jakarta'), 'City name should match search');
    }

    @IsTest
    static void testSearch_ProvinceLookup() {
        String showData = '[{"param1":"Country","param2":"Country__c"}]';

        Test.startTest();
        List<customLookup_Controller.LookupResult> results = customLookup_Controller.searchRecords(
            'Location',
            'Name, Country__r.Name',
            'Jakarta',
            'Province',
            null,
            null,
            null,
            showData,
            null
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Province lookup should return records');
        System.assertNotEquals(null, results[0].Name, 'Result should have a Name');
    }

    @IsTest
    static void testSearch_AddressLookup() {
        Schema.Location city = [SELECT Id FROM Location WHERE RecordType.Name = 'City' LIMIT 1];
        String showData = '[{"param1":"City","param2":"City__c"}]';

        Test.startTest();
        List<customLookup_Controller.LookupResult> results = customLookup_Controller.searchRecords(
            'Location',
            'Name, City__r.Name, Zip_Code__r.Name',
            'Sudirman',
            'Address',
            null,
            city.Id,
            null,
            showData,
            null
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Address lookup should return records');
    }

    @IsTest
    static void testSearch_ExchangeRateLookup() {
        String showData = '[{"param1":"Rate","param2":"Exchange_Rate__c"}]';

        Test.startTest();
        List<customLookup_Controller.LookupResult> results = customLookup_Controller.searchRecords(
            'Master_Data__c',
            'Name',
            'USD',
            'Exchange Rate',
            null,
            null,
            null,
            showData,
            null
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Exchange Rate lookup should return records');
        System.assert(results[0].Subtitle != null, 'Subtitle should show exchange rate');
    }

    @IsTest
    static void testSearch_DefaultLookup() {
        Test.startTest();
        List<customLookup_Controller.LookupResult> results = customLookup_Controller.searchRecords(
            'Location',
            'Name, City__r.Name',
            'Setiabudi',
            'Village',
            null,
            null,
            null,
            null,
            null
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Default lookup should return records');
    }

    @IsTest
    static void testSearch_Coverage() {

        String showData = '[{"param1":"Name"}]';

        Test.startTest();
        List<customLookup_Controller.LookupResult> results = customLookup_Controller.searchRecords(
            'Master_Data__c',
            'Name, COVERAGE_REF_ID__c',
            'Coverage',
            'Coverage',
            null,
            null,
            null,
            null,
            null
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Default lookup should return records');
    }

    @IsTest
    static void testGetRecordById() {
        Schema.Location province = [SELECT Id FROM Location WHERE RecordType.Name = 'Province' LIMIT 1];

        Test.startTest();
        SObject rec = customLookup_Controller.getRecordById('Location', province.Id, 'Province');
        Test.stopTest();

        System.assertNotEquals(null, rec, 'getRecordById should return record');
    }
}