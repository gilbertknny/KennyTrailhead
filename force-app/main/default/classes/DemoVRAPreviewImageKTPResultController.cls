public with sharing class DemoVRAPreviewImageKTPResultController {
    @AuraEnabled(cacheable=true)
    public static string getImageUrlByContentVersionId(id recordId){
        try {
            if (recordId == null) return null;

            List<ContentVersion> versions = [
            SELECT Id
            FROM ContentVersion
            WHERE Id = :recordId
            LIMIT 1
            ];

            if (versions.isEmpty()) return null;

            return '/sfc/servlet.shepherd/version/download/' + versions[0].Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}