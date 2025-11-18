@IsTest
public class ClaimControllerNonMVTest {

    // -------------------------
    // Helper: Buat Account untuk NameInsuredId
    // -------------------------
    private static Account createAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }

    // -------------------------
    // Helper: Buat InsurancePolicy
    // -------------------------
    private static InsurancePolicy createPolicy(Account acc) {
        InsurancePolicy pol = new InsurancePolicy(
            Name = 'POL-TEST',
            NameInsuredId = acc.Id,
            EffectiveToDate = Date.today().addDays(365)
        );
        insert pol;
        return pol;
    }

    // -------------------------
    // Helper: Buat Opportunity
    // -------------------------
    private static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Sum_Insured__c = 1000000,
            Cur__c = 'IDR',
            Busreq_ID__c = 'BR-001'
        );
        insert opp;
        return opp;
    }

    // -------------------------
    // Helper: Buat Claim
    // -------------------------
    private static Claim createClaim(InsurancePolicy pol, Opportunity opp) {
        Claim clm = new Claim(
            Name = 'CLM-TEST-001',
            PolicyNumberId = pol.Id,
            COB__c = '201',
            Opportunity__c = opp.Id
        );
        insert clm;
        return clm;
    }

    // -------------------------
    // Helper: Buat Asset (Risk)
    // -------------------------
    private static Asset createAsset(Opportunity opp) {
        Asset a = new Asset(
            Name = 'Risk-001',
            Address_Description__c = 'Jl. Test 123',
            Opportunity__c = opp.Id,
            Risk_ID__c = 'RISK001',
            Amount_IDR__c = 500000
        );
        insert a;
        return a;
    }

    // -------------------------
    // Helper: Buat InsurancePolicyCoverage
    // -------------------------
    private static InsurancePolicyCoverage createCoverage(Asset a, InsurancePolicy pol) {
        InsurancePolicyCoverage cov = new InsurancePolicyCoverage(
            CoverageName = 'Fire Coverage',
            Risk_ID__c = a.Id,
            DeductibleAmount = 100000,
            Deductible_PCT__c = 5,
            Deductible_Type__c = 'Flat',
            InsurancePolicyId = pol.Id
        );
        insert cov;
        return cov;
    }

    // -------------------------
    // Test getClaimDetails tanpa Opportunity
    // -------------------------
    @IsTest
    static void testGetClaimDetails_NoOpportunity() {
        Account acc = createAccount();
        InsurancePolicy pol = createPolicy(acc);
        Claim clm = new Claim(
            Name = 'CLM-TEST-002',
            PolicyNumberId = pol.Id,
            COB__c = '201'
        );
        insert clm;

        Test.startTest();
        ClaimControllerNonMV.ClaimDetailsWrapper wrapper = ClaimControllerNonMV.getClaimDetails(clm.Id);
        Test.stopTest();

        System.assertEquals(pol.Name, wrapper.policyNo);
        System.assertEquals('201', wrapper.classOfBusiness);
        System.assertEquals(0, wrapper.sumInsured);
        System.assertEquals('IDR', wrapper.cur);
    }

    // -------------------------
    // Test getClaimDetails dengan Opportunity
    // -------------------------
    @IsTest
    static void testGetClaimDetails_WithOpportunity() {
        Account acc = createAccount();
        InsurancePolicy pol = createPolicy(acc);
        Opportunity opp = createOpportunity();
        Claim clm = createClaim(pol, opp);

        Test.startTest();
        ClaimControllerNonMV.ClaimDetailsWrapper wrapper = ClaimControllerNonMV.getClaimDetails(clm.Id);
        Test.stopTest();

        System.assertEquals(pol.Name, wrapper.policyNo);
        System.assertEquals(opp.Sum_Insured__c, wrapper.sumInsured);
        System.assertEquals(opp.Cur__c, wrapper.cur);
    }

    // -------------------------
    // Test searchRisksNonMV
    // -------------------------
    @IsTest
    static void testSearchRisksNonMV() {
        Opportunity opp = createOpportunity();
        Asset a = createAsset(opp);

        Test.startTest();
        ClaimControllerNonMV.PaginatedAssetWrapper wrapper = ClaimControllerNonMV.searchRisksNonMV('Risk-001', 'Jl. Test', 10, 1);
        Test.stopTest();

        System.assertEquals(1, wrapper.assetList.size());
        System.assertEquals(a.Name, wrapper.assetList[0].Name);
    }

    // -------------------------
    // Test getAssetsForOpportunity
    // -------------------------
    @IsTest
    static void testGetAssetsForOpportunity() {
        Opportunity opp = createOpportunity();
        Asset a = createAsset(opp);

        Test.startTest();
        ClaimControllerNonMV.PaginatedAssetWrapper wrapper = ClaimControllerNonMV.getAssetsForOpportunity(opp.Id, 10, 1);
        Test.stopTest();

        System.assertEquals(1, wrapper.assetList.size());
        System.assertEquals(a.Id, wrapper.assetList[0].Id);
    }

    // -------------------------
    // Test getAssetsForOpportunity null
    // -------------------------
    @IsTest
    static void testGetAssetsForOpportunity_Null() {
        Test.startTest();
        ClaimControllerNonMV.PaginatedAssetWrapper wrapper = ClaimControllerNonMV.getAssetsForOpportunity(null, 10, 1);
        Test.stopTest();

        System.assertEquals(0, wrapper.totalItemCount);
    }

    // -------------------------
    // Test getCoveragesForAsset
    // -------------------------
    @IsTest
    static void testGetCoveragesForAsset() {
        Account acc = createAccount();
        InsurancePolicy pol = createPolicy(acc);
        Opportunity opp = createOpportunity();
        Asset a = createAsset(opp);
        InsurancePolicyCoverage cov = createCoverage(a, pol);

        Test.startTest();
        ClaimControllerNonMV.CoverageWrapper wrapper = ClaimControllerNonMV.getCoveragesForAsset(a.Id);
        Test.stopTest();

        System.assertEquals(1, wrapper.coverages.size());
        System.assertEquals(100000, wrapper.totalDeductible);
    }
}