/**
 * Controller for LWC "lwcRenewal"
 * TC : GS
 * DATE : 28/10/25
 */

public without sharing class ClsRenewal {
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getPicklist(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};
      	List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {  
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
	@AuraEnabled
    public static string saveData(string opptype, string refid, string statusrenewalid, string description,
                                 string insuranceEndorseDate,string endorseNoteChangeId){
        string result = '';
        Savepoint sp = Database.setSavepoint();
        try{
            if(refid != null && opptype != null){
                InsurancePolicy ip = [SELECT Id,SourceOpportunityId FROM InsurancePolicy WHERE Id =:refid];
                //String objectApiName = 'Opportunity';
                //List<String> fields = getAllFields(objectApiName); String.join(fields, ',')
                //String query = 'SELECT Id FROM ' + objectApiName + ' WHERE Ref_Policy_Number__c = \'' + String.escapeSingleQuotes(refid) + '\' ORDER BY Id LIMIT 1';
            	//LIST<Opportunity> listopp = Database.query(query);
                if(ip.SourceOpportunityId != null){
                    //Opportunity opp = ip.SourceOpportunityId;
                    /*Opportunity newopp = opp.clone(false,true,false,false);
                    newopp.Opportunity_Type__c = opptype;
                    newopp.Ref_Policy_Number__c = null;
                    newopp.StageName = 'Opportunity';
                    Database.SaveResult sr = Database.insert(newopp);
                    result = sr.Id;*/
                    Map<String,Object> params = new Map<String,Object>();
                    params.put('recordId',ip.SourceOpportunityId);
                    params.put('OpportunityType',opptype);
                    params.put('ref_policy_number',refid);
                    if(opptype == 'RN'){ params.put('Description',description);}
                    else if(opptype == 'ED'){
                        Date dtInsurance = Date.valueOf(insuranceEndorseDate);
                    	params.put('Insurance_Endorse_Date',dtInsurance);
                    	params.put('Endorse_Note_Change',endorseNoteChangeId);
                    	params.put('Endorsement_Description',description);
                    }
                    //params.put('ExpiredDatePolicy','');
                    //params.put('BUSREQ_ID','');
                    
                    Flow.Interview.Opportunity_Auto_Launched_Clone_Oppty newopp = new Flow.Interview.Opportunity_Auto_Launched_Clone_Oppty(params);
                    newopp.start();
                    Opportunity oppresult = (Opportunity)newopp.getvariableValue('OpportunityResult');
                    system.debug(LoggingLevel.WARN,'oppresult:'+oppresult);
                    
                    if(opptype == 'RN'){
                        //InsurancePolicy ip = New InsurancePolicy();
                        //ip.Id = refid;
                        ip.Status_Renewal__c = statusrenewalid;
                        Database.SaveResult sr = Database.update(ip);
                    }
                    result = oppresult.Id;
                }else{ result = 'Opportunity not find, please change the Policy Number!'; }
            }else{ result = 'Data must be filled!'; }
        }catch(exception e){ Database.rollback(sp); result = e.getMessage(); }
        system.debug(LoggingLevel.WARN,'result:'+result);
        return result;
    }
    
    /*public static List<String> getAllFields(String objectApiName) {
        List<String> fieldNames = new List<String>();
        Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            // Optionally, filter for creatable or updateable fields if needed
            // if (fieldMap.get(fieldName).getDescribe().isCreateable()) {
                fieldNames.add(fieldName);
            // }
        }
        return fieldNames;
    }*/
}