@isTest
private class SCC_IntegrationUtilityTest {

    @isTest
    static void testNormal() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('VarTest6', '123456789');
        params.put('VarTest.Seven', '987654321');
        params.put('VarTest.Seven.Eight', '67364');
        String response = SCC_IntegrationUtility.sendData('For_Test_Class', params);
    }

    @isTest
    static void withMock() {
        Test.setMock(HttpCalloutMock.class, new SCC_IntegrationUtilityMock());

        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        params.put('VarTest6', '123456789');
        params.put('VarTest.Seven', '987654321');
        params.put('VarTest.Seven.Eight', '67364');
        String response = SCC_IntegrationUtility.sendData('For_Test_Class', params);
        Test.stopTest();
    }

    @isTest
    static void testInTestMode() {
        Map<String, Object> params = new Map<String, Object>();
        String response = SCC_IntegrationUtility.sendData('For_Test_Class_1', params);
    }
}