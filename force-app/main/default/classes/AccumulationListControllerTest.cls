/**
 * @description Test class for AccumulationListController
 * @author Pepp (Final Fix V2)
 * @date 2025
 */
@isTest
private class AccumulationListControllerTest {

    private static final String BUS_REQ_ID = 'BR-12345';

    @testSetup
    static void makeData() {
        // 1. Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // 2. Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Busreq_ID__c = BUS_REQ_ID
        );
        insert opp;

        // 3. Create Quote
        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert q;

        // 4. Create Accumulation Records
        List<Accumulation__c> accList = new List<Accumulation__c>();
        
        // Acc 1: Via Asset (Direct Link to Opp)
        accList.add(new Accumulation__c(
            Group_ID__c = 'GRP-01', 
            Version__c = '1', 
            Request_Number__c = 'REQ-ASSET'
        ));

        // Acc 2: Via Risk (Yang aslinya adalah Asset object linked to Quote)
        accList.add(new Accumulation__c(
            Group_ID__c = 'GRP-02', 
            Version__c = '1', 
            Request_Number__c = 'REQ-RISK'
        ));

        // Acc 3: Via BusReq ID
        accList.add(new Accumulation__c(
            Group_ID__c = 'GRP-03', 
            Version__c = '2', 
            Request_Number__c = BUS_REQ_ID
        ));

        insert accList;
    }

    /**
     * @description Test Strategy 1: Asset yang terhubung langsung ke Opportunity
     */
    @isTest
    static void testGetAccumulationViaOppAsset() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Accumulation__c accRecord = [SELECT Id FROM Accumulation__c WHERE Request_Number__c = 'REQ-ASSET' LIMIT 1];

        // Buat Asset yang nempel ke Opportunity
        Asset asset = new Asset(
            Name = 'Opp Asset',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Opportunity__c = opp.Id,
            Accumulation__c = accRecord.Id
        );
        insert asset;

        Test.startTest();
        List<AccumulationListController.AccumulationRecord> results = AccumulationListController.getAccumulationsByQuote(q.Id);
        Test.stopTest();

        System.assert(checkResultContainsId(results, accRecord.Id), 'Harus menemukan Accumulation via Opp Asset');
    }

    /**
     * @description Test Strategy 2: "Risk" (Asset) yang terhubung ke Quote via Field Risk_Name__c
     */
    @isTest
    static void testGetAccumulationViaRiskAsset() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Accumulation__c accRecord = [SELECT Id FROM Accumulation__c WHERE Request_Number__c = 'REQ-RISK' LIMIT 1];

        // Buat Asset yang berperan sebagai "Risk"
        Asset riskAsset = new Asset(
            Name = 'Risk Asset',
            AccountId = [SELECT Id FROM Account LIMIT 1].Id,
            Accumulation__c = accRecord.Id
        );
        insert riskAsset;

        // Update Quote untuk menunjuk ke Asset ini sebagai Risk
        q.Risk_Name__c = riskAsset.Id; 
        update q;

        Test.startTest();
        List<AccumulationListController.AccumulationRecord> results = AccumulationListController.getAccumulationsByQuote(q.Id);
        Test.stopTest();

        System.assert(checkResultContainsId(results, accRecord.Id), 'Harus menemukan Accumulation via Risk (Asset Linked to Quote)');
    }

    /**
     * @description Test Strategy 3: Via Business Request ID
     */
    @isTest
    static void testGetAccumulationViaBusReqId() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Accumulation__c accRecord = [SELECT Id FROM Accumulation__c WHERE Request_Number__c = :BUS_REQ_ID LIMIT 1];

        Test.startTest();
        List<AccumulationListController.AccumulationRecord> results = AccumulationListController.getAccumulationsByQuote(q.Id);
        Test.stopTest();

        System.assert(checkResultContainsId(results, accRecord.Id), 'Harus menemukan Accumulation via BusReq ID');
    }

    /**
     * @description Negative Test: Skenario input kosong atau data tidak ditemukan
     */
    @isTest
    static void testNegativeScenarios() {
        Test.startTest();
        
        // 1. Input Null
        List<AccumulationListController.AccumulationRecord> resNull = AccumulationListController.getAccumulationsByQuote(null);
        System.assertEquals(0, resNull.size(), 'Input Null harus return list kosong');

        // 2. Quote Bersih (Punya Opp, tapi tidak punya link ke Accumulation manapun)
        // Kita buat data baru yang terisolasi
        Opportunity cleanOpp = new Opportunity(
            Name = 'Clean Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Busreq_ID__c = 'NON-EXISTENT-ID' // Pastikan ID ini beda
        );
        insert cleanOpp;

        Quote cleanQuote = new Quote(
            Name = 'Clean Quote',
            OpportunityId = cleanOpp.Id
        );
        insert cleanQuote;
        
        List<AccumulationListController.AccumulationRecord> resClean = AccumulationListController.getAccumulationsByQuote(cleanQuote.Id);
        System.assertEquals(0, resClean.size(), 'Quote tanpa relasi accumulation harus return list kosong');
        
        Test.stopTest();
    }

    // Helper untuk cek hasil list
    private static Boolean checkResultContainsId(List<AccumulationListController.AccumulationRecord> results, String targetId) {
        for(AccumulationListController.AccumulationRecord rec : results) {
            if(rec.id == targetId) return true;
        }
        return false;
    }
}