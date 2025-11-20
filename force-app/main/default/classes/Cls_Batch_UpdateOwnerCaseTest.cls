@isTest
private class Cls_Batch_UpdateOwnerCaseTest {
	@testSetup static void setup(){
        Account acc = new Account();
        acc.LastName = 'Test';
        insert acc;
        
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.Description = 'Test';
        cs.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs.AccountId = acc.Id;
        cs.SCC_Cust_Phone1__c = '081234567890';
        cs.Cust_Current_Phone__c = '081234567890';
        cs.SCC_Amount__c = 1000000;
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SSC_Call_Type_Description__c = 'Test';
        insert cs;
    }
    
    static testMethod void testProcess(){
        List<Case> listdata = [SELECT Id FROM Case];
        Test.startTest();
		Cls_Batch_UpdateOwnerCase b = new Cls_Batch_UpdateOwnerCase(listdata);
		database.executebatch(b,200);
		Test.stopTest();
    }
}