@RestResource(urlMapping ='/updateIncident/*')
global with sharing class SCC_IncidentUpdate {
    @HttpPatch
    global static void updateIncident(){
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        String incidentId = requestApi.requestURI.substring(requestApi.requestURI.lastIndexOf('/')+1);
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> mapRc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_ITSM_API_Wrapper.ResponseITSMModel responseModel = new SCC_ITSM_API_Wrapper.ResponseITSMModel();
        Boolean cekData = false;

        try{
            String wrapperClassName = 'RequestITSMModel';
            String cond = 'Wrapper_Class_Name__c=:wrapperclassname';
            String reqobj = requestApi?.requestBody?.toString();
            System.debug(reqobj);
            Map<String, Object> mapreq = (Map<String, Object>) JSON.deserializeUntyped(reqobj);
            SCC_ITSM_API_Wrapper.RequestITSMModel requestModel = (SCC_ITSM_API_Wrapper.RequestITSMModel) json.deserializeStrict(reqobj, SCC_ITSM_API_Wrapper.RequestITSMModel.class);

            String allfield = SOQL_SOBJECT.getallfield('SCC_Mandatory_Field_API__mdt');
            String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Mandatory_Field_API__mdt', cond, '', '', '');
            List<SCC_Mandatory_Field_API__mdt> listMandatory = Database.query(queries);

            for(SCC_Mandatory_Field_API__mdt md : listMandatory){
                String val = String.valueOf(mapreq.get(md.MasterLabel));
                if(String.isBlank(val)){
                    cekData = true;
                    responseModel.ResponseCode = mapRc?.get('Mandatory')?.Response_Code__c;
                    responseModel.ResponseMessage = mapRc?.get('Mandatory')?.Description__c+ ' '+md.MasterLabel;
                    break;
                }
            }

            if((mapreq.get('status') == 'Closed' || mapreq.get('status') == 'Resolved') && mapreq.get('reopenStatus') == ''){
                String resolutionType = String.valueOf(mapreq.get('resolutionType'));
                String rootCause = String.valueOf(mapreq.get('rootCause'));
                String actionItem = String.valueOf(mapreq.get('actionItem'));

                if(String.isBlank(resolutionType)){
                    cekData = true;
                    responseModel.ResponseCode = mapRc?.get('resolutionType')?.Response_Code__c;
                    responseModel.ResponseMessage = mapRc?.get('resolutionType')?.Description__c + ' ' + mapreq.get('status');
                    
                }

                if(String.isBlank(rootCause)){
                    cekData = true;
                    responseModel.ResponseCode = mapRc?.get('rootCause')?.Response_Code__c;
                    responseModel.ResponseMessage = mapRc?.get('rootCause')?.Description__c + ' ' + mapreq.get('status');
                }

                if(String.isBlank(actionItem)){
                    cekData = true;
                    responseModel.ResponseCode = mapRc?.get('actionItem')?.Response_Code__c;
                    responseModel.ResponseMessage = mapRc?.get('actionItem')?.Description__c + ' ' + mapreq.get('status');
                    
                }
            }


            if(!cekData){
                responseModel = SCC_ITSMCtrl.updateCase(requestModel,incidentId);
            }
            returnJson = SCC_ITSMCtrl.returnAPI(responseModel);
            SCC_IncidentUpdate.insertErrorLog(null, requestApi, respondApi, returnJson);
        } catch(Exception e){
            String typename = e.getTypeName().replace('System.', '');
            responseModel = new SCC_ITSM_API_Wrapper.ResponseITSMModel();
            responseModel.ResponseMessage = e.getMessage();
            if(mapRc.containskey(typename)){
                responseModel.ResponseCode = mapRc.get(typename).Response_Code__c;
            }
            else{
                for(SCC_Custom_API_Response_Code__mdt rc:maprc.values()){
                    if(responseModel.responseMessage.contains(rc.MasterLabel)) {
                        responseModel.responseCode = rc.Response_Code__c;
                        break;
                    }
                }
            }
            if(String.isBlank(responseModel.responseCode)){
                responseModel.responseCode = maprc?.get('General_Error')?.Response_Code__c;
            }
            returnJson = SCC_ITSMCtrl.returnAPI(responseModel);
            SCC_IncidentUpdate.insertErrorLog(e, requestApi, respondApi, returnJson);
        }
       

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(returnJson);
        RestContext.response.statusCode = 200;
    }

    public static void insertErrorLog(Exception e,RestRequest requestApi,RestResponse respondApi,String returnJson){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = e?.getMessage();
        dl.trace = e?.getStackTraceString();
        dl.typename = e?.getTypeName();
        dl.linenumber = string.valueOf(e?.getLineNumber()); 
        dl.errorcause = string.valueOf(e?.getCause()); 
        dl.classname = 'SCC_IncidentUpdate';
        dl.header = String.valueof(requestApi?.headers);
        dl.body = requestApi?.requestBody?.toString();
        dl.iprequest = requestApi?.remoteAddress; 
        dl.statusCode = respondApi?.statusCode; 
        dl.responseBody = returnJson; 
        dl.urlEndpoint = '/updateIncident/'; 
        dl.typeApi = 'Inbound';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
    }
}