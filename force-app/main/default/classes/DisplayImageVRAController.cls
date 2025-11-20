public with sharing class DisplayImageVRAController {
    public class VRAFileResult {
        @AuraEnabled public String versionId;
        @AuraEnabled public String previewUrl;
        @AuraEnabled public String title;
    }

    @AuraEnabled(cacheable=true)
    public static List<VRAFileResult> getFileImageCaseVRA(Id recordId) {
        try {
            List<ContentDocumentLink> links = [
                SELECT ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId 
                AND ContentDocument.FileExtension IN ('png', 'jpg', 'jpeg')
                ORDER BY ContentDocument.CreatedDate DESC 
                LIMIT 10
            ];
            System.debug('Fetched ContentDocumentLink records: ' + links);

            List<VRAFileResult> results = new List<VRAFileResult>();

            for (ContentDocumentLink link : links) {
                System.debug('Processing ContentDocumentLink: ' + link);
                VRAFileResult file = new VRAFileResult();
                file.versionId = link.ContentDocument.LatestPublishedVersionId;
                file.previewUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + file.versionId;
                file.title = link.ContentDocument.Title;
                System.debug('Created VRAFileResult: ' + file);
                results.add(file);
            }

            System.debug('Returning results: ' + results);
            return results;

        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}