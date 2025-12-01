/**
 * @description       : Test Class for Aswata_Treaty_Distribution
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-01-2025
 * @last modified by  : Ahmad Yazid Munif
**/

@isTest
private class Aswata_Treaty_Distribution_Test {
    @testSetup
    static void makeData() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'testad',
            Email = 'testadmin' + System.currentTimeMillis() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AdminTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test.admin.' + System.currentTimeMillis() + '@testorg.com' // Unique Username
        );
        insert adminUser;

        // Id standardRtId = Schema.SObjectType.Transaction_Data__c.getRecordTypeInfosByName().get('Co-Insurer').getRecordTypeId();
        Account insertAcc = Aswata_TestDataFactory.createAccount('Jhon');
        Opportunity opp = new Opportunity(
            Name = 'OPPTY-01',
            AccountId = insertAcc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Amount = 50000,
            Busreq_ID__c = '015.1010.201.2025.000099.00'
        );
        insert opp;
        // Opportunity opp = Aswata_TestDataFactory.createOpportunity(insertAcc,'OPPTY-01');
        Asset risk = Aswata_TestDataFactory.createRisk(opp,'RISK TEST');
        // Aswata_TestDataFactory.createAsset(opp,risk,'RUMAH');
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Asset' 
            AND Name = 'Risk' 
            LIMIT 1
        ];
        Accumulation__c acc = new Accumulation__c(
            Zip_Code__c = '80811'
        );
        insert acc;
        // Create Asset record
        Asset ast = new Asset(
            Name = 'Rumah',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            // COB__c = '201',
            RecordTypeId = rt.Id,
            Accumulation__c = acc.Id
        );
        insert ast;

        Quote testQuote = new Quote(
            Name = 'Test Quote 001',
            OpportunityId = opp.Id,
            Treaty_Distribution_Response__c = 'Response Data Here'
        );
        insert testQuote;

        RecordType rtTrxData = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Transaction_Data__c'
            AND Name = 'Co-Insurer'
            LIMIT 1
        ];

        Transaction_Data__c trxDataSuccess = new Transaction_Data__c(
            Opportunity__c = opp.Id,
            RecordTypeId = rtTrxData.Id,
            Amount__c = 12345.67
        );
        insert trxDataSuccess;
    }
    @isTest
    static void relatedOpptyTest() {
        Quote quoteRecord = [SELECT Id FROM Quote LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Aswata_Treaty_Distribution.QuoteOpptyRelated> resultQuote = Aswata_Treaty_Distribution.getRelatedListRisk(quoteRecord.Id);
            Test.stopTest();
            System.assertEquals(1, resultQuote.size(), 'Seharusnya ada satu record terkait yang ditemukan.');
        }
    }
    @IsTest
    static void testGetTransactionDataOppSuccess() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        Id quoteId = testQuote.Id;

        Transaction_Data__c result;
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            result = Aswata_Treaty_Distribution.getTransactionDataOpp(quoteId);
            Test.stopTest();
        }
        System.assertNotEquals(null, result, 'A Transaction_Data__c record should have been found.');
        System.assertEquals(12345.67, result.Amount__c, 'The correct Amount__c value should be returned.');
    }
    @IsTest
    static void testProcessAssetUpdates() {
        List<Asset> assetsToUpdate = [SELECT Id FROM Asset LIMIT 1];
        Decimal setFacultativeValue = 0;
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            Aswata_Treaty_Distribution.processAssetUpdates(assetsToUpdate, setFacultativeValue);
            Test.stopTest();
        }
        Asset updatedAsset = [
            SELECT Id, Facultative__c, Has_Facultative__c, Facultative_Folder__c
            FROM Asset
            WHERE Id = :assetsToUpdate[0].Id
        ];
        System.assertEquals(0, updatedAsset.Facultative__c, 'Facultative__c should be set to 0.');
    }
    @IsTest
    static void testSaveTreatyDistributionSuccess() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        Id quoteIdInput = testQuote.Id;
        TreatySubData subData = new TreatySubData();
        subData.accumulation = 5000;
        subData.capacity = 5500;
        MasterDataWrapper wrapper1 = new MasterDataWrapper();
        wrapper1.busreqId = '015.1010.201.2025.000099.00';
        wrapper1.riskNo = '1';
        wrapper1.setFacultative = 2000;
        wrapper1.totalSumInsured100 = 5000;
        wrapper1.bppda = subData;
        MasterDataWrapper wrapper2 = new MasterDataWrapper();
        wrapper2.busreqId = '015.1010.201.2025.000088.00';
        wrapper2.riskNo = '2';
        wrapper2.setFacultative = 100;
        wrapper2.totalSumInsured100 = 80000;
        wrapper2.surplus = subData;
        List<MasterDataWrapper> masterDataList = new List<MasterDataWrapper>{ wrapper1, wrapper2 };
        String jsonDataString = JSON.serialize(masterDataList);
        IdListWrapper list1Wrapper = new IdListWrapper();
        list1Wrapper.busreqId='015.1010.201.2025.000099.00';
        list1Wrapper.riskId='1';
        list1Wrapper.setFacultative=2000;
        IdListWrapper list1Wrapper2 = new IdListWrapper();
        list1Wrapper2.busreqId='015.1010.201.2025.000088.00';
        list1Wrapper2.riskId='1';
        list1Wrapper2.setFacultative=2000;
        List<IdListWrapper> idList = new List<IdListWrapper>();
        idList.add(list1Wrapper);
        idList.add(list1Wrapper2);
        String idListString = JSON.serialize(idList);
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        String result;
        System.runAs(adminUser) {
            Test.startTest();
            result = Aswata_Treaty_Distribution.saveTreatyDistribution(quoteIdInput,jsonDataString,idListString);
            Test.stopTest();
        }

        // --- ASSERT: VERIFIKASI HASIL ---
        // 1. Verifikasi Return Value (Jika sukses, diasumsikan mengembalikan string 'Success')
        System.assertEquals('Success', result, 'Method seharusnya mengembalikan string "Success" saat berhasil.');

        // 2. Verifikasi DML (PENTING untuk Sev3: Assert)
        // Jika method ini melakukan DML (Insert/Update/Upsert record Treaty/Risk),
        // Anda HARUS query database di sini untuk memverifikasi perubahan status.

        // Contoh: Asumsikan Anda mengupdate field pada Asset
        // Asset updatedAsset = [SELECT Id, Total_Facultative__c FROM Asset WHERE Id = :asset.Id];
        // System.assertEquals(2000, updatedAsset.Total_Facultative__c, 'Field Asset seharusnya terupdate.');
    }
    /**
     * @description Class for set accumulation capacity
     */
    public class TreatySubData {
        /**
         * @description accumulation
         */
        public Decimal accumulation;
        /**
         * @description capacity
         */
        public Decimal capacity;
    }
    /**
     * @description Class for set busreq riskId setFacultative
     */
    public class IdListWrapper {
        /**
         * @description busreqId
         */
        public String busreqId;
        /**
         * @description riskId
         */
        public String riskId;
        /**
         * @description setFacultative
         */
        public Decimal setFacultative;
    }
    /**
     * @description Class for set masterData
     */
    public class MasterDataWrapper {
        /**
         * @description busreqId
         */
        public String busreqId;
        /**
         * @description riskId
         */
        public String riskNo;
        /**
         * @description totalSumInsured100
         */
        public Decimal totalSumInsured100;
        /**
         * @description setFacultative
         */
        public Decimal setFacultative;
        /**
         * @description bppda
         */
        public TreatySubData bppda;
        /**
         * @description surplu
         */
        public TreatySubData surplus;
    }
}