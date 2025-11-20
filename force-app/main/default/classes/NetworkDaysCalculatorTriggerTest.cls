@isTest
public class NetworkDaysCalculatorTriggerTest {

    @isTest
    static void testWithStartAndEndDate() {
        // Create a case record with both start and end dates
        Case caseWithDates = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 1, 1),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 1, 15)
        );
        insert caseWithDates;

        // Retrieve the inserted record to check the calculated value
        Case insertedCase = [SELECT SLA_Pelaporan2__c FROM Case WHERE Id = :caseWithDates.Id];
        System.assertNotEquals(null, insertedCase.SLA_Pelaporan2__c, 'SLA_Pelaporan2__c should be calculated');
    }

    @isTest
    static void testWithStartDateOnly() {
        // Create a case record with only start date
        Case caseWithStartDateOnly = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 1, 1)
        );
        insert caseWithStartDateOnly;

        // Retrieve the inserted record to check the calculated value using today's date
        Case insertedCase = [SELECT SLA_Pelaporan2__c FROM Case WHERE Id = :caseWithStartDateOnly.Id];
        System.assertNotEquals(null, insertedCase.SLA_Pelaporan2__c, 'SLA_Pelaporan2__c should be calculated using today\'s date');
    }

    @isTest
    static void testWithNullStartDate() {
        // Create a case record without start date
        Case caseWithNullStartDate = new Case();
        insert caseWithNullStartDate;

        // Retrieve the inserted record to check that SLA_Pelaporan2__c is null
        Case insertedCase = [SELECT SLA_Pelaporan2__c FROM Case WHERE Id = :caseWithNullStartDate.Id];
        System.assertEquals(null, insertedCase.SLA_Pelaporan2__c, 'SLA_Pelaporan2__c should be null if start date is null');
    }
}