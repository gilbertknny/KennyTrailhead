trigger EventErrorLog on Error_Logs__e (after insert) {
    EventErrorLogHandler.handleAfterInsert(Trigger.new);
}