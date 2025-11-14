trigger Aswata_Trigger_Account on Account (before insert, after insert, before update, after update) {
    new Aswata_TriggerHandler_Account().run();
}