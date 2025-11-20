/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCC_ApprovalProcess_Test {
    @TestSetup
    static void setupdata(){
        // Step 1: Create test data for the related objects.

        // Create users and assign permission set in a separate context
        User u1, u2, u3;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Get the Permission Set first
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'WFM_Agent'];
            
            String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@example.com';

            // Create mock Users
            u1 = new User(
                Alias = 'Test1',
                Email = 'test1@example.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                Username = uniqueUsername  + 1,
                LastName = 'User1',
                FirstName = 'Test',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                User_Level__c = 'Agent',
                Agent_Type__c = 'MRS'
            );
            insert u1;
            
            // Assign Permission Set only to u1
            PermissionSetAssignment psAssignment = new PermissionSetAssignment(
                AssigneeId = u1.Id,
                PermissionSetId = ps.Id
            );
            insert psAssignment;
            
            u2 = new User(
                Alias = 'Test2',
                Email = 'test3@example.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                Username = uniqueUsername + 2,
                LastName = 'User2',
                FirstName = 'Test',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                User_Level__c = 'Agent Leader',
                Agent_Type__c = 'MRS'
            );
            insert u2;
            
            u3 = new User(
                Alias = 'Test3',
                Email = 'test1@example.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                Username = uniqueUsername + 3,
                LastName = 'User3',
                FirstName = 'Test',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                User_Level__c = 'SPV',
                Agent_Type__c = 'MRS'
            );
            insert u3;
            
            User u4 = new User(
                Id = UserInfo.getUserId(),
                User_Level__c = 'Assistant Manager',
                Agent_Type__c = 'MRS'
            );
            update u4;
        }
        List<Opsi_Jadwal__c> listopsi = new List<Opsi_Jadwal__c>();
        for(integer i=1; i<=22;i++){
            Opsi_Jadwal__c oj = new Opsi_Jadwal__c(Kode__c = 'S'+i, Name = 'S'+i);
            listopsi.add(oj);
        }
        Opsi_Jadwal__c libur = new Opsi_Jadwal__c(Kode__c = 'LIBUR', Name = 'LIBUR');
        Opsi_Jadwal__c off = new Opsi_Jadwal__c(Kode__c = 'OFF', Name = 'OFF');
        listopsi.add(libur);
        listopsi.add(off);
        insert listopsi;

        // Create Poin_Shift__c record
        Poin_Shift__c ps = new Poin_Shift__c(
            Type_Pengajuan__c = 'Request Off',
            Poin__c = 1
        );
        insert ps;
    }

    @isTest
    static void BulkApprove() {
        // TO DO: implement unit test
        Map<String,User> mapus = new Map<String,User>();
        User u1, u2, u3, u4;
        for(User us:[select id,User_Level__c,Agent_Type__c from User where Agent_Type__c='MRS' and User_Level__c!=null]){
            mapus.put(us.User_Level__c,us);
        }
        u1 = mapus.get('Agent');
        u2 = mapus.get('Agent Leader');
        u3 = mapus.get('SPV');
        u4 = mapus.get('Assistant Manager');
        
        //Create User Type
        User_Type__c ut1 = new User_Type__c(
            User__c = u1.Id,
            Manager__c = u2.Id,
            User_Level__c = 'Agent',
            Agent_Type__c = 'MRS'
        );
        insert ut1;
        
        User_Type__c ut2 = new User_Type__c(
            User__c = u2.Id,
            Manager__c = u3.Id,
            User_Level__c = 'Agent Leader',
            Agent_Type__c = 'MRS'
        );
        insert ut2;
        
        User_Type__c ut3 = new User_Type__c(
            User__c = u3.Id,
            Manager__c = UserInfo.getUserId(),
            User_Level__c = 'SPV',
            Agent_Type__c = 'MRS'
        );
        insert ut3;
        
        User_Type__c ut4 = new User_Type__c(
            User__c = UserInfo.getUserId(),
            User_Level__c = 'Assistant Manager',
            Agent_Type__c = 'MRS'
        );
        insert ut4;

        // Create Cuti_Poin_Karyawan__c with required fields
        Cuti_Poin_Karyawan__c cpk = new Cuti_Poin_Karyawan__c(
            Nama_Karyawan__c = u1.Id,
            Poin_Terpakai__c = 0,          
            Unique_Id__c = u1.Id
        );
        insert cpk;

        // Create Cuti_Karyawan__c without modifying Sisa_Cuti__c (since it's read-only)
        Cuti_Karyawan__c ck = new Cuti_Karyawan__c();
        ck.Nama_Karyawan__c = u1.id;
        ck.Tahun__c = system.today().year();
        ck.Quota_Cuti__c = 10;
        ck.Tahun_Cuti__c = 'Tahun Ini';
        ck.Unique_Id__c = u1.id+'-'+system.today().year();
        ck.Cuti_poin_Karyawan__c = cpk.id;
        Date dt = system.today();
        List<Jadwal_Karyawan__c> listjk = new List<Jadwal_Karyawan__c>();
        List<Opsi_Jadwal__c> listopsi = [Select id from Opsi_Jadwal__c];
        for(Integer i = 0 ;i<listopsi.size();i++){
            Jadwal_Karyawan__c jk = new Jadwal_Karyawan__c(
                Nama_Karyawan__c = u1.Id,
                Tanggal__c = Date.today().addDays(i),
                Opsi_Jadwal__c = listopsi[i].Id,  // Correctly reference the Opsi_Jadwal__c record here
                Unique_ID__c = u1.Id + '-' + Date.today().addDays(i)
            );
            listjk.add(jk);
        }
        insert listjk;

        // Create Request_Leave__c (Cuti request)
        Request_Leave__c rl = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Cuti',
            Date_From__c = Date.today().addDays(2),
            Date_To__c = Date.today().addDays(3),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl;
        SCC_ApprovalProcess.FlowInputvalues fi2 = new SCC_ApprovalProcess.FlowInputvalues();
        fi2.query = 'select id from Request_Leave__c limit 1';
        fi2.type = 'Bulk';
        fi2.recordId = rl.Id;
        fi2.action = 'Reject';
        fi2.comment = 'Reject';
        fi2.userId = UserInfo.getUserId();
        List<SCC_ApprovalProcess.FlowInputvalues> listfi = new List<SCC_ApprovalProcess.FlowInputvalues>{fi2};
        SCC_ApprovalProcess.invocablevoid(listfi);
    }

    @isTest
    static void SingleApprove() {
        // TO DO: implement unit test
        Map<String,User> mapus = new Map<String,User>();
        User u1, u2, u3, u4;
        for(User us:[select id,User_Level__c,Agent_Type__c from User where Agent_Type__c='MRS' and User_Level__c!=null]){
            mapus.put(us.User_Level__c,us);
        }
        u1 = mapus.get('Agent');
        u2 = mapus.get('Agent Leader');
        u3 = mapus.get('SPV');
        u4 = mapus.get('Assistant Manager');
        
        //Create User Type
        User_Type__c ut1 = new User_Type__c(
            User__c = u1.Id,
            Manager__c = u2.Id,
            User_Level__c = 'Agent',
            Agent_Type__c = 'MRS'
        );
        insert ut1;
        
        User_Type__c ut2 = new User_Type__c(
            User__c = u2.Id,
            Manager__c = u3.Id,
            User_Level__c = 'Agent Leader',
            Agent_Type__c = 'MRS'
        );
        insert ut2;
        
        User_Type__c ut3 = new User_Type__c(
            User__c = u3.Id,
            Manager__c = UserInfo.getUserId(),
            User_Level__c = 'SPV',
            Agent_Type__c = 'MRS'
        );
        insert ut3;
        
        User_Type__c ut4 = new User_Type__c(
            User__c = UserInfo.getUserId(),
            User_Level__c = 'Assistant Manager',
            Agent_Type__c = 'MRS'
        );
        insert ut4;

        // Create Cuti_Poin_Karyawan__c with required fields
        Cuti_Poin_Karyawan__c cpk = new Cuti_Poin_Karyawan__c(
            Nama_Karyawan__c = u1.Id,
            Poin_Terpakai__c = 0,          
            Unique_Id__c = u1.Id
        );
        insert cpk;

        // Create Cuti_Karyawan__c without modifying Sisa_Cuti__c (since it's read-only)
        Cuti_Karyawan__c ck = new Cuti_Karyawan__c();
        ck.Nama_Karyawan__c = u1.id;
        ck.Tahun__c = system.today().year();
        ck.Quota_Cuti__c = 10;
        ck.Tahun_Cuti__c = 'Tahun Ini';
        ck.Unique_Id__c = u1.id+'-'+system.today().year();
        ck.Cuti_poin_Karyawan__c = cpk.id;
        Date dt = system.today();
        List<Jadwal_Karyawan__c> listjk = new List<Jadwal_Karyawan__c>();
        List<Opsi_Jadwal__c> listopsi = [Select id from Opsi_Jadwal__c];
        for(Integer i = 0 ;i<listopsi.size();i++){
            Jadwal_Karyawan__c jk = new Jadwal_Karyawan__c(
                Nama_Karyawan__c = u1.Id,
                Tanggal__c = Date.today().addDays(i),
                Opsi_Jadwal__c = listopsi[i].Id,  // Correctly reference the Opsi_Jadwal__c record here
                Unique_ID__c = u1.Id + '-' + Date.today().addDays(i)
            );
            listjk.add(jk);
        }
        insert listjk;

        // Create Request_Leave__c (Cuti request)
        Request_Leave__c rl = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Cuti',
            Date_From__c = Date.today().addDays(2),
            Date_To__c = Date.today().addDays(3),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl;
        SCC_ApprovalProcess.FlowInputvalues fi2 = new SCC_ApprovalProcess.FlowInputvalues();
        fi2.query = 'select id from Request_Leave__c limit 1';
        fi2.type = 'Single';
        fi2.recordId = rl.Id;
        fi2.action = 'Reject';
        fi2.comment = 'Reject';
        fi2.userId = UserInfo.getUserId();
        List<SCC_ApprovalProcess.FlowInputvalues> listfi = new List<SCC_ApprovalProcess.FlowInputvalues>{fi2};
        SCC_ApprovalProcess.invocablevoid(listfi);
    }

    @isTest
    static void BulkError() {
        // TO DO: implement unit test
        SCC_BulkApprovalProccess.insertErrorLog(null,'test class');
    }
}