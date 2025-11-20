/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Schedule_Batch_Holiday_APPK_test {
    @testSetup
    static void setup() {
        // Use an existing Business Hours for testing
        BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        
        if (defaultBH == null) {
            System.assert(false, 'Default Business Hours must exist for this test.');
        }

        // Ensure Holidays already exist for testing (assumes existing holidays in the org)
        List<Holiday> holidays = [SELECT Id FROM Holiday LIMIT 3];
        if (holidays.isEmpty()) {
            System.assert(false, 'At least 3 holidays must exist for this test. Please ensure holidays are created.');
        }
        
        SSC_Call_Type__c callType = Object_Test.setCallType('1703');
        insert callType;
        
        System.assertNotEquals(callType, null, 'An existing SSC_Call_Type__c record should be available.');

        // Create test Cases
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(SCC_Call_Type__c = callType.Id, CreatedDate = DateTime.now().addDays(-10), Tanggal_Pengaduan_Regulator__c = system.today().adddays(1),Tanggal_Tanggapan_ke_EMAIL_APPK__c = system.today().adddays(1),Tanggal_Surat_Keluar_ke_Uker__c = system.today().adddays(1),Jumlah_hari_SLA_Regulator__c='7'));
        caseList.add(new Case(SCC_Call_Type__c = callType.Id, CreatedDate = DateTime.now().addDays(-30), ClosedDate = DateTime.now().addDays(-5), Status = 'Closed'));
        insert caseList;
    }

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        ScheduleHoliday_APPK sc = new ScheduleHoliday_APPK();
        sc.execute(null);
    }

    @isTest
    static void myUnitTestError() {
        // TO DO: implement unit test
        BatchHoliday_APPK.insertErrorLog(null);
    }
}