public with sharing class SCC_DroneCheckManualReconCtrl {

    Public Static SCC_DroneAPIWrapper.CheckManualReconResponseModel GetCaseManualRecon(SCC_DroneAPIWrapper.CheckManualReconRequestModel jreq){
        Map<String, SCC_Manual_Recon_Query__mdt> mapmfc = SCC_Manual_Recon_Query__mdt.getAll();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();

        Date trx_date = jreq.transaction_date;
        String terminalID = jreq.terminal_id;
        String calltype = jreq.call_type;
        Integer amount = jreq.amount;
        String rekening = jreq.nomor_rekening;
        String nokartu = jreq.nomor_kartu;
        Boolean errorMandatory = false;

        String cond = 'transaction_date=:trx_date AND call_type=:calltype AND amount_transaction=:amount';

        if(String.isNotBlank(terminalID)){
            cond +=' AND terminal_id=:terminalID';
        }
        if(String.isNotBlank(rekening)){
            cond +=' AND no_rek=:rekening';
        }
        if(String.isNotBlank(nokartu)){
            cond +=' AND no_kartu=:nokartu';
        }

        if(String.isBlank(rekening) && String.isBlank(nokartu) &&  String.isBlank(terminalID)){
            errorMandatory = true;
        }

        for(SCC_Manual_Recon_Query__mdt mfc:mapmfc.values()){
         cond = cond.replace(mfc.MasterLabel,mfc.Field_API__c);
        }

        String allfield = 'Casenumber,Id,status,SCC_Status_Pembukuan__c,SCC_Is_Manual_Recon__c';
        String queries = SOQL_SOBJECT.SOQL(allfield,'', 'Case', cond, '', '', '');
        List<Case> listcs = Database.query(queries);
        SCC_DroneAPIWrapper.CheckManualReconResponseModel jres = new SCC_DroneAPIWrapper.CheckManualReconResponseModel();
        List<SCC_DroneAPIWrapper.DataManualRecon> dataList = new List<SCC_DroneAPIWrapper.DataManualRecon>();
   
        if(!listcs.isEmpty() && !errorMandatory){
            for(Case cs:listcs){
                SCC_DroneAPIWrapper.DataManualRecon dt = new SCC_DroneAPIWrapper.DataManualRecon();

                dt.caseId = cs.Id;
                dt.caseNumber = cs.CaseNumber;
                dt.status = cs.Status;
                dt.manualRekonFlag = cs.SCC_Is_Manual_Recon__c;
                dt.pembukuanSukses = cs.SCC_Status_Pembukuan__c;
                dataList.add(dt);
            }
            rc = maprc?.get('Success');
        }
        else if(errorMandatory){
            rc = maprc?.get('Mandatory');
        }
        else{
            rc = maprc?.get('Data_Not_Found');
        }
        jres.data = dataList;
        jres.totalSize = Integer.valueOf(listcs.size());
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;

        return jres;
    }


    Public Static String returnAPIGetCase(SCC_DroneAPIWrapper.CheckManualReconResponseModel jres){
        String return_json = '';
        return_json = (String) JSON.serialize(jres,false);
        return_json = return_json.normalizeSpace().trim(); 
        return return_json;
    }
}