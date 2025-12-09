trigger Aswata_Trigger_Asset on Asset (after insert, after update, after delete) {
    new Aswata_TriggerHandler_Asset().run();
}