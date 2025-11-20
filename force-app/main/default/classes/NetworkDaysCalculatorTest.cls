/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 12-30-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class NetworkDaysCalculatorTest {
    @testSetup
    static void setupData() {
        // Insert mock holidays
        Holiday h1 = new Holiday(Name = 'Mock Holiday 1', ActivityDate = Date.newInstance(2024, 12, 26));
        insert h1; // Add only 2024-12-26 as a holiday
    }

    @isTest
    static void testWithValidDates() {
        // Case with valid Tanggal_Pengaduan_Regulator__c and Tanggal_Tanggapan_ke_EMAIL_APPK__c
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 23),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 27)
        );
        insert testCase;

        Test.startTest();
        Test.stopTest();

        // Expected days: 24, 25, 27 (21, 22 are weekends; 26 is a holiday; 23 excluded as start date)
        testCase = [SELECT Id, SLA_Pelaporan2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(3, testCase.SLA_Pelaporan2__c, 
            'SLA Pelaporan2 should exclude start date, holidays, and weekends.');
    }

    @isTest
    static void testWithStartDateAfterEndDate() {
        // Case where Tanggal_Pengaduan_Regulator__c is after Tanggal_Tanggapan_ke_EMAIL_APPK__c
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 28),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 23)
        );
        insert testCase;

        Test.startTest();
        Test.stopTest();

        // Expect SLA_Pelaporan2 to be 0 since start date is after end date
        testCase = [SELECT Id,SLA_Pelaporan2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(0, testCase.SLA_Pelaporan2__c, 
            'SLA Pelaporan2 should be 0 if start date is after end date.');
    }

    @isTest
    static void testWithNullDates() {
        // Case with null dates
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = null,
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = null
        );
        insert testCase;

        Test.startTest();
        Test.stopTest();

        // Expect SLA_Pelaporan2 to be null since both dates are null
        testCase = [SELECT Id, SLA_Pelaporan2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, testCase.SLA_Pelaporan2__c, 
            'SLA Pelaporan2 should be null when dates are null.');
    }

    @isTest
    static void testWithHolidayAndWeekend() {
        // Case with valid dates including a holiday and weekends
        Case testCase = new Case(
            Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 20),
            Tanggal_Tanggapan_ke_EMAIL_APPK__c = Date.newInstance(2024, 12, 27)
        );
        insert testCase;

        Test.startTest();
        Test.stopTest();

        // Expected days: 23, 24, 25, 27 (20 is Friday; 21-22 are weekends; 26 is a holiday; 20 excluded as start date)
        testCase = [SELECT Id, SLA_Pelaporan2__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(4, testCase.SLA_Pelaporan2__c, 
            'SLA Pelaporan2 should exclude start date, holidays, and weekends.');
    }
}