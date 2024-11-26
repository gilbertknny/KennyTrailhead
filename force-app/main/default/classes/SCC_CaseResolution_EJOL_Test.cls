@istest
public with sharing class SCC_CaseResolution_EJOL_Test {
    @isTest
    static void searchEJ() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_EJOLMock.EJOL());
        SCC_CaseResolution_EJOL.searchEJ(Object_Test.EJLogRequest());
        Test.stopTest();
    }

    @isTest
    static void searchEJFailed() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_EJOLMock.EJOLFailed());
        SCC_CaseResolution_EJOL.searchEJ(Object_Test.EJLogRequest());
        Test.stopTest();
    }

    @isTest
    static void searchEJError() {
        // TO DO: implement unit test
        Test.startTest();
        SCC_CaseResolution_EJOL.searchEJ(Object_Test.EJLogRequest());
        Test.stopTest();
    }
}