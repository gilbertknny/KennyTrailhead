@isTest
public class SCC_Channel_Test {
    @testSetup static void setup(){
        SSC_Call_Type__c callType = new SSC_Call_Type__c();
        callType.Active__c = true;
        callType.Name = '8222';
        callType.SCC_Customer_Segment__c = 'Individu Umum';
        callType.SSC_Product_L1__c = 'Transaction Banking';
        callType.SSC_Product_L2__c = 'Transaction Solution';
        callType.SSC_Case_Category__c = 'Complaint - Transaction';
        callType.SSC_Case_Description__c = 'Nasabah Komplain Transaksi Rtgs Melalui E-Channel';
        callType.Send_to_Drone__c = true;
        callType.SCC_Agent_SLA__c = 1;
        callType.SCC_Level1_OLA__c = 3;
        callType.SCC_Level1_Escalation_team__c = 'SCC - Non Fraud Transaction - ISSUER';
        insert callType;
        
        Account acc = new Account(LastName = 'Test');
        insert acc;
        
        Case cs = new Case();
        cs.Subject = 'CC Maker owned Case';
        cs.Description = 'Test';
        cs.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs.AccountId = acc.Id;
        cs.SCC_Cust_Phone1__c = '081234567890';
        cs.Cust_Current_Phone__c = '081234567890';
        cs.SCC_Amount__c = 1000000;
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SSC_Call_Type_Description__c = 'Test';
        cs.SCC_Call_Type__c = callType.Id;
        cs.SCC_Terminal_ID__c = '000000';
        cs.SCC_Transaction_Date__c = System.Today();
        insert cs;
    }
    @IsTest
    static void testCaseEscalation(){
        Case cs = [SELECT Id FROM Case limit 1];
        Test.startTest();
        System.enqueueJob(new SCC_Channel(cs.Id, 'Escalation'));
        Test.stopTest();
    }
    @IsTest
    static void testSendToDrone(){
        Case cs = [SELECT Id FROM Case limit 1];
        Test.startTest();
        System.enqueueJob(new SCC_Channel(cs.Id, 'Send To Drone'));
        Test.stopTest();
    }
}