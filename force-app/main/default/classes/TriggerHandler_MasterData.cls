/**
 * Class for Trigger_MasterData
 * TC : GS
 * DATE : 10/10/25
 */

public with sharing class TriggerHandler_MasterData extends TriggerHandler{
    public override void afterUpdate(){ 
        /*List<String> listPDId = new List<String>();
        for(Master_Data__c data : (List<Master_Data__c>) Trigger.new) {
            Master_Data__c olddata = (Master_Data__c) Trigger.oldMap.get(data.id); 
            String rtpd = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Policy Distribution').getRecordTypeId(); 
            if(data.RecordTypeId == rtpd && data.USER_PIC__c != olddata.USER_PIC__c){
                listPDId.add(data.Id);
            }
        }
        //List<InsurancePolicy> listIP = [SELECT Id FROM InsurancePolicy WHERE Policy_Distribution__c IN:listPDId WITH SECURITY_ENFORCED];
        //if(listIP.size()>0){ List<Database.SaveResult> sr = Database.update(listIP);}
        List<Opportunity> listOpp = [SELECT Id FROM Opportunity WHERE Policy_Distribution__c IN:listPDId WITH SECURITY_ENFORCED];
        if(listOpp.size()>0){ List<Database.SaveResult> sr = Database.update(listOpp);}*/
    }
}