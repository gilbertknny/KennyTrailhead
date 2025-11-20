@isTest
public class DueDateUkerCalculatorTriggerTest {
    @testSetup
    static void setupTestData() {
        // Insert mock holidays
        List<Holiday> holidays = new List<Holiday>();
        holidays.add(new Holiday(Name = 'Holiday1', ActivityDate = Date.newInstance(2024, 12, 25))); // Christmas
        holidays.add(new Holiday(Name = 'Holiday2', ActivityDate = Date.newInstance(2024, 12, 26))); // Day after Christmas
        insert holidays;
    }

    @isTest
    static void testValidDueDateCalculation() {
        // Insert a case with valid Tanggal_Surat_Keluar_ke_Uker__c and valid picklist value
        Case testCase = new Case(
            Tanggal_Surat_Keluar_ke_Uker__c = Date.newInstance(2024, 12, 20), // Friday
            Jumlah_hari_SLA_Regulator__c = '7' // Picklist value of 7 network days
        );
        insert testCase;

        // Validate the calculated Due_Date_Uker__c
        testCase = [SELECT Due_Date_Uker__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(Date.newInstance(2025, 01, 02), testCase.Due_Date_Uker__c, 
            'Due Date should exclude weekends and holidays and correctly calculate the target date.');
    }

    @isTest
    static void testNullStartDate() {
        // Insert a case with a null Tanggal_Surat_Keluar_ke_Uker__c
        Case testCase = new Case(
            Tanggal_Surat_Keluar_ke_Uker__c = null,
            Jumlah_hari_SLA_Regulator__c = '10' // Valid picklist value
        );

        insert testCase;

        // Validate that Due_Date_Uker__c is null
        testCase = [SELECT Due_Date_Uker__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, testCase.Due_Date_Uker__c, 
            'Due Date should be null when Tanggal_Surat_Keluar_ke_Uker__c is null.');
    }

    @isTest
    static void testNullPicklistValue() {
        // Insert a case with a null Jumlah_hari_SLA_Regulator__c
        Case testCase = new Case(
            Tanggal_Surat_Keluar_ke_Uker__c = Date.newInstance(2024, 12, 20), // Friday
            Jumlah_hari_SLA_Regulator__c = null
        );

        insert testCase;

        // Validate that Due_Date_Uker__c is null
        testCase = [SELECT Due_Date_Uker__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, testCase.Due_Date_Uker__c, 
            'Due Date should be null when Jumlah_hari_SLA_Regulator__c is null.');
    }

    @isTest
    static void testUpdateCase() {
        // Insert a case and then update it
        Case testCase = new Case(
            Tanggal_Surat_Keluar_ke_Uker__c = Date.newInstance(2024, 12, 20), // Friday
            Jumlah_hari_SLA_Regulator__c = '11' // Valid picklist value
        );
        insert testCase;

        // Update the case with a new Tanggal_Surat_Keluar_ke_Uker__c
        testCase.Tanggal_Surat_Keluar_ke_Uker__c = Date.newInstance(2024, 12, 23); // Monday
        update testCase;

        // Validate the updated Due_Date_Uker__c
        testCase = [SELECT Due_Date_Uker__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(Date.newInstance(2025, 01, 09), testCase.Due_Date_Uker__c, 
            'Due Date should be updated based on the new Tanggal_Surat_Keluar_ke_Uker__c.');
    }

    @isTest
    static void testInvalidPicklistValue() {
        // Attempt to insert a case with an invalid picklist value
        Case testCase = new Case(
            Tanggal_Surat_Keluar_ke_Uker__c = Date.newInstance(2025, 01, 01), 
            Jumlah_hari_SLA_Regulator__c = 'InvalidValue' // Invalid picklist value
        );

        Test.startTest();
        try {
            insert testCase;
            System.assert(false, 'Insert should have failed due to invalid picklist value.');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains('bad value for restricted picklist field'),
                'Expected error for invalid picklist value.');
        }
        Test.stopTest();
    }
}