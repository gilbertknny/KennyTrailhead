@isTest
public class SCC_CaseMilestoneControllerTest {

    @testSetup
    static void setupData() {
        //create Account
        Account acct = new Account(Name='Test1',Phone = '8800533997');
        insert Acct; 

        //retrieve Default Entitlement Process information
        Id entitlementProcessId = [SELECT Id FROM SlaProcess 
                                WHERE SObjectType = 'Case' 
                                AND Name = 'Case Entitlement' 
                                   ORDER BY ID DESC LIMIT 1].Id;

        //create Entitlement Record
        Entitlement ent = new Entitlement (AccountId=Acct.Id, SLAProcessId = entitlementProcessId, Name = 'Case Entitlement');
        insert ent;
        
        // Create SSC_Call_Type__c
        List<SSC_Call_Type__c> ctList = new List<SSC_Call_Type__c>();
        SSC_Call_Type__c ct = new SSC_Call_Type__c(
            Active__c = true,
            Name = '8812',
            SCC_Customer_Segment__c = 'All',
            SSC_Product_L1__c = 'Transaction Banking',
            SSC_Product_L2__c = 'Transaction Solution',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Gagal Tarik Tunai dan Saldo Berkurang di ATM/CRM BRI',
            SCC_Agent_SLA__c = 1,
            SCC_Level1_OLA__c = 1
        );
        ctList.add(ct);
        insert ctList;
        

        // Create a test case
        Case testCase = new Case(
            SCC_Call_Type__c = ctList[0].Id,
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone',
            SlaStartDate = System.Now(),
            EntitlementId = ent.Id,
            IsStopped = false,
            Description = 'Test Case'
        );
        insert testCase;
    }
    
    @isTest
    static void testGetCaseMilestones() {
        // Retrieve the test case created in the testSetup method
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method and check results
        Test.startTest();
        List<CaseMilestone> result = SCC_CaseMilestoneController.getCaseMilestones(testCase.Id);
        Test.stopTest();
        
        // Assertions
        for (CaseMilestone cm : result) {
            System.assertEquals(testCase.Id, cm.CaseId, 'CaseId should match the test case Id');
        }
    }
}