public with sharing class SCC_ITSM {

    public class WrapperCreateTicket{
        public SCC_ITSMWrapper.ResponseCreateTicket res {get;set;}
        public SCC_ITSMWrapper.ResponseError err {get;set;}
        public WrapperCreateTicket(SCC_ITSMWrapper.ResponseCreateTicket res,SCC_ITSMWrapper.ResponseError err){
            this.res = res;
            this.err = err;
        }
    }

    public class WrapperReopenTicket{
        public SCC_ITSMWrapper.ResponseReopenTicket res {get;set;}
        public SCC_ITSMWrapper.ResponseError err {get;set;}
        public WrapperReopenTicket(SCC_ITSMWrapper.ResponseReopenTicket res,SCC_ITSMWrapper.ResponseError err){
            this.res = res;
            this.err = err;
        }
    }

    public static SCC_ITSM.WrapperCreateTicket createTicket(SCC_ITSMWrapper.RequestCreateTicket reqBody){
        String metaCreateTicket = 'ITSM_Create_Ticket';
        String classCreateTicket = 'SCC_ITSM_CreateTicket';
        SCC_ITSM_API.WrapperAPI resultApi;
        SCC_ITSMWrapper.ResponseCreateTicket resCreateTicket = new SCC_ITSMWrapper.ResponseCreateTicket();
        SCC_ITSMWrapper.ResponseError resError = new SCC_ITSMWrapper.ResponseError();

        String bodyRequest = JSON.serialize(reqBody,true);
        resultApi = SCC_ITSM_API.getResponseITSM(metaCreateTicket, bodyRequest, '', classCreateTicket, '');

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('@odata.context')))){
                resCreateTicket = (SCC_ITSMWrapper.ResponseCreateTicket) JSON.deserialize(resultApi.res.getBody(), SCC_ITSMWrapper.ResponseCreateTicket.class);
                if(mapResponse.containsKey('@odata.context')){
                    resCreateTicket.data_context = (String) mapResponse.get('@odata.context');
                }
                
            } else {
                If(String.isNotBlank(String.valueOf(mapResponse.get('code')))){
                    resError = (SCC_ITSMWrapper.ResponseError) JSON.deserialize(resultApi.res.getBody(), SCC_ITSMWrapper.ResponseError.class);
                }
            }

        } catch (Exception e){
                SCC_ITSM_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_ITSM_API.WrapperError(resultApi.urlCurrent,classCreateTicket));
        }
        SCC_ITSM.WrapperCreateTicket result = new SCC_ITSM.WrapperCreateTicket(resCreateTicket,resError);
        return result;
    }

    public static SCC_ITSM.WrapperReopenTicket reopenTicket(SCC_ITSMWrapper.RequestReopenTicket reqBody, String idIncident){
        String metaReopenTicket = 'ITSM_Reopen';
        String classReopenTicket = 'SCC_ITSM_ReopenTicket';
        SCC_ITSM_API.WrapperAPI resultApi;
        SCC_ITSMWrapper.ResponseReopenTicket resReopenTicket = new SCC_ITSMWrapper.ResponseReopenTicket();
        SCC_ITSMWrapper.ResponseError resError = new SCC_ITSMWrapper.ResponseError();

        String bodyRequest = JSON.serialize(reqBody,true);
        System.debug(bodyRequest);
        resultApi = SCC_ITSM_API.getResponseITSM(metaReopenTicket, bodyRequest, '', classReopenTicket, idIncident); 

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('@odata.context')))){
                resReopenTicket = (SCC_ITSMWrapper.ResponseReopenTicket) JSON.deserialize(resultApi.res.getBody(), SCC_ITSMWrapper.ResponseReopenTicket.class);
                if(mapResponse.containsKey('@odata.context')){
                    resReopenTicket.data_context = (String) mapResponse.get('@odata.context');
                }
            } else {
                if(String.isNotBlank(String.valueOf(mapResponse.get('code')))){
                    resError = (SCC_ITSMWrapper.ResponseError) JSON.deserialize(resultApi.res.getBody(), SCC_ITSMWrapper.ResponseError.class);
                }
            }
        } catch(Exception e){
            SCC_ITSM_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_ITSM_API.WrapperError(resultApi.urlCurrent,classReopenTicket));
        }

        SCC_ITSM.WrapperReopenTicket result = new SCC_ITSM.WrapperReopenTicket(resReopenTicket,resError);
        return result;

    }
}