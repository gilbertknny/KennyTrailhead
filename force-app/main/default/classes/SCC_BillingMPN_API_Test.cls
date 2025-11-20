/**
 * @description       : 
 * @author            : Suherbing Septian
 * @created date      : 15-09-2025
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_BillingMPN_API_Test {
    @isTest
    static void searchBillingMPN() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BillingMPN_Mock.BillingMPN());
        SCC_BillingMPN_API.searchBillingMPN(Object_Test_MPN.billingMPNRequest(),'','Bricare','500MR000007z3maYAA');
        Test.stopTest();
    }

    @isTest
    static void testFailureFindRTGS() {
        Exception caughtException = null;

        Test.startTest();
        try {
            SCC_BillingMPN_API.searchBillingMPN(null,'','Bricare','500MR000007z3maYAA');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void testDummyLabel() {
        Test.startTest();
        SCC_BillingMPN_API.useDummyResponseInTest = true;
        SCC_BillingMPN_API.searchBillingMPN(Object_Test_MPN.billingMPNRequest(),'','Bricare','500MR000007z3maYAA');
        Test.stopTest();
    }
}