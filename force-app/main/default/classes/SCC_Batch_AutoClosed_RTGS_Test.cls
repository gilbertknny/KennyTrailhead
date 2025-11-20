/**
 * @description       : 
 * @author            : Suherbing Septian
 * @group             : 
 * @last modified on  : 15/09/2025
 * @last modified by  : Suherbing Septian
**/

@isTest
private class SCC_Batch_AutoClosed_RTGS_Test {
    @TestSetup
    static void makeData(){
        SSC_Call_Type__c callType = Object_Test.setCallType('8222');
        insert callType;
        SCC_Call_Type_Feature__c callTypeFeature = Object_Test.setFitur(callType.Id);
        insert callTypeFeature;
        Case testCase = Object_Test.setCase(callType.Id);
        testCase.SCC_Call_Type_Feature__c = callTypeFeature.Id;
        testCase.SCC_Amount__c = 130000000;
        testCase.SCC_Transaction_Date__c = Date.today();
        testCase.SCC_Account_Number__c = '326301020301234';
        testCase.scc_Billing_Number__c = '3263010203012';
        insert testCase;

        // Buat custom setting BRIMO__c
        BRIMO__c brimoSetting = new BRIMO__c(
            Name = 'extId RTGS',
            request_refnum__c = 1000
        );
        insert brimoSetting;
    }
    @isTest
    static void testBatchSucess() {
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_FindRTGSMock.FindRTGS());
        String cond = 'isclosed = false';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Database.executeBatch(new SCC_Batch_AutoClosed_RTGS(queries), 1);
        test.stopTest();
    }

    @isTest
    static void testInsertError() {
        // TO DO: implement unit test
        test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(exception exc){
            SCC_Batch_AutoClosed_RTGS.InsertErrorLog(exc);
        }
        test.stopTest();
    }
}