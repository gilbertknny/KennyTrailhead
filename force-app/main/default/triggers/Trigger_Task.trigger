trigger Trigger_Task on Task (before insert, before update, after insert, after update, after delete) {
    new TriggerHandler_Task().run();
}