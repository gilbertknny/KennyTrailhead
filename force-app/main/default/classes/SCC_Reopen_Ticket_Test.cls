@isTest
public with sharing class SCC_Reopen_Ticket_Test {

    @TestSetup
    static void setupData() {

        Incident incident = new Incident(
            Subject = 'Ticket001 - Test',
            Urgency = 'Low',
            Impact = 'Minor / Localized',
            Nomor_tiket_iRIS__c = 'INC001',
            Resolution_Type__c = 'Initial',
            Root_Cause__c = 'None',
            Status = 'Open'
        );
        insert incident;
    }
   
    @isTest
    static void testReopenTicketITSM(){
        SCC_Reopent_Ticket_ITSM.RequestReopenITSM request = new SCC_Reopent_Ticket_ITSM.RequestReopenITSM();
        request.BRI_SApp_Reopen_Justification = 'Test Reopen';
        request.IncidentId = '1234';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_ITSM_Mock.ResponseReopenTicketITSM());
        List<SCC_Reopent_Ticket_ITSM.RequestReopenITSM> requests = new List<SCC_Reopent_Ticket_ITSM.RequestReopenITSM>();
        requests.add(request);
        List<SCC_Reopent_Ticket_ITSM.ResponseReopenITSM> responses = SCC_Reopent_Ticket_ITSM.reopenTicketITSM(requests);
        Test.stopTest();
    }

}