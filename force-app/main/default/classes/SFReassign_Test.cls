@IsTest
public class SFReassign_Test {

    @IsTest
    static void testReassignApprovalWorkitem() {
        // --- Step 1: Create test data ---
        FKD_Marketing__c app = BFI_TestDataFactory.createFKDMarketing_approval(
            'Test App', 'AGR-001', 'Jane Smith'
        );

        // Create a dummy user to reassign to
        User reassignee = BFI_TestDataFactory.createSysAdminUser('treas');

        // --- Step 2: Submit record for approval ---
        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setComments('Submitting for approval');
        submitReq.setObjectId(app.Id);

        Approval.ProcessResult submitResult = Approval.process(submitReq);

        System.assert(submitResult.isSuccess(), 'Submission should succeed');
        System.assertEquals('Pending', submitResult.getInstanceStatus(),
            'Record should be pending approval');

        // --- Step 3: Query Workitem (pending approval step) ---
        ProcessInstanceWorkitem piw = [
            SELECT Id, ActorId, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :app.Id
            LIMIT 1
        ];

        Id oldActor = piw.ActorId;

        // --- Step 4: Call SfReassign ---
        SfReassign.ParamIn prm = new SfReassign.ParamIn();
        prm.recordId_piw = piw.Id;
        prm.strActorId = reassignee.Id;

        Test.startTest();
        SfReassign.setReassign(new List<SfReassign.ParamIn>{ prm });
        Test.stopTest();

        // --- Step 5: Verify ActorId was updated ---
        ProcessInstanceWorkitem updatedPiw = [
            SELECT Id, ActorId
            FROM ProcessInstanceWorkitem
            WHERE Id = :piw.Id
            LIMIT 1
        ];

        System.assertNotEquals(oldActor, updatedPiw.ActorId,
            'ActorId should have changed after reassignment');
        System.assertEquals(reassignee.Id, updatedPiw.ActorId,
            'ActorId should match the reassigned user');
    }
}