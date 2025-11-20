/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCC_Brimo_Test {
	@TestSetup
    static void setupDate(){
        //Insert custom settings record
        insert new Brimo__c(
            Name= 'delete user brimo',
            request_refnum__c  = 0
        );
        insert new Brimo__c(
            Name= 'inquiry user brimo',
            request_refnum__c  = 0
        );
        insert new Brimo__c(
            Name= 'inquiry onboarding brimo',
            request_refnum__c  = 0
        );
    }
    
    @isTest
    static void searchUserBrimo() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BrimoMock.ResponseInquiryUserBrimo());
        SCC_Brimo.searchUserBrimo(Object_Test2.setRequestBrimo(),'System','');
        Test.stopTest();
    }

    @isTest
    static void searchOnboardingBrimo() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BrimoMock.ResponseInquiryOnboardingBrimo());
        SCC_Brimo.searchOnboardingBrimo(Object_Test2.setRequestBrimo(),'System','');
        Test.stopTest();
    }

    @isTest
    static void deleteUserBrimo() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BrimoMock.ResponseDeleteUserBrimo());
        SCC_Brimo.deleteUserBrimo(Object_Test2.setRequestBrimo(),'System','');
        Test.stopTest();
    }
}