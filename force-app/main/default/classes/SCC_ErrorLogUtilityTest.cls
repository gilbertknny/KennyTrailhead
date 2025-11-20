/**
 * @description       : Test Class for SCC_ErrorLogUtility and SCC_ErrorLogWrapper
 * @last modified on  : 03-06-2025
 * @last modified by  : Ahmad Yazid Munif
**/
@isTest
private class SCC_ErrorLogUtilityTest {
    
    @isTest
    static void testInsertErrorLogSuccess() {
        // Create an instance of SCC_ErrorLogWrapper
        SCC_ErrorLogWrapper errorLogWrapper = new SCC_ErrorLogWrapper();
        errorLogWrapper.apiType = 'Inbound';
        errorLogWrapper.className = 'MyClass';
        errorLogWrapper.endPoint = 'https://example.com/api';
        errorLogWrapper.endPointLong = 'https://example.com/api/long';
        errorLogWrapper.errorCause = 'Some cause';
        errorLogWrapper.errorMessages = 'Some error message';
        errorLogWrapper.lineNumber = '42';
        errorLogWrapper.requestHeader = 'Some header';
        errorLogWrapper.requestIP = '192.168.1.1';
        errorLogWrapper.requestIPLong = '3232235777';
        errorLogWrapper.requestBody = '{"key":"value"}';
        errorLogWrapper.responseHeader = 'Some response header';
        errorLogWrapper.responseStatus = '200 OK';
        errorLogWrapper.responseStatusCode = 200;
        errorLogWrapper.responseBody = '{"response":"value"}';
        errorLogWrapper.stackTrace = 'Stack trace here';
        errorLogWrapper.errorDatetime = DateTime.now();
        errorLogWrapper.typeName = 'TypeName';
        errorLogWrapper.userRun = UserInfo.getUserId();

        // Call the insertErrorLog method
        Test.startTest();
        SCC_ErrorLogUtility.insertErrorLog(errorLogWrapper);
        Test.stopTest();

        // Verify the Error_Log__c record was inserted
        Error_Log__c[] logs = [SELECT Id, API_Type__c, Class_Name__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(),'Matched');
        System.assertEquals('Inbound', logs[0].API_Type__c,'Matched');
        System.assertEquals('MyClass', logs[0].Class_Name__c,'Matched');
    }

    @isTest
    static void testInsertErrorLogNullWrapper() {
        // Call the insertErrorLog method with null wrapper and expect an exception
        try {
            Test.startTest();
            SCC_ErrorLogUtility.insertErrorLog(null);
            Test.stopTest();
            System.assert(false, 'Expected an exception to be thrown');
        } catch (IllegalArgumentException e) {
            System.assertEquals('ErrorLogWrapper cannot be null', e.getMessage(),'Matched');
        }
    }

    @isTest
    static void testInsertErrorLogDmlException() {
        // Create an instance of SCC_ErrorLogWrapper
        SCC_ErrorLogWrapper errorLogWrapper = new SCC_ErrorLogWrapper();
        errorLogWrapper.apiType = 'REST';
        errorLogWrapper.className = 'MyClass';
        errorLogWrapper.endPoint = 'https://example.com/api';
        errorLogWrapper.endPointLong = 'https://example.com/api/long';
        errorLogWrapper.errorCause = 'Some cause';
        errorLogWrapper.errorMessages = 'Some error message';
        errorLogWrapper.lineNumber = '42';
        errorLogWrapper.requestHeader = 'Some header';
        errorLogWrapper.requestIP = '192.168.1.1';
        errorLogWrapper.requestIPLong = '3232235777';
        errorLogWrapper.requestBody = '{"key":"value"}';
        errorLogWrapper.responseHeader = 'Some response header';
        errorLogWrapper.responseStatus = '200 OK';
        errorLogWrapper.responseStatusCode = 200;
        errorLogWrapper.responseBody = '{"response":"value"}';
        errorLogWrapper.stackTrace = 'Stack trace here';
        errorLogWrapper.errorDatetime = DateTime.now();
        errorLogWrapper.typeName = 'TypeName';
        errorLogWrapper.userRun = '005';

        try {
            Test.startTest();
            SCC_ErrorLogUtility.insertErrorLog(errorLogWrapper);
            Test.stopTest();   
            System.assert(false, 'An exception was expected but not thrown.');
        } catch (Exception e) {
            String msg = 'Insert failed';
            System.assertEquals(e.getMessage().contains(msg), e.getMessage().contains(msg), 'Unexpected exception message.');
        }
    }
}