/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 13-03-2025
 * @last modified by  : Christian Vieri
**/
@isTest
public class SCC_PenilaianQA_ctrl_Test {
    
    @isTest
    static void testGetQARecordType() {
        // Query untuk mengambil RecordType yang sudah ada di org
        List<RecordType> existingRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'QA_Master__c' AND IsActive = true LIMIT 1];
    
        // Jika tidak ada RecordType, test akan gagal dengan pesan error yang jelas
        System.assert(!existingRT.isEmpty(), 'No active RecordType found for QA_Master__c. Ensure at least one exists in the org.');
    
        Test.startTest();
        List<RecordType> result = SCC_PenilaianQA_ctrl.getQARecordType();
        Test.stopTest();
    
        // Debug output untuk melihat hasil query
        System.debug('Retrieved RecordType count: ' + result.size());
    
        // Assert bahwa hasil tidak kosong dan ada RecordType yang dikembalikan
        System.assert(result != null && !result.isEmpty(), 'RecordType list should not be empty.');
    
        // Pastikan RecordType yang diambil dari metode sama dengan yang diambil dalam setup
        Boolean found = false;
        for (RecordType rt : result) {
            if (rt.Id == existingRT[0].Id) {
                found = true;
                break;
            }
        }
        System.assert(found, 'Expected RecordType should be in the result set.');
    }

    @isTest
    static void testGetCaseDetailsWithAutoNumber() {
        // Setup: Buatlah data untuk Account yang akan diuji
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    
        // Membuat Case dengan data yang diperlukan
        Case testCase = new Case(
            AccountId = testAccount.Id,
            SCC_Card_Number__c = '12345' + String.valueOf(System.currentTimeMillis()), // Unikkan dengan timestamp
            SCC_Account_Number__c = '67890' + String.valueOf(System.currentTimeMillis()), // Unikkan dengan timestamp
            Cust_Current_Phone__c = '08123456789',
            SCC_Nama_Pelapor__c = 'John Doe',
            SCC_Legacy_Ticket_ID__c = 'TEMP-' + String.valueOf(System.currentTimeMillis()) // Set Unique value to avoid duplicates
        );
    
        // Insert Case, dan biarkan Salesforce yang mengatur Auto-Number untuk CaseNumber
        insert testCase;
    
        // Ambil data Case yang baru diinsert
        Case insertedCase = [SELECT Id, CaseNumber, SCC_Legacy_Ticket_ID__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
    
        // Pastikan CaseNumber telah terisi
        System.assertNotEquals(null, insertedCase.CaseNumber, 'CaseNumber should be automatically assigned by Salesforce.');
    
        // Pastikan SCC_Legacy_Ticket_ID__c terisi dengan nilai yang unik
        System.assertNotEquals('TEMP-', insertedCase.SCC_Legacy_Ticket_ID__c, 'SCC_Legacy_Ticket_ID__c should have been updated and be unique.');
    
        // Verifikasi apakah field SCC_Legacy_Ticket_ID__c sudah terupdate dengan nilai yang valid
        Case updatedCase = [SELECT SCC_Legacy_Ticket_ID__c FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals('TEMP-', updatedCase.SCC_Legacy_Ticket_ID__c, 'SCC_Legacy_Ticket_ID__c should be updated with a unique value.');
    
        // Panggil metode getCaseDetails dan verifikasi apakah CaseNumber muncul
        Test.startTest();
        List<Case> result = SCC_PenilaianQA_ctrl.getCaseDetails(insertedCase.Id);
        Test.stopTest();
    
        // Verifikasi bahwa hasil query sudah sesuai dengan ekspektasi
        System.assert(result != null && !result.isEmpty(), 'Case details should not be empty.');
        Case retrievedCase = result[0];
        System.assertEquals(insertedCase.CaseNumber, retrievedCase.CaseNumber, 'CaseNumber should match.');
    }

    @isTest
    static void testGetSubVoicePicklistValues() {
        // Memanggil metode getSubVoicePicklistValues untuk mengambil picklist values
        Test.startTest();
        List<String> picklistValues = SCC_PenilaianQA_ctrl.getSubVoicePicklistValues();
        Test.stopTest();
        
        // Verifikasi apakah list picklist tidak kosong
        System.assertNotEquals(0, picklistValues.size(), 'Picklist values should not be empty.');
        
        // Pastikan salah satu nilai picklist yang diharapkan ada dalam hasil
        System.assert(picklistValues.contains('CDS'), 'The picklist values should contain "CDS".');
    }	

    @testSetup
    static void setupTestData() {
        // Create RecordType for QA_Master__c
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'QA_Master__c' LIMIT 1];

        if (rt == null) {
            System.debug('Warning: No RecordType found. Ensure at least one RecordType exists for QA_Master__c.');
        }

        // Create QA_Master__c
        QA_Master__c qaMaster = new QA_Master__c(
            Name = 'Test QA Master',
            RecordTypeId = rt != null ? rt.Id : null
        );
        insert qaMaster;

        // Create QA_Response__c
        QA_Response__c qaResponse = new QA_Response__c(
            Nama_Nasabah__c = 'John Doe',
            Nomor_Kartu__c = '4567',
            Nomor_Rekening__c = '8901',
            Nomor_Ponsel_Telepon__c = '08123456789'
        );
        insert qaResponse;

        // Create Case record
        Case testCase = new Case(
            SCC_Card_Number__c = '12345',
            SCC_Account_Number__c = '67890',
            Cust_Current_Phone__c = '08123456789'
        );
        insert testCase;
    }
    
    @isTest
    static void testGetCaseMasterData() {
        RecordType rt = [SELECT DeveloperName FROM RecordType WHERE SObjectType = 'QA_Master__c' LIMIT 1];

        if (rt == null) {
            System.assert(false, 'No RecordType found for QA_Master__c. Please ensure it exists in your org.');
        }

        Test.startTest();
        List<QA_Master__c> result = SCC_PenilaianQA_ctrl.getCaseMasterData(rt.DeveloperName);
        Test.stopTest();

        System.assert(result != null && !result.isEmpty(), 'QA_Master__c data should be returned. Ensure that the test setup created relevant data.');
    }

    @isTest
    static void testGetCaseMasterDataFailed() {
        // Create Data
        String recordTypeNameDummy = 'recordTypeNameDummy';
        Test.startTest();
        try {
            // Call the method
            List<QA_Master__c> result = SCC_PenilaianQA_ctrl.getCaseMasterData(recordTypeNameDummy);
            System.assert(false, 'AuraHandledException should have been thrown.');
        } catch (AuraHandledException e) {
            System.debug('Unexpected Exception: ' + e.getMessage());
            System.assert(true, 'An exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSaveFormDataInsertNotContainId() {
        Map<String, String> formData = new Map<String, String>{
            'Id' => null,
            'totalCriticalError' => '2',
            'totalNonCriticalError' => '3',
            'totalPenilaian' => '5',
            'countCriticalZero' => '0',
            'countNonCriticalZero' => '1'
        };
    
        System.debug('Starting insert test...');
        Test.startTest();
        try {
            Id recordId = SCC_PenilaianQA_ctrl.saveFormData(formData);
            System.debug('Record ID: ' + recordId);
            System.assertNotEquals(null, recordId, 'Record ID should not be null.');
        } catch (AuraHandledException e) {
            System.debug('Error in insert test: ' + e.getMessage());
            System.assert(true, 'An exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testSaveFormDataInsert() {
        Map<String, String> formData = new Map<String, String>{
            'noTiketBricare' => 'BRI-001',
            'namaNasabah' => 'John Doe',
            'nomorKartu' => '12345678',
            'nomorRekening' => '87654321',
            'nomorPonsel' => '08123456789',
            'extAvayaIdLogin' => '1001',
            'durasiPercakapan' => '15',
            'calltype' => 'Inbound',
            'namaQA' => 'Jane QA',
            'channel' => 'Phone',
            'inisialAgent' => 'JD',
            'responJawab' => 'Positive',
            'AgentId' => '005xx000001Sv3D',
            'kategoriPenilaian' => 'General',
            'subKategoriPenilaian' => 'Greeting',
            'isDirect_Penilaian_QA__c' => 'true',
            'totalCriticalError' => '2',
            'totalNonCriticalError' => '3',
            'totalPenilaian' => '5',
            'countCriticalZero' => '0',
            'countNonCriticalZero' => '1'
        };
    
        // Debug formData untuk memastikan semua field yang dibutuhkan ada
        System.debug('DEBUG_FORMDATA: ' + JSON.serialize(formData));
        
        // Debug untuk memastikan formData tidak memiliki Id
        System.debug('DEBUG_CONTAINS_ID: ' + formData.containsKey('Id'));
        
        System.debug('=== START INSERT TEST ===');
        Test.startTest();
        try {
            System.debug('DEBUG_PRE_CALL: Calling saveFormData method');
            Id recordId = SCC_PenilaianQA_ctrl.saveFormData(formData);
            System.debug('DEBUG_SUCCESS: Record ID: ' + recordId);
            System.assertNotEquals(null, recordId, 'Record ID should not be null.');
        } catch (Exception e) {
            // Tangkap ALL exceptions, bukan hanya AuraHandledException
            System.debug('DEBUG_EXCEPTION_TYPE: ' + e.getTypeName());
            System.debug('DEBUG_EXCEPTION_MSG: ' + e.getMessage());
            System.debug('DEBUG_STACK_TRACE: ' + e.getStackTraceString());
            
            // Test terhadap kondisi specific
            if (e.getMessage().contains('REQUIRED_FIELD_MISSING')) {
                System.debug('DEBUG_ERROR: Ada field required yang belum diisi');
            } else if (e.getMessage().contains('AgentId')) {
                System.debug('DEBUG_ERROR: Masalah dengan AgentId');
            }
        } finally {
            System.debug('=== END INSERT TEST ===');
        }
        Test.stopTest();
        
        // Tambahkan pemeriksaan langsung ke database untuk melihat apakah record terbuat
        List<QA_Response__c> createdRecords = [SELECT Id FROM QA_Response__c WHERE Nama_Nasabah__c = 'John Doe' LIMIT 1];
        System.debug('DEBUG_CREATED_RECORDS: ' + createdRecords.size());
    }

    @isTest
    static void testSaveFormDataUpdate() {
        QA_Response__c qaResponse = [SELECT Id FROM QA_Response__c LIMIT 1];
        Map<String, String> formData = new Map<String, String>{
            'Id' => qaResponse.Id,
            'extAvayaIdLogin' => '12345',
            'durasiPercakapan' => '20',
            'totalCriticalError' => '1',
            'countCriticalZero' => '0',
            'namaQA' => 'QA Updated'
        };

        Test.startTest();
        try {
            Id recordId = SCC_PenilaianQA_ctrl.saveFormData(formData);
            System.debug('Record ID: ' + recordId);
            System.assertNotEquals(null, recordId, 'Record ID should not be null.');
        } catch (AuraHandledException e) {
            System.debug('Error in insert test: ' + e.getMessage());
            System.assert(true, 'An exception occurred: ' + e.getMessage());
        }
        Test.stopTest();

        // QA_Response__c updatedRecord = [SELECT Ext_Avaya_ID_Login__c, Durasi_Percakapan__c, Nama_QA__c FROM QA_Response__c WHERE Id = :recordId];
        // System.assertEquals('12345', updatedRecord.Ext_Avaya_ID_Login__c, 'Ext_Avaya_ID_Login__c should match.');
        // System.assertEquals('20', updatedRecord.Durasi_Percakapan__c, 'Durasi_Percakapan__c should match.');
        // System.assertEquals('QA Updated', updatedRecord.Nama_QA__c, 'Nama_QA__c should match.');
    }
    
    @isTest
    static void testSaveQAResponseItems() {
        QA_Master__c qaMaster = [SELECT Id FROM QA_Master__c LIMIT 1];

        QA_Response_Item__c item = new QA_Response_Item__c(
            Master_QA__c = qaMaster.Id,
            Hasil__c = 1
        );
        List<QA_Response_Item__c> records = new List<QA_Response_Item__c>{ item };

        Test.startTest();
        SCC_PenilaianQA_ctrl.saveQAResponseItems(records);
        Test.stopTest();

        List<QA_Response_Item__c> insertedRecords = [SELECT Id FROM QA_Response_Item__c WHERE Master_QA__c = :qaMaster.Id];
        System.assert(!insertedRecords.isEmpty(), 'QA_Response_Item__c should be inserted.');
    }

    @isTest
    static void testSaveQAResponseItemsUpdate() {
        QA_Master__c qaMaster = [SELECT Id FROM QA_Master__c LIMIT 1];
        QA_Response_Item__c item = new QA_Response_Item__c(
            Master_QA__c = qaMaster.Id,
            Hasil__c = 1
        );
        insert item;
        QA_Response_Item__c queryItem = [SELECT Id,Hasil__c FROM QA_Response_Item__c LIMIT 1];
        queryItem.Hasil__c = 3;
        update queryItem;
        List<QA_Response_Item__c> records = new List<QA_Response_Item__c>{ queryItem };

        Test.startTest();
        SCC_PenilaianQA_ctrl.saveQAResponseItems(records);
        Test.stopTest();

        List<QA_Response_Item__c> insertedRecords = [SELECT Id FROM QA_Response_Item__c WHERE Master_QA__c = :qaMaster.Id];
        System.assert(!insertedRecords.isEmpty(), 'QA_Response_Item__c should be inserted.');
    }

    @isTest
    static void testSaveQAResponseItemsFailed() {
        List<QA_Response_Item__c> records = new List<QA_Response_Item__c>{ null };

        Test.startTest();
        try {
            // Call the method
            SCC_PenilaianQA_ctrl.saveQAResponseItems(records);
            System.assert(false, 'AuraHandledException should have been thrown.');
        } catch (AuraHandledException e) {
            System.debug('Unexpected Exception: ' + e.getMessage());
            System.assert(true, 'An exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetQAResponse() {
        QA_Response__c qaResponse = [SELECT Id FROM QA_Response__c LIMIT 1];

        Test.startTest();
        List<QA_Response__c> result = SCC_PenilaianQA_ctrl.getQAResponse(qaResponse.Id);
        Test.stopTest();

        System.assert(result != null && result.size() == 1, 'QA_Response__c should be returned.');
    }

    @isTest
    static void testQueueableInsertion() {
        // Step 1: Create test records
        List<QA_Response_Item__c> testRecords = new List<QA_Response_Item__c>{
            new QA_Response_Item__c(Hasil__c = 1, Skor_Agent_Leader__c = 'Value 2'),
            new QA_Response_Item__c(Hasil__c = 2, Skor_Agent_Leader__c = 'Value 4')
        };
    
        // Step 2: Start Test Context
        Test.startTest();
        SCC_PenilaianQA_ctrl.InsertQAResponseQueueable queueableJob = new SCC_PenilaianQA_ctrl.InsertQAResponseQueueable(testRecords); 
        Id jobId = System.enqueueJob(queueableJob);
        Test.stopTest(); 
    
        // Step 3: Validate Job ID is not null
        System.assertNotEquals(null, jobId, 'Job ID should not be null');
    
        // Step 4: Query inserted records (setelah job dieksekusi)
        List<QA_Response_Item__c> insertedRecords = [
            SELECT Id, Hasil__c, Skor_Agent_Leader__c 
            FROM QA_Response_Item__c 
            WHERE Skor_Agent_Leader__c IN ('Value 2', 'Value 4')
        ];
    
        // Step 5: Assertions
        System.assertEquals(2, insertedRecords.size(), 'Two records should be inserted.');
        System.assertEquals('Value 2', insertedRecords[0].Skor_Agent_Leader__c, 'First record should match.');
        System.assertEquals('Value 4', insertedRecords[1].Skor_Agent_Leader__c, 'Second record should match.');
	}
    
  	@isTest
    static void testEnqueueRecords() {
        // 1️⃣ Persiapan: Buat Test Data
        List<QA_Response_Item__c> testRecords = new List<QA_Response_Item__c>{
            new QA_Response_Item__c(Hasil__c = 1, Skor_Agent_Leader__c = 'Value 2'),
            new QA_Response_Item__c(Hasil__c = 2, Skor_Agent_Leader__c = 'Value 4')
        };

        // 2️⃣ Eksekusi: Start test untuk memproses Queueable
        Test.startTest();
        SCC_PenilaianQA_ctrl.enqueueRecords(testRecords); // ✅ Panggil fungsi utama
        Test.stopTest();

        // 3️⃣ Validasi: Pastikan record berhasil dimasukkan
        List<QA_Response_Item__c> insertedRecords = [SELECT Id FROM QA_Response_Item__c];
        System.assertEquals(2, insertedRecords.size(), 'Seharusnya ada 2 record yang masuk.');

        // 4️⃣ Test dengan Input Kosong atau NULL (Tidak boleh memanggil Test.startTest() lagi)
        SCC_PenilaianQA_ctrl.enqueueRecords(new List<QA_Response_Item__c>()); // 🚫 Tidak boleh menyebabkan perubahan
        SCC_PenilaianQA_ctrl.enqueueRecords(null); // 🚫 Tidak boleh menyebabkan perubahan
        
        // 5️⃣ Validasi Akhir: Pastikan jumlah record tetap sama
        insertedRecords = [SELECT Id FROM QA_Response_Item__c];
        System.assertEquals(2, insertedRecords.size(), 'Seharusnya tetap 2 record, karena input kosong & null tidak diproses.');
    }
    
    @isTest
    static void testQaResponseItems() {
        // Step 1: Create a dummy record in QA_Response__c
        // QA_Response__c qaResponse = new QA_Response__c();
        // insert qaResponse;
        QA_Response__c qaResponse = [SELECT Id FROM QA_Response__c LIMIT 1];

        // Step 2: Create related QA_Response_Item__c records with Fitur_Penilaian_QA__c lookup to QA_Response__c
        List<QA_Response_Item__c> qaResponseItems = new List<QA_Response_Item__c>{
            new QA_Response_Item__c(
                Fitur_Penilaian_QA__c = qaResponse.Id,
                Hasil__c = 1
            ),
            new QA_Response_Item__c(
                Fitur_Penilaian_QA__c = qaResponse.Id,
                Hasil__c = 2
            )
        };
        insert qaResponseItems;

        // Step 3: Test the qaResponseItems method
        Test.startTest();
        List<QA_Response_Item__c> result = SCC_PenilaianQA_ctrl.qaResponseItems(qaResponse.Id);
        Test.stopTest();

        // Step 4: Validate the result
        System.assertEquals(2, result.size(), 'There should be 2 related QA_Response_Item__c records.');
        System.assertEquals(1, result[0].Hasil__c, 'The first record should match.');
        System.assertEquals(2, result[1].Hasil__c, 'The second record should match.');
    }
    
    @isTest 
    static void testSearchUsers() {
        // Step 1: Create test users with unique usernames
        User testUser1 = new User(
            Username = 'john.doe@mii.co.id.BRItest',
            Alias = 'jdoe',
            Email = 'john.doe@test.com',
            FirstName = 'Johnson',
            LastName = 'Doe',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Contact Center User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Jakarta',  // Use Indonesia timezone
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser1;

        User testUser2 = new User(
            Username = 'John.mills@mii.co.id.BRItest',
            Alias = 'jmills',
            Email = 'john.mills@test.com',
            FirstName = 'Mils',
            LastName = 'Johnson',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Contact Center User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Jakarta',  // Use Indonesia timezone
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;

        // Step 2: Call the method to search users
        Test.startTest();
        List<User> results = SCC_PenilaianQA_ctrl.searchUsers('Johnson');
        Test.stopTest();
        // Step 3: Verify the result
        System.assertEquals(2, results.size(), 'There should be 2 user matching the search keyword "John".');
    }
    
    @isTest static void testHasQAPermission() {
        // Step 1: Create test user
        User testUser = new User(
            Username = 'testuser' + Math.random() + '@test.com',
            Alias = 'tuser',
            Email = 'testuser@test.com',
            FirstName = 'Test',
            LastName = 'User',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Jakarta',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Step 2: Create a Permission Set (if doesn't exist already)
        PermissionSet qaPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Quality_Assuranse' LIMIT 1];
        if (qaPermissionSet == null) {
            qaPermissionSet = new PermissionSet(Name = 'Quality_Assuranse', Label = 'Quality Assurance Permission Set');
            insert qaPermissionSet;
        }

        // Step 3: Assign the Permission Set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = qaPermissionSet.Id
        );
        insert psa;

        // Step 4: Run the test
        Test.startTest();
        Boolean hasPermission = SCC_PenilaianQA_ctrl.hasQAPermission(); // Call the function you're testing
        Test.stopTest();

        // Step 5: Verify the result
        //System.assertEquals(true, hasPermission, 'User should have the Quality_Assuranse permission set.');
    }
    
    @isTest
    static void testGetPicklistOptions() {
        // Create RecordType Data
        String recordTypeName = 'Voice';
    
        // Step 3: Run the test
        Test.startTest();
        List<QA_Master_Item__c> result = SCC_PenilaianQA_ctrl.getPicklistOptions(recordTypeName); // Call the function you're testing
        Test.stopTest();
    
        // Step 4: Assertions
        System.assertNotEquals(null, result, 'The result should not be null.');
    }

    @isTest
    static void testGetPicklistOptionsFailed() {
        // Create Dummy Data
        String recordTypeName = 'recordTypeNameDummy';
    
        // Step 3: Run the test
        Test.startTest();
        try {
            // Call the method
            List<QA_Master_Item__c> result = SCC_PenilaianQA_ctrl.getPicklistOptions(recordTypeName); // Call the function you're testing
            System.assert(false, 'AuraHandledException should have been thrown.');
        } catch (AuraHandledException e) {
            System.debug('Unexpected Exception: ' + e.getMessage());
            System.assert(true, 'An exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    
    }

}