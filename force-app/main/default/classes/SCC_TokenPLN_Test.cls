@isTest
public with sharing class SCC_TokenPLN_Test {

    @TestSetup
    static void makeData(){
        //call type
        SSC_Call_Type__c caseType = new SSC_Call_Type__c(
            Name = '8810',
            External_Id__c = '8810',
            SCC_Customer_Segment__c = 'Segment 1',
            SSC_Product_L1__c = 'Savings',
            SSC_Product_L2__c = 'Digital Savings',
            SSC_Case_Category__c = 'Inquiry',
            SSC_Case_Description__c = 'Description 1',
            Active__c = true
        );
        insert caseType;

        //feature
        SCC_Call_Type_Feature__c feature = new SCC_Call_Type_Feature__c(Name = 'Ayopop', Fitur_ID__c = 'AYOPOP001' , Call_Type__c = caseType.Id);
        insert feature;

        //terminal
        SCC_Terminal_ID__c terminal = new SCC_Terminal_ID__c(Name = '00000155' , SCC_Teller_Id__c = '99952' , SCC_Account_Number__c = '100010000003' , Ext_Id__c = '-100010000003-99-99952');
        insert terminal;

        //account
        Account acc = new Account(LastName = 'Test Account');
        insert acc;

        //case 
         Case cs = new Case(
            Subject = 'Test Case PLN',
            AccountId = acc.Id,
            SCC_Call_Type__c = caseType.Id,
            SCC_Call_Type_Feature__c = feature.Id,
            Terminal_ID__c = terminal.Id,
            SCC_Billing_Number__c = '1234567890',
            Nomor_Token_PLN__c = '0987654321'
        );
        insert cs;


    }

    @IsTest
    static void testGetCaseDetail() {
        Case cs = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Case result = SCC_TokenPLN.getCaseDetail(cs.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'result must not null');
        System.assertEquals(cs.Id, result.Id, 'succes get case id');
    }

       @IsTest
    static void testUpdateCase_Success() {
        Case cs = [SELECT Id FROM Case LIMIT 1];
        String newToken = 'TOKEN123';
        String newBilling = 'BILL999';

        Test.startTest();
        Case updatedCase = SCC_TokenPLN.updateCase(cs.Id, newToken, newBilling);
        Test.stopTest();

        System.assertEquals(newToken, updatedCase.Nomor_Token_PLN__c, 'Nomor token updated');
        System.assertEquals(newBilling, updatedCase.SCC_Billing_Number__c, 'Billing number updated');
    }

    @IsTest
    static void testUpdateCase_NotFound() {

        Id fakeCaseId = '500000000000000AAA'; 

        Test.startTest();
        try {
            SCC_TokenPLN.updateCase(fakeCaseId, 'TOKENX', 'BILLX');
        } catch (AuraHandledException e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

     @IsTest
    static void testUpdateCase_ExceptionHandling() {
        
        Test.startTest();
        try {
            SCC_TokenPLN.updateCase(null, 'TOKENERR', 'BILLERR');
           // System.assert(false, 'Seharusnya throw AuraHandledException');
        } catch (AuraHandledException e) {
           // System.assert(e.getMessage().contains('Error update Case'));
        }
        Test.stopTest();
    }
}