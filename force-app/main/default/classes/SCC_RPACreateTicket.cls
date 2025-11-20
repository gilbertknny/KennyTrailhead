/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 23-06-2025
 * @last modified by  : Christian Vieri
**/
@RestResource(urlMapping='/RPACreateTicket/*')
global without sharing class SCC_RPACreateTicket {
    @HttpPost
    global static void createCase() {
        String returnJson = '';
        String accId = '';
        Account acc = new Account();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = Restcontext.response;
        SCC_RPAWrapper.InsertUpdateCaseResponseModel jres = new SCC_RPAWrapper.InsertUpdateCaseResponseModel();
        SCC_RPAController.ErrorLog el = new SCC_RPAController.ErrorLog();
        el.requestApi = requestApi;
        el.respondApi = respondApi;
        el.classname = 'SCC_RPACreateTicket';
        el.url = '/RPACreateTicket/';
        try{
            String reqobj = requestApi?.requestBody?.toString(); 

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(reqobj);
            String accountNumber = (String) jsonMap.get('SCC_Account_Number__c');
            system.debug('account Number: ' + accountNumber);

            // Contoh validasi sederhana
            if (!String.isBlank(accountNumber)) {
                SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
                SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
                req.acctNo = accountNumber;
                req.channelId = 'CHMS';
                req.personalNumber = label.Personal_Number;
                res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req,'System','');
                if(res?.data!=null){
                    for(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData dt:res?.data){
                        String cifno = dt.cifno;
                        String condacc = 'SCC_cifno__c=:cifno';
                        String allfieldacc = SOQL_SOBJECT.getallfield('Account');
                        String queriesacc = SOQL_SOBJECT.SOQL(allfieldacc, '', 'Account', condacc, '', '', '1');
                        List<Account> listacc = Database.query(queriesacc);
                        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi demographicInfo = dt?.demografi;
                        if(!listacc.isEmpty()){
                            acc = SCC_LegacyCaseAPICtrl.returnAccount(demographicInfo, listacc[0].id, dt?.cifno);
                        }
                        else{   
                            acc = SCC_LegacyCaseAPICtrl.returnAccount(demographicInfo, null, dt?.cifno);
                        }
                    } 
                    accId = acc?.id;
                    system.debug('account Id: ' + accId);
                }
            }
            User us = SCC_RPAController.getRPAUser();
            Case cs = (Case) JSON.deserialize(reqobj, Case.class);
            if (accId != '') {
                cs.accountId = accId;
            }
            cs.OwnerId = us.id;
            insert cs;
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