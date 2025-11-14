/** @description UploadFileQueueable */
public with sharing class UploadFileQueueable implements Queueable, Database.AllowsCallouts {
    public Blob bl;
    /** @description UploadFileQueueable @param b */
    public UploadFileQueueable(Blob b) {
        this.bl = b;
    }
    /** @description execute @param context */
    public void execute(QueueableContext context) {
        APILog.WrapperRequest wr = WebserviceAPI.setWrapperRequest('' , bl, 'SalesforceFile');
        APILog.WrapperAPI wapi = APILog.getResponseAPI(wr);
    }
}