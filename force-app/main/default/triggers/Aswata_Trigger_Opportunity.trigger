trigger Aswata_Trigger_Opportunity on Opportunity (before insert, after insert, before update, after update) {
	new Aswata_TriggerHandler_Opportunity().run();
}