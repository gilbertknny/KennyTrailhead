@isTest
public class Sch_SendToDroneTest {
	@testSetup static void setup(){
        Account acc = new Account();
        acc.LastName = 'Test';
        insert acc;
        
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.Description = 'Test';
        cs.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs.AccountId = acc.Id;
        cs.SCC_Cust_Phone1__c = '123456789012';
        cs.SCC_Amount__c = 1000000;
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SSC_Call_Type_Description__c = 'Test';
        insert cs;      
        
        Drone__c d = new Drone__c();
        d.Case__c = cs.Id;
        d.Status__c = 'Draft';
        d.Method__c = 'Insert';
        insert d;
        
        Drone__c d2 = new Drone__c();
        d2.Case__c = cs.Id;
        d2.Status__c = 'Draft';
        d2.Method__c = 'Update';
        insert d2;
    }
    
    static testMethod void testProcess(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        SCC_InvocableDrone.Invocablevoid(null);
        SCC_InvocableDrone.createTicketDrone(cs.Id);
        SCC_InvocableDrone.updateTicketDrone(cs.Id);
        
        Test.setMock(HttpCalloutMock.class, new Cls_HttpMockTest());
        Test.startTest();
        system.schedule('Send To Drone 0', '0 0 * * * ?', new Sch_SendToDrone());
        Test.stopTest();
    }
}