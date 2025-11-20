/**
 * @description FeedItemTriggerHandler
 */
public without sharing class FeedItemTriggerHandler {
    /**
     * @description FeedItemTriggerHandler
     * @param newFeedItems of type List<FeedItem>
     */
    public static void checkChatterPostFileExtensionAndFileSize(List<FeedItem> newFeedItems) {
        //  Prepare data structures for file format and size checks
        Map<Id, FeedItem> contentversionIdToFeedItemMap = new Map<Id, FeedItem>();
        Set<String> fileFormats = new Set<String>{'docx', 'pdf', 'ppt', 'pptx', 'xls', 'xlsx', 'png', 'jpg', 'jpeg', 'snote'};
        Integer maxSizeAllowed = Integer.valueOf(Label.BRI_File_Size_More_Than_25MB);
        
        //  Populate contentversionIdToFeedItemMap with ContentPost FeedItems
        for (FeedItem fi : newFeedItems) {
            if (fi.Type == 'ContentPost') {
                contentversionIdToFeedItemMap.put(fi.RelatedRecordId, fi);
            }
        }
        
        //  Query ContentVersions and apply validation checks
        List<ContentVersion> contentVersions = [SELECT Id, FileExtension, ContentSize 
                                                FROM ContentVersion 
                                                WHERE Id IN :contentversionIdToFeedItemMap.keySet()
                                                WITH SECURITY_ENFORCED];
        for (ContentVersion cv : contentVersions) {
            FeedItem relatedFeedItem = contentversionIdToFeedItemMap.get(cv.Id);
            
            // Check file extension
            if (!fileFormats.contains(cv.FileExtension.toLowerCase())) {
                relatedFeedItem.addError('Only supported formats .docx, .pdf, .ppt, .pptx, .xls, .xlsx, .png, .jpg, jpeg are allowed');
            }
            
            // Check file size
            else if (cv.ContentSize > maxSizeAllowed) {
                relatedFeedItem.addError('File Size should be less than 25 Mb');
            }
        }
    }
}