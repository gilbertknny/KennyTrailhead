@IsTest(SeeAllData=true)
@SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue, PMD.ApexUnitTestClassShouldHaveRunAs')
public class LeadControllerTest {

    // Helper method to generate unique email addresses for testing
    private static String generateUniqueEmail(String prefix) {
        return prefix + DateTime.now().getTime() + Math.random().intValue() + '@test.com';
    }

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
    static void testCreateLeadIndividual() {
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

        String uniqueEmail = generateUniqueEmail('marco');

        Test.startTest();
        Id leadId = LeadController.createLead(
            'Marco',                    // firstName
            'Santoso',                  // lastName
            uniqueEmail,                // email - using unique email
            '08123456789',              // phone
            'Marco Santoso',            // company (Individual: concat first+last)
            city.Province__c,           // provinceId
            city.Id,                    // cityId
            zip != null ? zip.Id : null,              // zipCodeId
            zip != null ? zip.Village__c : null,      // villageId
            'I',                        // customerType (Individual)
            'Test description'         // userDescription
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Email, Phone, Company, 
                   City__c, Province__c, Zip__c, Village__c,
                   Account_Segment__c, User_Description__c,
                   Company_Email__c, Company_Phone__c
            FROM Lead
            WHERE Id = :leadId
        ];
        
        System.assertEquals('Marco', insertedLead.FirstName, 'First name should match');
        System.assertEquals('Santoso', insertedLead.LastName, 'Last name should match');
        System.assertEquals('Marco Santoso', insertedLead.Company, 'Company should be concatenated name');
        System.assertEquals('I', insertedLead.Account_Segment__c, 'Customer type should be Individual');
        System.assertEquals(city.Id, insertedLead.City__c, 'City reference should match');
        System.assertEquals('Test description', insertedLead.User_Description__c, 'Description should match');
        System.assertEquals(uniqueEmail, insertedLead.Company_Email__c, 'Company email should be set when company is not blank');
        System.assertEquals('08123456789', insertedLead.Company_Phone__c, 'Company phone should be set when company is not blank');
        
        if (zip != null) {
            System.assertEquals(zip.Id, insertedLead.Zip__c, 'Zip code reference should match');
        }
    }

    @IsTest
    static void testCreateLeadBusiness() {
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

        String uniqueEmail = generateUniqueEmail('business');

        Test.startTest();
        Id leadId = LeadController.createLead(
            'John',                     // firstName
            'Doe',                      // lastName
            uniqueEmail,                // email - using unique email
            '08123456780',              // phone
            'Business Corp',            // company (actual company name)
            city.Province__c,           // provinceId
            city.Id,                    // cityId
            zip != null ? zip.Id : null,              // zipCodeId
            zip != null ? zip.Village__c : null,      // villageId
            'E',                        // customerType (Enterprise)
            'Business inquiry'          // userDescription
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Email, Phone, Company, 
                   City__c, Province__c, Zip__c, Village__c,
                   Account_Segment__c, User_Description__c,
                   Company_Email__c, Company_Phone__c
            FROM Lead
            WHERE Id = :leadId
        ];
        
        System.assertEquals('John', insertedLead.FirstName, 'First name should match');
        System.assertEquals('Doe', insertedLead.LastName, 'Last name should match');
        System.assertEquals('Business Corp', insertedLead.Company, 'Company should match');
        System.assertEquals('E', insertedLead.Account_Segment__c, 'Customer type should be Enterprise');
        System.assertEquals(city.Id, insertedLead.City__c, 'City reference should match');
        System.assertEquals('Business inquiry', insertedLead.User_Description__c, 'Description should match');
        System.assertEquals(uniqueEmail, insertedLead.Company_Email__c, 'Company email should be set for business');
        System.assertEquals('08123456780', insertedLead.Company_Phone__c, 'Company phone should be set for business');
        
        if (zip != null) {
            System.assertEquals(zip.Id, insertedLead.Zip__c, 'Zip code reference should match');
        }
    }

    @IsTest
    static void testCreateLeadWithoutCompany() {
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

        String uniqueEmail = generateUniqueEmail('test');

        Test.startTest();
        Id leadId = LeadController.createLead(
            'Test',                     // firstName
            'User',                     // lastName
            uniqueEmail,                // email - using unique email
            '08123456789',              // phone
            null,                       // company (null)
            city.Province__c,           // provinceId
            city.Id,                    // cityId
            null,                       // zipCodeId
            null,                       // villageId
            'I',                        // customerType
            'Test description'          // userDescription
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Company, 
                   Company_Email__c, Company_Phone__c
            FROM Lead
            WHERE Id = :leadId
        ];
        
        System.assertEquals('Test', insertedLead.FirstName, 'First name should match');
        System.assertEquals('User', insertedLead.LastName, 'Last name should match');
        System.assertEquals(null, insertedLead.Company, 'Company should be null');
        System.assertEquals(null, insertedLead.Company_Email__c, 'Company email should be null when company is null');
        System.assertEquals(null, insertedLead.Company_Phone__c, 'Company phone should be null when company is null');
    }

    @IsTest
    static void testCreateLeadExceptionHandling() {
        Test.startTest();
        try {
            // This should fail because required fields are missing
            LeadController.createLead(
                null,    // firstName
                null,    // lastName
                null,    // email
                null,    // phone
                null,    // company
                null,    // provinceId
                null,    // cityId
                null,    // zipCodeId
                null,    // villageId
                null,    // customerType
                null     // userDescription
            );
            System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            // Expected behavior
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }
}