@isTest
public class DueDatePICCalculatorTest {
    @isTest
    static void testCalculateDueDateComprehensive() {
        // Case 1: Regular scenario with no holidays
        Date startDate = Date.newInstance(2024, 12, 26); // Thursday
        Integer numNetworkDays = 3;
        Set<Date> holidays = new Set<Date>();
        Date result = DueDatePICCalculator.calculateDueDate(startDate, numNetworkDays, holidays);
        System.assertEquals(Date.newInstance(2024, 12, 31), result, 'Regular scenario failed.');

        // Case 2: Single holiday during the period
        holidays.add(Date.newInstance(2024, 12, 30)); // Monday is a holiday
        result = DueDatePICCalculator.calculateDueDate(startDate, numNetworkDays, holidays);
        System.assertEquals(Date.newInstance(2025, 1, 1), result, 'Single holiday scenario failed.');

        // Case 3: Start date is a weekend
        startDate = Date.newInstance(2024, 12, 28); // Saturday
        result = DueDatePICCalculator.calculateDueDate(startDate, numNetworkDays, holidays);
        System.assertEquals(Date.newInstance(2025, 1, 2), result, 'Start date on weekend failed.');

        // Case 4: Start date is a holiday
        startDate = Date.newInstance(2024, 12, 30); // Holiday
        result = DueDatePICCalculator.calculateDueDate(startDate, numNetworkDays, holidays);
        System.assertEquals(Date.newInstance(2025, 1, 2), result, 'Start date on holiday failed.');

        // Case 5: Very large numNetworkDays
        startDate = Date.newInstance(2024, 12, 1); // Sunday
        holidays.clear();
        holidays.add(Date.newInstance(2024, 12, 25)); // Christmas
        result = DueDatePICCalculator.calculateDueDate(startDate, 20, holidays);
        System.assertEquals(Date.newInstance(2024, 12, 30), result, 'Large numNetworkDays failed.');

        // Case 6: No working days (all are holidays)
        holidays.clear();
        holidays.addAll(new Set<Date>{
            Date.newInstance(2024, 12, 2),
            Date.newInstance(2024, 12, 3),
            Date.newInstance(2024, 12, 4)
        });
        startDate = Date.newInstance(2024, 12, 1); // Sunday
        result = DueDatePICCalculator.calculateDueDate(startDate, 1, holidays);
        System.assertEquals(Date.newInstance(2024, 12, 5), result, 'No working days failed.');

        // Case 7: Leap year (Feb 29 handling)
        holidays.clear();
        startDate = Date.newInstance(2024, 2, 28); // Thursday (Leap year)
        result = DueDatePICCalculator.calculateDueDate(startDate, 2, holidays);
        System.assertEquals(Date.newInstance(2024, 3, 1), result, 'Leap year handling failed.');

        // Case 8: No holidays and start on a weekend
        holidays.clear();
        startDate = Date.newInstance(2024, 12, 28); // Saturday
        result = DueDatePICCalculator.calculateDueDate(startDate, 1, holidays);
        System.assertEquals(Date.newInstance(2024, 12, 30), result, 'Start on weekend failed.');

        // Case 9: All days are holidays
        holidays.addAll(new Set<Date>{
            Date.newInstance(2024, 12, 29),
            Date.newInstance(2024, 12, 30),
            Date.newInstance(2024, 12, 31),
            Date.newInstance(2025, 1, 1),
            Date.newInstance(2025, 1, 2)
        });
        startDate = Date.newInstance(2024, 12, 28); // Saturday
        result = DueDatePICCalculator.calculateDueDate(startDate, 1, holidays);
        System.assertEquals(Date.newInstance(2025, 1, 3), result, 'All days are holidays failed.');

        // Case 10: Invalid inputs
        System.assertEquals(null, DueDatePICCalculator.calculateDueDate(null, 3, holidays), 'Null start date failed.');
        System.assertEquals(null, DueDatePICCalculator.calculateDueDate(startDate, null, holidays), 'Null numNetworkDays failed.');
        System.assertEquals(null, DueDatePICCalculator.calculateDueDate(startDate, 0, holidays), 'Zero numNetworkDays failed.');
        System.assertEquals(null, DueDatePICCalculator.calculateDueDate(startDate, -1, holidays), 'Negative numNetworkDays failed.');

        // Case 11: Validate isWeekend method indirectly
        startDate = Date.newInstance(2024, 12, 28); // Saturday
        holidays.clear();
        result = DueDatePICCalculator.calculateDueDate(startDate, 1, holidays);
        System.assertEquals(Date.newInstance(2024, 12, 30), result, 'Should skip Saturday (weekend) and return the next valid date.');

        startDate = Date.newInstance(2024, 12, 29); // Sunday
        result = DueDatePICCalculator.calculateDueDate(startDate, 1, holidays);
        System.assertEquals(Date.newInstance(2024, 12, 30), result, 'Should skip Sunday (weekend) and return the next valid date.');
    }
    
    @isTest
static void testDueDatePICCalculatorTrigger_HolidayInsert() {
    // Insert a holiday record to simulate holidays in the system
    Holiday holiday = new Holiday(
        Name = 'Christmas',  // Add Name if required
        ActivityDate = Date.newInstance(2024, 12, 25)
    );
    
    insert holiday; // Insert holiday (setup object)
}

@isTest
static void testDueDatePICCalculatorTrigger_CaseInsert() {
    // Start a new test context to avoid mixed DML operation error
    Test.startTest();
    
    // Now insert the case record (non-setup object) after Holiday has been inserted
    Case testCase = new Case(
        Tanggal_Pengaduan_Regulator__c = Date.newInstance(2024, 12, 28), // Saturday
        Jumlah_hari_SLA_Regulator__c = '7' // Use a valid picklist value like 'Seven'
    );
    
    insert testCase; // Insert case (non-setup object)
    
    Test.stopTest();
    
    // Retrieve the inserted case to check the Due Date
    testCase = [SELECT Due_Date_PIC__c FROM Case WHERE Id = :testCase.Id];

    // Assert that the Due Date is correctly calculated, skipping the weekend and the holiday
    System.assertEquals(Date.newInstance(2025, 01, 07), testCase.Due_Date_PIC__c, 'Due date calculation is incorrect.');
}


}