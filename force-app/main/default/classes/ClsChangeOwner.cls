/**
 * Controller for LWC "lwcChangeOwner"
 * TC : GS
 * DATE : 10/10/25
 */

public without sharing class ClsChangeOwner {
    @AuraEnabled(cacheable=false)
    public static Boolean getPermission(){
        Boolean result = false;
        String userId = UserInfo.getUserId();
        User us = [SELECT Id,Profile.Name FROM User WHERE Id=:userId];
        if(us.Profile.Name == 'System Administrator'){ result = true; }
        else{
            //SPV & MANAGER
        	List<PermissionSetAssignment> listPSA = [SELECT Id,AssigneeId
                                                 FROM PermissionSetAssignment 
												WHERE (PermissionSet.Name LIKE '%SPV%' 
                                                 OR PermissionSet.Name LIKE '%Manager%')
                                                 AND AssigneeId =:userId
                                                 AND IsActive = TRUE];
            if(listPSA.size()>0){ result = true; }
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static User getUser(string recordId){
        User u = new User();
        if(recordId != null && recordId != ''){
            u = [SELECT Id,Name,Branch__c 
                 FROM User 
                 WHERE Id =:recordId WITH SECURITY_ENFORCED];
        }
        return u;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Account> getAccounts(string ownerId){
        List<Account> listdata = new List<Account>();
        if(ownerId != null && ownerId != ''){
            listdata = [SELECT Id,Name,OwnerId,ParentId,ParentName__c,Type,Branch__c
                        FROM Account 
                        WHERE OwnerId =:ownerId WITH SECURITY_ENFORCED];
        }
        return listdata;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Opportunity> getOpportunity(string ownerId){
        List<Opportunity> listdata = new List<Opportunity>();
        if(ownerId != null && ownerId != ''){
            List<String> listOppId = new List<String>();
            List<Quote> listQuote = [SELECT Id,OpportunityId 
                                     FROM Quote 
                                     WHERE OwnerId =:ownerId
                                    AND Status IN('Approved','Rejected') WITH SECURITY_ENFORCED];
            for(Quote qu : listQuote){
                listOppId.add(qu.OpportunityId);
            }
            
            listdata = [SELECT Id,Name,OwnerId,AccountId,AccountName__c,StageName,Opportunity_Type__c,CloseDate
                        FROM Opportunity 
                        WHERE OwnerId =:ownerId
                       	AND isClosed = FALSE
                       	AND AccountId != NULL
                       	AND Id NOT IN:listOppId WITH SECURITY_ENFORCED];
        }
        return listdata;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<InsurancePolicy> getInsurancePolicy(string ownerId){
        List<InsurancePolicy> listdata = new List<InsurancePolicy>();
        if(ownerId != null && ownerId != ''){
            listdata = [SELECT Id,Name,OwnerId,GrossWrittenPremium, PolicyType, NameInsuredId,NameInsured__c 
                        FROM InsurancePolicy 
                        WHERE OwnerId =:ownerId
                       AND Status NOT IN('Issused','Cancelled') WITH SECURITY_ENFORCED];
        }
        return listdata;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Lead> getLead(string ownerId){
        List<Lead> listdata = new List<Lead>();
        if(ownerId != null && ownerId != ''){
            listdata = [SELECT Id,Name,OwnerId,Company,Status 
                        FROM Lead 
                        WHERE OwnerId =:ownerId
                       AND isConverted = FALSE WITH SECURITY_ENFORCED];
        }
        return listdata;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Claim> getClaim(string ownerId){
        List<Claim> listdata = new List<Claim>();
        if(ownerId != null && ownerId != ''){
            listdata = [SELECT Id,Name,OwnerId,AccountId,AccountName__c,ClaimReason,Status,ApprovedAmount 
                        FROM Claim 
                        WHERE OwnerId =:ownerId
                       AND isClosed = FALSE WITH SECURITY_ENFORCED];
        }
        return listdata;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Case> getCase(string ownerId){
        List<Case> listdata = new List<Case>();
        if(ownerId != null && ownerId != ''){
            listdata = [SELECT Id,CaseNumber,OwnerId,Subject, Status, CreatedDate 
                        FROM Case 
                        WHERE OwnerId =:ownerId
                       AND isClosed = FALSE WITH SECURITY_ENFORCED];
        }
        return listdata;
    }
    
    @AuraEnabled
    public static string saveData(String data) {
    	String result = '';
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug(LoggingLevel.WARN,'data:'+data);
            Map<String,String> mapId = new Map<String,String>();
            Map<String,String> mapWhoId = new Map<String,String>();
            List<Account> listDataAccount = new List<Account>();
            List<Opportunity> listDataOpportunity = new List<Opportunity>();
            List<InsurancePolicy> listDataInsurancePolicy = new List<InsurancePolicy>();
            List<Lead> listDataLead = new List<Lead>();
            List<Claim> listDataClaim = new List<Claim>();
            List<Case> listDataCase = new List<Case>();
            List<Task> listDataTask = new List<Task>();
            
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
            system.debug(LoggingLevel.WARN,'Account');
            List<Object> listAccount = (List<Object>) dataMap.get('account');
            for(Object obj : listAccount){
                Map<String,Object> mapObj = (Map<String, Object>)obj;
                String strId = (String)mapObj.get('Id');
                String strOwnerId = (String)mapObj.get('OwnerId');
                mapId.put(strId,strOwnerId);
                Account acc = new Account();
                acc.Id = strId;
                acc.OwnerId = strOwnerId;
                acc.IsSchedule__c = true; //Schedule SFAWT-17
                listDataAccount.add(acc);
                
            }
            system.debug(LoggingLevel.WARN,'Opportunity');
            List<Object> listOpportunity = (List<Object>) dataMap.get('opportunity');
            for(Object obj : listOpportunity){
                Map<String,Object> mapObj = (Map<String, Object>)obj;
                String strId = (String)mapObj.get('Id');
                String strOwnerId = (String)mapObj.get('OwnerId');
                mapId.put(strId,strOwnerId);
                Opportunity opp = new Opportunity();
                opp.Id = strId;
                opp.OwnerId = strOwnerId;
                listDataOpportunity.add(opp);
            }
            system.debug(LoggingLevel.WARN,'Insurance Policy');
            List<Object> listInsurancepolicy = (List<Object>) dataMap.get('insurancepolicy');
            for(Object obj : listInsurancepolicy){
                Map<String,Object> mapObj = (Map<String, Object>)obj;
                String strId = (String)mapObj.get('Id');
                String strOwnerId = (String)mapObj.get('OwnerId');
                mapId.put(strId,strOwnerId);
                InsurancePolicy ip = new InsurancePolicy();
                ip.Id = strId;
                ip.OwnerId = strOwnerId;
                listDataInsurancePolicy.add(ip);
            }
            system.debug(LoggingLevel.WARN,'Lead');
            List<Object> listLead = (List<Object>) dataMap.get('lead');
            for(Object obj : listLead){
                Map<String,Object> mapObj = (Map<String, Object>)obj;
                String strId = (String)mapObj.get('Id');
                String strOwnerId = (String)mapObj.get('OwnerId');
                mapWhoId.put(strId,strOwnerId);
                Lead ld = new Lead();
                ld.Id = strId;
                ld.OwnerId = strOwnerId;
                listDataLead.add(ld);
            }
            system.debug(LoggingLevel.WARN,'Claim');
            List<Object> listClaim = (List<Object>) dataMap.get('claim');
            for(Object obj : listClaim){
                Map<String,Object> mapObj = (Map<String, Object>)obj;
                String strId = (String)mapObj.get('Id');
                String strOwnerId = (String)mapObj.get('OwnerId');
                mapId.put(strId,strOwnerId);
                Claim cl = new Claim();
                cl.Id = strId;
                cl.OwnerId = strOwnerId;
                listDataClaim.add(cl);
            }
            system.debug(LoggingLevel.WARN,'Case');
            List<Object> listCase = (List<Object>) dataMap.get('case');
            for(Object obj : listCase){
                Map<String,Object> mapObj = (Map<String, Object>)obj;
                String strId = (String)mapObj.get('Id');
                String strOwnerId = (String)mapObj.get('OwnerId');
                mapId.put(strId,strOwnerId);
                Case cs = new Case();
                cs.Id = strId;
                cs.OwnerId = strOwnerId;
                listDataCase.add(cs);
            }
            
            List<Task> listtask = [SELECT Id,WhatId FROM Task 
                                   WHERE Status NOT IN('Completed','Cancelled')
                                  AND WhatId IN:mapId.keySet() AND WhatId != NULL WITH SECURITY_ENFORCED];
            for(Task ts : listtask){
                String strOwnerId = mapId.get(ts.WhatId);
                if(strOwnerId != null){
                	Task newts = new Task();
                	newts.Id = ts.Id;
                    newts.OwnerId = strOwnerId;
                    listDataTask.add(newts);
                }
            }
            listtask = [SELECT Id,WhoId FROM Task 
                                   WHERE Status NOT IN('Completed','Cancelled')
                                  AND WhoId IN:mapWhoId.keySet() AND WhoId != NULL WITH SECURITY_ENFORCED];
            for(Task ts : listtask){
                String strOwnerId = mapWhoId.get(ts.WhoId);
                if(strOwnerId != null){
                	Task newts = new Task();
                	newts.Id = ts.Id;
                    newts.OwnerId = strOwnerId;
                    listDataTask.add(newts);
                }
            }
            
            system.debug(LoggingLevel.WARN,'listDataAccount:'+listDataAccount);
            system.debug(LoggingLevel.WARN,'listDataOpportunity:'+listDataOpportunity);
            system.debug(LoggingLevel.WARN,'listDataInsurancePolicy:'+listDataInsurancePolicy);
            system.debug(LoggingLevel.WARN,'listDataLead:'+listDataLead);
            system.debug(LoggingLevel.WARN,'listDataClaim:'+listDataClaim);
            system.debug(LoggingLevel.WARN,'listDataCase:'+listDataCase);
            system.debug(LoggingLevel.WARN,'listDataTask:'+listDataTask);
            
            List<String> listid = new List<String>();
            if(listDataAccount.size()>0){ List<Database.SaveResult> sr = Database.update(listDataAccount);}
            if(listDataOpportunity.size()>0){ 
                List<Database.SaveResult> listsr = Database.update(listDataOpportunity);
                for(Database.SaveResult sr : listsr){
                    listid.add(sr.Id);
                }
            }
            if(listDataInsurancePolicy.size()>0){ List<Database.SaveResult> sr = Database.update(listDataInsurancePolicy);}
            if(listDataLead.size()>0){ List<Database.SaveResult> sr = Database.update(listDataLead); }
            if(listDataClaim.size()>0){ List<Database.SaveResult> sr = Database.update(listDataClaim); }
            if(listDataCase.size()>0){ List<Database.SaveResult> sr = Database.update(listDataCase); }
            if(listDataTask.size()>0){ List<Database.SaveResult> sr = Database.update(listDataTask); }
            //CALL SFAWT-15
            callSFAWT15(listid);            
            result = 'Sukses';
        }catch(Exception e){
            Database.rollback(sp); 
            result = e.getMessage();
        }
        return result;
    }
    
    public static void callSFAWT15(List<String> listid){
        List<Opportunity> listopp = [SELECT Id,Busreq_ID__c,Marketer_ID__c FROM Opportunity WHERE Id IN:listid AND Id != null];
        if(listopp.size()>0){
            String strJSON = '{';
            strJSON += '"data": {';
            strJSON += '"BUSINESS_REQUEST": [';
            Integer i = 0;
            for(Opportunity opp : listopp){
                if(i > 0){ strJSON += ','; }
                strJSON += '{"BUSREQ_ID": "'+opp.Busreq_ID__c+'","MARKETER_ID": "'+opp.Marketer_ID__c+'"}'; 
                i++;
            }
            strJSON += ']}';
            strJSON += '}';
            List<VlocityMappingFlowBridge.Request> requests = new List<VlocityMappingFlowBridge.Request>();
            VlocityMappingFlowBridge.Request req = new VlocityMappingFlowBridge.Request();
            req.ipName = 'SFAWT-15';
            req.jsonInput = strJSON;
            requests.add(req);
            List<VlocityMappingFlowBridge.Response> listres = VlocityMappingFlowBridge.invoke(requests);
            system.debug(LoggingLevel.WARN,'listres:'+listres);
        }
    }
}