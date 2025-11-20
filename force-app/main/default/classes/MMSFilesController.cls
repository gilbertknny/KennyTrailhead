public with sharing class MMSFilesController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getMMSFiles(String caseId) {
        List<ContentDocumentLink> lstCDL = [
            SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.CreatedDate
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :caseId
            ORDER BY ContentDocument.CreatedDate DESC LIMIT 1
        ];
        
        Set<Id> cdlId = new Set<Id>();
        for(ContentDocumentLink objCDL : lstCDL){
            cdlId.add(objCDL.ContentDocumentId);
        }
        
        // Query the files related to the Incident
        if(!cdlId.isEmpty()){
            return [
                SELECT Id, Title, FileType, ContentSize, CreatedDate 
                FROM ContentDocument 
                WHERE Id IN :cdlId
            ];
        }
        return null;
    }
}