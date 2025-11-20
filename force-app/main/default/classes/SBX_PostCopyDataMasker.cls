/**
* @description Worker class used to call the Batchable Apex SBX_BatchMaskSandboxData that is used to perform Data Masking of PII fields. 
* It extends the  SBX_PostCopyWorker worker class and implements the run method.
*/ 
public class SBX_PostCopyDataMasker extends SBX_PostCopyWorker {

    private static final String CLASS_NAME = 'SBX_PostCopyDataMasker';

    public override String getClassName(){
        return CLASS_NAME;
    }

    public override void run(SandboxContext context){
        System.debug(context.organizationId());
        System.debug(context.sandboxId());
        System.debug(context.sandboxName());
        Database.executeBatch(new SBX_BatchMaskSandboxData());
        //Adding code to generate exception in test class
        If(Test.isRunningTest()){
            insert new Account();
        }
    }
}