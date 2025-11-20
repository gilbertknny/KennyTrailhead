public with sharing class SCC_Create_Ticket_ITSM {

    @InvocableMethod(label='Invocable ITSM' description='Create ITSM Ticket' category='Invocable')
    public static List<ResponseCreateITSM> createTicketITSM(List<RequestCreateITSM> req){

        RequestCreateITSM inputReq = new RequestCreateITSM();
        List<ResponseCreateITSM> outputRes = new List<ResponseCreateITSM>();
        

        try{
            //get input from itsm
            for(RequestCreateITSM r : req){
                inputReq.BRI_SourceKey = r.BRI_SourceKey;
                inputReq.BRI_SApp_Detail = r.BRI_SApp_Detail;
                inputReq.BRI_SApp_TicketNumber = r.BRI_SApp_TicketNumber;
                inputReq.Subject = r.Subject;
                inputReq.Symptom = r.Symptom;
                inputReq.BRI_SApp_OLA = r.BRI_SApp_OLA;
                inputReq.BRI_LayananTerdampak = r.BRI_LayananTerdampak;
            }

            SCC_ITSMWrapper.RequestCreateTicket reqBody = MapRequestITSM(inputReq);
            SCC_ITSM.WrapperCreateTicket resTicket = SCC_ITSM.createTicket(reqBody);

            if(resTicket.res.RecId != ''){
                SCC_ITSMWrapper.ResponseCreateTicket data = resTicket.res;
                ResponseCreateITSM resOutput = new ResponseCreateITSM();
                resOutput.BRI_CategorySystem = data.BRI_CategorySystem;
                resOutput.BRI_CIDITEMUKAN = data.BRI_CIDITEMUKAN;
                resOutput.BRI_DetectedTime = data.BRI_DetectedTime;
                resOutput.BRI_FormatTiketIncident = data.BRI_FormatTiketIncident;
                resOutput.BRI_LayananTerdampak = data.BRI_LayananTerdampak;
                resOutput.BRI_SApp_Detail = data.BRI_SApp_Detail;
                resOutput.BRI_SApp_TicketNumber =data.BRI_SApp_TicketNumber;
                resOutput.BRI_SourceKey = data.BRI_SourceKey;
                resOutput.Impact = data.Impact;
                resOutput.RecId = data.RecId;
                resOutput.Urgency = data.Urgency;
                resOutput.Symptom = data.Symptom;
                resOutput.Status = data.Status;
                resOutput.IncidentNumber = data.IncidentNumber;

                outputRes.add(resOutput);
            } 

            if(resTicket.err.code != ''){
                //
            }

        } catch (Exception e){
            //
            System.debug('Error occured'+e.getMessage());
        }
        
        return outputRes;
    }


    private static String formatDateTime(DateTime dt) {
        String formattedDateTime = dt.format('M/d/yyyy h:mm:ss a','GMT');
        return formattedDateTime;
    }

    private static SCC_ITSMWrapper.RequestCreateTicket MapRequestITSM(RequestCreateITSM req){
        String createdDate = formatDateTime(Datetime.now());
        SCC_Endpoint_API__mdt metaApi = SCC_Endpoint_API__mdt.getInstance('ITSM_Create_Ticket');
        SCC_ITSMWrapper.RequestCreateTicket reqTicket = new SCC_ITSMWrapper.RequestCreateTicket();
        reqTicket.BRI_DetectedTime = createdDate;
        reqTicket.ProfileLink = metaApi.profileLink__c;
        reqTicket.Subject = req.Subject;
        reqTicket.Symptom = req.Symptom;
        reqTicket.Source = 'Bricare';
        reqTicket.BRI_SourceKey = req.BRI_SourceKey;
        reqTicket.BRI_LayananTerdampak = req.BRI_LayananTerdampak;
        reqTicket.BRI_TipeIncident= 'Not Yet Identified';
        reqTicket.BRI_CategorySystem = 'Not Yet Identified';
        reqTicket.Urgency = 'Low';
        reqTicket.Impact = 'Minor / Localized';
        reqTicket.BRI_CIDITEMUKAN = 'Tidak';
        reqTicket.BRI_SApp_Detail = req.BRI_SApp_Detail;
        reqTicket.BRI_SApp_TicketNumber =req.BRI_SApp_TicketNumber;
        reqTicket.BRI_SApp_OLA = req.BRI_SApp_OLA;

        return reqTicket;
    }

    public class RequestCreateITSM{

        @InvocableVariable(required=true)
        public String Subject;

        @InvocableVariable(required=true)
        public String BRI_SourceKey;

        @InvocableVariable(required=true)
        public String Symptom;

        @InvocableVariable(required=true)
        public String BRI_SApp_Detail;

        @InvocableVariable(required=true)
        public String BRI_SApp_TicketNumber;

        @InvocableVariable(required=true)
        public String BRI_SApp_OLA;

        @InvocableVariable(required=true)
        public String BRI_LayananTerdampak;
    }

    public class ResponseCreateITSM {

        @InvocableVariable
        public String Impact;

        @InvocableVariable
        public String RecId;

        @InvocableVariable
        public String Urgency;

        @InvocableVariable
        public String BRI_FormatTiketIncident;

        @InvocableVariable
        public String BRI_CategorySystem;

        @InvocableVariable
        public String BRI_DetectedTime;

        @InvocableVariable
        public String BRI_CIDITEMUKAN;

        @InvocableVariable
        public String BRI_LayananTerdampak;

        @InvocableVariable
        public String BRI_SourceKey;

        @InvocableVariable
        public String BRI_SApp_Detail;

        @InvocableVariable
        public String BRI_SApp_TicketNumber;

        @InvocableVariable
        public String Symptom;

        @InvocableVariable
        public Integer IncidentNumber;

        @InvocableVariable
        public String Status;

        @InvocableVariable
        public Integer BRI_SApp_OLA;

    }  


}