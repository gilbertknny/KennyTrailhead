trigger Aswata_Trigger_Lead on Lead (before insert, after insert, before update, after update) {
	new Aswata_TriggerHandler_Lead().run();
}