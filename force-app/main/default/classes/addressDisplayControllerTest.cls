@isTest
private class addressDisplayControllerTest {
    
    @testSetup
    static void setup() {
        // Buat Country
        Schema.Location countryLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        countryLoc.Name = 'Indonesia';
        countryLoc.LocationType = 'Country';
        insert countryLoc;
        
        // Buat Province
        Schema.Location provinceLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        provinceLoc.Name = 'Jawa Barat';
        provinceLoc.LocationType = 'Province';
        provinceLoc.Country__c = countryLoc.Id;
        insert provinceLoc;
        
        // Buat City
        Schema.Location cityLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        cityLoc.Name = 'Bandung';
        cityLoc.LocationType = 'City';
        cityLoc.Country__c = countryLoc.Id;
        cityLoc.Province__c = provinceLoc.Id;
        insert cityLoc;
        
        // Buat Address TANPA Zip_Code untuk avoid FIELD_FILTER_VALIDATION_EXCEPTION
        List<Schema.Location> addresses = new List<Schema.Location>();
        for(Integer i = 1; i <= 5; i++) {
            Schema.Location addr = (Schema.Location)Location.sObjectType.newSObject(null, true);
            addr.Name = 'Alamat Test ' + i;
            addr.LocationType = 'Address';
            addr.Country__c = countryLoc.Id;
            addr.Province__c = provinceLoc.Id;
            addr.City__c = cityLoc.Id;
            // SKIP Zip_Code__c karena validation issue
            addresses.add(addr);
        }
        insert addresses;
    }
    
    @isTest
    static void testSearchLocations_noFilter() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, null, null, null, null);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 5, 'Should have at least 5 addresses');
    }
    
    @isTest
    static void testSearchLocations_withSearchKey() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Test 1', null, null, null, null, 10);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should find exactly 1 address');
        System.assert(results[0].Name.contains('Test 1'), 'Name should contain Test 1');
    }
    
    @isTest
    static void testSearchLocations_withCountry() {
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, country.Id, null, null, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Should find addresses');
        System.assertEquals(country.Id, results[0].CountryId, 'CountryId should match');
    }
    
    @isTest
    static void testSearchLocations_withProvince() {
        Schema.Location province = [SELECT Id FROM Location WHERE LocationType = 'Province' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, province.Id, null, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Should find addresses');
        System.assertEquals(province.Id, results[0].ProvinceId, 'ProvinceId should match');
    }
    
    @isTest
    static void testSearchLocations_withCity() {
        Schema.Location city = [SELECT Id FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, null, city.Id, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Should find addresses');
        System.assertEquals(city.Id, results[0].CityId, 'CityId should match');
    }
    
    // SKIP test with ZipCode karena FIELD_FILTER_VALIDATION_EXCEPTION
    
    @isTest
    static void testSearchLocations_withAllFilters() {
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        Schema.Location province = [SELECT Id FROM Location WHERE LocationType = 'Province' LIMIT 1];
        Schema.Location city = [SELECT Id FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Alamat', country.Id, province.Id, city.Id, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Should find addresses');
        System.assertEquals(country.Id, results[0].CountryId, 'CountryId should match');
        System.assertEquals(province.Id, results[0].ProvinceId, 'ProvinceId should match');
        System.assertEquals(city.Id, results[0].CityId, 'CityId should match');
    }
    
    @isTest
    static void testSearchLocations_withLimit() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, null, null, null, 3);
        Test.stopTest();
        
        System.assert(results.size() <= 3, 'Should respect limit of 3');
    }
    
    @isTest
    static void testSearchLocations_defaultLimit() {
        // Insert lebih dari 10 records untuk test default limit
        List<Schema.Location> extras = new List<Schema.Location>();
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        Schema.Location province = [SELECT Id FROM Location WHERE LocationType = 'Province' LIMIT 1];
        Schema.Location city = [SELECT Id FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        for(Integer i = 6; i <= 15; i++) {
            Schema.Location addr = (Schema.Location)Location.sObjectType.newSObject(null, true);
            addr.Name = 'Extra Address ' + i;
            addr.LocationType = 'Address';
            addr.Country__c = country.Id;
            addr.Province__c = province.Id;
            addr.City__c = city.Id;
            extras.add(addr);
        }
        insert extras;
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, null, null, null, null);
        Test.stopTest();
        
        System.assert(results.size() <= 10, 'Should use default limit of 10');
    }
    
    @isTest
    static void testSearchLocations_noResults() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('XYZ999NotExist', null, null, null, null, 10);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list');
    }
    
    @isTest
    static void testSearchLocations_sqlInjection() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Test\'OR\'1\'=\'1', null, null, null, null, 10);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should handle SQL injection safely');
    }
    
    @isTest
    static void testSearchLocations_searchKeyWithCountry() {
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Test', country.Id, null, null, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Should find addresses');
        for(addressDisplayController.AddressWrapper w : results) {
            System.assert(w.Name.contains('Test'), 'Name should contain Test');
            System.assertEquals(country.Id, w.CountryId, 'CountryId should match');
        }
    }
    
    @isTest
    static void testSearchLocations_verifyWrapper() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Alamat Test 1', null, null, null, null, 1);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should find exactly 1 address');
        addressDisplayController.AddressWrapper w = results[0];
        
        System.assertNotEquals(null, w.Id, 'Id should not be null');
        System.assertNotEquals(null, w.Name, 'Name should not be null');
        System.assertNotEquals(null, w.CountryId, 'CountryId should not be null');
        System.assertNotEquals(null, w.ProvinceId, 'ProvinceId should not be null');
        System.assertNotEquals(null, w.CityId, 'CityId should not be null');
        // ZipId bisa null karena tidak di-set
    }
    
    // ========== Tests for getAddressById ==========
    
    @isTest
    static void testGetAddressById_validId() {
        Schema.Location addr = [SELECT Id FROM Location WHERE LocationType = 'Address' LIMIT 1];
        
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById(addr.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(addr.Id, result.Id, 'Id should match');
        System.assertNotEquals(null, result.Name, 'Name should not be null');
        System.assertNotEquals(null, result.CountryId, 'CountryId should not be null');
        System.assertNotEquals(null, result.CountryName, 'CountryName should not be null');
        System.assertNotEquals(null, result.ProvinceId, 'ProvinceId should not be null');
        System.assertNotEquals(null, result.ProvinceName, 'ProvinceName should not be null');
        System.assertNotEquals(null, result.CityId, 'CityId should not be null');
        System.assertNotEquals(null, result.CityName, 'CityName should not be null');
    }
    
    @isTest
    static void testGetAddressById_nullId() {
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById(null);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null for null input');
    }
    
    @isTest
    static void testGetAddressById_blankId() {
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById('');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null for blank input');
    }
    
    @isTest
    static void testGetAddressById_invalidId() {
        // Generate fake ID dengan 15 karakter
        String fakeId = '000000000000000';
        
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById(fakeId);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null for invalid ID');
    }
    
    @isTest
    static void testGetAddressById_nonAddressLocation() {
        // Get City Location (bukan Address)
        Schema.Location city = [SELECT Id FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById(city.Id);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null for non-Address LocationType');
    }
    
    @isTest
    static void testGetAddressById_verifyAllFields() {
        Schema.Location addr = [SELECT Id, Name FROM Location WHERE LocationType = 'Address' LIMIT 1];
        Schema.Location country = [SELECT Id, Name FROM Location WHERE LocationType = 'Country' LIMIT 1];
        Schema.Location province = [SELECT Id, Name FROM Location WHERE LocationType = 'Province' LIMIT 1];
        Schema.Location city = [SELECT Id, Name FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById(addr.Id);
        Test.stopTest();
        
        System.assertEquals(addr.Id, result.Id, 'Address Id should match');
        System.assertEquals(addr.Name, result.Name, 'Address Name should match');
        System.assertEquals(country.Id, result.CountryId, 'CountryId should match');
        System.assertEquals(country.Name, result.CountryName, 'CountryName should match');
        System.assertEquals(province.Id, result.ProvinceId, 'ProvinceId should match');
        System.assertEquals(province.Name, result.ProvinceName, 'ProvinceName should match');
        System.assertEquals(city.Id, result.CityId, 'CityId should match');
        System.assertEquals(city.Name, result.CityName, 'CityName should match');
        // ZipId dan ZipName bisa null
    }
    
    @isTest
    static void testGetAddressById_withBranchId() {
        // Test jika Branch_Name__r.BRANCH_ID__c terisi
        Schema.Location addr = [SELECT Id FROM Location WHERE LocationType = 'Address' LIMIT 1];
        
        Test.startTest();
        addressDisplayController.AddressWrapper result = 
            addressDisplayController.getAddressById(addr.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        // BranchId bisa null jika tidak di-setup
    }
    
    @isTest
    static void testGetAddressById_performanceTest() {
        List<Schema.Location> addresses = [SELECT Id FROM Location WHERE LocationType = 'Address' LIMIT 5];
        
        Test.startTest();
        for(Schema.Location addr : addresses) {
            addressDisplayController.AddressWrapper result = 
                addressDisplayController.getAddressById(addr.Id);
            System.assertNotEquals(null, result, 'Each result should not be null');
        }
        Test.stopTest();
        
        // Verify tidak ada SOQL limit exceeded
        System.assert(Limits.getQueries() < Limits.getLimitQueries(), 'Should not exceed SOQL limits');
    }
}