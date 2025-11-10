/**
 * @description ContentVersion_TriggerHandler
 */
public with sharing class ContentVersion_TriggerHandler extends TriggerHandler{
	protected override void beforeInsert() {
        Savepoint sp = Database.setSavepoint();
        try{
        	ContentVersion_Manager.crud((List<ContentVersion>) trigger.new );
        }
        catch(exception exc){            
           seterror((ContentVersion) trigger.new.get(0), exc, sp);
        }
    }

    protected override void afterInsert() {
        Savepoint sp = Database.setSavepoint();
        try{
        	ContentVersion_Manager.crud((List<ContentVersion>) trigger.new );
        }
        catch(exception exc){            
            seterror((ContentVersion) trigger.new.get(0), exc, sp);
        }
    }
    /**
     * @description seterror
     * @param conver
     * @param exc
     * @param sp
     */
    public static void seterror(ContentVersion conver,Exception exc,Savepoint sp){
        ErrorLogRecord.DebugLog dl = ErrorLogRecord.setError(conver, 'ContentVersion_TriggerHandler', exc);
        ErrorLogRecord.errorException(dl, sp, exc);
    }

}