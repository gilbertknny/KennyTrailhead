@isTest
public class NetworkDaysSLARegulatorCalculatorTest {
    @isTest
    static void testWithHolidayAndWeekend() {
        // Step 1: Create a user for setup DML
        User user = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        // Step 2: Insert holiday records inside a System.runAs block
        System.runAs(user) {
            List<Holiday> holidays = new List<Holiday>();
            holidays.add(new Holiday(Name = 'Natal 2024 Test', ActivityDate = Date.newInstance(2024, 12, 22))); // Unique Name
            holidays.add(new Holiday(Name = 'Cuti Bersama Natal 2024 Test', ActivityDate = Date.newInstance(2024, 12, 26))); // Unique Name
            insert holidays;
        }

        // Step 3: Create a case with start and end dates
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 23),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 27),
            Subject = 'Test Case for SLA Calculation' // Required field
        );
        insert testCase;

        // Step 4: Execute the trigger by querying the updated case
        Test.startTest();
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        Test.stopTest();

        // Step 5: Assert the SLA Regulator value
        Integer expectedDays = 3; // 23 (working), 24 (working), 27 (working); excludes 22 (holiday) and 26 (holiday)
        System.assertEquals(expectedDays, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator should exclude holidays and weekends.');
    }

    @isTest
    static void testWithStartDateAfterEndDate() {
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 28),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 27),
            Subject = 'Invalid Date Case' // Required field
        );
        insert testCase;

        Test.startTest();
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        Test.stopTest();

        System.assertEquals(null, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator should be null if start date is after end date.');
    }

    @isTest
    static void testWithNullDates() {
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = null,
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = null,
            Subject = 'Null Dates Case' // Required field
        );
        insert testCase;

        Test.startTest();
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        Test.stopTest();

        System.assertEquals(null, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator should be null if both dates are null.');
    }
}