public with sharing class FileUploadController {

    // public static final Integer maxSize = 5 * 1024 * 1024;

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
        Incident inc = [SELECT Id, Nomor_tiket_iRIS__c FROM Incident WHERE id =: recordId LIMIT 1];
        String contentType = SCC_ITSMWebserviceHelper.GetContentType();
        String incidentId = inc.Nomor_tiket_iRIS__c;
        String responseBody = SCC_ITSMFile.UploadtoITSM(contentVersionId, contentType, incidentId);

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
    public static List<String> uploadFiles(List<String> contentVersionIds, String recordId) {
        Incident inc = [SELECT Id, Nomor_tiket_iRIS__c FROM Incident WHERE id =: recordId LIMIT 1];
        String contentType = SCC_ITSMWebserviceHelper.GetContentType();
        String incidentId = inc.Nomor_tiket_iRIS__c;
        List<String> responseBody = new List<String>();

        // Long totalSize = 0;
        // for (String contentVersionId : contentVersionIds) {
        //     ContentVersion cv = [SELECT Id, Title, ContentSize FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
        //     totalSize += cv.ContentSize;
        // }

        // if (totalSize > maxSize) {
        //     throw new AuraHandledException('Total ukuran file tidak boleh lebih dari 5MB.');
        // }

        for (String contentVersionId : contentVersionIds) {
            String resBody = SCC_ITSMFile.UploadtoITSM(contentVersionId, contentType, incidentId);
            if (String.isNotBlank(resBody)) {
                responseBody.add(resBody);
            }
        }

        return responseBody;
    }

    @AuraEnabled
    public static List<SCC_ITSMFile.UploadResponse> uploadFilesToITSM(List<String> lcvid, List<String> lcdid, String recId) {
        Incident inc = [SELECT Id, Nomor_tiket_iRIS__c FROM Incident WHERE id =: recId LIMIT 1];
        List<SCC_ITSMFile.UploadRequest> requests = new List<SCC_ITSMFile.UploadRequest>();
        SCC_ITSMFile.UploadRequest req = new SCC_ITSMFile.UploadRequest();
        req.lcvid = lcvid;
        req.lcdid = lcdid;
        req.recId = inc.Nomor_tiket_iRIS__c;
        requests.add(req);

        return SCC_ITSMFile.uploadToITSM(requests);
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