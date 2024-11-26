global with sharing class SCC_Wise4th implements Queueable, Database.AllowsCallouts {
    global SCC_Wise4th() {

    }

    global void execute(QueueableContext context){
        processWise();
    }

    public void executeNow() {
        processWise();
    }

    private void processWise(){
    
        try {

            SCC_Wise_General.wrapperWiseGeneral dataProgram = SCC_Wise_General.getWiseListId('Program');
            Integer totalProgram = dataProgram.total;
            Map<Integer,String> categorizeProgram = dataProgram.categorize;

            if(totalProgram > 0 && !categorizeProgram.isEmpty()){
                ID jobId = System.enqueueJob(new SCC_WiseLookupQueueable4(1,categorizeProgram,totalProgram));
            } else {
                System.debug('data kosong');
            }

        } catch(Exception e){
            insertErrorLog(e, 'SCC_Wise4th');
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