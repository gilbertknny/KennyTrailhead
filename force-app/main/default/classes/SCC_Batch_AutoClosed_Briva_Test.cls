/**
 * @description       : Test class for SCC_Batch_AutoClosed_Briva
 * @last modified on  : 03-06-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_Batch_AutoClosed_Briva_Test {
    @TestSetup
    static void makeData() {
        // SSC_Call_Type__c callType = Object_Test.setCallType('8412');
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

        Case testCaseNonBriva = Object_Test.setCase(callType.Id);
        testCase.SCC_Call_Type_Feature__c = callTypeFeature.Id;
        testCase.SCC_Amount__c = 50000;
        testCase.SCC_Transaction_Date__c = Date.today().addDays(-3);
        testCase.SCC_Account_Number__c = '326301020305555';
        testCase.SCC_Nomor_Briva_Tagihan__c = '';
        insert testCaseNonBriva;

        Master_Kor__c masterKor1 = new Master_Kor__c(
            Name = '326301020301234',
            Case_Type__c = callType.Id);
        
        insert masterKor1;
    }
    
    @isTest
    static void testBatchSuccess() {
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SCC_RekeningKoran_Mock.ResponseRekeningKoran_MatchedConditions());
        
        // String cond = 'isclosed = false';
        // String addfield = '';
        // String allfield = SOQL_SOBJECT.getallfield('Case');
        // String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        
        // String queries = 'SELECT Id, SCC_Amount__c, SCC_Account_Number__c, SCC_Call_Type_Feature__r.Call_Type__r.External_Id__c, SCC_Nomor_Briva_Tagihan__c FROM Case Limit 1';
        String queries = 'SELECT Id, SCC_Amount__c, SCC_Account_Number__c,SCC_Call_Type__r.external_id__c, SCC_Nomor_Briva_Tagihan__c, SCC_Transaction_Date__c FROM Case WHERE SCC_Account_Number__c = \'326301020301234\'';

        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(queries), 1);
        
        test.stopTest();
        
        Case updatedCase = [SELECT Status, SCC_Status_Transaksi__c FROM Case WHERE SCC_Account_Number__c = '326301020301234' LIMIT 1];
        System.assertEquals('Closed', updatedCase.Status);
        System.assertEquals('Gagal', updatedCase.SCC_Status_Transaksi__c);
    }
    @isTest
    static void testBatchNonBriva() {
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SCC_RekeningKoran_Mock.ResponseRekeningKoran_MatchedConditions());
        
        // String cond = 'isclosed = false';
        // String addfield = '';
        // String allfield = SOQL_SOBJECT.getallfield('Case');
        // String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        
        // String queries = 'SELECT Id, SCC_Amount__c, SCC_Account_Number__c, SCC_Call_Type_Feature__r.Call_Type__r.External_Id__c, SCC_Nomor_Briva_Tagihan__c FROM Case Limit 1';
        String queries = 'SELECT Id, SCC_Amount__c, SCC_Account_Number__c,SCC_Call_Type__r.external_id__c, SCC_Nomor_Briva_Tagihan__c, SCC_Transaction_Date__c FROM Case WHERE SCC_Account_Number__c = \'326301020305555\'';

        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(queries), 1);
        
        test.stopTest();
        
        Case updatedCase = [SELECT Status, SCC_Status_Transaksi__c FROM Case WHERE SCC_Account_Number__c = '326301020301234' LIMIT 1];
        System.assertEquals('New', updatedCase.Status);
        System.assertEquals('Berhasil', updatedCase.SCC_Status_Transaksi__c);
    }
    @isTest
    static void testBatchSuccessException() {
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SCC_RekeningKoran_Mock.ResponseRekeningKoran_MatchedConditions());
        
        // String cond = 'isclosed = false';
        // String addfield = '';
        // String allfield = SOQL_SOBJECT.getallfield('Case');
        // String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        
        // String queries = 'SELECT Id, SCC_Amount__c, SCC_Account_Number__c, SCC_Call_Type_Feature__r.Call_Type__r.External_Id__c, SCC_Nomor_Briva_Tagihan__c FROM Case Limit 1';
        String queries = 'SELECT Id, SCC_Amount__c, SCC_Account_Number__c,SCC_Call_Type__r.external_id__c, SCC_Nomor_Briva_Tagihan__c FROM Case WHERE SCC_Account_Number__c = \'326301020305555\'';

        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(queries), 1);
        
        test.stopTest();
    }
    
}