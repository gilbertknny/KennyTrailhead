trigger Trigger_MasterData on Master_Data__c (before insert, before update, after insert, after update) {
    new TriggerHandler_MasterData().run();
}