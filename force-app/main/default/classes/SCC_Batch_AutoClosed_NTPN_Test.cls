/**
 * @description       : 
 * @author            : Suherbing Septian
 * @group             : 
 * @last modified on  : 16/09/2025
 * @last modified by  : Suherbing Septian
**/

@isTest
private class SCC_Batch_AutoClosed_NTPN_Test {
    @TestSetup
    static void setupData(){
        SSC_Call_Type__c callType = Object_Test.setCallType('8810');
        insert callType;
        SCC_Call_Type_Feature__c callTypeFeature = Object_Test.setFitur(callType.Id);
        insert callTypeFeature;
        Case testCase = Object_Test.setCase(callType.Id);
        testCase.SCC_Call_Type_Feature__c = callTypeFeature.Id;
        testCase.SCC_Amount__c = 350000;
        testCase.SCC_Transaction_Date__c = Date.today();
        testCase.SCC_Account_Number__c = '326301020301234';
        testCase.scc_Billing_Number__c = '3263010203012';
        insert testCase;
    }
    @isTest
    static void testBatchSucess() {
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BillingMPN_Mock.BillingMPN());
        String cond = 'isclosed = false';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Database.executeBatch(new SCC_Batch_AutoClosed_NTPN(queries), 1);
        test.stopTest();
    }

    @isTest
    static void testUpdateEmpty() {
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_BillingMPN_Mock.BillingMPN());
        String cond = 'isclosed = true';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Database.executeBatch(new SCC_Batch_AutoClosed_NTPN(queries), 1);
        test.stopTest();
    }
}