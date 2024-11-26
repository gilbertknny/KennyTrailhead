// public with sharing class BristarSummary_API {
//     public BristarSummary_API() {

//     }
// }

// Apex Class Name    : EventMonitoring_API
// Created Date       : 25 September 2024
// Created Time       : 03.00 AM
// @author            : Suherbing Septian
// Modification Log :
// Ver   Date         Author                            Modification
// 1.0   25/09/2024   Suherbing Septian                 Initial Version

@RestResource(urlMapping='/bristarSummaryQuery/*')
global with sharing class BristarSummary_API{
    @HttpPost
    global static void  getSummary(){
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse responsApi = Restcontext.response;
        BristarSummary_API_Wrapper.GetResponseModel jres = new BristarSummary_API_Wrapper.GetResponseModel();
        try{
            String reqobj = requestApi?.requestBody?.toString(); 
            BristarSummary_API_Wrapper.GetRequest_Model jreq = (BristarSummary_API_Wrapper.GetRequest_Model) json.deserialize(reqobj, BristarSummary_API_Wrapper.GetRequest_Model.class);
            returnJson = BristarSummary_API_Ctrl.GetBristarSummary(jreq);
            BristarSummary_API.insertErrorLog(null, requestApi,responsApi,returnJson);
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
            returnJson = BristarSummary_API_Ctrl.returnAPI(jres);
            BristarSummary_API.insertErrorLog(exc, requestApi, responsApi,returnJson);
        }
        Restcontext.response.addHeader('Content-Type', 'application/json');
        Restcontext.response.responseBody = Blob.valueOf(returnJson);
        Restcontext.response.statuscode = 200;
    }

    public static void insertErrorLog(Exception e,RestRequest requestApi,RestResponse responsApi,String returnJson){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = e?.getMessage();
        dl.trace = e?.getStackTraceString();
        dl.typename = e?.getTypeName();
        dl.linenumber = string.valueOf(e?.getLineNumber()); 
        dl.errorcause = string.valueOf(e?.getCause()); 
        dl.classname = 'BristarSummary_API';
        dl.header = String.valueof(requestApi?.headers);
        dl.body = requestApi?.requestBody?.toString();
        dl.iprequest = requestApi?.remoteAddress; 
        dl.statuscode = responsApi?.statusCode; 
        System.debug('Status  :'+responsApi.statusCode);
        System.debug('Status Code :'+dl.statuscode);
        dl.responsebody = returnJson; 
        dl.urLendpoint = '/bristarSummaryQuery/'; 
        dl.typeapi = 'Inbound';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
}