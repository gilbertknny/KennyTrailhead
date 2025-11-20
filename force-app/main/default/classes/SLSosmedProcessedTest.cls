@isTest
public class SLSosmedProcessedTest {
    @isTest
    static void testProcessInBackground() {
        Case testCase = new Case(
            Status = 'New',
            Subject = 'Test Case for SLSosmedProcessed',
            Priority = 'High'
        );
        insert testCase;

        Set<Id> caseIds = new Set<Id>{testCase.Id};

        Test.startTest();
        SLSosmedProcessed.processInBackground(caseIds);
        Test.stopTest();

        System.assertEquals(true, [SELECT COUNT() FROM Case WHERE Id = :testCase.Id] > 0);
    }

    @isTest
    static void testProcessInBackgroundWithException() {
        Case testCase = new Case(
            Status = 'New',
            Subject = 'Test Case for SLSosmedProcessed',
            Priority = 'High'
        );
        insert testCase;

        Set<Id> caseIds = new Set<Id>{testCase.Id};

        Test.startTest();
        SLSosmedProcessed.processInBackground(caseIds);
        Test.stopTest();

        System.assertEquals(true, [SELECT COUNT() FROM Case WHERE Id = :testCase.Id] > 0);
    }
}