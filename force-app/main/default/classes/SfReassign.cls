public without sharing class SfReassign {
	public class ParamIn {
        @InvocableVariable
        public String recordId_piw;
     
        @InvocableVariable
        public String strActorId;
    }
    
 	@InvocableMethod
    public static void setReassign(List<ParamIn> PrmIn)
    {
        ProcessInstanceWorkItem pi = [SELECT Id, ActorId FROM ProcessInstanceWorkItem WHERE Id =: PrmIn[0].recordId_piw LIMIT 1];
		pi.ActorId = PrmIn[0].strActorId;
		update pi;
    }
}