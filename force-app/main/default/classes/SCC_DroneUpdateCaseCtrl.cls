public without sharing class SCC_DroneUpdateCaseCtrl {
    Public Static SCC_DroneAPIWrapper.UpdateCaseResponseModel UpdateCase(SCC_DroneAPIWrapper.UpdateCaseRequestModel jreq){
        Map<String,String> mapcsori = new Map<String,String>();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_DroneAPIWrapper.UpdateCaseResponseModel jres = new SCC_DroneAPIWrapper.UpdateCaseResponseModel();
        List<SCC_Call_Type_Feature__c> fiturList = new List<SCC_Call_Type_Feature__c>();
        List<SSC_Call_Type__c> calltypelist = new List<SSC_Call_Type__c>();

        String casenumber = jreq.case_number;
        String calltype = jreq.update_call_type;
        String fitur = String.valueOf(jreq.fitur_id);

        String cond = 'Case_Number__c=:casenumber';
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', cond, '', '', '');
        List<Case> caseList = Database.query(queries);

        if(!String.isBlank(calltype)){
        String condct = 'Name=:calltype AND Active__c = true';
        String allfieldCasect = SOQL_SOBJECT.getallfield('SSC_Call_Type__c');
        String queriesct = SOQL_SOBJECT.SOQL(allfieldCasect, '', 'SSC_Call_Type__c', condct, '', '', '');
         calltypelist = Database.query(queriesct);
        }

        if(fitur != null){
        String condfitur = 'Fitur_ID__c=:fitur';
        String allfieldfitur = SOQL_SOBJECT.getallfield('SCC_Call_Type_Feature__c');
        String queriesfitur = SOQL_SOBJECT.SOQL(allfieldfitur, '', 'SCC_Call_Type_Feature__c', condfitur, '', '', '');
        fiturList = Database.query(queriesfitur);
        }
        
        if(!caseList.isEmpty()){
            Case cs = new Case();
            cs.Id = caseList[0].id;
            cs.SCC_Drone_Closed_By__c = jreq.closed_by;
            cs.SCC_Closure_Comments__c = jreq.closure_comments;

            if(!String.isBlank(jreq.remark)){
                cs.SCC_Remark__c = jreq.remark;
            }
            if(!String.isBlank(jreq.update_call_type)){
                if(calltypelist.size() > 0){
                    cs.SCC_Call_Type__c = calltypelist[0].id;
                }
            }
            if(!fiturList.isEmpty()){
                cs.SCC_Call_Type_Feature__c = fiturList[0].id;  
                cs.SCC_Call_Type__c = fiturList[0].Call_Type__c;  
            }
            

            if(!String.isBlank(jreq.process)){
                cs.Status = jreq.process;
                if(cs.Status == 'Closed'){
                    cs.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi';
                }
            }

            system.debug('case:'+cs);
            Database.SaveResult sr = Database.update(cs);
            system.debug('sr:'+sr);
            if(sr.isSuccess()){
                jres.responseCode = maprc.get('Success').Response_Code__c;
            	jres.responseMessage = maprc.get('Success').Description__c;
            }else{
                String errmsg = '';
                String errcode = '';
            	for(Database.Error err : sr.getErrors()) {
                    errmsg += err.getMessage() + ' ';
                    errcode = String.valueOf(err.getStatusCode());
                }
                jres.responseCode = errcode;
                jres.responseMessage = errmsg;
            }
        }
        else {
            jres.responseCode = maprc.get('Data_Not_Found').Response_Code__c;
            jres.responseMessage = maprc.get('Data_Not_Found').Description__c;
        }
        system.debug('jres:'+jres);
        return jres;
    }

    Public Static String returnAPI(SCC_DroneAPIWrapper.UpdateCaseResponseModel jres){
        String return_json = '';
        return_json = (String) JSON.serialize(jres,false);
        return_json = return_json.normalizeSpace().trim(); 
        return return_json;
    }
}