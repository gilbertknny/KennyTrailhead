@RestResource(urlMapping='/legacyCaseQuery/*')
global with sharing class SCC_CaseQueryLegacyAPI{
    @HttpPost
    global static void  getCase(){
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        SCC_LegacyCaseAPIWrapper.GetCaseResponseModel jres = new SCC_LegacyCaseAPIWrapper.GetCaseResponseModel();
        try{
            String reqobj = requestApi?.requestBody?.toString(); 
            SCC_LegacyCaseAPIWrapper.GetCaseRequestModel jreq = (SCC_LegacyCaseAPIWrapper.GetCaseRequestModel) json.deserialize(reqobj, SCC_LegacyCaseAPIWrapper.GetCaseRequestModel.class);
            returnJson = SCC_LegacyCaseAPICtrl.getCase(jreq);
            SCC_CaseQueryLegacyAPI.insertErrorLog(null, requestApi, respondApi,returnJson);
        }
        catch(Exception exc){
            String typename = exc.getTypeName().replace('System.', '');
            jres.responseMessage = exc?.getMessage();
            if(maprc.containskey(typename)){
                jres.responseCode = maprc.get(typename).Response_Code__c;
            }
            else{
                for(SCC_Custom_API_Response_Code__mdt rc:maprc.values()){
                    if(jres.responseMessage.contains(rc.MasterLabel)) {
                        jres.responseCode = rc.Response_Code__c;
                        break;
                    }
                }
            }
            if(String.isBlank(jres.responseCode)) {
                jres.responseCode = maprc?.get('General_Error')?.Response_Code__c;
            }
            returnJson = SCC_LegacyCaseAPICtrl.returnAPIGetCase(jres);
            SCC_CaseQueryLegacyAPI.insertErrorLog(exc, requestApi, respondApi,returnJson);
        }
        Restcontext.response.addHeader('Content-Type', 'application/json');
        Restcontext.response.responseBody = Blob.valueOf(returnJson);
        Restcontext.response.statuscode = 200;
    }

    public static void insertErrorLog(Exception e,RestRequest requestApi,RestResponse respondApi,String returnJson){
        SCC_API.WrapperError we = new SCC_API.WrapperError('','SCC_CaseQueryLegacyAPI');
        we.inEndpoint = '/legacyCaseQuery/'; 
        we.requestApi = requestApi;
        we.respondApi = respondApi;
        SCC_API.InsertErrorLogInbound(e, we, returnJson);
    }
}