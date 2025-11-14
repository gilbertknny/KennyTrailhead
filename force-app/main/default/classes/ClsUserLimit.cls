/**
 * Controller for Flow Update Quotation Get User Limit
 * TC : GS
 * DATE : 10/10/25
 */

public without sharing class ClsUserLimit {
	@InvocableMethod(label='User Limit' description='Returns user limit' )
    public static List<string> getUserIds(List<ID> ids) {
        List<string> result = new List<String>();
        String recordId = ids[0];
        Decimal amount = 0;
        Decimal limitAmount;
        Quote data = [SELECT Id,Opportunity.Total_Sum_Insured__c FROM Quote WHERE Id=:recordId WITH SECURITY_ENFORCED];
        if(data.Opportunity.Total_Sum_Insured__c != NULL){amount = data.Opportunity.Total_Sum_Insured__c;}
        UserLimit ul = getUserId(amount);
        if(ul != null){
            if(ul.id != null && ul.userid != null){
                Master_Data__c md = new Master_Data__c();
                md.Id = ul.id;
            	md.Counter_Date__c = DateTime.Now();
            	Database.SaveResult sr = Database.update(md);
                result.add(ul.userid);
            }
        }
        return result;   
    } 
    
    public static UserLimit getUserId(Decimal amount){
        UserLimit result = new UserLimit();
        Decimal limitAmount;
        List<Master_Data__c> listMDmin =[SELECT Id,LIMIT_AMOUNT__c FROM Master_Data__c 
                                      WHERE RecordType.DeveloperName = 'Approval_Limit'
                                     AND AUTHORITY_TYPE__c = 'UW'
                                     AND LIMIT_AMOUNT__c >=: amount
                                     AND Status__c = 'Approved' WITH SECURITY_ENFORCED
                                     ORDER BY LIMIT_AMOUNT__c ASC LIMIT 1 ];
        if(listMDmin.size()>0){limitAmount = listMDmin[0].LIMIT_AMOUNT__c;}
        if(limitAmount != null){
            List<Master_Data__c> listMD = [SELECT Id,USER_ID__c,Counter_Date__c FROM Master_Data__c 
                                           WHERE RecordType.DeveloperName = 'Approval_Limit'
                                           AND AUTHORITY_TYPE__c = 'UW'
                                           AND LIMIT_AMOUNT__c =: limitAmount
                                           AND Status__c = 'Approved' WITH SECURITY_ENFORCED
                                          ORDER BY Counter_Date__c ASC
                                          LIMIT 1];
            Master_Data__c md = listMD[0];
            result.id = md.Id;
            result.userid = md.USER_ID__c;
        } 
        return result;
    } 
    
    public class UserLimit{
        public string id;
        public string userid;
    }
}