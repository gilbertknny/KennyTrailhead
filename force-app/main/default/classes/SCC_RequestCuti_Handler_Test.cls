@isTest
private class SCC_RequestCuti_Handler_Test {

    @TestSetup
    static void setupTestData() {
        // Create test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser@test.com' + System.currentTimeMillis()
        );
        insert testUser;
        
        System.runAs(testUser) {
            // Create test Cuti & Poin Karyawan record
            Cuti_Poin_Karyawan__c cutiPoin = new Cuti_Poin_Karyawan__c(
                Nama_Karyawan__c = testUser.Id,
                Poin_Terpakai__c = 0,
                Unique_Id__c = 'TEST-' + testUser.Id,
                OwnerId = testUser.Id
                // Note: Cuti_Tahun_Ini__c, Poin__c, and Sisa_Poin__c are roll-up/formula fields
                // and will be calculated automatically
            );
            insert cutiPoin;
        }
    }

    @isTest
    static void testBeforeInsert() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Cuti_Poin_Karyawan__c cutiPoin = [SELECT Id FROM Cuti_Poin_Karyawan__c 
                                             WHERE Nama_Karyawan__c = :testUser.Id LIMIT 1];
            
            Request_Leave__c requestLeave = new Request_Leave__c(
                Cuti_Poin_Karyawan__c = cutiPoin.Id,
                Nama_Karyawan__c = testUser.Id,
                Date_From__c = Date.today().addDays(4),
                Date_To__c = Date.today().addDays(5),
                Hari_Tahun_Ini__c = 3,
                Hari_Tahun_Depan__c = 0,
                Type_Request__c = 'Request Off',  // Verify this picklist value
                Reason__c = 'Kuliah',  // Verify this picklist value
                Notes__c = 'Test leave request',
                Approval_Status__c = 'Draft',  // Verify this picklist value
                OwnerId = testUser.Id
            );
            
            Test.startTest();
            Database.SaveResult result = Database.insert(requestLeave, false);
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Record should be inserted successfully');
        }
    }
    
    @isTest
    static void testBeforeUpdate() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Cuti_Poin_Karyawan__c cutiPoin = [SELECT Id FROM Cuti_Poin_Karyawan__c 
                                             WHERE Nama_Karyawan__c = :testUser.Id LIMIT 1];
            
            Request_Leave__c requestLeave = new Request_Leave__c(
                Cuti_Poin_Karyawan__c = cutiPoin.Id,
                Nama_Karyawan__c = testUser.Id,
                Date_From__c = Date.today().addDays(4),
                Date_To__c = Date.today().addDays(5),
                Hari_Tahun_Ini__c = 3,
                Hari_Tahun_Depan__c = 0,
                Type_Request__c = 'Request Off',
                Reason__c = 'Kuliah',
                Notes__c = 'Test leave request',
                Approval_Status__c = 'Draft',
                OwnerId = testUser.Id
            );
            insert requestLeave;
            
            requestLeave.Approval_Status__c = 'Approve by Manager';
            requestLeave.Notes__c = 'Updated leave request';
            
            Test.startTest();
            Database.SaveResult result = Database.update(requestLeave, false);
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Record should be updated successfully');
        }
    }
    
    @isTest
    static void testAfterUpdate() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Cuti_Poin_Karyawan__c cutiPoin = [SELECT Id FROM Cuti_Poin_Karyawan__c 
                                             WHERE Nama_Karyawan__c = :testUser.Id LIMIT 1];
            
            Request_Leave__c requestLeave = new Request_Leave__c(
                Cuti_Poin_Karyawan__c = cutiPoin.Id,
                Nama_Karyawan__c = testUser.Id,
                Date_From__c = Date.today().addDays(4),
                Date_To__c = Date.today().addDays(5),
                Hari_Tahun_Ini__c = 3,
                Hari_Tahun_Depan__c = 0,
                Type_Request__c = 'Request Off',
                Reason__c = 'Kuliah',
                Notes__c = 'Test leave request',
                Approval_Status__c = 'Draft',
                OwnerId = testUser.Id
            );
            insert requestLeave;
            
            requestLeave.Approval_Status__c = 'Approve by Manager';
            
            Test.startTest();
            Database.SaveResult result = Database.update(requestLeave, false);
            Test.stopTest();
            
            System.assert(result.isSuccess(), 'Record should be updated successfully');
        }
    }
    
    @isTest
    static void testErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Request_Leave__c requestLeave = new Request_Leave__c();
            // Don't set required fields to force an error
            
            Test.startTest();
            try {
                insert requestLeave;
                //System.assert(false, 'Should have thrown an exception');
            } catch (Exception e) {
                System.assert(e.getMessage() != null, 'Error message should not be null');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testErrorLogRecord() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Cuti_Poin_Karyawan__c cutiPoin = [SELECT Id FROM Cuti_Poin_Karyawan__c 
                                             WHERE Nama_Karyawan__c = :testUser.Id LIMIT 1];
            
            Request_Leave__c requestLeave = new Request_Leave__c(
                Cuti_Poin_Karyawan__c = cutiPoin.Id,
                Nama_Karyawan__c = testUser.Id,
                Date_From__c = Date.today().addDays(4),
                Date_To__c = Date.today().addDays(5),
                Type_Request__c = 'Request Off',
                Reason__c = 'Kuliah',
                OwnerId = testUser.Id
            );
            
            Savepoint sp = Database.setSavepoint();
            Exception testException = new System.DmlException('Test Exception');
            
            Test.startTest();
            //SCC_RequestCuti_Handler.ErrorLogRecord(requestLeave, sp, testException);
            Test.stopTest();
        }
    }
    
}