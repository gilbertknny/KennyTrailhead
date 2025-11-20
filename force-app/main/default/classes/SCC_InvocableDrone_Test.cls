@isTest
public with sharing class SCC_InvocableDrone_Test {
    @TestSetup
    static void createCase(){
        SSC_Call_Type__c callType = new SSC_Call_Type__c();
        callType.Active__c = true;
        callType.Name = '8222';
        callType.SCC_Customer_Segment__c = 'Individu Umum';
        callType.SSC_Product_L1__c = 'Transaction Banking';
        callType.SSC_Product_L2__c = 'Transaction Solution';
        callType.SSC_Case_Category__c = 'Complaint - Transaction';
        callType.SSC_Case_Description__c = 'Nasabah Komplain Transaksi Rtgs Melalui E-Channel';
        callType.Send_to_Drone__c = true;
        callType.SCC_Agent_SLA__c = 1;
        callType.SCC_Level1_OLA__c = 3;
        callType.SCC_Level1_Escalation_team__c = 'SCC - Non Fraud Transaction - ISSUER';
        callType.External_Id__c = '8222';
        insert callType;
        
        Case cs = new Case();
        cs.SCC_Terminal_ID__c = 'Test Terminal ID';
        cs.SCC_Transaction_Date__c = Date.today();
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Cust_Phone1__c = '081299928812';
        cs.Cust_Current_Phone__c = '081234567890';
        cs.SCC_Transaction_Date__c = Date.today();
        cs.Description = 'test desc';
        cs.SCC_Email__c = 'test@gmail.com';
        cs.SCC_Amount__c = 100;
        cs.SCC_Drone_Ticket_ID__c = '812999';
        cs.SCC_Call_Type__c = callType.Id;
        insert cs;
    }
    @isTest
    static void testCreateTicket() {
        //String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        //String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        //List<Case> cs = Database.query(queries);
        List<Case> cs = [SELECT Id,
                            CaseNumber,
                            ContactId,
                            Description,
                            Account.name,
                    		status,
                    		ownerid,
                            SCC_Account_Number__c,
                            SCC_Transaction_Date__c,
                            SCC_Card_Number__c,
                            SCC_Call_Type__c,
                            SCC_Call_Type__r.Name,
                            SCC_Call_Type__r.External_Id__c,
                            SCC_Branch_Unit__r.Name,
                            SCC_Amount__c,
                            SCC_Remark__c,
                            SCC_Cust_Phone1__c,
                            Cust_Current_Phone__c,
                            SCC_Email__c
                       FROM Case];
        
        Test.setMock(HttpCalloutMock.class, new SCC_InvocableDroneWrapperMock());
            
        Test.startTest();
        SCC_InvocableDrone.createTicketDrone(cs[0].id);
        Test.stopTest();
    }
    
    private class SCC_InvocableDroneWrapperMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":true,"code":200,"message":"Create ticket Success","data": {"ticket_no":"3929876","ticket_no_chm" :"TTB000078921749"}}');
            res.setStatusCode(200);
            return res;
        }
	}
    @isTest
    static void testUpdateTicket() {
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        List<Case> cs = Database.query(queries);

        Test.startTest();
        SCC_InvocableDrone.updateTicketDrone(cs[0].id);
        Test.stopTest();
    }
    @istest
    static void invocablemethod(){
        SCC_InvocableDrone.InputVariable inv = new SCC_InvocableDrone.InputVariable();
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '1');
        Case cs = Database.query(queries);
		inv.param = 'Create Ticket Drone';
        inv.recordId = cs.id;
        list<SCC_InvocableDrone.InputVariable> listinv = new list<SCC_InvocableDrone.InputVariable>();
        listinv.add(inv);
        
        Test.startTest();
        SCC_InvocableDrone.Invocablevoid(listinv);
        Test.stopTest();
    }
}