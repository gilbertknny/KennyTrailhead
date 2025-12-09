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
        Quote data = [SELECT Id,OpportunityId FROM Quote WHERE Id=:recordId WITH SECURITY_ENFORCED];
        UserLimit ul = getUserIdFilter(data.OpportunityId);
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
    
    public static UserLimit getUserIdFilter(String recordId){
        Opportunity opp = [SELECT Id,COB__c FROM Opportunity WHERE Id=:recordId WITH SECURITY_ENFORCED];
        String strField = '';
        List<Master_Data__c> listmd = [SELECT Id,showData__c 
                                       FROM Master_Data__c 
                                       WHERE BSN_ID__c =:opp.COB__c 
                                       AND RecordType.Name = 'User Limit' 
                                       AND Status__c = 'Active' WITH SECURITY_ENFORCED];
        if(listmd.size()>0){
            Master_Data__c md = listmd[0];
            strField = md.showData__c;
        }
        
        UserLimit result = new UserLimit();
        if(strField != '' && strField != null){
            List<Object> untypedList = (List<Object>) JSON.deserializeUntyped(strField);
            String queryfieldOpp = '';
            for (Object item : untypedList) {
                Map<String, Object> itemMap = (Map<String, Object>) item;
                String param1 = (String)itemMap.get('param1');
                String param2 = (String)itemMap.get('param2');
                if(param2 != '' && param2 != 'Total_Sum_Insured__c'){queryfieldOpp += ',' + param2;}
            }
            
            Decimal amount;
            String strQueryOpp = 'SELECT Id,Total_Sum_Insured__c';
            if(queryfieldOpp != ''){ strQueryOpp+= queryfieldOpp; }
            strQueryOpp += ' FROM Opportunity';
            strQueryOpp += ' WHERE Id =:recordId';
            Opportunity oppview = Database.query(strQueryOpp);    
            String queryfield = ''; //MASTER DATA
            for (Object item : untypedList) {
                if(oppview.Total_Sum_Insured__c != null){ amount = oppview.Total_Sum_Insured__c; }
                Map<String, Object> itemMap = (Map<String, Object>) item;
                String param1 = (String)itemMap.get('param1');
                String param2 = (String)itemMap.get('param2');
                Object obj = oppview.get(param2);
                String strObj = (String)obj;
                if(param1 != '' && param2 != ''){
                    if(strObj == null){
                        queryfield += ' AND '+param1 + '='+strObj;
                    }else{
                        queryfield += ' AND '+param1 + '= \''+strObj+'\'';
                    }
                }
            }
            system.debug('amount:'+amount);
            system.debug('queryfield:'+queryfield);
            
            result = getUserId(amount,queryfield);
        }
        
        return result;
    } 
    
    public static UserLimit getUserId(Decimal amount,String queryfield){
        UserLimit result = new UserLimit();
        if(amount != null){
            Decimal limitAmount;
            String strQueryMDMin = 'SELECT Id,LIMIT_AMOUNT__c FROM Master_Data__c';
            strQueryMDMin += ' WHERE RecordType.DeveloperName = \''+ 'Approval_Limit'+'\'';
            strQueryMDMin += ' AND AUTHORITY_TYPE__c = \''+'UW'+'\'';
            strQueryMDMin += ' AND LIMIT_AMOUNT__c >=: amount';
            strQueryMDMin += ' AND Status__c = \''+'Approved'+'\'';
            if(queryfield != '' && queryfield != null) {strQueryMDMin += queryfield;}
            strQueryMDMin += ' ORDER BY Counter_Date__c ASC';
            strQueryMDMin += ' LIMIT 1';
            system.debug('strQueryMDMin:'+strQueryMDMin);
            List<Master_Data__c> listMDmin = Database.query(strQueryMDMin);
            system.debug('listMDmin:'+listMDmin);
            
            if(listMDmin.size()>0){limitAmount = listMDmin[0].LIMIT_AMOUNT__c;}
            if(limitAmount != null){
                String strQueryMD = 'SELECT Id,USER_ID__c FROM Master_Data__c';
                strQueryMD += ' WHERE RecordType.DeveloperName = \''+ 'Approval_Limit'+'\'';
                strQueryMD += ' AND AUTHORITY_TYPE__c = \''+'UW'+'\'';
                strQueryMD += ' AND LIMIT_AMOUNT__c =: limitAmount';
                strQueryMD += ' AND Status__c = \''+'Approved'+'\'';
                if(queryfield != '' && queryfield != null) {strQueryMD += queryfield;}
                strQueryMD += ' ORDER BY Counter_Date__c ASC';
                strQueryMD += ' LIMIT 1';
                List<Master_Data__c> listMD = Database.query(strQueryMD);
                Master_Data__c md = listMD[0];
                result.id = md.Id;
                result.userid = md.USER_ID__c;
            } 
        }
        return result;
    }
    
    public class UserLimit{
        public string id;
        public string userid;
    }
}