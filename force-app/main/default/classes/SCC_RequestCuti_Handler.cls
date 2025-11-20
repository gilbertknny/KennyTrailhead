public without sharing class SCC_RequestCuti_Handler extends TriggerHandler{
    Protected override void beforeInsert(){
        Savepoint sp = Database.setSavepoint();
        try{
            SCC_RequestCuti_Manager.crud((List <Request_Leave__c>) trigger.new);
        }
        catch(exception exc){            
            ErrorLogRecord((Request_Leave__c) trigger.new.get(0), sp, exc);        
        }
    }

    Protected override void beforeUpdate(){
        Savepoint sp = Database.setSavepoint();
        try{
            SCC_RequestCuti_Manager.crud((List <Request_Leave__c>) trigger.new);
        }
        catch(exception exc){            
            ErrorLogRecord((Request_Leave__c) trigger.new.get(0), sp, exc);        
        }
    }
    
    Protected override void afterInsert(){
        Savepoint sp = Database.setSavepoint();
        try{
            SCC_RequestCuti_Manager.crud((List <Request_Leave__c>) trigger.new);
        }
        catch(exception exc){            
            ErrorLogRecord((Request_Leave__c) trigger.new.get(0), sp, exc);        
        }
    }
    Protected override void afterUpdate(){
        Savepoint sp = Database.setSavepoint();
        try{
            SCC_RequestCuti_Manager.crud((List <Request_Leave__c>) trigger.new);
        }
        catch(exception exc){            
            ErrorLogRecord((Request_Leave__c) trigger.new.get(0), sp, exc);        
        }
    }

    public static void ErrorLogRecord(Request_Leave__c rl, Savepoint sp, exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.classname = 'SCC_RequestCuti_Handler';
        dl.cs = rl;
        ErrorLogRecord.errorexception(dl, sp, exc);
    }
}