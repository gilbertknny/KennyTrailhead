public class SCC_UnlockApproval {
    public static void unlock(Case[] newList, Map<Id, Case> oldMap) {
        for(Case c : newList){
            Case oldCase = oldMap.get(c.Id);
            System.debug('masuk unlock approval');
            if(c.Approval_Status__c != oldCase.Approval_Status__c && (c.Approval_Status__c == 'Waiting for Checker' || c.Approval_Status__c == 'Waiting for Signer')){
                System.debug('diunlock');
                unlockThisCase(c.Id);
            }
        }
    }
    
    @future (callout=false)
    public static void unlockThisCase(id recordId){
        Approval.UnLockResult lr = Approval.unlock(recordId, false);
                System.debug('diunlock setelah');
                if (lr.isSuccess()) {
                    System.debug('Successfully Unlocked Quote with ID: ' + lr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Quote fields that affected this error: ' + err.getFields());
                    }
                }
    }
    
    @InvocableMethod(label='Unlock Record' description='Invocable code model can call from apex/flow' category='Invocable')    
    public static void Invocablevoid(List< flowInputvalues > flowinput) {
        for(flowInputvalues fi:flowinput){
            unlockInvoc(fi.csid, fi.newStatus, fi.oldStatus);
        }
    }
    
    public static void unlockInvoc(String csid, String newStatus, String oldStatus){
        if(newStatus != oldStatus && (newStatus == 'Waiting for Checker' || newStatus == 'Waiting for Signer')){
            System.debug('diunlock');
            Approval.unlock(csId, false);
            System.debug('diunlock setelah');
        }
    }
    
    public class flowInputvalues{
        //PARAM
        @invocablevariable public String csid;
        @invocablevariable public String newStatus;
        @invocablevariable public String oldStatus;
    }
}