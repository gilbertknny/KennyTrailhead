/**
 * @description  Trigger for event before and after insert for EmailMessage.
 *               Call EmailMessageTriggerHandler separation of concern.
 * @author       Peppp
 * @date         2025
 * @triggerUsage Fill Thread_ID__c before insert.
 */
trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {

    // Handle BEFORE INSERT
    if (Trigger.isBefore && Trigger.isInsert) {
        EmailMessageTriggerHandler.beforeInsert(Trigger.new);
    }

    // Handle AFTER INSERT
    if (Trigger.isAfter && Trigger.isInsert) {
        EmailMessageTriggerHandler.afterInsert(Trigger.new);
    }
}