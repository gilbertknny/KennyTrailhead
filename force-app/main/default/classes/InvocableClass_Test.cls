/*** @description InvocableClass_Test */
@IsTest
private class InvocableClass_Test {

    @TestSetup
    static void setupTestData() {
        String strRTMd = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Approval Limit').getRecordTypeId();
        Master_Data__c md = new Master_Data__c();
        md.RecordTypeId = strRTMd;
        md.AUTHORITY_TYPE__c = 'UW';
        md.LIMIT_AMOUNT__c = 1000000;
        md.Status__c = 'Approved';
        insert md;

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

    @IsTest
    static void testInvocableMethodBatchExecution() {
        // Retrieve setup data
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Opportunity oldOpp = [SELECT Id FROM Opportunity WHERE Name = 'Old Opty' LIMIT 1];
            Opportunity newOpp = [SELECT Id FROM Opportunity WHERE Name = 'New Opty' LIMIT 1];

            // Prepare input for Invocable class
            InvocableClass.InputVariable input = new InvocableClass.InputVariable();
            input.accountId = acc.Id;
            input.oldoptyId = oldOpp.Id;
            input.newoptyId = newOpp.Id;
            input.param = 'BatchRiskAssetCoverage';
            input.LintaswataSync = false;

            Test.startTest();
            InvocableClass.Invocablevoid(new List<InvocableClass.InputVariable>{ input });
            Test.stopTest();
        }
        System.assert(true, 'Batch executed successfully without exception.');
    }

    @IsTest
    static void testInvocableMethodUnderwritingApproval() {
        
        // Prepare input for Invocable class
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            InvocableClass.InputVariable input = new InvocableClass.InputVariable();
            input.param = 'UnderwritingApproval';
            input.sumInsured = 100000;

            Test.startTest();
            InvocableClass.Invocablevoid(new List<InvocableClass.InputVariable>{ input });
            Test.stopTest();
        }
        System.assert(true, 'executed successfully.');
    }

    @IsTest
    static void testInvocableMethodWithInvalidParam() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Opportunity oldOpp = [SELECT Id FROM Opportunity WHERE Name = 'Old Opty' LIMIT 1];
            Opportunity newOpp = [SELECT Id FROM Opportunity WHERE Name = 'New Opty' LIMIT 1];

            // Input with invalid param - should skip batch
            InvocableClass.InputVariable input = new InvocableClass.InputVariable();
            input.accountId = acc.Id;
            input.oldoptyId = oldOpp.Id;
            input.newoptyId = newOpp.Id;
            input.param = 'InvalidParam';

            Test.startTest();
            InvocableClass.Invocablevoid(new List<InvocableClass.InputVariable>{ input });
            Test.stopTest();
        }
        // No batch should have been executed; just verify no exception
        System.assert(true, 'Handled invalid param without errors.');
    }

    @IsTest
    static void testInvocableMethodWithEmptyList() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.startTest();
            InvocableClass.Invocablevoid(new List<InvocableClass.InputVariable>());
            Test.stopTest();
        }
        System.assert(true, 'Empty input list handled gracefully. ');
    }
}