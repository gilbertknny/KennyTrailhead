// Apex Class Name    : EventMonitoring_API
// Created Date       : 25 September 2024
// Created Time       : 03.00 AM
// @author            : Suherbing Septian
// Modification Log :
// Ver   Date         Author                            Modification
// 1.0   25/09/2024   Suherbing Septian                 Initial Version

@RestResource(urlMapping='/EventMonitoringQuery/*')
global with sharing class EventMonitoring_API{
    @HttpPost
    global static void  getEventMonitoring(){
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse responsApi = Restcontext.response;
        EventMonitoring_API_Wrapper.GetResponseModel jres = new EventMonitoring_API_Wrapper.GetResponseModel();
        try{
            String reqobj = requestApi?.requestBody?.toString(); 
            EventMonitoring_API_Wrapper.GetRequest_Model jreq = (EventMonitoring_API_Wrapper.GetRequest_Model) json.deserialize(reqobj, EventMonitoring_API_Wrapper.GetRequest_Model.class);
            returnJson = EventMonitoring_API_Ctrl.getEventMonitoring(jreq);
            EventMonitoring_API.insertErrorLog(null, requestApi,responsApi,returnJson);
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
            returnJson = EventMonitoring_API_Ctrl.returnAPI(jres);
            EventMonitoring_API.insertErrorLog(exc, requestApi, responsApi,returnJson);
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
        dl.classname = 'EventMonitoring_API';
        dl.header = String.valueof(requestApi?.headers);
        dl.body = requestApi?.requestBody?.toString();
        dl.iprequest = requestApi?.remoteAddress; 
        dl.statuscode = responsApi?.statusCode; 
        System.debug('Status  :'+responsApi.statusCode);
        System.debug('Status Code :'+dl.statuscode);
        dl.responsebody = returnJson; 
        dl.urLendpoint = '/EventMonitoringQuery/'; 
        dl.typeapi = 'Inbound';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
}