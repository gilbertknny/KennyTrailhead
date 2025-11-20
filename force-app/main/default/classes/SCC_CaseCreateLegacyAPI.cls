@RestResource(urlMapping='/legacyCaseCreation/*')
global with sharing class SCC_CaseCreateLegacyAPI {
    @HttpPost
    global static void createCase() {
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel jres = new SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel();
        Boolean cekData = false;
        String fm = '';
        try{
            String wrapperclassname = 'CreateCaseRequestModel';
            String cond = 'Wrapper_Class_Name__c=:wrapperclassname';
            String reqobj = requestApi?.requestBody?.toString(); 
            Map<String, Object> mapreq = (Map<String, Object>) JSON.deserializeUntyped(reqobj);
            SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel jreq = (SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel) json.deserialize(reqobj, SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel.class);
            String allfield = SOQL_SOBJECT.getallfield('SCC_Mandatory_Field_API__mdt');
            String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Mandatory_Field_API__mdt', cond, '', '', '');
            List<SCC_Mandatory_Field_API__mdt> listmf = Database.query(queries);
            for(SCC_Mandatory_Field_API__mdt md:listmf){
                String val = String.valueOf(mapreq.get(md.MasterLabel));
                if(String.isBlank(val)){
                    cekData = true;
                    jres.responseCode = maprc?.get('Mandatory')?.Response_Code__c;
                    jres.responseMessage = maprc?.get('Mandatory')?.Description__c+' '+md.MasterLabel;
                    break;
                }
            }
            if(cekData==false){
                jres = SCC_LegacyCaseAPICtrl.CreateCase(jreq);
            }
            returnJson = SCC_LegacyCaseAPICtrl.returnAPI(jres); 
            SCC_CaseCreateLegacyAPI.InsertErrorLog(null, requestApi, respondApi,returnJson);   
        }
        catch(Exception exc){
            String typename = exc.getTypeName().replace('System.', '');
            jres = new SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel();
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
            returnJson = SCC_LegacyCaseAPICtrl.returnAPI(jres);
            SCC_CaseCreateLegacyAPI.InsertErrorLog(exc, requestApi, respondApi,returnJson);
        }
        Restcontext.response.addHeader('Content-Type', 'application/json');
        Restcontext.response.responseBody = Blob.valueOf(returnJson);
        Restcontext.response.statuscode = 200;
    }

    public static void insertErrorLog(Exception e,RestRequest requestApi,RestResponse respondApi,String returnJson){
        SCC_API.WrapperError we = new SCC_API.WrapperError('','SCC_CaseCreateLegacyAPI');
        we.inEndpoint = '/legacyCaseCreation/'; 
        we.requestApi = requestApi;
        we.respondApi = respondApi;
        SCC_API.InsertErrorLogInbound(e, we, returnJson);
    }
}