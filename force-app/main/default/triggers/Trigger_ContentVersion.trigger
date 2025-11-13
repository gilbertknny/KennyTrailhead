trigger Trigger_ContentVersion on ContentVersion (before insert, after insert) {
    new ContentVersion_TriggerHandler().run();
}