@isTest
public with sharing class SCC_Batch_Auto_Closed_Pulsa_SLA_test {
    @TestSetup
    static void makeData(){

        SSC_Call_Type__c ct = Object_Test.setCallType('8434');
        insert ct;

        Case cs = new Case();
        cs.subject = 'Test 8434 SLA';
        cs.SCC_Call_Type__c = ct.Id;
        cs.Description = 'Test';
        cs.Status = 'Escalated';
        cs.Origin  = 'BRImo';
        cs.SCC_Terminal_ID__c = '123456';
        cs.SCC_Transaction_Date__c = system.today();
        cs.Holiday__c = 3;
        cs.scc_Billing_Number__c = '081223983242';
        cs.SCC_Amount__c = 100000;
        insert cs;

        Case cs2 = new Case();
        cs.subject = 'Test 8434 SLA Error';
        cs.SCC_Call_Type__c = ct.Id;
        cs.Description = 'Test';
        cs.Status = 'Escalated';
        cs.Origin  = 'BRImo';
        cs.SCC_Terminal_ID__c = '123456';
        cs.SCC_Transaction_Date__c = system.today();
        cs.Holiday__c = 3;
        cs.scc_Billing_Number__c = '081223983242';
        insert cs2;

        Test.setCreatedDate(cs.Id, Datetime.now().addDays(-12));
        Test.setCreatedDate(cs2.Id, Datetime.now().addDays(-12));
        
    }

    private static String buildQueryById(Id caseId){
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String addfield = ',SCC_Call_Type__r.External_Id__c';
        String cond     = 'IsClosed = false AND Id = \'' + caseId + '\'';
        return SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
    }

    @IsTest
    static void runBatchPulsaSLA() {
        
        Case cs = [SELECT Id FROM Case WHERE subject = 'Test 8434 SLA' LIMIT 1];

        Test.startTest();
        Database.executeBatch(new SCC_Batch_Auto_Closed_Pulsa_Token_SLA(buildQueryById(cs.Id)), 200);
        Test.stopTest();
    }

       @isTest
    static void testInsertError() {
        test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(exception exc){
            SCC_Batch_Auto_Closed_Pulsa_Token_SLA.InsertErrorLog(exc);
        }
        test.stopTest();
    }

   
}