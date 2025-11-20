@RestResource(urlMapping='/droneCheckManualRecon/*')
global with sharing class SCC_DroneCheckManualRecon {
    
    @HttpPost
    global static void GetCaseManualRecon() {
        String return_json = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest request_api = RestContext.request;
        RestResponse respond_api = Restcontext.response;
        Boolean cek_data = false;
        String fm = '';
        SCC_DroneAPIWrapper.CheckManualReconResponseModel jres = new SCC_DroneAPIWrapper.CheckManualReconResponseModel();
        List<SCC_DroneAPIWrapper.DataManualRecon> jresData = new List<SCC_DroneAPIWrapper.DataManualRecon>();
        try{
            String wrapperclassname = 'CheckManualReconRequestModel';
            String cond = 'Wrapper_Class_Name__c=:wrapperclassname';
            String reqobj = request_api?.requestBody?.toString(); 

            Map<String, Object> mapreq = (Map<String, Object>) JSON.deserializeUntyped(reqobj);
            
            SCC_DroneAPIWrapper.CheckManualReconRequestModel jreq = (SCC_DroneAPIWrapper.CheckManualReconRequestModel) json.deserialize(reqobj, SCC_DroneAPIWrapper.CheckManualReconRequestModel.class);

            String allfield = SOQL_SOBJECT.getallfield('SCC_Mandatory_Field_API__mdt');
            String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Mandatory_Field_API__mdt', cond, '', '', '');
            List<SCC_Mandatory_Field_API__mdt> listmf = Database.query(queries);
            for(SCC_Mandatory_Field_API__mdt md:listmf){
                String val = String.valueOf(mapreq.get(md.MasterLabel));
                if(String.isBlank(val)){
                    cek_data = true;
                    jres.totalSize = 0;
                    jres.responseCode = maprc?.get('Mandatory')?.Response_Code__c;
                    jres.responseMessage = maprc?.get('Mandatory')?.Description__c+' '+md.MasterLabel;
                    jres.data = jresData;
                    break;
                }
            }
            if(cek_data==false){
                jres= SCC_DroneCheckManualReconCtrl.GetCaseManualRecon(jreq);
            }

            return_json = SCC_DroneCheckManualReconCtrl.returnAPIGetCase(jres);
			SCC_DroneCheckManualRecon.InsertErrorLog(null, request_api, respond_api,return_json);

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
            return_json = SCC_DroneCheckManualReconCtrl.returnAPIGetCase(jres);
            SCC_DroneCheckManualRecon.InsertErrorLog(exc, request_api, respond_api,return_json);
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
        dl.classname = 'SCC_DroneCheckManualRecon';
        dl.header = String.valueof(request_api?.headers);
        dl.body = request_api?.requestBody?.toString();
        dl.iprequest = request_api?.remoteAddress; 
        dl.statusCode = respond_api?.statusCode; 
        dl.responseBody = return_json; 
        dl.urlEndpoint = '/droneCheckManualRecon/'; 
        dl.typeApi = 'Inbound';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
}