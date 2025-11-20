@isTest
public class SCC_RequestCuti_Manager_Test {
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
            Poin__c = 0
        );
        insert ps;
    }

    @isTest
    public static void testCutiApproved() {      
        // Step 1: Create test data for the related objects.

        // Create users and assign permission set in a separate context
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
        
        rl.Approval_Status__c = 'Submit for Approval';
        update rl;
        rl.Approval_Status__c='Approve by Asisten Manager';
        update rl;
    }

    @isTest
    public static void testCutiRejected() {      
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

        // Create Poin_Shift__c record
        Poin_Shift__c ps = new Poin_Shift__c(
            Type_Pengajuan__c = 'Request Off',
            Poin__c = 0
        );
        insert ps;
        
        // Create Cuti_Poin_Karyawan__c with required fields
        Cuti_Poin_Karyawan__c cpk = new Cuti_Poin_Karyawan__c(
            Nama_Karyawan__c = u1.Id,
            Poin_Terpakai__c = 0,          
            Unique_Id__c = u1.Id
        );
        insert cpk;

        Poin_Karyawan__c pk = new Poin_Karyawan__c(
            Cuti_Poin_Karyawan__c = cpk.id,
            nama_karyawan__c = u1.id,
            Poin__c = 100,
            Score__c = 100
        );

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
        
        rl.Approval_Status__c = 'Submit for Approval';
        update rl;
        rl.Approval_Status__c = 'Reject by Asisten Manager';
        update rl;
    }

    @isTest
    public static void testOffApproved() {      
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

        Poin_Karyawan__c pk = new Poin_Karyawan__c(
            Cuti_Poin_Karyawan__c = cpk.id,
            nama_karyawan__c = u1.id,
            Poin__c = 100,
            Score__c = 100
        );

        // Create Request_Leave__c (Cuti request)
        Request_Leave__c rl = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Off',
            Date_From__c = Date.today().addDays(2),
            Date_To__c = Date.today().addDays(3),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl;
        
        rl.Approval_Status__c = 'Submit for Approval';
        update rl;
        rl.Approval_Status__c = 'Approve by Asisten Manager';
        update rl;
    }

    @isTest
    public static void testOffReject() {      
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

        Poin_Karyawan__c pk = new Poin_Karyawan__c(
            Cuti_Poin_Karyawan__c = cpk.id,
            nama_karyawan__c = u1.id,
            Poin__c = 100,
            Score__c = 100
        );

        // Create Request_Leave__c (Cuti request)
        Request_Leave__c rl = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Off',
            Date_From__c = Date.today().addDays(2),
            Date_To__c = Date.today().addDays(3),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl;
        
        rl.Approval_Status__c = 'Submit for Approval';
        update rl;
        rl.Approval_Status__c = 'Reject by Asisten Manager';
        update rl;
    }

    @isTest
    public static void testDoubleRequestOff() {      
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

        Poin_Karyawan__c pk = new Poin_Karyawan__c(
            Cuti_Poin_Karyawan__c = cpk.id,
            nama_karyawan__c = u1.id,
            Poin__c = 100,
            Score__c = 100
        );

        // Create Request_Leave__c (Cuti request)
        Request_Leave__c rl = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Off',
            Date_From__c = Date.today().addDays(2),
            Date_To__c = Date.today().addDays(3),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl;
        Request_Leave__c rl2 = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Off',
            Date_From__c = Date.today().addDays(4),
            Date_To__c = Date.today().addDays(6),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl2;
    }

    @isTest
    public static void testDoubleRequestCuti() {      
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
        Request_Leave__c rl2 = new Request_Leave__c(
            Nama_Karyawan__c = u1.Id,
            Type_Request__c = 'Request Cuti',
            Date_From__c = Date.today().addDays(4),
            Date_To__c = Date.today().addDays(6),
            Approval_Status__c = 'Draft',
            Agent_Leader__c = u2.Id,
            SPV__c = u3.id,
            Assistant_Manager__c = u4.Id
        );
        insert rl2;
    }
}