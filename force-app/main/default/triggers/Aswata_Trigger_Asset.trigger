trigger Aswata_Trigger_Asset on Asset (before insert, after insert, after update, after delete, before update) {
    new Aswata_TriggerHandler_Asset().run();
}