@IsTest(seeAllData=false)
public class Aswata_Async_PremiumCalculation_Test {
    @IsTest
    static void testAswataPremiCalculation_WithCoverage() {
        // Step 1: Create shared prerequisite data once
        Account acc = Aswata_TestDataFactory.createAccount('Coverage Account');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'Coverage Opportunity');
        InsurancePolicy policy = Aswata_TestDataFactory.createInsurancePolicy(acc, opp);
        Asset risk = Aswata_TestDataFactory.createRisk(opp, 'Test Risk');
        // Step 2: Build coverage records (no DML inside loop)
        List<InsurancePolicyCoverage> coverages = new List<InsurancePolicyCoverage>();
        for (Integer i = 0; i < 3; i++) {
            InsurancePolicyCoverage cov = new InsurancePolicyCoverage(
                //Name = 'Coverage ' + i,
                InsurancePolicyId = policy.Id,
                Opportunity__c = opp.Id,
                Risk_ID__c = risk.Id,
                Premi_Amount__c = 1000 + (i * 500)
            );
            coverages.add(cov);
        }
        insert coverages;

        // Step 3: Call the @future method
        Test.startTest();
        Aswata_Async_PremiCalculation.aswataPremiCalculation(opp.Id);
        Test.stopTest();

        // Step 4: Verify total Premium__c = 4500
        Opportunity updatedOpp = [SELECT Premium__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(4500, updatedOpp.Premium__c, 'Premium__c should equal total Premi_Amount__c');
    }

    @IsTest
    static void testAswataPremiCalculation_NoCoverage() {
        Account acc = Aswata_TestDataFactory.createAccount('No Coverage Account');
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(acc, 'No Coverage Opportunity');

        Test.startTest();
        Aswata_Async_PremiCalculation.aswataPremiCalculation(opp.Id);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Premium__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, updatedOpp.Premium__c, 'Premium__c should remain null when no coverage exists');
    }
}