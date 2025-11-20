/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 10-12-2024
 * @last modified by  : Ardyta Yudianto
**/
@isTest
private class SCC_BrimoCeriaUploadFileAPITest {
    
    @isTest
    static void testUploadFileSuccess() {
        // Prepare the mock request body
        String requestBody = '{"fileName": "testFile.txt", "fileContent": "This is a test file."}';
        
        // Set up the mock request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        Test.startTest();
        SCC_BrimoCeriaUploadFileAPI.uploadFile();
        Test.stopTest();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertNotEquals(null, RestContext.response.responseBody);
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('responseMessage'));
    }

    @isTest
    static void testUploadFileException() {
        // Prepare the mock request body that will cause an exception
        String requestBody = '{"fileName": "", "fileContent": ""}'; // Assuming empty fields will cause an error
        
        // Set up the mock request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        Test.startTest();
        SCC_BrimoCeriaUploadFileAPI.uploadFile();
        Test.stopTest();

        // Verify the response
        System.assertEquals(200, RestContext.response.statusCode);
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('responseMessage'));
        System.assert(responseBody.contains('responseCode'));
    }

    @isTest
    static void testInsertErrorLog() {
        // Create a mock response model
        SCC_BrimoCeriaWrapper.InsertFileResponseModel jres = new SCC_BrimoCeriaWrapper.InsertFileResponseModel();
        jres.responseMessage = 'Test error message';
        jres.responseCode = 'TestCode';

        // Create a mock error log
        SCC_BrimoCeriaController.ErrorLog el = new SCC_BrimoCeriaController.ErrorLog();
        el.classname = 'BrimoCeriaUploadFile';
        el.url = '/BrimoCeriaUploadFile/';

        // Call the insertErrorLog method
        String returnJson = SCC_BrimoCeriaUploadFileAPI.insertErrorLog(null, jres, el);

        // Verify the return JSON
        System.assertNotEquals(null, returnJson);
        System.assert(returnJson.contains('Test error message'));
        System.assert(returnJson.contains('TestCode'));
    }
}