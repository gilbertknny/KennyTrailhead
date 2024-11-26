public with sharing class SCC_Batch_AutoClosed implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public String Query;
    public SCC_Batch_AutoClosed(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext bc, List<Case> scope){
        try{
            List<Case> listcs = new List<Case>();
            for(Case s : scope){
                SCC_RekonWrapper.RequestRekon req = new SCC_RekonWrapper.RequestRekon();
                req.AccountNumber = s.SCC_Account_Number__c;
                req.Amount = String.valueOf(s.SCC_Amount__c);
                req.Page = 1;
                req.TerminalID =s.terminal_id__r.name;
                req.TransactionDate = String.valueOf(s.SCC_Transaction_Date__c);
                if(String.isNotBlank(s.SCC_Call_Type__c)){
                    String ctnum = s.SCC_Call_Type__r.Name.substringbefore('-').trim();
                    if(String.isNotBlank(s?.SCC_Call_Type__r?.External_Id__c)){
                        ctnum = s.SCC_Call_Type__r.External_Id__c;
                    }
                    SCC_RekonWrapper.ResponseRekon res = SCC_Rekon.SearchRekon(req, ctnum);
                    if(res?.RESPONSE_DATA?.result!=null){
                        for(SCC_RekonWrapper.ResponseRekonResult rrr: res?.RESPONSE_DATA?.result){
                            if(rrr?.StatusPenyelesaian=='Transaction Successful'){
                                s.Status = 'Closed';
                                s.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                                s.SCC_Closure_Comments__c = label.Closed_Rekon;
                                listcs.add(s);
                            }
                        }
                    }    
                }
            }
            //update scope;
            if(!listcs.isempty()){
                update listcs;
            }
        }
        catch(Exception exc){
            InsertErrorLog(exc);
        }
    }
  
    public void finish(Database.BatchableContext bc){
     
    }

    public static void InsertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}