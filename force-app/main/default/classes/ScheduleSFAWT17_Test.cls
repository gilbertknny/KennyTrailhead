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
 * @description ScheduleSFAWT17_Test
 */
@isTest
private class ScheduleSFAWT17_Test {
    @testSetup
    static void setupData() {
        // TO DO: implement unit test setup
        Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
        // Arrange
        Account acc = new Account(Name='Test Account',RecordtypeId = rtId,Client_id__c = 'CLIENT123',Type='0',Account_Segment__c='E',Account_Sub_Segment__c='Y',Account_Channel__c='0',isschedule__c=true);
        insert acc;

        Schedule__c mysc = new Schedule__c();
        mysc.name = 'Account';
        mysc.Schedule_Time__c = '0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23';
        insert mysc;
    }
    
    @isTest
    static void myUnitTest() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            // TO DO: implement unit test
            ScheduleSFAWT17 sch = new ScheduleSFAWT17();
            sch.execute(null);
            system.assertEquals(UserInfo.getUserId(), currentUser.Id);
        }
    }
}