public with sharing class IncidentFilesController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getIncidentFiles(String incidentId) {
        List<ContentDocumentLink> lstCDL = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :incidentId
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