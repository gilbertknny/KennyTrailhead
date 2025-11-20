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
 * 
 * @description       : CASA Test Class
 * @author            : Femy
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 */
@isTest
public with sharing class SCC_CASA_Test {
    @TestSetup
    static void setupDate(){
        //Insert custom settings record
        insert new Brimo__c(
            Name= 'extidCasaHold',
            request_refnum__c  = 0
        );
        insert new Brimo__c(
            Name= 'extidCasaUnhold',
            request_refnum__c  = 0
        );
    }
    @isTest
    static void holdAmount() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CASAMock.ResponseHoldAmount());
        SCC_CASA_Wrapper.RequestHoldAmount req = Object_Test2.setRequestHoldAmount();
        SCC_CASA.holdAmount(req.request,'System',userinfo.getUserId());
        Test.stopTest();
    }

    @isTest
    static void unholdAmount() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CASAMock.ResponseUnholdAmount());
        SCC_CASA_Wrapper.RequestUnholdAmount req = Object_Test2.setRequestUnholdAmount();
        SCC_CASA.unholdAmount(req.request,'System',userinfo.getUserId());
        Test.stopTest();
    }
}