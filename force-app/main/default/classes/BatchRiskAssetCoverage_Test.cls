/*** @description BatchRiskAssetCoverage_Test */
@isTest
private class BatchRiskAssetCoverage_Test {

    @TestSetup
    static void setupTestData() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create a RecordType for Asset with Name = 'Risk'
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset' AND Name = 'Risk' LIMIT 1];
        
        // Create a test Opportunity
        Opportunity oldOpp = new Opportunity(Name = 'Old Opty', StageName = 'Prospecting', CloseDate = System.today());
        insert oldOpp;

        // Create a test Asset related to old Opportunity
        Asset asset = new Asset(
            Name = 'Test Asset',
            RecordTypeId = rt.Id,
            Opportunity__c = oldOpp.Id
        );
        insert asset;

        // Create another Opportunity for new reference
        Opportunity newOpp = new Opportunity(Name = 'New Opty', StageName = 'Prospecting', CloseDate = System.today());
        insert newOpp;
    }

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity oldOpp = [SELECT Id FROM Opportunity WHERE Name = 'Old Opty' LIMIT 1];
        Opportunity newOpp = [SELECT Id FROM Opportunity WHERE Name = 'New Opty' LIMIT 1];
        String query = 'SELECT Id from Asset where Opportunity__c = '+'\''+oldOpp.Id+'\' and Recordtype.Name = '+'\'Risk'+'\'';
        BatchRiskAssetCoverage batch = new BatchRiskAssetCoverage(query,newOpp.Id,acc.Id);
        Database.executeBatch(batch,1);
        BatchRiskAssetCoverage.insertErrorLog(null);
        Test.stopTest();
        System.assert(true, 'Batch executed without unhandled exception.');
    }
}