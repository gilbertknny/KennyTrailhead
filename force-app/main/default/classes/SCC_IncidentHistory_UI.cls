public with sharing class SCC_IncidentHistory_UI {
    
    @AuraEnabled
    public static Incident getIncidentDetail(String idIncident){
        // String cond = 'id=:idIncident';
        // String allfield = SOQL_SOBJECT.getallfield('Incident');
        // String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Incident', cond, '', '', '');
        // Incident inc = Database.query(queries);
        // return inc;

        if (String.isBlank(idIncident)) {
            throw new AuraHandledException('Incident ID cannot be null or empty');
        }
        
        try {
            Incident inc = [SELECT Id,IncidentNumber, Hold_Justification__c, Un_Hold_Justification__c, Root_Cause2__c, Remark_History__c
            FROM Incident 
            WHERE Id = :idIncident 
            LIMIT 1];

            return inc;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving Incident: ' + e.getMessage());
        }
    }

}