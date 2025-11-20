trigger FeedItemTrigger on FeedItem (before insert) {

    FeedItemTriggerHandler.checkChatterPostFileExtensionAndFileSize(trigger.new);

}