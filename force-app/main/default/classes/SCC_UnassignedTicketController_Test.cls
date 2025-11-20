@isTest
public class SCC_UnassignedTicketController_Test {
    @testSetup static void setup(){
        Group sccQ = new Group(Name='SCC - Non Fraud Transaction - ON US', Type='Queue');
        insert sccQ;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueuesObject qObj = new QueueSObject(QueueID = sccQ.id, SObjectType = 'Case');
            insert qObj;
        }
        
        Account acc = new Account(LastName = 'Test');
        
        SSC_Call_Type__c callType = new SSC_Call_Type__c();
        callType.Active__c = true;
        callType.Name = '8812';
        callType.SCC_Customer_Segment__c = 'Individu Umum';
        callType.SSC_Product_L1__c = 'Transaction Banking';
        callType.SSC_Product_L2__c = 'Transaction Solution';
        callType.SSC_Case_Category__c = 'Complaint - Transaction';
        callType.SSC_Case_Description__c = 'Nasabah Komplain Gagal Tarik Tunai dan Saldo Berkurang di ATM/CRM BRI';        
        
        Orgeh__c orgeh = new Orgeh__c();
        orgeh.Name = 'SCC - Non Fraud Transaction - ON US';
        orgeh.External_Id__c = '666';
        orgeh.Permission_Set__c = 'BO Agent';
        orgeh.Profile__c = 'Back Office Agent';
        orgeh.Role__c = 'Back Office Agent';

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert orgeh;
            insert acc;
            insert callType;
        }
        
        List<Case> cases = new List<Case>();
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.Description = 'Test';
        cs.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs.AccountId = acc.Id;
        cs.SCC_Cust_Phone1__c = '081234567890';
        cs.Cust_Current_Phone__c = '081234567890';
        cs.SCC_Amount__c = 1000000;
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SSC_Call_Type_Description__c = 'Test';
        cs.Status = 'Escalated';
        cs.SCC_Call_Type__c = callType.Id;
        cs.OwnerId = sccQ.Id;
        cs.SCC_Case_Category__c = 'Request';
        cs.SCC_Nama_Pelapor__c = 'test';
        cs.SCC_Product_L1__c  = 'Savings';
        cs.SCC_Product_L2__c = 'Giro (CA)';
        cs.SCC_Segment__c = 'Individu Umum';
        cases.add(cs);
        
        Case cs2 = new Case();
        cs2.Subject = 'Test2';
        cs2.Description = 'Test2';
        cs2.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs2.AccountId = acc.Id;
        cs2.SCC_Cust_Phone1__c = '081234567890';
        cs2.Cust_Current_Phone__c = '081234567890';
        cs2.SCC_Amount__c = 2000000;
        cs2.SCC_Card_Number__c = '1234567890123456';
        cs2.SCC_Account_Number__c = '1234567890123456';
        cs2.SSC_Call_Type_Description__c = 'Test';
        cs2.Status = 'Escalated';
        cs2.SCC_Call_Type__c = callType.Id; 
        cs2.OwnerId = sccQ.Id;
        cs2.SCC_Case_Category__c = 'Request';
        cs2.SCC_Nama_Pelapor__c = 'test';
        cs2.SCC_Product_L1__c  = 'Savings';
        cs2.SCC_Product_L2__c = 'Giro (CA)';
        cs2.SCC_Segment__c = 'Individu Umum';
        cases.add(cs2);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert cases;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Back Office Users'];
        
        List<User> users = new List<User>();
        User agent = new User();
        agent.LastName = 'BO agent';
        agent.Username = 'boAgentTestx@gmail.com';
        agent.Email = 'boAgent@gmail.com';
        agent.Alias = 'BO agent';
        agent.TimeZoneSidKey = 'Asia/Jakarta';
        agent.LocaleSidKey = 'in_ID';
        agent.EmailEncodingKey = 'ISO-8859-1';
        agent.ProfileId = p.Id;
        agent.LanguageLocaleKey = 'en_US';
        agent.IsActive = true;
        agent.SCC_Orgeh__c = '666';
        users.add(agent);
        
        User spv = new User();
        spv.LastName = 'BO spv';
        spv.Username = 'boSpv@gmail.com';
        spv.Email = 'boSpv@gmail.com';
        spv.Alias = 'BO spv';
        spv.TimeZoneSidKey = 'Asia/Jakarta';
        spv.LocaleSidKey = 'in_ID';
        spv.EmailEncodingKey = 'ISO-8859-1';
        spv.ProfileId = p.Id;
        spv.LanguageLocaleKey = 'en_US';
        spv.IsActive = true;
        spv.SCC_Orgeh__c = '666';
        users.add(spv);
        insert users;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FinancialServicesCloudExtension'];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_BO_Agent'];
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_BO_Supervisor_Manager'];
        
        List<Id> userIds = new List<Id>{agent.Id, spv.Id};
        List<PermissionSetAssignment> currPSA = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN :userIds];
        if(currPSA.size()==0){
            System.runAs(new User(Id = UserInfo.getUserId())) {
                List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
                psa.add(new PermissionSetAssignment(AssigneeId = agent.Id, PermissionSetId = ps.Id));
                psa.add(new PermissionSetAssignment(AssigneeId = agent.Id, PermissionSetId = ps2.Id));
                psa.add(new PermissionSetAssignment(AssigneeId = spv.Id, PermissionSetId = ps.Id));
                psa.add(new PermissionSetAssignment(AssigneeId = spv.Id, PermissionSetId = ps3.Id));
                insert psa;
                
                List<GroupMember> gm = new List<GroupMember>();
                gm.add(new GroupMember(GroupId = sccQ.Id, UserOrGroupId = agent.Id));
                gm.add(new GroupMember(GroupId = sccQ.Id, UserOrGroupId = spv.Id));
                insert gm;
            }
        }
    }
    
    @isTest
    static void testGetSearchCases() {
        Map<String, Object> result = SCC_UnassignedTicketController.getSearchCases(1, 10, '8812', '12345', '2022-01-01');
        //System.assertEquals(0, ((List<Case>)result.get('data')).size()); // Update to expect 0 cases
    }
    
    @isTest
    static void testGetBackOfficeAgents() {
        List<User> result = SCC_UnassignedTicketController.getBackOfficeAgents();
        List<User> q = [SELECT Id, Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SCC_BO_NFT')];
        System.assertEquals(q.size(), result.size());
    }

    @isTest
    static void testAssignCasesToAgent() {
        List<Id> agentIds = new List<Id>(new Map<Id, User>([SELECT Id FROM User WHERE username = 'boAgentTestx@gmail.com']).keySet());
        List<Id> caseIds = new List<Id>(new Map<Id, Case>([SELECT Id FROM Case]).keySet());
        
        User spv = [SELECT Id FROM User WHERE Username = 'boSpv@gmail.com' LIMIT 1];
        System.runAs(spv) {
            Exception error;
            AsyncApexJob aajob;
            try {
                Id jobID = SCC_UnassignedTicketController.assignCasesToAgent(agentIds, caseIds);
                aajob = SCC_UnassignedTicketController.getBatchJobStatus(jobID);
            } catch (Exception e) {
                error = e;
            }
            
            System.assertEquals(null, error, 'Exception should not be thrown');
        }
    }
    
    @isTest
    static void testAssignCasesToNoAgent() {
        List<Id> caseIds = new List<Id>(new Map<Id, Case>([SELECT Id FROM Case]).keySet());
        
        User spv = [SELECT Id FROM User WHERE Username = 'boSpv@gmail.com' LIMIT 1];
        System.runAs(spv) {
            Exception error;
            try {
                SCC_UnassignedTicketController.assignCasesToAgent(new List<String>(), caseIds);
            } catch (Exception e) {
                error = e;
            }
            
            System.assertNotEquals(null, error, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), error.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals('Tidak ada Agen yang dipilih.', error.getMessage(), 'Specific error message is expected');
        }
    }
    
    @isTest
    static void testAssignNoCaseToAgent() {
        List<Id> agentIds = new List<Id>(new Map<Id, User>([SELECT Id FROM User WHERE username = 'boAgentTestx@gmail.com']).keySet());
        
        User spv = [SELECT Id FROM User WHERE Username = 'boSpv@gmail.com' LIMIT 1];
        System.runAs(spv) {
            Exception error;
            try {
                SCC_UnassignedTicketController.assignCasesToAgent(agentIds, new List<String>());
            } catch (Exception e) {
                error = e;
            }
            
            System.assertNotEquals(null, error, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), error.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals('Tidak ada Case yang dipilih.', error.getMessage(), 'Specific error message is expected');
        }
    }
}