@isTest
public class DueDateUkerCalculatorTest {

    @testSetup
    static void setupHolidays() {
        // Insert holidays in a separate transaction to avoid MIXED_DML_OPERATION
        insert new List<Holiday>{
            new Holiday(ActivityDate = Date.newInstance(2024, 12, 25), Name = 'Christmas'),
            new Holiday(ActivityDate = Date.newInstance(2024, 12, 26), Name = 'Boxing Day')
        };
    }

    @isTest
    static void testCalculateDueDate() {
        // Create a Case record with valid picklist values
        Case testCase = new Case(
            Tanggal_Surat_Keluar_ke_Uker__c = Date.newInstance(2024, 12, 20),
            Jumlah_hari_SLA_Regulator__c = '7', // Use a valid picklist value
            Status = 'New',
            Origin = 'Email'
        );

        Test.startTest();
        insert testCase; // Insert the test case
        testCase = [SELECT Due_Date_Uker__c FROM Case WHERE Id = :testCase.Id];
        Test.stopTest();

        // Expected due date: 2024-12-30 (excluding weekends and holidays)
        Date expectedDueDate = Date.newInstance(2025, 1, 2);
        System.assertEquals(expectedDueDate, testCase.Due_Date_Uker__c, 'Due date calculation is incorrect.');
    }
}