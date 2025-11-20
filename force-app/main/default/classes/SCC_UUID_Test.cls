@isTest
private class SCC_UUID_Test {

    @isTest
    static void testSerializeAndDebug() {
        Case testCase = new Case(
            SCC_UUID__c = 'Test 1, Test 2');
        insert testCase;
        Test.startTest();
        SCC_UUID.serializeAndDebug(testCase.Id);
        Test.stopTest();
    }
}