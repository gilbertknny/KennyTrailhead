public without sharing class SCC_ITSMCtrl {

    public static SCC_ITSM_API_Wrapper.ResponseITSMModel updateCase(SCC_ITSM_API_Wrapper.RequestITSMModel jreq,String idIncident) {
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_ITSM_API_Wrapper.ResponseITSMModel jres = new SCC_ITSM_API_Wrapper.ResponseITSMModel();
        SCC_ITSM_API_Wrapper.IncidentUpdate updtResponse = new SCC_ITSM_API_Wrapper.IncidentUpdate();

        String resolutionType = jreq.resolutionType;
        String rootCause = jreq.rootCause;
        String status = jreq.status;
        String incidentId = idIncident;
        String actionItems = jreq.actionItem.replaceAll('\n', '<br>');
        String reopenStatus = jreq.reopenStatus;
        String reopenJustification = jreq.reopenJustification;
        String holdJustification = jreq.holdJustification;
        String unholdStatus = jreq.unholdStatus;
        String unholdJustification = jreq.unholdJustification;
        String totalSLA_IT = jreq.totalSLA_IT;

        String queries = 'SELECT Id, Resolution_Type__c, Root_Cause__c, Status, Hold_Justification__c , Un_Hold_Justification__c , Un_Hold_Status__c , Case__r.Id, Total_SLA__c FROM Incident WHERE Case__r.Id = :incidentId';
        
        List<Incident> incidentList = Database.query(queries);

        if (!incidentList.isEmpty()) {
            Incident incd = incidentList[0];

            if (!String.isBlank(resolutionType)) {
                incd.Resolution_Type__c = resolutionType;
            }
            if (!String.isBlank(rootCause)) {
                incd.Root_Cause__c = rootCause;
            }
            if(!String.isBlank(actionItems)){
                incd.Action_Items__c = actionItems;
            }
            if (!String.isBlank(status)) {
                incd.Status = status;
            }

            if(!String.isBlank(reopenStatus)){
                incd.Reopen_Status__c = reopenStatus;
            }

            if(!String.isBlank(reopenJustification)){
                incd.Reopen_Justification__c = reopenJustification;
            }

            if(!String.isBlank(holdJustification)){
                incd.Hold_Justification__c = holdJustification;
            }

            if(!String.isBlank(unholdStatus)){
                incd.Un_Hold_Status__c = unholdStatus;
            }

            if(!String.isBlank(unholdJustification)){
                incd.Un_Hold_Justification__c = unholdJustification;
            }

            if(!String.isBlank(totalSLA_IT)){
                incd.Total_SLA__c = totalSLA_IT;
            }
            
                Database.SaveResult sr = Database.update(incd);

                if (sr.isSuccess()) {
                    updtResponse.actionItem = jreq.actionItem;
                    updtResponse.IncidentCHMId = incd.Id;
                    updtResponse.incidentId = idIncident;
                    updtResponse.resolutionType = jreq.resolutionType;
                    updtResponse.rootCause = jreq.rootCause;
                    updtResponse.status = jreq.status;
                    updtResponse.updatedDate = String.valueOf(DateTime.now());
                    updtResponse.reopenStatus = jreq.ReopenStatus;
                    updtResponse.reopenJustification = jreq.ReopenJustification;
                    updtResponse.unholdStatus = jreq.unholdStatus;
                    updtResponse.unholdJustification = jreq.unholdJustification;
                    updtResponse.holdJustification = jreq.holdJustification;
                    updtResponse.totalSLA_IT = jreq.totalSLA_IT;

                    jres.ResponseCode = maprc.get('Success').Response_Code__c;
                    jres.ResponseMessage = maprc.get('Success').Description__c;
                    jres.updatedData = updtResponse;

                } else {
                    String errmsg = '';
                    String errcode = '';
                    for (Database.Error err : sr.getErrors()) {
                        errmsg += err.getMessage() + ' ';
                        errcode = String.valueOf(err.getStatusCode());
                    }
                    jres.ResponseCode = errcode;
                    jres.ResponseMessage = errmsg;
                }

        } else {
            jres.ResponseCode = maprc.get('Data_Not_Found').Response_Code__c;
            jres.ResponseMessage = maprc.get('Data_Not_Found').Description__c;
        }

        return jres;
    }

    public static String returnAPI(SCC_ITSM_API_Wrapper.ResponseITSMModel jres) {
        String returnJson = (String) JSON.serialize(jres, false);
        returnJson = returnJson.normalizeSpace().trim();
        return returnJson;
    }
}