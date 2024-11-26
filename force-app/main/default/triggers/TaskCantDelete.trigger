trigger TaskCantDelete on Task (before delete) {
    String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

    for (Task tsk : Trigger.old) {
        if (userProfileName != 'System Administrator') {
            tsk.addError('Penghapusan task dinonaktifkan untuk non-Sistem Administrator.');
        }
    }
}