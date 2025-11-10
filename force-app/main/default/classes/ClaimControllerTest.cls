@IsTest
public class ClaimControllerTest {

    // -------------------------
    // Helper: Buat Account
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
            Name = 'POL-MV-001',
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
            Name = 'Test Motor Vehicle Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Sum_Insured__c = 500000000,
            Cur__c = 'IDR',
            Busreq_ID__c = 'BR-MV-001'
        );
        insert opp;
        return opp;
    }

    // -------------------------
    // Helper: Buat Master Data (Model)
    // -------------------------
    private static Master_Data__c createMasterData() {
        Master_Data__c md = new Master_Data__c(
            Name = 'Toyota Avanza'
            // Tambahkan field required lainnya jika ada
        );
        insert md;
        return md;
    }

    // -------------------------
    // Helper: Buat Asset (Vehicle)
    // -------------------------
    private static Asset createAsset(Opportunity opp, Master_Data__c model) {
        Asset a = new Asset(
            Name = 'Vehicle-001',
            Model__c = model.Id,
            Chasis_No__c = 'CHASIS12345',
            Engine_No__c = 'ENGINE67890',
            Opportunity__c = opp.Id,
            Risk_ID__c = 'RISK-MV-001',
            Amount_IDR__c = 250000000
        );
        insert a;
        return a;
    }

    // -------------------------
    // Helper: Buat Claim
    // -------------------------
    private static Claim createClaim(InsurancePolicy pol, Opportunity opp) {
        Claim clm = new Claim(
            Name = 'CLM-MV-001',
            PolicyNumberId = pol.Id,
            COB__c = '101',
            Register_No__c = 'B1234XYZ',
            Opportunity__c = opp.Id,
            Casco__c = true,
            LIFE_INSURANCE__c = false,
            PA_Passanger__c = true,
            TPL__c = true,
            PA_Driver__c = false,
            PLL__c = false
        );
        insert clm;
        return clm;
    }

    // -------------------------
    // Helper: Buat InsurancePolicyCoverage
    // -------------------------
    private static InsurancePolicyCoverage createCoverage(Asset a, InsurancePolicy pol) {
        InsurancePolicyCoverage cov = new InsurancePolicyCoverage(
            CoverageName = 'Comprehensive Coverage',
            Risk_ID__c = a.Id,
            DeductibleAmount = 5000000,
            Deductible_PCT__c = 10,
            Deductible_Type__c = 'Percentage',
            Minimum_Amount__c = 500000,
            InsurancePolicyId = pol.Id
        );
        insert cov;
        return cov;
    }

    // -------------------------
    // Test getClaimDetails
    // -------------------------
    @IsTest
    static void testGetClaimDetails() {
        Account acc = createAccount();
        InsurancePolicy pol = createPolicy(acc);
        Opportunity opp = createOpportunity();
        Claim clm = createClaim(pol, opp);

        Test.startTest();
        ClaimController.ClaimDetailsWrapper wrapper = ClaimController.getClaimDetails(clm.Id);
        Test.stopTest();

        System.assertEquals(pol.Name, wrapper.policyNo);
        System.assertEquals(opp.Sum_Insured__c, wrapper.sumInsured);
        System.assertEquals(true, wrapper.isCasco);
    }

    // -------------------------
    // Test searchRisks
    // -------------------------
    @IsTest
    static void testSearchRisks() {
        Opportunity opp = createOpportunity();
        Master_Data__c model = createMasterData();
        Asset a = createAsset(opp, model);

        Test.startTest();
        ClaimController.PaginatedAssetWrapper wrapper = ClaimController.searchRisks('Toyota', 'CHASIS', 'ENGINE', 10, 1);
        Test.stopTest();

        System.assertEquals(1, wrapper.totalItemCount);
        System.assertEquals(1, wrapper.assetList.size());
    }

    // -------------------------
    // Test getCoveragesForAsset
    // -------------------------
    @IsTest
    static void testGetCoveragesForAsset() {
        Account acc = createAccount();
        InsurancePolicy pol = createPolicy(acc);
        Opportunity opp = createOpportunity();
        Master_Data__c model = createMasterData();
        Asset a = createAsset(opp, model);
        InsurancePolicyCoverage cov = createCoverage(a, pol);

        Test.startTest();
        List<InsurancePolicyCoverage> coverages = ClaimController.getCoveragesForAsset(a.Id);
        Test.stopTest();

        System.assertEquals(1, coverages.size());
        System.assertEquals(cov.Id, coverages[0].Id);
    }

    // -------------------------
    // Test getAssetsForOpportunity
    // -------------------------
    @IsTest
    static void testGetAssetsForOpportunity() {
        Opportunity opp = createOpportunity();
        Master_Data__c model = createMasterData();
        Asset a = createAsset(opp, model);

        Test.startTest();
        ClaimController.PaginatedAssetWrapper wrapper = ClaimController.getAssetsForOpportunity(opp.Id, 10, 1);
        Test.stopTest();

        System.assertEquals(1, wrapper.totalItemCount);
        System.assertEquals(1, wrapper.assetList.size());
    }

    // -------------------------
    // Test getAssetsForOpportunity null
    // -------------------------
    @IsTest
    static void testGetAssetsForOpportunity_Null() {
        Test.startTest();
        ClaimController.PaginatedAssetWrapper wrapper = ClaimController.getAssetsForOpportunity(null, 10, 1);
        Test.stopTest();

        System.assertEquals(0, wrapper.totalItemCount);
    }
}