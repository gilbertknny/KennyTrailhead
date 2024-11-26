public without sharing class Ctrl_picklistFormulir {
	@AuraEnabled(cacheable=true)
    public static Map<String, String> getMasterPicklist(Id recordId,String idCallType) {
        Map<String, String> options = new Map<String, String>();
        /*List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{'Case'});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get('Case_Reason__c').getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    options.put(entry.getValue(), entry.getLabel());
                }
            }
            
        }*/
        options.put('','Select an Option');
        List<Case> listcs = [SELECT Id,SCC_Call_Type__c FROM Case WHERE Id=:recordId AND SCC_Call_Type__c != NULL];
        if(listcs.size()>0){
            Case cs = listcs[0];
            if(idCallType == null) idCallType = cs.SCC_Call_Type__c;
            system.debug('idCallType:'+idCallType);
            List<Formulir_Detail__c> listdata = [SELECT Id,Name FROM Formulir_Detail__c WHERE Case_Type__c =:idCallType];
            for(Formulir_Detail__c data : listdata){
                options.put(data.Id,data.Name);
            }
        }
        return options;
    }
    
    @AuraEnabled
    public static formulir saveSelectedValues(Id recordId, String selectedValue) {
        system.debug('recordId:'+recordId);
        system.debug('selectedValue:'+selectedValue);
        formulir result = new formulir();
        try{
            if(selectedValue == '') selectedValue = NULL;
            Case record = new Case(Id = recordId,Formulir_Detail__c = selectedValue);
            if (Schema.sObjectType.Case.fields.Formulir_Detail__c.isUpdateable()) {
                Database.SaveResult sr = Database.update(record);
                if(sr.isSuccess()) result.message = 'Success';
                else{ string errmsg = ''; for(Database.Error err : sr.getErrors()) { errmsg += err.getMessage();} result.message = errmsg; }
            }
            Case cs = getCase(recordId);
            result.description = cs.Description;
            result.id = cs.Id;
            result.isClosed = cs.IsClosed;
        }catch(Exception ex){ result.message = ex.getMessage();}
        if(result.message != null){
            if(result.message.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') > 0) result.message = result.message.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
        }
        system.debug('result:'+result);
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getFieldValues(Id recordId) {      
        Case cs = [SELECT Id,Formulir_Detail__c FROM Case WHERE Id=:recordId];
        return cs.Formulir_Detail__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static Case getCase(Id recordId) {      
        Case cs = [SELECT Id,isClosed,Description FROM Case WHERE Id=:recordId];
        return cs;
    }

    public class formulir{
        @AuraEnabled public id id {get;set;}
        @AuraEnabled public Boolean isClosed {get;set;}
        @AuraEnabled public String Description {get;set;}
        @AuraEnabled public String message {get;set;}
    }
}