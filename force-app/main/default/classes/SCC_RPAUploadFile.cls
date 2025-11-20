@RestResource(urlMapping='/RPAUploadFile/*')
global without sharing class SCC_RPAUploadFile {
    @HttpPost
    global static void uploadFile() {
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        String type = requestApi.requestURI.substring(requestApi.requestURI.lastIndexOf('/')+1);
        SCC_RPAWrapper.InsertFileResponseModel jres = new SCC_RPAWrapper.InsertFileResponseModel();
        SCC_RPAController.ErrorLog el = new SCC_RPAController.ErrorLog();
        el.requestApi = requestApi;
        el.respondApi = respondApi;
        el.classname = 'SCC_RPAUploadFile';
        el.url = '/RPAUploadFile/'+type;
        try{
            SCC_RPAWrapper.InsertFileRequestModel jreq = (SCC_RPAWrapper.InsertFileRequestModel) JSON.deserialize(requestApi?.requestBody?.toString(), SCC_RPAWrapper.InsertFileRequestModel.class);
            jres = SCC_RPAController.setResponseFile(jreq,type);
            returnJson = InsertErrorLog(null, jres,el);
        }
        catch(Exception exc){
            String typename = exc.getTypeName().replace('System.', '');
            jres = new SCC_RPAWrapper.InsertFileResponseModel();
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
            returnJson = InsertErrorLog(exc, jres,el);
        }
        Restcontext.response.addHeader('Content-Type', 'application/json');
        Restcontext.response.responseBody = Blob.valueOf(returnJson);
        Restcontext.response.statuscode = 200;
    }

    public static String insertErrorLog(Exception e,SCC_RPAWrapper.InsertFileResponseModel jres,SCC_RPAController.ErrorLog el){
        String returnjson = '';
        returnjson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim();
        el.returnJson = returnJson;
        SCC_RPAController.InsertErrorLog(e, el);
        return returnJson;
    }
}