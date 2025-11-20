public with sharing class SCC_Reopent_Ticket_ITSM {

    @InvocableMethod(label='Invocable Reopen ITSM' description='Reopen ITSM Ticket' category='Invocable')
    public static List<ResponseReopenITSM> reopenTicketITSM(List<RequestReopenITSM> req){

        RequestReopenITSM inputReq = new RequestReopenITSM();
        List<ResponseReopenITSM> outputRes = new List<ResponseReopenITSM>();

        try{
            for(RequestReopenITSM r : req){
                inputReq.BRI_SApp_Reopen_Justification = r.BRI_SApp_Reopen_Justification;
                inputReq.IncidentId = r.IncidentId;
                
            }

            SCC_ITSMWrapper.RequestReopenTicket reqBody = mapRequestITSM(inputReq);
            String idIncident = inputReq.IncidentId;
            SCC_ITSM.WrapperReopenTicket resTicket = SCC_ITSM.reopenTicket(reqBody, idIncident);

            if(resTicket.res.RecId != ''){
                SCC_ITSMWrapper.ResponseReopenTicket data = resTicket.res;
                ResponseReopenITSM resOutput = new ResponseReopenITSM();
                resOutput.BRI_CategorySystem = data.BRI_CategorySystem;
                resOutput.BRI_CIDITEMUKAN = data.BRI_CIDITEMUKAN;
                resOutput.BRI_DetectedTime = data.BRI_DetectedTime;
                resOutput.BRI_FormatTiketIncident = data.BRI_FormatTiketIncident;
                resOutput.BRI_isReopenFromIntegration = data.BRI_isReopenFromIntegration;
                resOutput.BRI_LayananTerdampak = data.BRI_LayananTerdampak;
                resOutput.BRI_SApp_Detail = data.BRI_SApp_Detail;
                resOutput.BRI_SApp_Reopen_Justification = data.BRI_SApp_Reopen_Justification;
                resOutput.BRI_SApp_TicketNumber = data.BRI_SApp_TicketNumber;
                resOutput.BRI_SourceKey = data.BRI_SourceKey;
                resOutput.Impact = data.Impact;
                resOutput.RecId = data.RecId;
                resOutput.Source = data.Source;
                resOutput.Status = data.Status;
                resOutput.Subject = data.Subject;
                resOutput.Symptom = data.Symptom;
                resOutput.TipeIncident = data.BRI_TipeIncident;
                resOutput.Urgency = data.Urgency;
                resOutput.LastModDateTime = convertDateTime(data.LastModDateTime);
                
                outputRes.add(resOutput);
            }

        } catch (Exception e){
            System.debug('Error occured'+e.getMessage());
        }

        return outputRes;
    }

    private static SCC_ITSMWrapper.RequestReopenTicket mapRequestITSM(RequestReopenITSM req){
        SCC_ITSMWrapper.RequestReopenTicket reqReopen = new SCC_ITSMWrapper.RequestReopenTicket();
        reqReopen.BRI_isReopenFromIntegration = 'True';
        reqReopen.BRI_SApp_Reopen_Justification = req.BRI_SApp_Reopen_Justification;

        return reqReopen;
    }

    private static Datetime convertDateTime(String dt){
        List<String> frmtDate = dt.split('T');
        Datetime updatedDt = Datetime.valueOf(frmtDate[0]+' '+frmtDate[1]);
        return updatedDt;
    }

    public class RequestReopenITSM{

        @InvocableVariable(required=true)
        public String BRI_SApp_Reopen_Justification;

        @InvocableVariable(required=true)
        public String IncidentId;

    }

    public class ResponseReopenITSM{
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

        //field reopen
        @InvocableVariable
        public String Source;

        @InvocableVariable
        public String Status;

        @InvocableVariable
        public String Subject;

        @InvocableVariable
        public String TipeIncident;

        @InvocableVariable 
        public Boolean BRI_isReopenFromIntegration;

        @InvocableVariable
        public String BRI_SApp_Reopen_Justification;

        @InvocableVariable
        public Datetime LastModDateTime;
    }
}