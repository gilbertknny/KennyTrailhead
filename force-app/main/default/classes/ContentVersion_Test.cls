/**
 * @description ContentVersion_Test
 */
@IsTest
private class ContentVersion_Test {

    @IsTest
    static void testInsertContentVersion() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.startTest();
            Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account acc = new Account(Name='Test Account',RecordtypeId = rtId,Client_id__c = 'CLIENT123');
            insert acc;
            // Membuat dummy ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = 'UnitTestFile';
            cv.PathOnClient = 'UnitTestFile.txt';
            cv.VersionData = Blob.valueOf('Hello World Test');
            cv.LinkedEntityId__c =  'CLIENT123';
            cv.fieldtype__c = 'Client_ID';
            cv.ID_Type__c = 'OTHER';
            insert cv; // <== Trigger akan otomatis terpanggil

            // Query lagi untuk memastikan berhasil
            ContentVersion insertedCv = [
                SELECT Id, Title, FileExtension, VersionData
                FROM ContentVersion
                WHERE Id = :cv.Id
            ];
            
            System.assertEquals('UnitTestFile', insertedCv.Title);
            System.assertNotEquals(null, insertedCv.VersionData);
            
            Test.stopTest();
        }
    }

    @IsTest
    static void testInsertContentVersion2() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.startTest();
            Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account acc = new Account(Name='Test Account',RecordtypeId = rtId,Client_id__c = 'CLIENT123');
            insert acc;
            // Membuat dummy ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = 'UnitTestFile';
            cv.PathOnClient = 'UnitTestFile.txt';
            cv.VersionData = Blob.valueOf('Hello World Test');
            cv.LinkedEntityId__c =  acc.id;
            cv.fieldtype__c = 'Salesforce';
            cv.ID_Type__c = 'OTHER';
            insert cv; // <== Trigger akan otomatis terpanggil

            // Query lagi untuk memastikan berhasil
            ContentVersion insertedCv = [
                SELECT Id, Title, FileExtension, VersionData
                FROM ContentVersion
                WHERE Id = :cv.Id
            ];
            
            System.assertEquals('UnitTestFile', insertedCv.Title);
            System.assertNotEquals(null, insertedCv.VersionData);
            
            Test.stopTest();
        }
    }

    @IsTest
    static void testInsertContentVersionError() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.startTest();
            // Membuat dummy ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = 'UnitTestFile';
            cv.PathOnClient = 'UnitTestFile.txt';
            cv.VersionData = Blob.valueOf('Hello World Test');
            cv.LinkedEntityId__c =  'CLIENT123';
            cv.fieldtype__c = 'Client_ID';
            cv.ID_Type__c = 'OTHER';
            //insert cv; // <== Trigger akan otomatis terpanggil
            Database.SaveResult sr = Database.insert(cv, false);
            System.assertEquals(false, sr.isSuccess());
            Test.stopTest();
        }
    }
}