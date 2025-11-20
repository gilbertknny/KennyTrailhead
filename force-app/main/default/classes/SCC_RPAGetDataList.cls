@RestResource(urlMapping='/RPAGetListTicket/*')
global without sharing class SCC_RPAGetDataList {
    @HttpPost
    global static void getData() {
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        SCC_RPAWrapper.GetCaseResponseModelBulk jres = new SCC_RPAWrapper.GetCaseResponseModelBulk();
        SCC_RPAController.ErrorLog el = new SCC_RPAController.ErrorLog();
        el.requestApi = requestApi;
        el.respondApi = respondApi;
        el.classname = 'SCC_RPAGetDataList';
        el.url = '/RPAGetListTicket/';
        try{
            SCC_RPAWrapper.GetCaseRequestModelBulk jreq = (SCC_RPAWrapper.GetCaseRequestModelBulk) JSON.deserialize(requestApi?.requestBody?.toString(), SCC_RPAWrapper.GetCaseRequestModelBulk.class);
            jres = SCC_RPAController.setResponseListCase(jreq);
            returnJson = InsertErrorLog(null, jres,el);
        }
        catch(Exception exc){
            String typename = exc.getTypeName().replace('System.', '');
            jres = new SCC_RPAWrapper.GetCaseResponseModelBulk();
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

    public static String insertErrorLog(Exception e,SCC_RPAWrapper.GetCaseResponseModelBulk jres,SCC_RPAController.ErrorLog el){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim();
        el.returnJson = returnJson;
        SCC_RPAController.InsertErrorLog(e, el);
        return returnJson;
    }    
}