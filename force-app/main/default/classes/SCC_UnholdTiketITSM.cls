public with sharing class SCC_UnholdTiketITSM {

    @InvocableMethod(label='Unhold Tiket ITSM' description='Unhold Tiket ITSM' category='Invocable')
    public static List<ResponseReopenITSM> unholdTicketITSM(List<RequestUnhold> req){

        RequestUnhold inputReq = new RequestUnhold();
        List<ResponseReopenITSM> outputRes = new List<ResponseReopenITSM>();

        try{
            for(RequestUnhold r : req){
                inputReq.IncidentId = r.IncidentId;
                inputReq.BRI_SApp_UnHold_Justification = r.BRI_SApp_UnHold_Justification;
                
            }

            SCC_ITSMWrapper.RequestUnhold reqBody = mapRequestITSM(inputReq);
            String idIncident = inputReq.IncidentId;
            SCC_ITSMWrapper.ResponseReopenTicket resUnhold = SCC_ITSM.unholdTicket(reqBody, idIncident);
        

            if(resUnhold.RecId != ''){
                SCC_ITSMWrapper.ResponseReopenTicket data = resUnhold;
                ResponseReopenITSM resOutput = new ResponseReopenITSM();
                resOutput.BRI_CategorySystem = data.BRI_CategorySystem;
                resOutput.BRI_CIDITEMUKAN = data.BRI_CIDITEMUKAN;
                resOutput.BRI_DetectedTime = data.BRI_DetectedTime;
                resOutput.BRI_FormatTiketIncident = data.BRI_FormatTiketIncident;
                resOutput.BRI_isReopenFromIntegration = data.BRI_isReopenFromIntegration;
                resOutput.BRI_isUnHoldFromIntegration = data.BRI_isUnHoldFromIntegration;
                resOutput.BRI_LayananTerdampak = data.BRI_LayananTerdampak;
                resOutput.BRI_SApp_UnHold_Justification = data.BRI_SApp_UnHold_Justification;
                resOutput.BRI_SApp_UnHold_Status = data.BRI_SApp_UnHold_Status;
                resOutput.BRI_SApp_UnHold_RejectJustification = data.BRI_SApp_UnHold_RejectJustification;
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

            // if(resTicket.RecId != ''){
            //     SCC_ITSMWrapper.ResponseReopenITSM data = resTicket;
            //     ResponseReopenITSM resOutput = new ResponseReopenITSM();

            //     resOutput.BRI_CategorySystem = data.BRI_CategorySystem;;
            //     resOutput.BRI_CIDITEMUKAN = data.briCIDItemUKAN;
            //     resOutput.BRI_DetectedTime = data.briDetectedTime;
            //     resOutput.BRI_FormatTiketIncident = data.briFormatTiketIncident;
            //     resOutput.BRI_isUnHoldFromIntegration = data.BRI_isUnHoldFromIntegration;
            //     resOutput.BRI_LayananTerdampak = data.briLayananTerdampak;
            //     resOutput.BRI_SApp_UnHold_Justification = data.briSApp_UnHold_Justification;
            //     resOutput.BRI_SApp_TicketNumber = data.briSApp_TicketNumber;
            //     resOutput.BRI_SourceKey = data.briSourceKey;
            //     resOutput.Impact = data.Impact;
            //     resOutput.RecId = data.RecId;
            //     resOutput.Source = data.Source;
            //     resOutput.Status = data.Status;
            //     resOutput.Subject = data.Subject;
            //     resOutput.Symptom = data.Symptom;
            //     resOutput.TipeIncident = data.BRI_TipeIncident;
            //     resOutput.Urgency = data.Urgency;
            //     resOutput.LastModDateTime = convertDateTime(data.LastModDateTime);
                
            //     outputRes.add(resOutput);
            // }

        } catch (Exception e){
            System.debug('Error occured'+e.getMessage());
        }

        return outputRes;
    }

    private static SCC_ITSMWrapper.RequestUnhold mapRequestITSM(RequestUnhold req){
        SCC_ITSMWrapper.RequestUnhold reqReopen = new SCC_ITSMWrapper.RequestUnhold();
        reqReopen.BRI_isUnHoldFromIntegration = 'True';
        reqReopen.BRI_SApp_UnHold_Justification = req.BRI_SApp_UnHold_Justification;

        return reqReopen;
    }

    private static Datetime convertDateTime(String dt){
        List<String> frmtDate = dt.split('T');
        Datetime updatedDt = Datetime.valueOf(frmtDate[0]+' '+frmtDate[1]);
        return updatedDt;
    }

    public class RequestUnhold{

      
        @InvocableVariable(required=true)
        public String BRI_SApp_UnHold_Justification;

        @InvocableVariable(required=true)
        public String IncidentId;
    }

       public class ResponseReopenITSM{
        @InvocableVariable
        public String Impact;

        @InvocableVariable
        public String BRI_isUnHoldFromIntegration;

        @InvocableVariable
        public String BRI_SApp_UnHold_Justification;

        @InvocableVariable
        public String BRI_SApp_UnHold_Status;

        @InvocableVariable
        public String BRI_SApp_UnHold_RejectJustification;

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