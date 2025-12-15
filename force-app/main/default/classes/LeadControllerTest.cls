@IsTest(SeeAllData=true)
@SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue, PMD.ApexUnitTestClassShouldHaveRunAs')
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

        Test.startTest();
        Id leadId = LeadController.createLead(
            'Marco',                    // firstName
            'Santoso',                  // lastName
            'marco@example.com',        // email
            '08123456789',              // phone
            'Marco Santoso',            // company (Individual: concat first+last)
            city.Province__c,           // provinceId
            city.Id,                    // cityId
            zip != null ? zip.Id : null,              // zipCodeId
            zip != null ? zip.Village__c : null,      // villageId
            'I',                        // customerType (Individual)
            'Test description',         // userDescription
            null                        // leadReferralName (null for Individual)
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Email, Phone, Company, 
                   City__c, Province__c, Zip__c, Village__c,
                   Account_Segment__c, Lead_Referral_Name__c
            FROM Lead
            WHERE Id = :leadId
        ];
        
        System.assertEquals('Marco', insertedLead.FirstName, 'First name should match');
        System.assertEquals('Santoso', insertedLead.LastName, 'Last name should match');
        System.assertEquals('Marco Santoso', insertedLead.Company, 'Company should be concatenated name');
        System.assertEquals('I', insertedLead.Account_Segment__c, 'Customer type should be Individual');
        System.assertEquals(city.Id, insertedLead.City__c, 'City reference should match');
        System.assert(insertedLead.Lead_Referral_Name__c == null, 'Lead Referral Name should be null for Individual');
        
        if (zip != null) {
            System.assertEquals(zip.Id, insertedLead.Zip__c, 'Zip code reference should match');
        }
    }

    @IsTest
    static void testCreateLeadEnterprise() {
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
            'PT. Maju Jaya',            // firstName (set to Company for Enterprise)
            'PT. Maju Jaya',            // lastName (set to Company for Enterprise)
            'contact@majujaya.com',     // email
            '08123456780',              // phone
            'PT. Maju Jaya',            // company
            city.Province__c,           // provinceId
            city.Id,                    // cityId
            zip != null ? zip.Id : null,              // zipCodeId
            zip != null ? zip.Village__c : null,      // villageId
            'E',                        // customerType (Enterprise)
            'Enterprise inquiry',       // userDescription
            'John Doe'                  // leadReferralName (original names concatenated)
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Email, Phone, Company, 
                   City__c, Province__c, Zip__c, Village__c,
                   Account_Segment__c, Lead_Referral_Name__c
            FROM Lead
            WHERE Id = :leadId
        ];
        
        System.assertEquals('PT. Maju Jaya', insertedLead.FirstName, 'First name should be Company name for Enterprise');
        System.assertEquals('PT. Maju Jaya', insertedLead.LastName, 'Last name should be Company name for Enterprise');
        System.assertEquals('PT. Maju Jaya', insertedLead.Company, 'Company should match');
        System.assertEquals('E', insertedLead.Account_Segment__c, 'Customer type should be Enterprise');
        System.assertEquals('John Doe', insertedLead.Lead_Referral_Name__c, 'Lead Referral Name should store original contact name');
        System.assertEquals(city.Id, insertedLead.City__c, 'City reference should match');
        
        if (zip != null) {
            System.assertEquals(zip.Id, insertedLead.Zip__c, 'Zip code reference should match');
        }
    }

    @IsTest
    static void testCreateLeadWithNullReferralName() {
        // Test that null leadReferralName doesn't cause issues
        
        List<Schema.Location> cities = [
            SELECT Id, Province__c
            FROM Location
            WHERE LocationType = 'City'
            AND RecordType.Name = 'City'
            LIMIT 1
        ];
        System.assert(!cities.isEmpty(), 'No City Location found in org data');
        Schema.Location city = cities[0];

        Test.startTest();
        Id leadId = LeadController.createLead(
            'Test',                     // firstName
            'User',                     // lastName
            'test@example.com',         // email
            '08123456789',              // phone
            'Test User',                // company
            city.Province__c,           // provinceId
            city.Id,                    // cityId
            null,                       // zipCodeId
            null,                       // villageId
            'I',                        // customerType
            'Test',                     // userDescription
            null                        // leadReferralName (explicit null)
        );
        Test.stopTest();

        Lead insertedLead = [
            SELECT Id, FirstName, LastName, Lead_Referral_Name__c
            FROM Lead
            WHERE Id = :leadId
        ];
        
        System.assertEquals('Test', insertedLead.FirstName, 'First name should match');
        System.assertEquals('User', insertedLead.LastName, 'Last name should match');
        System.assert(insertedLead.Lead_Referral_Name__c == null, 'Lead Referral Name should be null');
    }

    @IsTest
    static void testCreateLeadExceptionHandling() {
        // Test exception handling by passing invalid data
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
                null,    // userDescription
                null     // leadReferralName
            );
            System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            // Expected behavior
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }
}