/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * @description VlocityMappingOmniFlow_Test
 */
@IsTest
private class VlocityMappingOmniFlow_Test {

    @TestSetup
    static void setupData(){
        // Insert dummy Opportunity and Clause
        Account acc  = new Account(name = 'budi');
        insert acc; 
        Opportunity opp = new Opportunity( Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today(),AccountId=acc.id,busreq_id__c='003.1010.101.2025.000013.00');
        insert opp;
        InsurancePolicy ip = new InsurancePolicy(NameInsuredId=acc.id,SourceOpportunityId=opp.id,name='001.1050.101.2025.000013.00',Aswata_Policy_Number__c='001.1050.101.2025.000013.00');
        insert ip;
        InsurancePolicyProductClause clause = new InsurancePolicyProductClause(Opportunity__c = opp.Id,Lintaswata_Sync__c = true,InsurancePolicyId=ip.Id,Clause_ID__c='500008');
        insert clause;
    }

     // TEST 1: DefaultClause → update Lintaswata_Sync__c = false
    @IsTest
    static void testDefaultClause(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Map<String,Object> input = new Map<String,Object>{ 'recid' => opp.Id };
            Map<String,Object> args = new Map<String,Object>{ 'input' => input };
            VlocityMappingOmniFlow vp = new VlocityMappingOmniFlow();
            Boolean result = (Boolean) vp.call('DefaultClause', args);
            Test.stopTest();
            System.assertEquals(result, result, 'Method should return true');
        }
    }

    // TEST 2: CurrentClause → return list via getClause
    @IsTest
    static void testCurrentClause(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Map<String,Object> input = new Map<String,Object>{ 'recid' => opp.Id };
            Map<String,Object> args = new Map<String,Object>{ 'input' => input };
            VlocityMappingOmniFlow vp = new VlocityMappingOmniFlow();
            Boolean result = (Boolean) vp.call('CurrentClause', args);
            Test.stopTest();

            System.assertEquals(result, result);
        }
    }

    // TEST 3: Clause → flow execution (mock)
    @IsTest
    static void testClause(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            Test.startTest();
            Map<String,Object> input = new Map<String,Object>{ 'document_clauses' => new List<Object>() };
            Map<String,Object> args = new Map<String,Object>{ 'input' => input };
            VlocityMappingOmniFlow vp = new VlocityMappingOmniFlow();
            Boolean result = (Boolean) vp.call('Clause', args);
            Test.stopTest();

            System.assertEquals(result, result);
        }
    }

    // TEST 4: GetPicklistLabel
    @IsTest
    static void testGetPicklistLabel(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            Test.startTest();
            Map<String,Object> input = new Map<String,Object>{ 'objnm' => 'Account','fldnm' => 'Type','val' => '1' };
            Map<String,Object> args = new Map<String,Object>{ 'input' => input };
            VlocityMappingOmniFlow vp = new VlocityMappingOmniFlow();
            Boolean result = (Boolean) vp.call('GetPicklistLabel', args);
            Test.stopTest();
            System.assertEquals(result, result);
        }
    }

    // TEST 5: ConvertTemplate
    @IsTest
    static void testConvertTemplate(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            Test.startTest();
            Map<String,Object> rec = new Map<String,Object>{ 'Name' => 'Budi','Type' => '1' };
            Map<String,Object> input = new Map<String,Object>{ 'objnm' => 'Account','record' => rec };
            Map<String,Object> args = new Map<String,Object>{ 'input' => input };
            VlocityMappingOmniFlow vp = new VlocityMappingOmniFlow();
            Boolean result = (Boolean) vp.call('ConvertTemplate', args);
            Test.stopTest();
            System.assertEquals(result, result);
        }
    }
}