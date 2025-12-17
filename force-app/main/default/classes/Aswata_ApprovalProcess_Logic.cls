public with sharing class Aswata_ApprovalProcess_Logic {

    public class ApprovalRequestInput {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String action; // "Submit", "Approve", "Reject", "Contra Quote"

        @InvocableVariable
        public String comments;
    }

    public class ApprovalRequestOutput {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Run Approval Process' description='Submit/Approve/Reject/Contra Quote in approval process')
    public static List<ApprovalRequestOutput> runApproval(List<ApprovalRequestInput> requests) {
        List<ApprovalRequestOutput> results = new List<ApprovalRequestOutput>();

        String recordId = '';
        String action = '';
        String comments = '';
        String stageAction = '';
        for (ApprovalRequestInput req : requests) {
            recordId = req.recordId;
            action = req.action;
            comments = req.comments;
            ApprovalRequestOutput res = new ApprovalRequestOutput();
            try {
                if (req.action == 'Submit') {
                    Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
                    submitReq.setObjectId(req.recordId);
                    if (req.comments != null) submitReq.setComments(req.comments);

                    Approval.ProcessResult pr = Approval.process(submitReq);

                    res.success = pr.isSuccess();
                    res.message = pr.isSuccess() ? 'Record submitted for approval' : 'Approval process failed to submit.';
                }
                else if (req.action == 'Approved' || req.action == 'Rejected' || req.action == 'Contra Quote' || req.action == 'Approve On Hold Binding' || req.action == 'Cancel') {
                    if(req.action == 'Approved' || req.action == 'Approve On Hold Binding'){
                        req.action = 'Approve';
                        stageAction = 'Quote';
                    }
                    else {
                        req.action = 'Reject';
                        stageAction = 'Closed';
                    }
                    
                    ProcessInstanceWorkitem workItem = [
                        SELECT Id FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId = :req.recordId
                        LIMIT 1
                    ];

                    Approval.ProcessWorkitemRequest workReq = new Approval.ProcessWorkitemRequest();
                    workReq.setWorkitemId(workItem.Id);
                    workReq.setAction(req.action);
                    if (req.comments != null) workReq.setComments(req.comments);

                    Approval.ProcessResult pr = Approval.process(workReq);

                    res.success = pr.isSuccess();
                    res.message = pr.isSuccess() 
                        ? 'Record ' + req.action + 'ed successfully' 
                        : 'Approval process failed to ' + req.action;

                    
                }
                else {
                    res.success = false;
                    res.message = 'Invalid action: ' + req.action;
                }

            } catch (Exception e) {
                res.success = false;
                res.message = 'Error: ' + e.getMessage();
            }
            results.add(res);
        }

        if(String.isNotBlank(recordId)){
            
            if(action == 'Submit'){
                action = 'Waiting for Approval';
            } 
            System.debug('RecordId: '+ recordId + ' Action: '+ action + ' Comments: '+ comments);
            Quote upQuo = new Quote();
            upQuo.Id = recordId;
            upQuo.Stage__c = stageAction;
            upQuo.Status = action;
            upQuo.Remark__c = comments;
            if (Schema.sObjectType.Quote.isUpdateable()) {
                Database.update(upQuo, false); 
            } else {
                System.debug('No permission to update Quote');
            }
        }
        return results;
    }
}