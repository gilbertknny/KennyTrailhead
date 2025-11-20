@isTest
public with sharing class CustomLookupController_Test {
    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8812');
        insert ct;
   }
    
    @isTest
    static void testclass(){
        CustomLookupController.fetchRecords('SSC_Call_Type__c', 'Name', '8812', '');
    }
    @isTest
    static void TerminalID() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.TerminalIDResponse());
        CustomLookupController.getDataDetail('2024-01-01', '12345');
        test.stopTest();
    }

    @isTest
    static void TerminalIDList() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.TerminalIDListResponse());
        CustomLookupController.getListAPI('12345', '2024-01-01');
        test.stopTest();
    }
}