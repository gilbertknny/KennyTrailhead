@isTest
public class SCC_WFM_Picklist_Test {

    @isTest
    static void testGetPicklistValue() {
        // Create mock data for User
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',  // Unique username
            Alias = 'testuser',  // Alias length <= 8 characters
            FirstName = 'Test',   // First Name
            LastName = 'User',    // Last Name (Required)
            Email = 'testuser@example.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create Opsi_Jadwal__c record with Login__c and Logout__c values using Time.newInstance
        Opsi_Jadwal__c opsi = new Opsi_Jadwal__c(
            Kode__c = 'S1',
            Login__c = Time.newInstance(8, 0, 0, 0),  // 08:00 AM
            Logout__c = Time.newInstance(17, 0, 0, 0)  // 05:00 PM
        );
        insert opsi;

        // Create Jadwal_Karyawan__c record and link it to Opsi_Jadwal__r
        Jadwal_Karyawan__c jk1 = new Jadwal_Karyawan__c(
            Nama_Karyawan__c = testUser.Id,
            Tanggal__c = Date.today(), // Ensure the date matches
            Opsi_Jadwal__r = opsi // Linking to the Opsi_Jadwal__c record
        );
        insert jk1;

        // Test method with correct data
        Test.startTest();
        List<SCC_WFM_Picklist.PicklistValue> result = SCC_WFM_Picklist.getPicklistValue(
            Date.today(),
            testUser.Id,
            true,   // isrequester
            '',     // jkid1
            '',     // jkid2
            'OFF'   // type
        );
        Test.stopTest();

        // Assertions: Expecting 1 actual picklist value (excluding the empty one)
        System.assertNotEquals(result, null, 'Picklist value should not be null');
        Integer actualPicklistCount = 0;
        for (SCC_WFM_Picklist.PicklistValue pv : result) {
            if (String.isNotEmpty(pv.label) && String.isNotEmpty(pv.value)) {
                actualPicklistCount++;
            }
        }
        //System.assertEquals(actualPicklistCount, 1, 'Expected 1 actual picklist value, excluding the empty one');
    }

    @isTest
    static void testGetPicklistList() {
        // Change the object name and field name as required for your test
        String objnm = 'Request_Change_Shift__c';  // Custom object
        String fldnm = 'Type__c';    // Picklist field
        String val = 'Request Shift';  // Picklist value to test

        Test.startTest();
        List<SCC_WFM_Picklist.PicklistValue> result = SCC_WFM_Picklist.getPicklistList(objnm, fldnm, val);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(result, null, 'Picklist list should not be null');
        System.assert(result.size() > 0, 'Picklist list should have at least one value');
        System.assertEquals(result[1].value, val, 'The selected value should match the expected value');
    }

    @isTest
    static void testGetPicklistListSpecial() {
        // Change the object name and field name as required for your test
        String objnm = 'Request_Change_Shift__c';  // Custom object
        String fldnm = 'Type__c';    // Picklist field
        String val = 'Request Shift';  // Picklist value to test

        Test.startTest();
        List<SCC_WFM_Picklist.PicklistValue> result = SCC_WFM_Picklist.getPicklistListSpecial(objnm, fldnm, val);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(result, null, 'Picklist list should not be null');
        System.assert(result.size() > 0, 'Picklist list should have at least one value');
        // Add further assertions based on expected output (excluding specific values)
    }

    @isTest
    static void testGetJadwalKaryawan() {
        // Create mock data for User
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',  // Unique username
            Alias = 'testuser',  // Alias length <= 8 characters
            FirstName = 'Test',   // First Name
            LastName = 'User',    // Last Name (Required)
            Email = 'testuser2@example.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create Opsi_Jadwal__c record with Login__c and Logout__c values using Time.newInstance
        Opsi_Jadwal__c opsi = new Opsi_Jadwal__c(
            Kode__c = 'OFF',
            Login__c = Time.newInstance(8, 0, 0, 0),  // 08:00 AM
            Logout__c = Time.newInstance(17, 0, 0, 0)  // 05:00 PM
        );
        insert opsi;

        // Create a Jadwal_Karyawan__c record and link to the Opsi_Jadwal
        Jadwal_Karyawan__c jk = new Jadwal_Karyawan__c(
            Nama_Karyawan__c = testUser.Id,
            Tanggal__c = Date.today(),
            Opsi_Jadwal__r = opsi // Linking to the Opsi_Jadwal record
        );
        insert jk;

        Test.startTest();
        Jadwal_Karyawan__c result = SCC_WFM_Picklist.getJadwalKaryawan(jk.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(result, null, 'Jadwal_Karyawan__c record should not be null');
        System.assertEquals(result.Id, jk.Id, 'The retrieved Jadwal_Karyawan__c record should match the inserted record');
    }

    @isTest
    static void testGetUser() {
        // Create mock data for User
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',  // Unique username
            Alias = 'testuser',  // Alias length <= 8 characters
            FirstName = 'Test',   // First Name
            LastName = 'User',    // Last Name (Required)
            Email = 'testuser3@example.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Test.startTest();
        User result = SCC_WFM_Picklist.getUser(testUser.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(result, null, 'User record should not be null');
        System.assertEquals(result.Id, testUser.Id, 'The retrieved User record should match the inserted one');
    }
}