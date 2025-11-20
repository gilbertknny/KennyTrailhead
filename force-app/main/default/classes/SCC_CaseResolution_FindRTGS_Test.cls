/**
 * @description       : 
 * @author            : Suherbing Septian
 * @created date      : 15-09-2025
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_CaseResolution_FindRTGS_Test {
    @isTest
    static void FindRTGS() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_FindRTGSMock.FindRTGS());
        SCC_CaseResolution_FindRTGS.searchRTGS(Object_Test_RTGS.findRTGSRequest(),'Bricare','500MR000007z3maYAA');
        Test.stopTest();
    }

    @isTest
    static void testFailureFindRTGS() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_CaseResolution_FindRTGS.searchRTGS(null,'Bricare','500MR000007z3maYAA');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testDummyLabel() {
        Test.startTest();
        SCC_CaseResolution_FindRTGS.useDummyResponseInTest = true;
        SCC_CaseResolution_FindRTGS.searchRTGS(Object_Test_RTGS.findRTGSRequest(),'Bricare','500MR000007z3maYAA');
        Test.stopTest();
    }
}