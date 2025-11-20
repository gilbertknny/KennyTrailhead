/**
 * @description       : Test Class for SCC_ITSMCalloutController
 * @last modified on  : 03-06-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_ITSMCalloutController_Test {
    @TestSetup
    static void makeData(){
        SSC_Call_Type__c callType = new SSC_Call_Type__c(
            Name = '8412',
            External_Id__c = '8412',
            SCC_Customer_Segment__c = 'Segment 1',
            SSC_Product_L1__c = 'Savings',
            SSC_Product_L2__c = 'Digital Savings',
            SSC_Case_Category__c = 'Inquiry',
            SSC_Case_Description__c = 'Description 1',
            Active__c = true);
        insert callType;

        SCC_Call_Type_Feature__c callTypeFeature = new SCC_Call_Type_Feature__c(
            Name = 'Feature 1',
            Call_Type__c = callType.Id
        );
        insert callTypeFeature;

        Case testCase = Object_Test.setCase(callType.Id);
        testCase.SCC_Call_Type_Feature__c = callTypeFeature.Id;
        testCase.SCC_Amount__c = 50000;
        testCase.SCC_Transaction_Date__c = Date.today().addDays(-3);
        testCase.SCC_Account_Number__c = '326301020301234';
        testCase.SCC_Nomor_Briva_Tagihan__c = 'KOR3';
        insert testCase;
    }
    @isTest
    static void testMakeCallout_Success() {
        String mockResponse = '{"status": "200 OK", "Transaction_Number": "9001", "Ticket_Number": "ABC123"}';
        MockHttpResponseGenerator calloutMock = new MockHttpResponseGenerator(mockResponse,200);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        String testCaseId = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        String response = SCC_ITSMCalloutController.makeCallout(testCaseId);
        Test.stopTest();

        System.assert(response.contains('200 OK'), 'Response should indicate success.');
    }
}