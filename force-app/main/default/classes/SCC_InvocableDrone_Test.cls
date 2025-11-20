@isTest
public with sharing class SCC_InvocableDrone_Test {
    @TestSetup
    static void createCase(){
        Case cs = new Case();

            cs.SCC_Terminal_ID__c = 'Test Terminal ID';
            cs.SCC_Transaction_Date__c = Date.today();
            cs.SCC_Account_Number__c = '1234567890123456';
            cs.SCC_Cust_Phone1__c = '081299928812';
            cs.Cust_Current_Phone__c = '081234567890';
            cs.SCC_Transaction_Date__c = Date.today();
            cs.Description = 'test desc';
            cs.SCC_Email__c = 'test@test.co';
            cs.SCC_Amount__c = 100;
        insert cs;
        
        cs.SCC_Drone_Ticket_ID__c = '812999';
        update cs;
    }
    @isTest
    static void testCreateTicket() {
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        List<Case> cs = Database.query(queries);

        System.debug('cs[0].id'+cs[0]);
        
        Test.startTest();
        SCC_InvocableDrone.createTicketDrone(cs[0].id);
        Test.stopTest();
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