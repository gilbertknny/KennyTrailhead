/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : Ardyta Yudianto
**/
@RestResource(urlMapping='/BrimoCeriaUploadFile/*')
global without sharing class SCC_BrimoCeriaUploadFileAPI {
    @HttpPost
    global static void uploadFile() {
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = RestContext.response;
        SCC_BrimoCeriaWrapper.InsertFileResponseModel jres = new SCC_BrimoCeriaWrapper.InsertFileResponseModel();
        SCC_BrimoCeriaController.ErrorLog el = new SCC_BrimoCeriaController.ErrorLog();
        el.requestApi = requestApi;
        el.respondApi = respondApi;
        el.classname = 'BrimoCeriaUploadFile';
        el.url = '/BrimoCeriaUploadFile/';

        try {
            // Deserialize request body into InsertFileRequestModel
            SCC_BrimoCeriaWrapper.InsertFileRequestModel jreq = (SCC_BrimoCeriaWrapper.InsertFileRequestModel) JSON.deserialize(requestApi?.requestBody?.toString(), SCC_BrimoCeriaWrapper.InsertFileRequestModel.class);
            // Process file upload
            jres = SCC_BrimoCeriaController.setResponseFile(jreq);
            returnJson = insertErrorLog(null, jres, el);
        } catch (Exception exc) {
            String typename = exc.getTypeName().replace('System.', '');
            jres = new SCC_BrimoCeriaWrapper.InsertFileResponseModel();
            jres.responseMessage = exc?.getMessage();
            if (maprc.containsKey(typename)) {
                jres.responseCode = maprc.get(typename).Response_Code__c;
            } else {
                jres.responseCode = maprc?.get('General_Error')?.Response_Code__c;
            }
            returnJson = insertErrorLog(exc, jres, el);
        }
        
        // Set response headers and body
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(returnJson);
        RestContext.response.statusCode = 200;
    }

    public static String insertErrorLog(Exception e, SCC_BrimoCeriaWrapper.InsertFileResponseModel jres, SCC_BrimoCeriaController.ErrorLog el) {
        String returnJson = (String) JSON.serialize(jres, false);
        returnJson = returnJson.normalizeSpace().trim();
        el.returnJson = returnJson;
        SCC_BrimoCeriaController.insertErrorLog(e, el);
        return returnJson;
    }
}