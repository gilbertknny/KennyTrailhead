public with sharing class SCC_EditCase {
    @AuraEnabled
    public static Case getCaseDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = ',SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name,parent.case_number__c';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Case cs = Database.query(queries);
        return cs;
    }

    @AuraEnabled
    public static CustomLookupController.RecordsData getParentCase(String idcs) {
        String cond = 'id=:idcs';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Case ct = Database.query(queries);
        CustomLookupController.RecordsData rd = new CustomLookupController.RecordsData(ct.Case_Number__c,ct.id);
        return rd;
    }

    @AuraEnabled
    public static Case updateCase(Case cs){
        update cs;
        return cs;
    }
}