/**
 * @description       : 
 * @author            : Alvin Vigo, Reinaldy Thando
 * @group             : 
 * @last modified on  : 05/11/2024
 * @last modified by  : Alvin Vigo, Reinaldy Thando
**/

@isTest
private class SCC_Batch_AutoClosed_RekeningKoran_Test {
    @TestSetup
    static void makeData(){
        SSC_Call_Type__c callType = Object_Test.setCallType('8812');
        insert callType;
        SCC_Call_Type_Feature__c callTypeFeature = Object_Test.setFitur(callType.Id);
        insert callTypeFeature;
        Case testCase = Object_Test.setCase(callType.Id);
        testCase.SCC_Call_Type_Feature__c = callTypeFeature.Id;
        testCase.SCC_Amount__c = 50000;
        testCase.SCC_Transaction_Date__c = Date.today();
        testCase.SCC_Account_Number__c = '326301020301234';
        insert testCase;
    }
    @isTest
    static void testBatchSucess() {
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekeningKoran_Mock.ResponseRekeningKoran_MatchedConditions());
        String cond = 'isclosed = false';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Database.executeBatch(new SCC_Batch_AutoClosed_RekeningKoran(queries), 1);
        test.stopTest();
    }

    @isTest
    static void myUnitTestError() {
        // TO DO: implement unit test
        test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(exception exc){
            SCC_Batch_AutoClosed_RekeningKoran.InsertErrorLog(exc);
        }
        test.stopTest();
    }
}