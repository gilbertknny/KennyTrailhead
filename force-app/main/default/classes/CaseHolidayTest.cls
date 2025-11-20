@isTest
public class CaseHolidayTest {
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
    static void testHoliday() {
        List<Case> caseList = [SELECT Id, Holiday__c FROM Case];
        
        System.assertNotEquals(null, caseList[0].Holiday__c);
        System.assertNotEquals(null, caseList[1].Holiday__c);
    }

    @isTest
    static void testSchedule() {
        ScheduleHoliday_APPK sch = new ScheduleHoliday_APPK();
        sch.execute(null);
        BatchHoliday_APPK.insertErrorLog(null);
    }
    
    @isTest
    static void testSetStartDate() {
        // Get a business hours record
        BusinessHours bh = [SELECT Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, 
                           MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                           WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                           FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime 
                           FROM BusinessHours WHERE IsActive = true LIMIT 1];
        
        // Create test times
        Time jammasuk = Time.newInstance(9, 0, 0, 0);
        Time jampulang = Time.newInstance(17, 0, 0, 0);
        
        Test.startTest();
        
        // Test case 1: DateTime before business hours
        DateTime beforeHours = DateTime.newInstance(Date.today(), Time.newInstance(7, 0, 0, 0));
        DateTime adjustedBeforeHours = CaseHolidayTriggerHandler.setstardate(beforeHours, bh, jammasuk, jampulang);
        System.assertEquals(DateTime.newInstance(Date.today(), jammasuk), adjustedBeforeHours, 
                          'DateTime before business hours should be adjusted to start of business hours');
        
        // Test case 2: DateTime within business hours
        DateTime withinHours = DateTime.newInstance(Date.today(), Time.newInstance(12, 0, 0, 0));
        DateTime adjustedWithinHours = CaseHolidayTriggerHandler.setstardate(withinHours, bh, jammasuk, jampulang);
        System.assertEquals(withinHours, adjustedWithinHours, 
                          'DateTime within business hours should remain unchanged');
        
        // Test case 3: DateTime after business hours
        DateTime afterHours = DateTime.newInstance(Date.today(), Time.newInstance(19, 0, 0, 0));
        DateTime adjustedAfterHours = CaseHolidayTriggerHandler.setstardate(afterHours, bh, jammasuk, jampulang);
        System.assertEquals(DateTime.newInstance(Date.today().addDays(1), jammasuk), adjustedAfterHours, 
                          'DateTime after business hours should be adjusted to next day start of business hours');
        
        Test.stopTest();
    }
}