public with sharing class SCC_InvocableInquiryBriva {
    
    @InvocableMethod(label='Invocable Briva' description='Inquiry Briva' category='Invocable')
    public static List<ResponseInquiryBriva> inquiryBriva(List<RequestInquiryBriva> req){


        RequestInquiryBriva inputReq = new RequestInquiryBriva();
        List<ResponseInquiryBriva> outputRes = new List<ResponseInquiryBriva>();

        try {

            for(RequestInquiryBriva r : req){
                inputReq.brivaNumber = r.brivaNumber;
                inputReq.recordId = r.recordId;
            }

            SCC_InquiryBriva.inquiryBriva(inputReq.brivaNumber, inputReq.recordId);
            // ResponseInquiryBriva resOutput = new ResponseInquiryBriva();

            // resOutput.corpAccounNumber = resBriva.corpAccountNo;
            // resOutput.errorCode = resBriva.errorCode;
            // resOutput.responseMessage = resBriva.responseMessage;
            // resOutput.responseCode = resBriva.responseCode;

            // outputRes.add(resOutput);
         

        } catch (Exception e) {
            System.debug('Error occured'+e.getMessage());
        }

        return outputRes;
    }
    
    public class RequestInquiryBriva{

        @InvocableVariable(required=true)
        public String brivaNumber;

        @InvocableVariable(required=true)
        public String recordId;
    }

    public class ResponseInquiryBriva{
        
        @InvocableVariable
        public String errorCode;
        
        @InvocableVariable
        public String corpAccounNumber;

        @InvocableVariable
        public String responseCode;

        @InvocableVariable
        public String responseMessage;
    }
}