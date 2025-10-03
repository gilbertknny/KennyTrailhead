global class SfApproval {
	public class ParamIn {
        @InvocableVariable
        public String recordId_piw;
     
        @InvocableVariable
        public String strAction;
        
        @InvocableVariable
        public String strComment;
    }
    
 	@InvocableMethod
    public static void giveApproval(List<ParamIn> PrmIn)
    {
        //List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recId];
        try{
            Approval.ProcessWorkitemRequest Preq = new Approval.ProcessWorkitemRequest();
                Preq.setComments( PrmIn[0].strComment );
                Preq.setAction( PrmIn[0].strAction );
                Preq.setWorkitemId( PrmIn[0].recordId_piw );
            Approval.process(Preq,true);
        } catch (Exception e) {
        	System.debug('giveApproval Exception: ' + e.getMessage());
            throw new CalloutException('Failed to call giveApproval: ' + e.getMessage());
        }

    }
}