@isTest
public class FeedItemTriggerTest {
    @isTest
    static void testSupportedFileFormatAndSize() {
        // Create a ContentVersion with a supported file format and appropriate size
        ContentVersion cv = new ContentVersion(
            Title = 'Supported File', 
            PathOnClient = 'file.pdf',
            VersionData = Blob.valueOf('Sample data'),
            Origin = 'H',
            FirstPublishLocationId = UserInfo.getUserId()
        );
        insert cv;
        
        // Create a FeedItem linked to the ContentVersion
        FeedItem fi = new FeedItem(
            ParentId = UserInfo.getUserId(),
            Type = 'ContentPost',
            RelatedRecordId = cv.Id
        );
        
        Test.startTest();
        insert fi;
        Test.stopTest();
                
        // Verify the FeedItem was inserted successfully
        FeedItem insertedFeedItem = [SELECT Id FROM FeedItem WHERE Id = :fi.Id];
        System.assertNotEquals(null, insertedFeedItem, 'FeedItem should have been inserted successfully.');
    }
}