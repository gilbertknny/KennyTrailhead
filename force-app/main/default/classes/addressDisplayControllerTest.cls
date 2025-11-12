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
        
        // Buat Address TANPA Zip_Code (skip field yang bermasalah)
        List<Schema.Location> addresses = new List<Schema.Location>();
        for(Integer i = 1; i <= 5; i++) {
            Schema.Location addr = (Schema.Location)Location.sObjectType.newSObject(null, true);
            addr.Name = 'Alamat Test ' + i;
            addr.LocationType = 'Address';
            addr.Country__c = countryLoc.Id;
            addr.Province__c = provinceLoc.Id;
            addr.City__c = cityLoc.Id;
            // SKIP Zip_Code__c
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
        
        System.assertNotEquals(null, results);
        System.assert(results.size() >= 5);
    }
    
    @isTest
    static void testSearchLocations_withSearchKey() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Test 1', null, null, null, null, 10);
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assert(results[0].Name.contains('Test 1'));
    }
    
    @isTest
    static void testSearchLocations_withCountry() {
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, country.Id, null, null, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size());
        System.assertEquals(country.Id, results[0].CountryId);
    }
    
    @isTest
    static void testSearchLocations_withProvince() {
        Schema.Location province = [SELECT Id FROM Location WHERE LocationType = 'Province' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, province.Id, null, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size());
        System.assertEquals(province.Id, results[0].ProvinceId);
    }
    
    @isTest
    static void testSearchLocations_withCity() {
        Schema.Location city = [SELECT Id FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, null, city.Id, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size());
        System.assertEquals(city.Id, results[0].CityId);
    }
    
    @isTest
    static void testSearchLocations_withAllFilters() {
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        Schema.Location province = [SELECT Id FROM Location WHERE LocationType = 'Province' LIMIT 1];
        Schema.Location city = [SELECT Id FROM Location WHERE LocationType = 'City' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Alamat', country.Id, province.Id, city.Id, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size());
        System.assertEquals(country.Id, results[0].CountryId);
        System.assertEquals(province.Id, results[0].ProvinceId);
        System.assertEquals(city.Id, results[0].CityId);
    }
    
    @isTest
    static void testSearchLocations_withLimit() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations(null, null, null, null, null, 3);
        Test.stopTest();
        
        System.assert(results.size() <= 3);
    }
    
    @isTest
    static void testSearchLocations_noResults() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('XYZ999NotExist', null, null, null, null, 10);
        Test.stopTest();
        
        System.assertEquals(0, results.size());
    }
    
    @isTest
    static void testSearchLocations_sqlInjection() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Test\'OR\'1\'=\'1', null, null, null, null, 10);
        Test.stopTest();
        
        System.assertEquals(0, results.size());
    }
    
    @isTest
    static void testSearchLocations_searchKeyWithCountry() {
        Schema.Location country = [SELECT Id FROM Location WHERE LocationType = 'Country' LIMIT 1];
        
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = 
            addressDisplayController.searchLocations('Test', country.Id, null, null, null, 10);
        Test.stopTest();
        
        System.assertNotEquals(0, results.size());
        for(addressDisplayController.AddressWrapper w : results) {
            System.assert(w.Name.contains('Test'));
            System.assertEquals(country.Id, w.CountryId);
        }
    }
}