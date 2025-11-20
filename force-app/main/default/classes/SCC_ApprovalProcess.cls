/**
    FITUR : WFM
 */
public with sharing class SCC_ApprovalProcess {
    @InvocableMethod(label='Invocable Aprroval' description='Invocable for Aprroval' category='Invocable')    
    public static void invocablevoid(List< FlowInputValues > flowinput) {
        for(FlowInputValues fi:flowinput){
            if(fi.type=='Bulk'){
                bulkApproveOrReject(fi);
            }
            else{
                setApproveOrReject(fi);
            }
        }
    }

    public static void bulkApproveOrReject(FlowInputvalues fi){
        Database.executeBatch(new SCC_BulkApprovalProccess(fi), 10);
    }

    public static void setApproveOrReject(FlowInputvalues fi){
        system.debug('fi : '+fi);
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :fi.recordId 
        ];
        system.debug('workItems : '+workItems);
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction(fi.action);
            req.setComments(fi.comment);
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
    }
    public class FlowInputvalues{
        //PARAM
        @invocablevariable public String type;
        @invocablevariable public String query;
        //
        @invocablevariable public String recordId;
        @invocablevariable public String action;
        @invocablevariable public String userId;
        @invocablevariable public String comment; //Valid values are: Approve, Reject, or Removed. //Only system administrators can specify Removed.
    }
}