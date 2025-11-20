/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 18-06-2025
 * @last modified by  : Christian Vieri
**/
@RestResource(urlMapping='/RPAUpdateTicket/*')
global with sharing class SCC_RPAUpdateTicket {
    @HttpPost
    global static void updateCase() {
        String returnJson = '';
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        SCC_RPAWrapper.InsertUpdateCaseResponseModel jres = new SCC_RPAWrapper.InsertUpdateCaseResponseModel();
        SCC_RPAController.ErrorLog el = new SCC_RPAController.ErrorLog();
        el.requestApi = requestApi;
        el.respondApi = respondApi;
        el.classname = 'SCC_RPAUpdateTicket';
        el.url = '/RPAUpdateTicket/';
        try{
            String reqobj = requestApi?.requestBody?.toString();
            Case cs = SCC_RPAController.UpdateCase(reqobj);
            Case css = [select id,createddate,CaseNumber,case_number__c from case where id=:cs.id];
            jres = SCC_RPAController.setResponse('Success');
            jres.TTNumber = css.case_number__c;
            jres.TicketId = css.id;
            returnJson = InsertErrorLog(null, jres,el); 
        }
        catch(Exception exc){
            String typename = exc.getTypeName().replace('System.', '');
            jres = new SCC_RPAWrapper.InsertUpdateCaseResponseModel();
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

    public static String insertErrorLog(Exception e,SCC_RPAWrapper.InsertUpdateCaseResponseModel jres,SCC_RPAController.ErrorLog el){
        String returnJson = '';
        returnJson = (String) JSON.serialize(jres,false);
        returnJson = returnJson.normalizeSpace().trim();
        el.returnJson = returnJson;
        SCC_RPAController.InsertErrorLog(e, el);
        return returnJson;
    }
}