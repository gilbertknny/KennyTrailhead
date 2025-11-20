/**
 * @description       : 
 * @author            : Suherbing Septian
 * @created date      : 15-09-2025
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_PartnerTrxHistory_Test {
    @isTest
    static void searchPtrTrxHistory() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_PartnerTrxHistory_Mock.PartnerTrxHistory());
        SCC_Brizzi_PartnerTrxHistory.searchPtrTrxHistory(Object_Test_Brizzi.ptrTrxHistoryRequest(),'Resolution Center','500MR000007z3maYAA');
        Test.stopTest();
    }

    @isTest
    static void testFailuresearchCard() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_Brizzi_PartnerTrxHistory.searchPtrTrxHistory(null,'Bricare','500MR000007z3maYAA');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testDummyLabel() {
        Test.startTest();
        SCC_Brizzi_PartnerTrxHistory.useDummyResponseInTest = true;
        SCC_Brizzi_PartnerTrxHistory.searchPtrTrxHistory(Object_Test_Brizzi.ptrTrxHistoryRequest(),'Resolution Center','500MR000007z3maYAA');
        Test.stopTest();
    }
}