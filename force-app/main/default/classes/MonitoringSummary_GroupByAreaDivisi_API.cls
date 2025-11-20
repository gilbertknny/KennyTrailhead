@RestResource(urlMapping='/MonitoringSummaryQueryByAreaDivisi/*')
global with sharing class MonitoringSummary_GroupByAreaDivisi_API{
    @HttpPost
    global static void  GetByAreaDivisi(){
        String return_json = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest request_api = RestContext.request;
        RestResponse respond_api = Restcontext.response;
        MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel jres = new MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel();
        System.debug('request_api :'+request_api);
        System.debug('jres :'+jres);
        try{
            String reqobj = request_api?.requestBody?.toString(); 
            MonitoringSummary_API_Wrapper.GetByAreaRequestModel jreq = (MonitoringSummary_API_Wrapper.GetByAreaRequestModel) json.deserialize(reqobj, MonitoringSummary_API_Wrapper.GetByAreaRequestModel.class);
            return_json = MonitoringSummary_API_Ctrl.GetByAreaDivisi(jreq);
            MonitoringSummary_GroupByAreaDivisi_API.InsertErrorLog(null, request_api, respond_api,return_json);
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
            return_json = MonitoringSummary_API_Ctrl.returnAPIGetByAreaDivisi(jres);
            MonitoringSummary_GroupByAreaDivisi_API.InsertErrorLog(exc, request_api, respond_api,return_json);
        }
        Restcontext.response.addHeader('Content-Type', 'application/json');
        Restcontext.response.responseBody = Blob.valueOf(return_json);
        Restcontext.response.statuscode = 200;
    }

    public static void InsertErrorLog(Exception e,RestRequest request_api,RestResponse respond_api,String return_json){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = e?.getMessage();
        dl.trace = e?.getStackTraceString();
        dl.typename = e?.getTypeName();
        dl.linenumber = string.valueOf(e?.getLineNumber()); 
        dl.errorcause = string.valueOf(e?.getCause()); 
        dl.classname = 'MonitoringSummary_GroupByAreaDivisi_API';
        dl.header = String.valueof(request_api?.headers);
        dl.body = request_api?.requestBody?.toString();
        dl.iprequest = request_api?.remoteAddress; 
        dl.status_code = respond_api?.statusCode; 
        dl.response_body = return_json; 
        dl.urL_endpoint = '/MonitoringSummaryQueryByAreaDivisi/'; 
        dl.type_api = 'Inbound';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
        System.debug('debugLog :'+dl);
    }
}