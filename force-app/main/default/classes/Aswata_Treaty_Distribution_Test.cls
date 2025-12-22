/**
 * @description       : Test Class for Aswata_Treaty_Distribution
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-15-2025
 * @last modified by  : Ahmad Yazid Munif
**/

@IsTest
private class Aswata_Treaty_Distribution_Test {
    @TestSetup
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
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
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
            json_accumulation__c = '80811'
        );
        insert acc;
        // Create Asset record
        Asset ast = new Asset(
            Name = 'Rumah',
            Opportunity__c = opp.Id,
            ParentId = risk.Id,
            // Address__c = newAddress.Id,
            // COB__c = '201',
            RecordTypeId = rt.Id,
            Accumulation_ID__c = acc.Id
        );
        insert ast;

        Quote testQuote = new Quote(
            Name = 'Test Quote 001',
            OpportunityId = opp.Id,
            Treaty_Distribution_Response__c = '[{"status":"404","busreq_id":"015.1010.201.2025.000099.00","dateOpportunity":"20/11/2025","dateQuoteRequest":"06/10/2025","dateAccumulation":"","idAccumulation":"","riskId":"02iMS000000VGN3YAO","riskNo":"9","location":"Gg. Abimanyu, SOLO, Indonesia, 57134","oppyQuoteNo":"00000023","insurancePeriod":"20/11/2025 - 20/12/2026","totalSumInsured100":0,"totalSumInsuredShare":0,"accumulatedSumInsured100":0,"accumulatedSumInsuredShare":0,"listAccumulatedRisk":"Test new riskkk2","setFacultative":99999,"bppda":{"limit":0,"accumulation":0,"capacity":0},"poolEq":{"limit":0,"accumulation":0,"capacity":0},"poolCustomBond":{"limit":0,"accumulation":0,"capacity":0},"kark":{"limit":0,"accumulation":0,"capacity":0},"underlying":{"limit":0,"accumulation":0,"capacity":0},"excessLoss":{"limit":0,"accumulation":0,"capacity":0},"grossRetention":{"limit":0,"accumulation":0,"capacity":0},"quotaShare":{"limit":0,"accumulation":0,"capacity":0},"surplus":{"limit":0,"accumulation":0,"capacity":0},"facoblig":{"limit":0,"accumulation":0,"capacity":0}},{"facoblig":{"capacity":0,"accumulation":0,"limit":0},"surplus":{"capacity":0,"accumulation":0,"limit":0},"quotaShare":{"capacity":0,"accumulation":0,"limit":0},"grossRetention":{"capacity":0,"accumulation":0,"limit":0},"excessLoss":{"capacity":0,"accumulation":0,"limit":0},"underlying":{"capacity":0,"accumulation":0,"limit":0},"kark":{"capacity":0,"accumulation":0,"limit":0},"poolCustomBond":{"capacity":0,"accumulation":0,"limit":0},"poolEq":{"capacity":0,"accumulation":0,"limit":0},"bppda":{"capacity":0,"accumulation":0,"limit":0},"setFacultative":5555,"listAccumulatedRisk":"Test","accumulatedSumInsuredShare":0,"accumulatedSumInsured100":0,"totalSumInsuredShare":0,"totalSumInsured100":0,"insurancePeriod":"20/11/2025 - 20/12/2026","oppyQuoteNo":"00000023","location":"","riskNo":"6","riskId":"02iMS000000IwOvYAK","idAccumulation":"","dateAccumulation":"","dateQuoteRequest":"06/10/2025","dateOpportunity":"20/11/2025","busreq_id":"015.1010.201.2025.000099.00","status":"404"}]'
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
    @IsTest
    static void getJsonResponse() {
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        Map<String,Object> resultResponse;
        System.runAs(adminUser) {
            Test.startTest();
            resultResponse = Aswata_Treaty_Distribution.getResponseTreaty(assetRecord.Id);
            Test.stopTest();
            System.assertNotEquals(null, resultResponse, 'Hasil respons seharusnya tidak null.');
        }
    }
    @IsTest
    static void relatedOpptyTest() {
        Quote quoteRecord = [SELECT Id FROM Quote LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<Aswata_Treaty_Distribution.QuoteOpptyRelated> resultQuote = Aswata_Treaty_Distribution.getRelatedListRisk(quoteRecord.Id);
            Test.stopTest();
            System.assertEquals(2, resultQuote.size(), 'Seharusnya ada dua record terkait yang ditemukan.');
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
        List<Asset> assetsToUpdate = [SELECT Id,Accumulation__r.Group_ID__c FROM Asset LIMIT 1];
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
        Asset selectAsset = [SELECT Id FROM Asset LIMIT 1];
        Id quoteIdInput = testQuote.Id;
        TreatySubData subData = new TreatySubData();
        subData.accumulation = 5000;
        subData.capacity = 5500;
        MasterDataWrapper wrapper1 = new MasterDataWrapper();
        wrapper1.busreqId = '015.1010.201.2025.000099.00';
        wrapper1.riskId = selectAsset.Id;
        wrapper1.setFacultative = 2000;
        // wrapper1.totalSumInsured100 = 5000;
        wrapper1.bppda = subData;
        String jsonDataString = JSON.serialize(wrapper1);
        IdListWrapper list1Wrapper = new IdListWrapper();
        list1Wrapper.busreqId='015.1010.201.2025.000099.00';
        list1Wrapper.riskId=selectAsset.Id;
        list1Wrapper.setFacultative=2000;
        List<IdListWrapper> idList = new List<IdListWrapper>();
        idList.add(list1Wrapper);
        // idList.add(list1Wrapper2);
        String idListString = JSON.serialize(idList);
        User adminUser = [SELECT Id FROM User WHERE Alias = 'testad' LIMIT 1];
        String result;
        System.runAs(adminUser) {
            Test.startTest();
            result = Aswata_Treaty_Distribution.saveTreatyDistribution(quoteIdInput,jsonDataString,idListString);
            Test.stopTest();
        }

        System.assertEquals('Success', result, 'Method seharusnya mengembalikan string "Success" saat berhasil.');
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
        public String riskId;
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