@IsTest
private class DeleteOldRiskTransactionCoverageTest {

    @IsTest
    static void testDeleteAllByOpportunityId_Success() {
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;

        // Create related Asset
        Asset a = new Asset(
            Name = 'Test Asset',
            Opportunity__c = opp.Id,
            Product2Id = null
        );
        insert a;

        // Create related Transaction_Data__c
        Transaction_Data__c trx = new Transaction_Data__c(
            Name = 'Test TRX',
            Opportunity__c = opp.Id
        );
        insert trx;

        Account insured = new Account(
            Name = 'Test Insured'
        );
        insert insured;

        // Create required InsurancePolicy record
        InsurancePolicy pol = new InsurancePolicy(
            Name = 'Test Policy',
            NameInsuredId = insured.id
        );
        insert pol;
        
        // Create related InsurancePolicyCoverage
        InsurancePolicyCoverage cov = new InsurancePolicyCoverage(
            Opportunity__c = opp.Id,
            InsurancePolicyId = pol.Id   // REQUIRED FIELD
        );
        insert cov;

        // Prepare callable input
        Map<String, Object> inputMap = new Map<String, Object>{
            'opptyId' => opp.Id
        };
        Map<String, Object> outerArgs = new Map<String, Object>{
            'input' => inputMap
        };

        // Call class via Callable interface
        DeleteOldRiskTransactionCoverage del = new DeleteOldRiskTransactionCoverage();
        Map<String, Object> result = (Map<String, Object>) del.call('deleteAllByOpportunityId', outerArgs);

        // Assertions
        System.assertEquals('SUCCESS', result.get('status'));
        System.assertEquals(1, result.get('assetDeleted'));
        System.assertEquals(1, result.get('transactionDataDeleted'));
        System.assertEquals(1, result.get('coverageDeleted'));

        // Verify records are deleted (soft delete)
        System.assertEquals(0, [
            SELECT Count() FROM Asset WHERE Opportunity__c = :opp.Id
        ]);
        System.assertEquals(0, [
            SELECT Count() FROM Transaction_Data__c WHERE Opportunity__c = :opp.Id
        ]);
        System.assertEquals(0, [
            SELECT Count() FROM InsurancePolicyCoverage WHERE Opportunity__c = :opp.Id
        ]);
    }


    @IsTest
    static void testDeleteAllByOpportunityId_BlankInput() {

        Map<String, Object> inputMap = new Map<String, Object>{
            'opptyId' => ''
        };
        Map<String, Object> outerArgs = new Map<String, Object>{
            'input' => inputMap
        };

        DeleteOldRiskTransactionCoverage del = new DeleteOldRiskTransactionCoverage();
        Map<String, Object> result = (Map<String, Object>) del.call('deleteAllByOpportunityId', outerArgs);

        System.assertEquals('ERROR', result.get('status'));
    }


    @IsTest
    static void testCall_UnknownAction() {
        DeleteOldRiskTransactionCoverage del = new DeleteOldRiskTransactionCoverage();

        try {
            del.call('invalidAction', new Map<String, Object>());
            System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Unknown action'));
        }
    }
}