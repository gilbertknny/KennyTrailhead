@isTest
public with sharing class SCC_Create_Ticket_ITSM_Test {
    
    @isTest
    static void testCreateTicketITSM(){
        
        SCC_Create_Ticket_ITSM.RequestCreateITSM request = new SCC_Create_Ticket_ITSM.RequestCreateITSM();
        request.Subject = 'Test Incident';
        request.BRI_SourceKey = 'Test Source Key';
        request.Symptom = 'Test Symptom';
        request.BRI_SApp_Detail = 'Test Detail';
        request.BRI_SApp_TicketNumber = 'T12345';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseCreateTicketITSM());
        List<SCC_Create_Ticket_ITSM.RequestCreateITSM> requests = new List<SCC_Create_Ticket_ITSM.RequestCreateITSM>();
        requests.add(request);
        List<SCC_Create_Ticket_ITSM.ResponseCreateITSM> responses = SCC_Create_Ticket_ITSM.createTicketITSM(requests);
        Test.stopTest();
    }

    @isTest
    static void testCreateTicketITSMError(){

        SCC_Create_Ticket_ITSM.RequestCreateITSM request = new SCC_Create_Ticket_ITSM.RequestCreateITSM();
        request.Subject = '';
        request.BRI_SourceKey = 'Test Source Key';
        request.Symptom = 'Test Symptom';
        request.BRI_SApp_Detail = 'Test Detail';
        request.BRI_SApp_TicketNumber = 'T12345';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseError());
        List<SCC_Create_Ticket_ITSM.RequestCreateITSM> requests = new List<SCC_Create_Ticket_ITSM.RequestCreateITSM>();
        requests.add(request);
        List<SCC_Create_Ticket_ITSM.ResponseCreateITSM> responses = SCC_Create_Ticket_ITSM.createTicketITSM(requests);
        Test.stopTest();
    }

}