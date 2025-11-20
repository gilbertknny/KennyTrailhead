@isTest
public class SCC_ReturnTicketDrone_Test {
    @testSetup static void setup(){
        List<Group> groupList = new List<Group>();
        groupList.add(new Group(Name='SCC - Contact Center', Type='Queue'));
        groupList.add(new Group(Name='7 - KC Banyuwangi', Type='Queue'));
        groupList.add(new Group(Name='SCC - Non Fraud Transaction - ISSUER', Type='Queue'));
        insert groupList;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<QueuesObject> qObjList = new List<QueuesObject>();
            qObjList.add(new QueueSObject(QueueID = groupList[0].id, SObjectType = 'Case'));
            qObjList.add(new QueueSObject(QueueID = groupList[1].id, SObjectType = 'Case'));
            qObjList.add(new QueueSObject(QueueID = groupList[2].id, SObjectType = 'Case'));
            insert qObjList;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Contact Center User'];
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Branch Users'];
        Profile p3 = [SELECT Id FROM Profile WHERE Name = 'Salesforce API Only System Integrations'];
        
        List<User> users = new List<User>();
        User ccMaker = new User();
        ccMaker.LastName = 'CC Maker';
        ccMaker.Username = 'ccMaker@gmail.com';
        ccMaker.Email = 'ccMaker@gmail.com';
        ccMaker.Alias = 'CCM';
        ccMaker.TimeZoneSidKey = 'Asia/Jakarta';
        ccMaker.LocaleSidKey = 'in_ID';
        ccMaker.EmailEncodingKey = 'ISO-8859-1';
        ccMaker.ProfileId = p.Id;
        ccMaker.LanguageLocaleKey = 'en_US';
        ccMaker.IsActive = true;
        ccMaker.SCC_Area__c = 'KP00';
        ccMaker.SCC_Area_Description__c = 'Kantor Pusat';
        ccMaker.SCC_Branch__c = '00229';
        users.add(ccMaker);
        
        User branchMaker = new User();
        branchMaker.LastName = 'Branch Maker';
        branchMaker.Username = 'branchMaker@gmail.com';
        branchMaker.Email = 'branchMaker@gmail.com';
        branchMaker.Alias = 'BranchM';
        branchMaker.TimeZoneSidKey = 'Asia/Jakarta';
        branchMaker.LocaleSidKey = 'in_ID';
        branchMaker.EmailEncodingKey = 'ISO-8859-1';
        branchMaker.ProfileId = p2.Id;
        branchMaker.LanguageLocaleKey = 'en_US';
        branchMaker.IsActive = true;
        branchMaker.SCC_Area__c = 'KW25';
        branchMaker.SCC_Area_Description__c = 'Regional Office Malang';
        branchMaker.SCC_Branch__c = '00007';
        branchMaker.Branch_Unit__c = '7 - KC Banyuwangi';
        users.add(branchMaker);
        
        User iUser = new User();
        iUser.LastName = 'BRI Integration';
        iUser.Username = 'BRIIntegration@gmail.com';
        iUser.Email = 'BRIIntegration@gmail.com';
        iUser.Alias = 'IUser';
        iUser.TimeZoneSidKey = 'Asia/Jakarta';
        iUser.LocaleSidKey = 'in_ID';
        iUser.EmailEncodingKey = 'ISO-8859-1';
        iUser.ProfileId = p3.Id;
        iUser.LanguageLocaleKey = 'en_US';
        iUser.IsActive = true;
        users.add(iUser);
        insert users;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_CC_Maker'];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SCC_Branch_Maker'];
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'Integration_Permmission'];
        
        List<Id> userIds = new List<Id>{ccMaker.Id, branchMaker.Id, iUser.Id};
        List<PermissionSetAssignment> currPSA = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN :userIds];
        if(currPSA.size()==0){
            System.runAs(new User(Id = UserInfo.getUserId())) {
                List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
                psa.add(new PermissionSetAssignment(AssigneeId = ccMaker.Id, PermissionSetId = ps.Id));
                psa.add(new PermissionSetAssignment(AssigneeId = branchMaker.Id, PermissionSetId = ps2.Id));
                psa.add(new PermissionSetAssignment(AssigneeId = iUser.Id, PermissionSetId = ps3.Id));
                insert psa;
                
                List<GroupMember> gm = new List<GroupMember>();
                gm.add(new GroupMember(GroupId = groupList[0].Id, UserOrGroupId = ccMaker.Id));
                gm.add(new GroupMember(GroupId = groupList[1].Id, UserOrGroupId = branchMaker.Id));
                insert gm;
            }
        }
        
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
        
        Account acc = new Account(LastName = 'Test');
        
        Branch_Unit__c bu = new Branch_Unit__c(Name = '7 - KC Banyuwangi', Nama_Cabang__c = 'KC Banyuwangi', Branch_Code__c = '7');
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert callType;
            insert acc;
            insert bu;
        }
        
        Case cs = new Case();
        cs.Subject = 'CC Maker owned Case';
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
        cs.OwnerId = groupList[2].id;
        cs.SCC_Drone_Ticket_ID__c = '134567';
        
        Case cs2 = new Case();
        cs2.Subject = 'Branch Maker owned Case';
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
        cs2.OwnerId = groupList[2].id;
        cs2.SCC_Drone_Ticket_ID__c = '456345';
        
        Case cs3 = new Case();
        cs3.Subject = 'Branch Maker owned Case';
        cs3.Description = 'Test2';
        cs3.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs3.AccountId = acc.Id;
        cs3.SCC_Cust_Phone1__c = '081234567890';
        cs3.Cust_Current_Phone__c = '081234567890';
        cs3.SCC_Amount__c = 3000000;
        cs3.SCC_Card_Number__c = '1234567890123456';
        cs3.SCC_Account_Number__c = '1234567890123456';
        cs3.SSC_Call_Type_Description__c = 'Test';
        cs3.Status = 'Escalated';
        cs3.SCC_Call_Type__c = callType.Id;
        cs3.OwnerId = groupList[2].id;
        cs3.SCC_Drone_Ticket_ID__c = '134567';
        
        System.runAs(ccMaker) {
            insert cs;
        }
        
        System.runAs(branchMaker) {
            insert new List<Case>{cs2, cs3};
        }
    }
    
    @isTest
    static void testReturnDrone() {
        User iUser = [SELECT Id FROM User WHERE LastName = 'BRI Integration'];
        List<Case> returnedCases = [SELECT Id, Status FROM Case];
        for (Integer i = 0; i < returnedCases.size(); i++) {
            returnedCases[i].Status = 'Returned';
        }
        
        system.debug(returnedCases);
        System.runAs(iUser) {
            update returnedCases;
        }
        
        List<Case> updatedCases = [SELECT Id, Status, SCC_Drone_Ticket_ID__c, SCC_Sub_Escalation_Level__c FROM Case];
        System.assertEquals(updatedCases[0].Status, 'Working', 'Status should be Working');
        System.assertEquals(updatedCases[1].SCC_Drone_Ticket_ID__c, null, 'Drone Ticket ID should be blank');
        System.assertEquals(updatedCases[2].SCC_Sub_Escalation_Level__c, null, 'Sub Escalation Level should be blank');
    }
}