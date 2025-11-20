public with sharing class DemoKYCKtpOcrInvoker {
    public class Request {
        @InvocableVariable(required=true) public Id contentVersionId;
        @InvocableVariable(required=true) public Id caseId;
    }

    @InvocableMethod(label='Extract KTP Data & Update Case')
    public static void invokeOCR(List<Request> requests) {
        for (Request req : requests) {
            System.enqueueJob(new DemoKYCKtpOcrServiceQueue(req.contentVersionId, req.caseId));
        }
    }
}