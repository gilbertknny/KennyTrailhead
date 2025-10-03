public class bb {
    public static String test(){
        return 'test';
    }
    /*
	@AuraEnabled
    public static List<ProcessInstanceWorkitem> getTaskApproval() {
        return [
            SELECT Id, CreatedBy.Name, OriginalActor.Name, Actor.Name,
                    ProcessInstance.Status, 
                    ProcessInstance.TargetObject.Name 
            FROM ProcessInstanceWorkitem
            WHERE IsDeleted = false
            ORDER BY CreatedDate DESC
        ];
    }

    public static void test(){
        for (ProcessInstanceWorkitem t : getTaskApproval()) {
           	System.debug('t = ' + t.CreatedBy.Name + '|' + t.OriginalActor.Name + '|' + t.Actor.Name );
        }
    }
    */
}