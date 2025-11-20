global with sharing class SCC_Wise3rd implements Queueable, Database.AllowsCallouts {
    global SCC_Wise3rd() {

    }

    global void execute(QueueableContext context){
        processWise();
    }

    private void processWise(){
    
        try {

            SCC_Wise_General.wrapperWiseGeneral dataPromo = SCC_Wise_General.getWiseListId('Promo');
            Integer totalPromo = dataPromo.total;
            Map<Integer,String> categorizePromo = dataPromo.categorize;

            if(totalPromo > 0 && !categorizePromo.isEmpty()){
                ID jobId = System.enqueueJob(new SCC_WiseLookupQueueable3(1,categorizePromo,totalPromo));
            } else {
                ID jobId2 = System.enqueueJob(new SCC_Wise4th());
            }

        } catch(Exception e){
            insertErrorLog(e, 'SCC_Wise3rd');
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