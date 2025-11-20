/**
 * @description       : 
 * @author            : Ahmad Yazid Munif
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : Ahmad Yazid Munif
**/
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
        insert cs;
        Case cs2 = new Case();
        cs2.Subject = 'Test2';
        cs2.Description = 'Test2';
        cs2.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs2.AccountId = acc.Id;
        cs2.SCC_Cust_Phone1__c = '123456789011';
        cs2.SCC_Amount__c = 1000000;
        cs2.SCC_Card_Number__c = '1234567890123455';
        cs2.SCC_Account_Number__c = '1234567890123455';
        cs2.SSC_Call_Type_Description__c = 'Test';
        cs2.SCC_Drone_Remark_Update__c = '[2025-03-11 12:30:00 User] Test remark for SCC Drone';
        insert cs2;
        
        CaseHistory ch = new CaseHistory();
        ch.CaseId = cs.Id;
        ch.DataType = 'Text';
        ch.Field = 'Description';
        insert ch;
        
        CaseHistory ch2 = new CaseHistory();
        ch2.CaseId = cs2.Id;
        ch2.DataType = 'Text';
        ch2.Field = 'Description';
        insert ch2;
    }
    static testMethod void testProcess(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        ApexPages.currentPage().getParameters().put('recordid',cs.id);
        
        Test.startTest();
        Ctrl_PDF_ReportBranch rb = new Ctrl_PDF_ReportBranch();
        Test.stopTest();
    }
    static testMethod void testProcess2(){
        Case cs = [SELECT Id FROM Case WHERE Subject = 'Test2'];
        ApexPages.currentPage().getParameters().put('recordid',cs.id);
        
        Test.startTest();
        Ctrl_PDF_ReportBranch rb = new Ctrl_PDF_ReportBranch();
        Test.stopTest();
    }
    @isTest
    static void testCompare() {
        Ctrl_PDF_ReportBranch.history history1 = new Ctrl_PDF_ReportBranch.history();
        history1.tanggalDT = DateTime.newInstance(2025, 3, 10, 10, 0, 0);

        Ctrl_PDF_ReportBranch.history history2 = new Ctrl_PDF_ReportBranch.history();
        history2.tanggalDT = DateTime.newInstance(2025, 3, 12, 14, 30, 0);

        Ctrl_PDF_ReportBranch.history history3 = new Ctrl_PDF_ReportBranch.history();
        history3.tanggalDT = DateTime.newInstance(2025, 3, 11, 8, 15, 0);

        List<Ctrl_PDF_ReportBranch.history> historyList = new List<Ctrl_PDF_ReportBranch.history>();
        historyList.add(history1);
        historyList.add(history2);
        historyList.add(history3);

        historyList.sort(new Ctrl_PDF_ReportBranch.HistoryComparator());

        System.assertEquals(history1.tanggalDT, historyList[0].tanggalDT, 'History 1 harusnya pertama');
        System.assertEquals(history3.tanggalDT, historyList[1].tanggalDT, 'History 3 harusnya kedua');
        System.assertEquals(history2.tanggalDT, historyList[2].tanggalDT, 'History 2 harusnya terakhir');
    }
}