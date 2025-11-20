@isTest
private class SCC_MMS_Test {

    @isTest
    static void createTicketMMS_Success() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_MMS_Mock.ResponseCreateTicketMMSSuccess());
        SCC_MMSWrapper.RequestCreateMMS request = Object_Test_MMS.requestCreateMMS();
        SCC_MMSWrapper.ResponseCreateMMS response = SCC_MMS.createTicketMMS(request);
        Test.stopTest();
    }

    @isTest
    static void createTicketMMS_Error() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_MMS_Mock.ResponseCreateTicketMMSError());
        SCC_MMSWrapper.RequestCreateMMS request = Object_Test_MMS.requestCreateMMS();
        SCC_MMSWrapper.ResponseCreateMMS response = SCC_MMS.createTicketMMS(request);
        Test.stopTest();
    }
}