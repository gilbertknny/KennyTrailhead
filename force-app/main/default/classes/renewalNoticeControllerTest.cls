/**
 * @description Test class for Renewal Notice Visualforce page
 * Handles the display of Insurance Policy and related Asset (Risk) information
 * @author Pepp
 * @date 2025-11-19
 */
@isTest
public class renewalNoticeControllerTest {

    /**
     * Utility: create NameInsured (Account)
     */
    private static Account createAccount() {
        Account acc = new Account(
            Name = 'John Doe'
        );
        insert acc;
        return acc;
    }

    /**
     * Utility: create minimal InsurancePolicy with required fields
     */
    private static InsurancePolicy createPolicy() {
        Account acc = createAccount();

        InsurancePolicy p = new InsurancePolicy(
            Name = 'Test Policy',
            NameInsuredId = acc.Id   // REQUIRED FIELD
        );
        insert p;
        return p;
    }

    /**
     * Utility: create Asset (risk)
     */
    private static Asset createRisk(Id policyId, Decimal amount, String name) {
        Asset a = new Asset(
            Name = name,
            Insurance_Policy__c = policyId,
            Amount_IDR__c = amount
        );
        insert a;
        return a;
    }

    /**
     * Test: multiple risks
     */
    @isTest
    static void testControllerWithMultipleRisks() {

        InsurancePolicy p = createPolicy();

        createRisk(p.Id, 100000, 'Risk A');
        createRisk(p.Id, 200000, 'Risk B');

        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(p);
        renewalNoticeController ctrl = new renewalNoticeController(std);
        Test.stopTest();

        System.assertEquals(2, ctrl.getNumberOfRisks());
        System.assertEquals(300000, ctrl.getTotalSumInsured());
        System.assertEquals(2, ctrl.getRisksList().size());
        System.assertEquals(null, ctrl.getSingleRisk());
    }

    /**
     * Test: single risk
     */
    @isTest
    static void testControllerWithSingleRisk() {

        InsurancePolicy p = createPolicy();

        createRisk(p.Id, 150000, 'Single Risk');

        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(p);
        renewalNoticeController ctrl = new renewalNoticeController(std);
        Test.stopTest();

        System.assertEquals(1, ctrl.getNumberOfRisks());
        System.assertNotEquals(null, ctrl.getSingleRisk());
        System.assertEquals(150000, ctrl.getTotalSumInsured());
    }

    /**
     * Test: policy with no risks
     */
    @isTest
    static void testControllerWithNoRisk() {

        InsurancePolicy p = createPolicy();

        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(p);
        renewalNoticeController ctrl = new renewalNoticeController(std);
        Test.stopTest();

        System.assertEquals(0, ctrl.getNumberOfRisks());
        System.assertEquals(0, ctrl.getTotalSumInsured());
        System.assertEquals(0, ctrl.getRisksList().size());
    }

    /**
     * Test: null record ID → will trigger initializeEmptyData()
     */
    @isTest
    static void testControllerWithNullId() {

        ApexPages.StandardController std = new ApexPages.StandardController(new InsurancePolicy());

        Test.startTest();
        renewalNoticeController ctrl = new renewalNoticeController(std);
        Test.stopTest();

        System.assertEquals(0, ctrl.getNumberOfRisks());
        System.assertEquals(0, ctrl.getTotalSumInsured());
        System.assertNotEquals(null, ctrl.getPolicy());
    }
}