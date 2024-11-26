public without sharing class Ctrl_mpCaseReason {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getMasterPicklist() {
        Map<String, String> options = new Map<String, String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{'Case'});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get('Case_Reason__c').getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    options.put(entry.getValue(), entry.getLabel());
                }
            }
            
        }
        return options;
    }
    
    @AuraEnabled
    public static string saveSelectedValues(Id recordId, List<String> selectedValues) {
        string result = '';
        try{
            Case record = new Case(Id = recordId,Case_Reason__c = String.join(selectedValues, ';'));
            if (Schema.sObjectType.Case.fields.Case_Reason__c.isUpdateable()) {
                Database.SaveResult sr = Database.update(record);
                if(sr.isSuccess()) result = 'Success';
                else{
                    string errmsg = '';
                    for(Database.Error err : sr.getErrors()) { errmsg += err.getMessage();}
                    result = errmsg;
                }
            }
        }catch(Exception ex){ result = ex.getMessage();}
        if(result != null){
            if(result.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') > 0)
            	result = result.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
        }
        system.debug('result:'+result);
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldValues(Id recordId) {      
        Case cs = [SELECT Id,Case_Reason__c FROM Case WHERE Id=:recordId];
        return cs.Case_Reason__c != null ? cs.Case_Reason__c.split(';') : new List<String>();
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getIsClosed(Id recordId) {      
        Case cs = [SELECT Id,isClosed FROM Case WHERE Id=:recordId];
        return cs.isClosed;
    }

    
}