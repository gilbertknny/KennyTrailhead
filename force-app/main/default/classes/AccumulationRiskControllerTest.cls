/**
 * @description   Test class for AccumulationRiskController.
 */
@IsTest
public class AccumulationRiskControllerTest {

    /**
     * @description   Happy path test: create Asset + related records and verify
     */
    @IsTest
    static void testGetRelatedRisksWithValidId() {

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Create Accumulation (Name autodetermined, do NOT set Name)
        Accumulation__c testAccumulation = new Accumulation__c();
        insert testAccumulation;

        // Create Asset linked to Accumulation
        Asset testAsset = new Asset(
            Name = 'Risk Asset',
            AccountId = testAccount.Id,
            SerialNumber = 'SN-100',
            Accumulation__c = testAccumulation.Id
        );
        insert testAsset;

        Test.startTest();
        List<Asset> resultAssets = AccumulationRiskController.getRelatedRisks(testAccumulation.Id);
        Test.stopTest();

        System.assertEquals(1, resultAssets.size(), 'Should return 1 related Asset.');
        System.assertEquals(
            testAccumulation.Id,
            resultAssets[0].Accumulation__c,
            'Accumulation ID must match.'
        );
    }

    /**
     * @description   Ensures method safely handles blank ID
     *                and returns empty list.
     */
    @IsTest
    static void testGetRelatedRisksWithBlankId() {

        Test.startTest();
        List<Asset> results = AccumulationRiskController.getRelatedRisks('');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty list for blank input.');
    }
}