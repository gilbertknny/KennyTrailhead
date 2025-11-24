trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        EmailMessageTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        EmailMessageTriggerHandler.afterInsert(Trigger.new);
    }
}