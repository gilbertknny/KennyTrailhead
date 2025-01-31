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
        caseList.add(new Case(SCC_Call_Type__c = callType.Id, CreatedDate = DateTime.now().addDays(-10)));
        caseList.add(new Case(SCC_Call_Type__c = callType.Id, CreatedDate = DateTime.now().addDays(-30), ClosedDate = DateTime.now().addDays(-5), Status = 'Closed'));
        insert caseList;
    }
    
    @isTest
    static void testHoliday() {
        List<Case> caseList = [SELECT Id, Holiday__c FROM Case];
        
        System.assertNotEquals(null, caseList[0].Holiday__c);
        System.assertNotEquals(null, caseList[1].Holiday__c);
    }
}