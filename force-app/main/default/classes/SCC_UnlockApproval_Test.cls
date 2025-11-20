/**
 * @description       : Test class for SCC_UnlockApproval
 * @last modified on  : 03-06-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_UnlockApproval_Test {
    @testSetup
    static void setupData() {
        Case caseRecord = new Case(
            Status = 'Draft',
            SCC_Account_Number__c = '12211200001',
            Approval_Status__c = 'Draft'
        );
        insert caseRecord;
    }
    @isTest
    static void testUnlockThisCase() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        SCC_UnlockApproval.unlockThisCase(caseId);
        Test.stopTest();

        System.assert(true, 'UnlockThisCase executed without exceptions');
    }

    @isTest
    static void testUnlockInvoc() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        SCC_UnlockApproval.unlockInvoc(caseId, 'Waiting for Checker', 'Pending Approval');
        Test.stopTest();

        System.assert(true, 'UnlockInvoc method executed without exceptions');
    }

    @isTest
    static void testInvocablevoid() {
        // Prepare the FlowInputvalues
        SCC_UnlockApproval.flowInputvalues input = new SCC_UnlockApproval.flowInputvalues();
        input.csid = [SELECT Id FROM Case LIMIT 1].Id;
        input.newStatus = 'Waiting for Checker';
        input.oldStatus = 'Pending Approval';

        List<SCC_UnlockApproval.flowInputvalues> inputs = new List<SCC_UnlockApproval.flowInputvalues>{ input };

        Test.startTest();
        SCC_UnlockApproval.Invocablevoid(inputs);
        Test.stopTest();

        System.assert(true, 'Invocablevoid method executed without exceptions');
    }

    @isTest
    static void testUnlock() {
        Case oldCaseRecord = [SELECT Id, Approval_Status__c FROM Case LIMIT 1];
        
        Case updatedCase = new Case(
            Id = oldCaseRecord.Id,
            Approval_Status__c = 'Waiting for Checker'
        );
        List<Case> newList = new List<Case>{ updatedCase };

        Map<Id, Case> oldMap = new Map<Id, Case>{ oldCaseRecord.Id => oldCaseRecord };

        Test.startTest();
        SCC_UnlockApproval.unlock(newList, oldMap);
        Test.stopTest();

        System.assert(true, 'Unlock method executed without exceptions');
    }
}