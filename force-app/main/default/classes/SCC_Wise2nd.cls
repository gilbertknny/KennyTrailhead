global with sharing class SCC_Wise2nd implements Queueable, Database.AllowsCallouts {
    global SCC_Wise2nd() {

    }

    global void execute(QueueableContext context){
        processWise();
    }

    private void processWise(){
    
        try {

            SCC_Wise_General.wrapperWiseGeneral dataProduk = SCC_Wise_General.getWiseListId('Produk');
            Integer totalProduk = dataProduk.total;
            Map<Integer,String> categorizeProduk = dataProduk.categorize;

            if(totalProduk > 0 && !categorizeProduk.isEmpty()){
                ID jobId = System.enqueueJob(new SCC_WiseLookupQueueable2(1,categorizeProduk,totalProduk));
            } else {
                ID jobId2 = System.enqueueJob(new SCC_Wise3rd());
            }

        } catch(Exception e){
            insertErrorLog(e, 'SCC_Wise2nd');
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