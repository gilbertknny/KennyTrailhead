/**
*   The sf-sandbox-post-copy framework is an open source project managed in Github (https://github.com/GSA/sf-sandbox-post-copy)
*
*   SBX_PostCopyManager
*
*   @author Derek Benner
*   @author Manikanta Ramineni
*   @author Christian Coleman
*   @date 4/12/2016
*/
public with sharing class SBX_PostCopyManager implements SandboxPostCopy{

    public void runApexClass(SandboxContext context){
        // run the list of apex classes stored in the metadata type Post_Copy_Task__mdt
        List<SBX_PostCopyWorker> workerList = SBX_PostCopyWorkerFactory.getWorkers();
        for(SBX_PostCopyWorker worker : workerList){
            worker.process(context);
        }
    }

}