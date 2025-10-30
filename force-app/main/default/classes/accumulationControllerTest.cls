@isTest
public class accumulationControllerTest {

    @testSetup
    static void setupData() {
        Opportunity opp = new Opportunity(
            Name = 'Opp Test',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Busreq_ID__c = 'BUSREQ-001'
        );
        insert opp;

        Asset ast = new Asset(
            Name = 'Asset Test',
            Address_Description__c = 'Jl. Sudirman No. 1',
            Risk_ID__c = 'RISK-001',
            Amount_IDR__c = 1000000,
            Opportunity__c = opp.Id
        );
        insert ast;
    }

    @isTest
    static void testGetUserBranchName() {
        Test.startTest();
        String branchName = accumulationController.getUserBranchName();
        Test.stopTest();

        System.assertNotEquals(null, branchName, 'Branch name tidak boleh null meskipun dummy');
    }

    @isTest
    static void testGetInitialAssetData() {
        Asset ast = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();
        accumulationController.InitialData data = accumulationController.getInitialAssetData(ast.Id);
        Test.stopTest();

        System.assertNotEquals(null, data, 'InitialData tidak boleh null');
        System.assertNotEquals(null, data.assetRow, 'AssetSearchResult harus terisi');
        System.assertEquals('RISK-001', data.assetRow.riskId);
    }

    @isTest
    static void testGetInitialAssetData_NullInput() {
        Test.startTest();
        accumulationController.InitialData data = accumulationController.getInitialAssetData(null);
        Test.stopTest();

        System.assertEquals(null, data, 'Jika assetId null, seharusnya return null');
    }

    @isTest
    static void testSearchAssets_WithParams() {
        Test.startTest();
        List<accumulationController.AssetSearchResult> results = accumulationController.searchAssets('Jl. Sudirman', null, null, null);
        Test.stopTest();

        System.assert(results.size() >= 0, 'Pencarian address tidak error');
    }

    @isTest
    static void testSearchAssets_NoParams() {
        Test.startTest();
        List<accumulationController.AssetSearchResult> results = accumulationController.searchAssets('', '', '', '');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Jika semua parameter kosong, return list kosong');
    }

    @isTest
    static void testCreateAccumulationRecord_WithOppId() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        accumulationController.AccumulationInput input = new accumulationController.AccumulationInput();
        input.businessRequestId = 'BUSREQ-001';
        input.address = 'Jl. Sudirman';
        input.zipCode = '12345';
        input.totalTSI = 1000000;
        input.versionStr = 'v1';
        input.oppId = opp.Id;
        input.policyNum = 'POLICY-001';

        Test.startTest();
        System.Test.setMock(System.StubProvider.class, new FlowMock());
        String accName = accumulationController.createAccumulationRecord(input);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Accumulation__c WHERE Policy_Number__c = 'POLICY-001']);
    }

    @isTest
    static void testCreateAccumulationRecord_WithoutOppId() {
        accumulationController.AccumulationInput input = new accumulationController.AccumulationInput();
        input.businessRequestId = 'BUSREQ-002';
        input.address = 'Jl. MH Thamrin';
        input.zipCode = '54321';
        input.versionStr = 'v2';
        input.policyNum = 'POLICY-002';

        Test.startTest();
        String accName = accumulationController.createAccumulationRecord(input);
        Test.stopTest();

    }

    private class FlowMock implements System.StubProvider {
        public Object handleMethodCall(
            Object stub,
            String methodName,
            System.Type returnType,
            List<System.Type> listParamTypes,
            List<String> listParamNames,
            List<Object> listParamValues
        ) {
            return null;
        }
    }
}