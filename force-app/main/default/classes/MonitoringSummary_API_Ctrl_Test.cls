@isTest
public with sharing class MonitoringSummary_API_Ctrl_Test {
    
    @IsTest
    static void testGetByDate(){
        Test.startTest();
    
        // Test successful scenario
        MonitoringSummary_API_Wrapper.GetByDateRequestModel rgmsdate = Object_Test.GetByDateRequestModel();
        String resultGetByDate = MonitoringSummary_API_Ctrl.GetByDate(rgmsdate);
        
        
        // Verify the content of the response
        MonitoringSummary_API_Wrapper.GetByDateResponseModel response = 
            (MonitoringSummary_API_Wrapper.GetByDateResponseModel)JSON.deserialize(resultGetByDate, MonitoringSummary_API_Wrapper.GetByDateResponseModel.class);
        System.assertNotEquals(null, response.MonitoringSummary, 'MonitoringSummary should not be null');
        System.assertNotEquals(0, response.MonitoringSummary.size(), 'MonitoringSummary should not be empty');
        
        // Test data not found scenario
        MonitoringSummary_API_Wrapper.GetByDateRequestModel rgmsdateNotFound = Object_Test.GetByDateRequestModelNotFound();
        String resultGetByDateNotFound = MonitoringSummary_API_Ctrl.GetByDate(rgmsdateNotFound);
        
        // Assertions for not found scenario
        System.assert(resultGetByDateNotFound.contains('"responseMessage":"Data tidak ditemukan"'), 
            'Should return "Data tidak ditemukan" for invalid date range. Actual result: ' + resultGetByDateNotFound);
        System.assert(resultGetByDateNotFound.contains('"responseCode":"14"'), 
            'Should return response code 14 for invalid date range. Actual result: ' + resultGetByDateNotFound);
        
        // Test returnAPIGetByDate
        MonitoringSummary_API_Wrapper.GetByDateResponseModel resrrgmsdate = Object_Test.GetByDateResponseModel();
        String returnResult = MonitoringSummary_API_Ctrl.returnAPIGetByDate(resrrgmsdate);
        System.assertNotEquals(null, returnResult, 'returnAPIGetByDate should return a non-null result');
        System.assert(returnResult.contains('"responseCode":"00"'), 'returnAPIGetByDate should include the response code');
        System.assert(returnResult.contains('"responseMessage":"Success"'), 'returnAPIGetByDate should include the response message');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetByAreaDivisi(){
        Test.startTest();
    
        MonitoringSummary_API_Wrapper.GetByAreaRequestModel rgmsad = Object_Test.GetByAreaDivisiRequestModel();
        String resultGetByAreaDivisi = MonitoringSummary_API_Ctrl.GetByAreaDivisi(rgmsad);
        System.assertNotEquals(null, resultGetByAreaDivisi, 'GetByAreaDivisi should return a non-null result');
        
        // Verify the content of the response
        MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel response = 
            (MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel)JSON.deserialize(resultGetByAreaDivisi, MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel.class);
        System.assertEquals('00', response.responseCode, 'Response code should be 00 for success');
        System.assertEquals('Success', response.responseMessage, 'Response message should be Success');
        System.assertNotEquals(null, response.MonitoringSummary, 'MonitoringSummary should not be null');
        
        // Test with invalid GroupBy
        rgmsad.GroupBy = 'Invalid';
        String resultInvalidGroupBy = MonitoringSummary_API_Ctrl.GetByAreaDivisi(rgmsad);
        System.assert(resultInvalidGroupBy.contains('"responseCode":"15"'), 'Should return response code 15 for invalid GroupBy');
        System.assert(resultInvalidGroupBy.contains('"responseMessage":"Mandatory"'), 'Should return Mandatory error for invalid GroupBy');
        
        // Test returnAPIGetByAreaDivisi
        MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel resrgmsad = Object_Test.GetByAreaDivisiResponseModel();
        String returnResult = MonitoringSummary_API_Ctrl.returnAPIGetByAreaDivisi(resrgmsad);
        System.assertNotEquals(null, returnResult, 'returnAPIGetByAreaDivisi should return a non-null result');
        System.assert(returnResult.contains('"responseCode":"00"'), 'returnAPIGetByAreaDivisi should include the response code');
        System.assert(returnResult.contains('"responseMessage":"Success"'), 'returnAPIGetByAreaDivisi should include the response message');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetByAreaBranch(){
        Test.startTest();
    
        MonitoringSummary_API_Wrapper.GetByAreaRequestModel rgmsab = Object_Test.GetByAreaBranchRequestModel();
        String resultGetByAreaBranch = MonitoringSummary_API_Ctrl.GetByAreaBranch(rgmsab);
        System.assertNotEquals(null, resultGetByAreaBranch, 'GetByAreaBranch should return a non-null result');
        
        // Verify the content of the response
        MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel response = 
            (MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel)JSON.deserialize(resultGetByAreaBranch, MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel.class);
        System.assertEquals('00', response.responseCode, 'Response code should be 00 for success');
        System.assertEquals('Success', response.responseMessage, 'Response message should be Success');
        System.assertNotEquals(null, response.MonitoringSummary, 'MonitoringSummary should not be null');
        
        // Test with invalid Area
        rgmsab.Area = 'Invalid';
        String resultInvalidArea = MonitoringSummary_API_Ctrl.GetByAreaBranch(rgmsab);
        System.assert(resultInvalidArea.contains('"responseCode":"15"'), 'Should return response code 15 for invalid Area');
        System.assert(resultInvalidArea.contains('"responseMessage":"Mandatory"'), 'Should return Mandatory error for invalid Area');
        
        // Test returnAPIGetByAreaBranch
        MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel resrgmsab = Object_Test.GetByAreaBranchResponseModel();
        String returnResult = MonitoringSummary_API_Ctrl.returnAPIGetByAreaBranch(resrgmsab);
        System.assertNotEquals(null, returnResult, 'returnAPIGetByAreaBranch should return a non-null result');
        System.assert(returnResult.contains('"responseCode":"00"'), 'returnAPIGetByAreaBranch should include the response code');
        System.assert(returnResult.contains('"responseMessage":"Success"'), 'returnAPIGetByAreaBranch should include the response message');
        
        Test.stopTest();
    }
}