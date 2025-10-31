@IsTest(SeeAllData=true)
public class LeadControllerTest {

    @IsTest
    static void testFindCities() {
        List<Schema.Location> cities = [
            SELECT Id, Name, Province__c
            FROM Location
            WHERE LocationType = 'City'
            AND RecordType.Name = 'City'
            LIMIT 1
        ];
        System.assert(!cities.isEmpty(), 'No City Location found in org data');

        Schema.Location city = cities[0];

        Test.startTest();
        List<LeadController.LocationWrapper> results = LeadController.findCities(city.Name);
        Test.stopTest();

        System.assert(results.size() > 0, 'Expected at least one city result');
    }

    @IsTest
    static void testGetZipCodes() {
        List<Schema.Location> cities = [
            SELECT Id
            FROM Location
            WHERE LocationType = 'City'
            AND RecordType.Name = 'City'
            LIMIT 1
        ];
        System.assert(!cities.isEmpty(), 'No City Location found');
        Schema.Location city = cities[0];

        List<Schema.Location> zips = [
            SELECT Id, Name, Village__c
            FROM Location
            WHERE LocationType = 'Zip Code'
            AND RecordType.Name = 'Zip Code'
            AND City__c = :city.Id
            LIMIT 1
        ];

        if (!zips.isEmpty()) {
            Schema.Location zip = zips[0];
            Test.startTest();
            List<LeadController.LocationWrapper> results = LeadController.getZipCodes(city.Id);
            Test.stopTest();

            System.assert(results.size() > 0, 'Expected at least one zip code result');
        }
    }

    @IsTest
    static void testGetCustomerTypeOptions() {
        Test.startTest();
        List<Map<String,String>> options = LeadController.getCustomerTypeOptions();
        Test.stopTest();

        System.assert(options.size() > 0, 'Expected some picklist values for Account_Segment__c');
    }

    @IsTest
    static void testCreateLead() {
        // Query an existing City Location
        List<Schema.Location> cities = [
            SELECT Id, Province__c
            FROM Location
            WHERE LocationType = 'City'
            AND RecordType.Name = 'City'
            LIMIT 1
        ];
        System.assert(!cities.isEmpty(), 'No City Location found in org data');
        Schema.Location city = cities[0];

        // Query a Zip Code Location related to that City (if available)
        List<Schema.Location> zips = [
            SELECT Id, Village__c
            FROM Location
            WHERE LocationType = 'Zip Code'
            AND RecordType.Name = 'Zip Code'
            AND City__c = :city.Id
            LIMIT 1
        ];
        Schema.Location zip = zips.isEmpty() ? null : zips[0];

        Test.startTest();
        Id leadId = LeadController.createLead(
            'Marco',
            'Santoso',
            'marco@example.com',
            '08123456789',
            'Test Company',
            city.Province__c,   // provinceId
            city.Id,            // cityId
            zip != null ? zip.Id : null,          // zipCodeId
            zip != null ? zip.Village__c : null,  // villageId
            'I',                // customerType
            'Test description'
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Email, City__c, Province__c, Zip__c, Village__c
            FROM Lead
            WHERE Id = :leadId
        ];
        System.assertEquals('Marco', insertedLead.FirstName);
        System.assertEquals(city.Id, insertedLead.City__c);
        if (zip != null) {
            System.assertEquals(zip.Id, insertedLead.Zip__c);
        }
    }
}