@isTest
public class NetworkDaysSLARegulatorCalcTriggerTest {
    
    @testSetup
    static void setupTestData() {
        // Insert mock holidays
        List<Holiday> holidays = new List<Holiday>();
        holidays.add(new Holiday(Name = 'Holiday1', ActivityDate = Date.newInstance(2024, 12, 25))); // Christmas
        holidays.add(new Holiday(Name = 'Holiday2', ActivityDate = Date.newInstance(2024, 12, 26))); // Day after Christmas
        insert holidays;
    }

    @isTest
    static void testValidDates() {
        // Case with valid Tanggal_Pengaduan_Regulator__c and Tanggal_Tanggapan_ke_EMAIL_APPK__c
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 23),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 29)
        );
        insert testCase;

        // Assert Menghitung_SLA_Regulator2__c calculation
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        // Expected days: 24, 27, 28 (25-26 are holidays, 21-22 are weekends)
        System.assertEquals(2, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator2 should exclude holidays and weekends.');
    }

    @isTest
    static void testNullStartDate() {
        // Case where Tanggal_Pengaduan_Regulator__c is null
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = null,
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 30)
        );
        insert testCase;

        // Assert Menghitung_SLA_Regulator2__c is null
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator2 should be null when Tanggal_Pengaduan_Regulator__c is null.');
    }

    @isTest
    static void testNullEndDate() {
        // Case where Tanggal_Tanggapan_ke_EMAIL_APPK__c is null
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 23),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = null
        );
        insert testCase;

        // Assert Menghitung_SLA_Regulator2__c is null
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator2 should be null when Tanggal_Tanggapan_ke_EMAIL_APPK__c is null.');
    }

    @isTest
    static void testStartDateAfterEndDate() {
        // Case where Tanggal_Pengaduan_Regulator__c is after Tanggal_Tanggapan_ke_EMAIL_APPK__c
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 30),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 23)
        );
        insert testCase;

        // Assert Menghitung_SLA_Regulator2__c is null
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator2 should be 0 when start date is after end date.');
    }

    @isTest
    static void testUpdateCase() {
        // Insert a case and then update it
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 20), // Friday
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 27) // Friday
        );
        insert testCase;

        // Update the case with a new end date
        testCase.Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 30); // Monday
        update testCase;

        // Assert updated Menghitung_SLA_Regulator2__c
        testCase = [SELECT Menghitung_SLA_Regulator2__c FROM Case WHERE Id = :testCase.Id];
        // Expected days: 23, 24, 27, 28, 29, 30 (25-26 are holidays, 21-22 are weekends)
        System.assertEquals(4, testCase.Menghitung_SLA_Regulator2__c, 
            'Menghitung SLA Regulator2 should be updated based on the new end date.');
    }
}