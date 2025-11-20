public with sharing class TriggerHandler_Case{
    public static void beforeUpdate(List<Case> newList, Map<Id,Case> oldMap){
        /*SObjectType objectName = Schema.getGlobalDescribe().get('Case');
        Map<String,Schema.SObjectField> fields = objectName.getDescribe().fields.getMap();
        Schema.sObjectField[] fieldList = fields.values();
        Boolean notRemarkIsChanged = false;
        Id curUserId = UserInfo.getUserId();
        Id curUserProfileId = UserInfo.getProfileId();
        String profileName = '';
        if(curUserProfileId != null){
            Profile pro = [SELECT Id, Name FROM Profile WHERE id = :curUserProfileId];
            profileName = pro.Name;
        }*/
        for(Case cs : newList){
            /*Schema.sObjectField[] changedField = getChangedFields(cs.Id, fieldList);
            if(cs.OwnerId != curUserId && profileName != 'System Administrator'){
                for(Schema.sObjectField field : changedField){
                    /*if(String.valueOf(field) == 'FlagSubmitReturn__c'){
                        notRemarkIsChanged = false;
                        break;
                    }else*/ /*if(String.valueOf(field) != 'SCC_Remark__c' && String.valueOf(field) != 'SCC_Drone_Remark_Update__c'){
                        notRemarkIsChanged = true;
                    }
                }
                if(notRemarkIsChanged){
                    cs.addError('Anda bukan pemilik Case, hanya bisa mengubah remark.');
                }
            }*/
        }
    }
    public static Schema.sObjectField[] getChangedFields(ID recordId, Schema.sObjectField[] fieldList) {
        Schema.sObjectField[] changedFields = new list<Schema.sObjectField> ();
        SObject o1 = Trigger.oldMap.get(recordId);
        SObject o2 = Trigger.newMap.get(recordId);
    
        for (Schema.sObjectField field : fieldList) {
            Object v1 = o1.get(field);
            Object v2 = o2.get(field);
            if (didFieldChange(v1, v2)) {
                changedFields.add(field);
            }
        }
        return changedFields;
    }
    
    private static Boolean didFieldChange(Object v1, Object v2) {
        if (v1 == null && v2 == null) {
            return false;
        }
        if (v1 != v2) {
            return true;
        }
        return false;
    }
}