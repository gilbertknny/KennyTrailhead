public with sharing class FileUploadControllerMMS {
    public class contentDataWrapper{
        public Integer fileSize {get; set;}
        public String fileType {get; set;}

        public contentDataWrapper(Integer fileSize , String filetType){
            this.fileSize = fileSize;
            this.fileType = fileType;
        }
    }


    @AuraEnabled
    public static contentDataWrapper contentData(String conVerId){
        ContentVersion cv = [SELECT ContentSize, FileType FROM ContentVersion WHERE Id =: conVerId];
        Integer fileSize = cv.ContentSize;
        String fileType = cv.FileType;
         
        contentDataWrapper result = new contentDataWrapper(fileSize,fileType);
        return result;
    }

    @AuraEnabled
    public static Integer fileSize(String contentId){
        ContentDocument cd = [SELECT Id, ContentSize  FROM ContentDocument WHERE Id =: contentId];
        Integer contentSize = cd.ContentSize;
        return contentSize;
    }


    @AuraEnabled
    public static String uploadFile(String contentVersionId, String recordId) {
        Case cs = [SELECT Id, CaseNumber FROM Case WHERE id =: recordId LIMIT 1];
        
        ContentVersion cv = [SELECT Id, ContentDocumentId, FileType, PathOnClient, VersionData 
                            FROM ContentVersion 
                            WHERE Id = :contentVersionId];
        
        String responseBody = SCC_MMSFile.UploadtoMMS(cv, cs.CaseNumber);
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        if (responseMap.get('responseCode') == '200') {
            Map<String, Object> responseData = (Map<String, Object>)responseMap.get('responseData');
            String filePath = (String)responseData.get('data');
            
            cs.MMS_File__c = filePath;
            update cs;
        }
    
        return responseBody;
    }

    @AuraEnabled
    public static void deleteFile(Id contentDocumentId) {
        try {
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
            delete cd;
        } catch (Exception e){
            throw new AuraHandledException('Error deleting files: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SCC_MMSFile.UploadResponse> uploadFilesToMMS(List<String> lcvid, List<String> lcdid, String recId) {
        Case cs = [SELECT Id, CaseNumber FROM Case WHERE id =: recId LIMIT 1];
        List<SCC_MMSFile.UploadRequest> requests = new List<SCC_MMSFile.UploadRequest>();
        SCC_MMSFile.UploadRequest req = new SCC_MMSFile.UploadRequest();
        req.lcvid = lcvid;
        req.lcdid = lcdid;
        req.recId = cs.CaseNumber;
        requests.add(req);

        return SCC_MMSFile.uploadToMMS(requests);
    }

    @AuraEnabled
    public static void deleteFiles(List<String> contentDocumentIds) {
        try {
            if (!contentDocumentIds.isEmpty()) {
                List<ContentDocument> docsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
                if (!docsToDelete.isEmpty()) {
                    delete docsToDelete;
                    System.debug('cd berhasil dihapus: ' + contentDocumentIds);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting files: ' + e.getMessage());
        }
    }
}