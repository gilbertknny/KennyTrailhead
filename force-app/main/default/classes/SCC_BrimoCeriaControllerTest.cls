/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 10-12-2024
 * @last modified by  : Ardyta Yudianto
**/
@isTest
private class SCC_BrimoCeriaControllerTest {

    @isTest
    static void testSetResponseFileSuccess() {
        // Prepare a mock InsertFileRequestModel
        SCC_BrimoCeriaWrapper.InsertFileRequestModel jreq = new SCC_BrimoCeriaWrapper.InsertFileRequestModel();
        jreq.linkedEntityId = '500MR000005aKVFYA2';
        jreq.Title = 'Test File';
        jreq.PathOnClient = 'testFile.png';
        jreq.versionData = EncodingUtil.base64Encode(Blob.valueOf('This is a test file content.'));

        // Call the method
        Test.startTest();
        SCC_BrimoCeriaWrapper.InsertFileResponseModel response = SCC_BrimoCeriaController.setResponseFile(jreq);
        Test.stopTest();

        // Verify the response
        System.assertNotEquals(null, response);
        System.assertEquals('Success', response.responseMessage);
        System.assertNotEquals(null, response.url);
    }
}