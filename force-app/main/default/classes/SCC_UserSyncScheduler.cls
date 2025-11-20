global with sharing class SCC_UserSyncScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        //SCC_UserSyncCtrl.syncUser();
        System.enqueueJob(new SCC_UserSyncCtrl());
    }

}