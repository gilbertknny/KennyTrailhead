public with sharing class CasetypeFilesController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getCasetypeFiles(String casetypeId) {
        List<ContentDocumentLink> lstCDL = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :casetypeId
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