public with sharing class SCC_DroneEDC {

    @AuraEnabled
    public static Case getCaseDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = ',SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name,Maker__r.Name,Signer__r.Name';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Case cs = Database.query(queries);
        return cs;
    }

    @AuraEnabled
    public static Case updateCase(Id caseId , String rmk){
        Case cs = getCaseDetail(caseId);
        if(String.isNotBlank(rmk)){
            String setrmk = '['+String.valueOf(system.now())+' '+UserInfo.getName()+'] '+rmk;
            cs.SCC_Drone_Remark_Update__c = cs.SCC_Drone_Remark_Update__c + '\n'+setrmk;
        }
        update cs;
        return cs;
    }
}