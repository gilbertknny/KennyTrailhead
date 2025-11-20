trigger AccountTrigger on Account (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            for (Account acc: Trigger.new) {
                acc.Phone = acc.Phone?.replaceFirst('^628', '08');
            }
        } else if (Trigger.isUpdate) {
            for (Account acc: Trigger.new) {
                acc.Phone = acc.Phone?.replaceFirst('^628', '08');
            }
        }
    }
}