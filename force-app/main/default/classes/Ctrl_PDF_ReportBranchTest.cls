@isTest
private class Ctrl_PDF_ReportBranchTest {
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
        cs.SCC_Remark__c = 'Ini Remark';
        cs.SCC_Drone_Remark_Update__c = '[2024-08-19 16:25:58  Nabila] tes remark' + '\n[2024-08-19 16:26:09  Nabila] tes remark lagi';
        insert cs;
        
        CaseHistory ch = new CaseHistory();
        ch.CaseId = cs.Id;
        ch.DataType = 'Text';
        ch.Field = 'Description';
        insert ch;
        
        ch = new CaseHistory();
        ch.CaseId = cs.Id;
        ch.DataType = 'DateTime';
        ch.Field = 'SCC_Waktu_Transaksi__c';
        insert ch;
    }
    static testMethod void testProcess(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        ApexPages.currentPage().getParameters().put('recordid',cs.id);
        
        Test.startTest();
        Ctrl_PDF_ReportBranch rb = new Ctrl_PDF_ReportBranch();
        Test.stopTest();
    }
}