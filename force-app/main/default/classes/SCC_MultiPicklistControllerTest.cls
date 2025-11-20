/**
 * @description       : 
 * @author            : Ardyta Yudianto, Alvin Vigo
 * @group             : Test Class
 * @last modified on  : 14/11/2024
 * @last modified by  : Ardyta Yudianto, Alvin Vigo
**/
@isTest
public class SCC_MultiPicklistControllerTest {
    @testSetup
    static void setupData() {
        Group sccQ = new Group(Name='SCC - Non Fraud Transaction - ON US', Type='Queue');
        insert sccQ;
        
         System.runAs(new User(Id = UserInfo.getUserId())) {
         QueuesObject qObj = new QueueSObject(QueueID = sccQ.id, SObjectType = 'Case');
         insert qObj;
        }

        Account testAccount = new Account(LastName = 'Test');
        insert testAccount;
        
        Orgeh__c testOrgeh = new Orgeh__c();
        testOrgeh.Name = 'SCC - Non Fraud Transaction - ON US';
        testOrgeh.External_Id__c = '666';
        testOrgeh.Permission_Set__c = 'BO Agent';
        testOrgeh.Profile__c = 'Back Office Agent';
        testOrgeh.Role__c = 'Back Office Agent';
        
        
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true
        );
        insert callTypeRecord;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testOrgeh;
            //insert testAccount;
            //insert callTypeRecord;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'mexxbrixxbenhil5@bri.com'
        );
        insert testUser;
    
        Case caseRecord1 = new Case();
        caseRecord1.Subject = 'Test';
        caseRecord1.Description = 'Test';
        caseRecord1.SCC_Waktu_Transaksi__c = DateTime.Now();
        caseRecord1.AccountId = testAccount.Id;
        caseRecord1.SCC_Cust_Phone1__c = '081234567890';
        caseRecord1.Cust_Current_Phone__c = '081234567890';
        caseRecord1.SCC_Amount__c = 1000000;
        caseRecord1.SCC_Card_Number__c = '1234567890123456';
        caseRecord1.SCC_Account_Number__c = '1234567890123456';
        caseRecord1.SSC_Call_Type_Description__c = 'Test';
        caseRecord1.Status = 'New';
        // caseRecord1.SCC_Call_Type__c = callTypeRecord.Id;
        caseRecord1.OwnerId = sccQ.Id;
        caseRecord1.SCC_Case_Category__c = 'Request';
        caseRecord1.SCC_Nama_Pelapor__c = 'test';
        caseRecord1.SCC_Product_L1__c  = 'Savings';
        caseRecord1.SCC_Product_L2__c = 'Giro (CA)';
        caseRecord1.SCC_Segment__c = 'Individu Umum';
        insert caseRecord1;
        
        Case caseRecord2 = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert caseRecord2;
    }

   @isTest
   static void testGetMasterSubCaseReference() {
      Test.startTest();
      Map<String, String> result = SCC_MultiPicklistController.getMasterSubCaseReference();
     Test.stopTest();
       
    }
    
    @isTest
    static void testGetUserProfile() {
        User testUser = [SELECT Id, Profile.Name FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            String profileName = SCC_MultiPicklistController.getUserProfile();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetLabels() {
        // Mock Metadata dari CSV, file CSV ada di Static Resources
        Map<String, SCC_Sub_Case_Reference__mdt> mockData = new Map<String, SCC_Sub_Case_Reference__mdt>{
            'Ref1' => new SCC_Sub_Case_Reference__mdt(
                MasterLabel = 'Label 1',
                Label = 'Sub Label 1',
                DeveloperName = 'Reference_1',
                Sub_Case_Reference__c = 'Ref1'
            ),
            'Ref2' => new SCC_Sub_Case_Reference__mdt(
                MasterLabel = 'Label 2',
                Label = 'Sub Label 2',
                DeveloperName = 'Reference_2',
                Sub_Case_Reference__c = 'Ref2'
            )
        };

        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            List<String> selectedValues = new List<String>{'Ref1', 'Ref2'};
            // Load Mock dari Static Resources
            Test.loadData(SCC_Sub_Case_Reference__mdt.sObjectType, 'SCC_SubCaseReference_Mock');
            List<String> labelValues = SCC_MultiPicklistController.getLabels(selectedValues);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetSubCaseReferenceFromCaseType() {
        SSC_Call_Type__c callTypeRecord = [SELECT Id FROM SSC_Call_Type__c WHERE Name = 'Test Call Type' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCaseType(callTypeRecord.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetSubCaseReferenceFromCaseTypexxEmptyField() {
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = 'Test Call Type Empty',
            SCC_Sub_Description__c = '', // Empty field
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)'
        );
        insert callTypeRecord;

        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCaseType(callTypeRecord.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetSubCaseReferenceFromCaseTypexxSingleValue() {
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = 'Test Call Type Single Value',
            SCC_Sub_Description__c = 'SingleOption',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)'
        );
        insert callTypeRecord;

        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCaseType(callTypeRecord.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetFieldValues() {
        SSC_Call_Type__c callTypeRecord = [SELECT Id, SCC_Sub_Description__c FROM SSC_Call_Type__c WHERE Name = 'Test Call Type' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            List<String> fieldValues = SCC_MultiPicklistController.getFieldValues(callTypeRecord.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveSelectedValues() {
        SSC_Call_Type__c callTypeRecord = [SELECT Id, SCC_Sub_Description__c FROM SSC_Call_Type__c WHERE Name = 'Test Call Type' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            List<String> selectedValues = new List<String>{'Option1', 'Option2', 'Option3'};
            SCC_MultiPicklistController.saveSelectedValues(callTypeRecord.Id, selectedValues);
            SSC_Call_Type__c updatedRecord = [SELECT SCC_Sub_Description__c FROM SSC_Call_Type__c WHERE Id = :callTypeRecord.Id LIMIT 1];
        }
    }

    @isTest
    static void testGetSubCaseReferenceFromCase() {
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = '1000',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true
        );
        insert callTypeRecord;

        Case testCase = [SELECT Id, SCC_Call_Type__c, SCC_Call_Type__r.SCC_Sub_Description__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        testCase.SCC_Call_Type__c = callTypeRecord.Id;
        update testCase;

        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCase(testCase.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetSubCaseReferenceFromCasexxNoCallType() {
        Case testCase = [SELECT Id, SCC_Call_Type__c, SCC_Call_Type__r.SCC_Sub_Description__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCase(testCase.Id);
            Test.stopTest();
        }
    }

    /* @isTest
    static void testGetSubCaseReferenceFromCasexxStatusClosed() {
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = '1000',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true
        );
        insert callTypeRecord;

        Case testCase = [SELECT Id, SCC_Call_Type__c, SCC_Call_Type__r.SCC_Sub_Description__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        testCase.Status = 'Closed';
        testCase.SCC_Nama_Pelapor__c = 'Willy';
        testCase.SCC_Call_Type__c = callTypeRecord.Id;
        testCase.SCC_Closure_Comments__c = 'hai';
        testCase.SCC_Resolution_Category__c = 'Dokumen Tidak Lengkap';
        update testCase;

        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCase(testCase.Id);
            Test.stopTest();
        }
    } */

    @isTest
    static void testGetSubCaseReferenceFromCasexxNoSCCSubDescription() {
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = '1001',
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = '',
            Active__c = true
        );
        insert callTypeRecord;

        Case testCase = [SELECT Id, SCC_Call_Type__c, SCC_Call_Type__r.SCC_Sub_Description__c FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        testCase.SCC_Call_Type__c = callTypeRecord.Id;
        update testCase;

        User testUser = [SELECT Id FROM User WHERE UserName = 'mexxbrixxbenhil5@bri.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = SCC_MultiPicklistController.getSubCaseReferenceFromCase(testCase.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveSelectedValuesOnCasexxValidScenario() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        //Sub_Case_Reference__c subCaseRef = [SELECT Id, sub_case_code__c FROM Sub_Case_Reference__c WHERE sub_case_code__c = 'SUB123' LIMIT 1];

        Test.startTest();
        SCC_MultiPicklistController.saveSelectedValuesOnCase(caseRecord.Id, 'SUB123');
        Test.stopTest();

        Case updatedCase = [SELECT SCC_Sub_Case_Lookup__c FROM Case WHERE Id = :caseRecord.Id];
        //System.assertEquals(subCaseRef.Id, updatedCase.SCC_Sub_Case_Lookup__c, 'The SCC_Sub_Case_Lookup__c field should be updated with the correct Sub_Case_Reference__c Id.');
    }

    @isTest
    static void testSaveSelectedValuesOnCasexxNonexistentSubCase() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];

        Test.startTest();
        SCC_MultiPicklistController.saveSelectedValuesOnCase(caseRecord.Id, 'NONEXISTENT');
        Test.stopTest();

        Case updatedCase = [SELECT SCC_Sub_Case_Lookup__c FROM Case WHERE Id = :caseRecord.Id];
        System.assertEquals(null, updatedCase.SCC_Sub_Case_Lookup__c, 'The SCC_Sub_Case_Lookup__c field should not be updated for a non-existent Sub Case value.');
    }

    // @isTest
    // static void testSaveSelectedValuesOnCase_DmlException() {
    //     Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
    
    //     Case caseWithInvalidData = new Case(
    //         Id = caseRecord.Id,
    //         Subject = 'Test Case with Invalid Data',
    //         SCC_Sub_Case__c = 'INVALID_SUB_CASE'
    //     );
    //     Test.startTest();
    //     try {
    //         SCC_MultiPicklistController.saveSelectedValuesOnCase(caseWithInvalidData.Id, 'INVALID_SUB_CASE');
    //         System.assert(false, 'Expected DmlException not thrown.');
    //     } catch (DmlException dme) {
    //         System.debug('Expected DML Exception: ' + dme.getMessage());
    //         System.assert(true, 'Expected DML Exception occurred.');
    //     }
    //     Test.stopTest();
    // }

    @isTest
    static void testSaveSelectedValuesOnCasexxFieldNotUpdateable() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];

        Test.startTest();
        Boolean isFieldUpdateable = Schema.sObjectType.Case.fields.SCC_Sub_Case__c.isUpdateable();
        
        if (!isFieldUpdateable) {
            try {
                SCC_MultiPicklistController.saveSelectedValuesOnCase(caseRecord.Id, 'SUB123');
            } catch (Exception e) {
                System.assert(false, 'An unexpected exception occurred: ' + e.getMessage());
            }
        }
        Test.stopTest();

        if (!isFieldUpdateable) {
            Case updatedCase = [SELECT SCC_Sub_Case_Lookup__c FROM Case WHERE Id = :caseRecord.Id];
        }
    }
}