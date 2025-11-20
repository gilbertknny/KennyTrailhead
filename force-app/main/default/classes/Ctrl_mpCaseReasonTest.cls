@isTest
public class Ctrl_mpCaseReasonTest {
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
        callType.External_Id__c = '8222';
        insert callType;
        
        Case cs = new Case();
        cs.SCC_Terminal_ID__c = 'Test Terminal ID';
        cs.SCC_Transaction_Date__c = Date.today();
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Cust_Phone1__c = '081299928812';
        cs.Cust_Current_Phone__c = '081234567890';
        cs.SCC_Transaction_Date__c = Date.today();
        cs.Description = 'test desc';
        cs.SCC_Email__c = 'test@gmail.com';
        cs.SCC_Amount__c = 100;
        cs.SCC_Drone_Ticket_ID__c = '812999';
        cs.SCC_Call_Type__c = callType.Id;
        insert cs;
    }
    
    static testMethod void testProcess(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        
        Ctrl_mpCaseReason.getMasterPicklist();
        Ctrl_mpCaseReason.getFieldValues(cs.Id);
        Ctrl_mpCaseReason.getIsClosed(cs.Id);
        List<String> selectedValues = new List<String>();
        selectedValues.add('Pengaduan yang berulang');
        Ctrl_mpCaseReason.saveSelectedValues(cs.Id, selectedValues);
    }
}