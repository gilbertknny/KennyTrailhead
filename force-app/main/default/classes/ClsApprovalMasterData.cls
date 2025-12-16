/**
 * Controller for LWC "lwcApprovalMasterData"
 * TC : GS
 * DATE : 10/10/25
 */

public without sharing class ClsApprovalMasterData {
    @AuraEnabled(cacheable=false)
    public static Boolean getPermission(){
        Boolean result = false;
        String userId = UserInfo.getUserId();
        User us = [SELECT Id,Profile.Name FROM User WHERE Id=:userId];
        if(us.Profile.Name == 'System Administrator'){ result = true; }
        else{
            //Capacity_Management_DeptHead_Group, Claim_Depthead_Group, UW_DeptHead_Group
        	List<PermissionSetAssignment> listPSA = [SELECT Id,AssigneeId
                                                 FROM PermissionSetAssignment 
												WHERE PermissionSet.Name IN ('Capacity_Management_DeptHead_Group','Claim_Depthead_Group','UW_DeptHead_Group')
                                                 AND AssigneeId =:userId
                                                 AND IsActive = TRUE];
            if(listPSA.size()>0){ result = true; }
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Master_Data__c> getMasterData(string strType,string strAuth) {
        List<Master_Data__c> listmd = new List<Master_Data__c>();
        String query = 'SELECT Id,Name,CreatedBy.Name ';
        String status = 'Draft';
        String filter = '';
        if(strAuth != null && strAuth != ''){
            query += ',BSN__c,AUTHORITY_TYPE__c,CURRENCY_CODE__c';
            query += ',LIMIT_AMOUNT__c,BRANCH_ID__c,RISK_CODE__c,AGE__c,TONNAGE__c';
            query += ',RISK_TYPE__c,Business_Type__c,Product_Segment__c,CREATED_DATE__c';
            filter += ' AND Authority_Type__c =:strAuth';
        }else if(strType == 'Treaty_Capacity'){
            query += ',BSN__c,TREATY_YEAR__c,RISK_CATEGORY__c,RISK_CLASS__c';
            query += ',EQ_ZONE__c,UR_AMOUNT__c,XL_AMOUNT__c,QS_PCT__c,QS_AMOUNT__c,SP1_LINES__c';
            query += ',SP1_AMOUNT__c,FACOBLIG_AMOUNT__c,CURRENCY_CODE__c,EFFECTIVE_DATE__c';
        }else if(strType == 'Policy_Distribution'){
            query += ',Product_Segment__c,Product_Line__c,Product_Type__c,Area__c,Branch_Name__c,USER_PIC__c';
        }
        query += ' FROM Master_Data__c WHERE Status__c=:status AND RecordType.DeveloperName=:strType';
        query += filter;
        listmd = Database.query(query);
        return listmd;
    }
    
    @AuraEnabled
    public static void approveData(string strType,string strAuth) {
        try {
            List<Master_Data__c> listmdnew = new List<Master_Data__c>();
            List<Master_Data__c> listmd = getMasterData(strType,strAuth);
            for(Master_Data__c md : listmd){
                md.Status__c = 'Approved';
                listmdnew.add(md);
            }
            if(listmdnew.size()>0){ List<Database.SaveResult> sr = Database.update(listmdnew);}
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN,'--->'+e);
        }
    }
    
    @AuraEnabled
    public static void rejectData(string strType,string strAuth) {
        try {
            List<Master_Data__c> listmd = getMasterData(strType,strAuth);
            if(listmd.size()>0){ List<Database.DeleteResult> dr = Database.delete(listmd);}
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN,'--->'+e);
        }
    }      
}