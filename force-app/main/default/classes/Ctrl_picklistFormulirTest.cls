@isTest
public class Ctrl_picklistFormulirTest {
	@testSetup static void setup(){
        SSC_Call_Type__c ct = new SSC_Call_Type__c(
            Active__c = true,
            Name = '8812',
            SCC_Customer_Segment__c = 'All',
            SSC_Product_L1__c = 'Transaction Banking',
            SSC_Product_L2__c = 'Transaction Solution',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Gagal Tarik Tunai dan Saldo Berkurang di ATM/CRM BRI'
        );
        insert ct;
        
        Formulir_Detail__c fd = new Formulir_Detail__c();
        fd.Case_Type__c = ct.Id;
        fd.Name = 'Test';
        insert fd;
        
        Formulir_Detail__c fd1 = new Formulir_Detail__c();
        fd1.Case_Type__c = ct.Id;
        fd1.Name = 'Test2';
        insert fd1;
        
        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.SCC_Call_Type__c = ct.Id;
        cs.Description = 'Testing';
        insert cs;
    }
    
    static testMethod void testProcess(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        Formulir_Detail__c fd = [SELECT Id FROM Formulir_Detail__c WHERE Name ='Test2' LIMIT 1];
        Ctrl_picklistFormulir.getMasterPicklist(cs.Id,null);
        Ctrl_picklistFormulir.getFieldValues(cs.Id);
        Ctrl_picklistFormulir.getCase(cs.Id);
        Ctrl_picklistFormulir.saveSelectedValues(cs.Id, fd.Id);
    }
}