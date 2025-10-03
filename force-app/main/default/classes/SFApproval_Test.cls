@IsTest
public with sharing class SFApproval_Test {
     @IsTest
    static void testApprovalUsingSfApproval() {
        // --- Step 1: Create test data ---
        FKD_Marketing__c app = BFI_TestDataFactory.createFKDMarketing_approval(
            'Test App', 'AGR-001', 'Jane Smith'
        );

        // --- Step 2: Submit for approval ---
        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setComments('Submitting for approval');
        submitReq.setObjectId(app.Id);

        Approval.ProcessResult submitResult = Approval.process(submitReq);
        System.assert(submitResult.isSuccess(), 'Submission should succeed');

        // --- Step 3: Query Workitem (pending approval step) ---
        ProcessInstanceWorkitem piw = [
            SELECT Id, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :app.Id
            LIMIT 1
        ];

        // --- Step 4: Call your custom Invocable ---
        SfApproval.ParamIn param = new SfApproval.ParamIn();
        param.recordId_piw = piw.Id;
        param.strAction = 'Approve';
        param.strComment = 'Invocable approval test';

        SfApproval.giveApproval(new List<SfApproval.ParamIn>{ param });

        // --- Step 5: Verify record is approved ---
        ProcessInstanceStep approvedStep = [
            SELECT StepStatus, Comments
            FROM ProcessInstanceStep
            WHERE ProcessInstance.TargetObjectId = :app.Id
            AND StepStatus = 'Approved'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.assertEquals('Approved', approvedStep.StepStatus,
            'Step should be marked as Approved');
        System.assertEquals('Invocable approval test', approvedStep.Comments,
            'Approval comment should match');
    }
}