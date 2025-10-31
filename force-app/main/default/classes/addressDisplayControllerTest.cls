@isTest
private class addressDisplayControllerTest {

    @isTest
    static void testSearchLocations_basic() {
        // 🔹 1. Buat record Master Data sebagai Branch
        Master_Data__c branchMaster = new Master_Data__c(
            Name = 'Branch Jakarta',
            BRANCH_ID__c = 'BR001'
        );
        insert branchMaster;

        // 🔹 2. Buat Country
        Schema.Location countryLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        countryLoc.Name = 'Indonesia';
        countryLoc.LocationType = 'Country';
        insert countryLoc;

        // 🔹 3. Buat Province
        Schema.Location provinceLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        provinceLoc.Name = 'Jawa Barat';
        provinceLoc.LocationType = 'Province';
        provinceLoc.Country__c = countryLoc.Id;
        insert provinceLoc;

        // 🔹 4. Buat City
        Schema.Location cityLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        cityLoc.Name = 'Bandung';
        cityLoc.LocationType = 'City';
        cityLoc.Country__c = countryLoc.Id;
        cityLoc.Province__c = provinceLoc.Id;
        insert cityLoc;

        // 🔹 5. Buat ZIP → lookup ke Branch (Master Data)
        Schema.Location zipLoc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        zipLoc.Name = '40123';
        zipLoc.LocationType = 'Zip';
        zipLoc.Branch_Name__c = branchMaster.Id; // ✅ lookup benar ke Master Data
        insert zipLoc;

        // 🔹 6. Buat Address utama
        Schema.Location address = (Schema.Location)Location.sObjectType.newSObject(null, true);
        address.Name = 'Alamat Utama';
        address.LocationType = 'Address';
        address.Country__c = countryLoc.Id;
        address.Province__c = provinceLoc.Id;
        address.City__c = cityLoc.Id;
        address.Zip_Code__c = zipLoc.Id;
        insert address;

        // 🔹 7. Jalankan method
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = addressDisplayController.searchLocations(
            'Alamat', 
            countryLoc.Id, 
            provinceLoc.Id, 
            cityLoc.Id, 
            zipLoc.Id, 
            5
        );
        Test.stopTest();

        // 🔹 8. Validasi hasil
        System.assertNotEquals(0, results.size(), 'Harusnya ada hasil dikembalikan');
        addressDisplayController.AddressWrapper first = results[0];
        System.assertEquals(address.Id, first.Id);
        System.assertEquals('Alamat Utama', first.Name);
        System.assertEquals(zipLoc.Id, first.ZipId);
        System.assertEquals('BR001', first.BranchId, 'Branch ID harus sesuai dari Master Data');
    }

    @isTest
    static void testSearchLocations_noFilter() {
        Schema.Location loc = (Schema.Location)Location.sObjectType.newSObject(null, true);
        loc.Name = 'Tanpa Filter';
        loc.LocationType = 'Address';
        insert loc;

        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = addressDisplayController.searchLocations(
            null, null, null, null, null, null
        );
        Test.stopTest();

        System.assert(results.size() > 0);
    }

    @isTest
    static void testSearchLocations_emptyResult() {
        Test.startTest();
        List<addressDisplayController.AddressWrapper> results = addressDisplayController.searchLocations(
            'TidakAdaData', null, null, null, null, 5
        );
        Test.stopTest();

        System.assertEquals(0, results.size());
    }
}