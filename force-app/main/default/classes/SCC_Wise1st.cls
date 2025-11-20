global with sharing class SCC_Wise1st implements Queueable, Database.AllowsCallouts {

    global SCC_Wise1st() {}

    global void execute(QueueableContext context){
        processWise();
    }

    public void executeNow() {
        processWise();
    }

    private void processWise(){
    
        try {
            SCC_Wise_General.wrapperWiseGeneral dataWi = SCC_Wise_General.getWiseListId('WI');
            Integer totalWi = dataWi.total;
            Map<Integer,String> categorizeWi = dataWi.categorize;

            if(totalWi > 0 && !categorizeWi.isEmpty()){
                ID jobId = System.enqueueJob(new SCC_WiseLookupQueueable(1,categorizeWi,totalWi));
            } else {
                ID jobId2 = System.enqueueJob(new SCC_Wise2nd());
            }


        } catch(Exception e){
            insertErrorLog(e, 'SCC_Wise1st');
        }
    }

    public static void insertErrorLog(Exception e, String className){
        ErrorLogRecord.DebugLog log = new ErrorLogRecord.DebugLog();
        log.message = e?.getMessage();
        log.trace = e?.getStackTraceString();
        log.typename = e?.getTypeName();
        log.linenumber = String.valueOf(e?.getLineNumber());
        log.errorcause = String.valueOf(e?.getCause());
        log.classname = className;
        ErrorLogRecord.inserterror(JSON.serialize(log));
    }
}