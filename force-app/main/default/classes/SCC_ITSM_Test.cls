@isTest
private class SCC_ITSM_Test {
   
    @isTest
    static void createTicketITSM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseCreateTicketITSM());
        SCC_ITSM.createTicket(Object_Test_ITSM.requestCreate());
        Test.stopTest();
    }

    @IsTest
    static void reopenTicketITSM() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseReopenTicketITSM());
        SCC_ITSM.reopenTicket(Object_Test_ITSM.requestReopen(), '12233');
        Test.stopTest();
    }

    @IsTest
    static void createTicketError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseError());
        SCC_ITSM.createTicket(Object_Test_ITSM.requestCreate());
        Test.stopTest();
    }

    @IsTest
    static void reopenTicketError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseError());
        SCC_ITSM.reopenTicket(Object_Test_ITSM.requestReopen(), '1234');
        Test.stopTest();
    }


}