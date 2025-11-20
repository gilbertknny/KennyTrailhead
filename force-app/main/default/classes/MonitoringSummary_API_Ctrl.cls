public with sharing class MonitoringSummary_API_Ctrl {

// Handle API get by Date

    Public Static String GetByDate(MonitoringSummary_API_Wrapper.GetByDateRequestModel jreq){
        //Map<String, SCC_Legacy_API_Mapping_Query__mdt> mapmfc = SCC_Legacy_API_Mapping_Query__mdt.getAll();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();
        //String cond = jreq.Qualification;
        Date StartDate = Date.valueOf(jreq.StartDate);
        Date EndDate = Date.valueOf(jreq.EndDate);
        String cond = 'Date__c <= :EndDate and Date__c >= :StartDate';
        String addfield = ',Anomali_Category__r.RecordType.Name,Anomali_Category__r.Name,User__r.Name';
        String allfield = SOQL_SOBJECT.getallfield('Monitoring_Summary__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Monitoring_Summary__c', cond, 'Date__c', 'ASC', '');
        List<Monitoring_Summary__c> listms = Database.query(queries);
        MonitoringSummary_API_Wrapper.GetByDateResponseModel jres = new MonitoringSummary_API_Wrapper.GetByDateResponseModel();
        List<MonitoringSummary_API_Wrapper.GetByDateDetailModel> MonitoringSummary = new List<MonitoringSummary_API_Wrapper.GetByDateDetailModel>();
        if(!listms.isEmpty()){
            System.debug('listms tidak kosong');
            for(Monitoring_Summary__c ms:listms){
                //Datetime dt = ms.Date__c;
                MonitoringSummary_API_Wrapper.GetByDateDetailModel msdt = new MonitoringSummary_API_Wrapper.GetByDateDetailModel();
                msdt.Tanggal = String.valueOf(ms.Date__c);
                msdt.AnomalyCategory_RecordType = ms.Anomali_Category__r.RecordType.Name;
                msdt.Area = ms.Area__c;
                msdt.Branch_Unit = ms.Branch_Unit__c;
                msdt.Divisi = ms.Divisi__c;
                msdt.AnomalyCategory_Name = ms.Anomali_Category__r.Name;
                msdt.MonitoringSummary_Name = ms.Name;
                msdt.User_Name = ms.User__r.Name;
                msdt.Total = String.valueOf(ms.Total__c);
                MonitoringSummary.add(msdt);
            }
            rc = maprc?.get('Success');
        }
        else{
            System.debug('listms kosong');
            rc = maprc?.get('Data_Not_Found');
        }
        System.debug('MonitoringSummary: '+MonitoringSummary);
        jres.MonitoringSummary = MonitoringSummary;
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        String return_json = MonitoringSummary_API_Ctrl.returnAPIGetByDate(jres);
        return return_json;
    }

    Public Static String returnAPIGetByDate(MonitoringSummary_API_Wrapper.GetByDateResponseModel jres){
        String return_json = '';
        return_json = (String) JSON.serialize(jres,false);
        return_json = return_json.normalizeSpace().trim(); 
        return return_json;
    }

// Handle API get by Divisi - Kantor Pusat

    Public Static String GetByAreaDivisi(MonitoringSummary_API_Wrapper.GetByAreaRequestModel jreq){
        //Map<String, SCC_Legacy_API_Mapping_Query__mdt> mapmfc = SCC_Legacy_API_Mapping_Query__mdt.getAll();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();
        //String cond = jreq.Qualification;
        String Area = jreq.Area;
        String GroupBy = jreq.GroupBy;
        MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel jres = new MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel();
        List<MonitoringSummary_API_Wrapper.GetByAreaDivisiDetailModel> MonitoringSummary = new List<MonitoringSummary_API_Wrapper.GetByAreaDivisiDetailModel>();
        if(GroupBy == 'Divisi' && Area == 'Kantor Pusat'){
            String cond = 'Area__c = :Area and Divisi__c != null';
            String addfield = ',Anomali_Category__r.RecordType.Name,Anomali_Category__r.Name,User__r.Name';
            String allfield = SOQL_SOBJECT.getallfield('Monitoring_Summary__c');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Monitoring_Summary__c', cond, 'Date__c', 'ASC', '');
            List<Monitoring_Summary__c> listms = Database.query(queries);
            if(!listms.isEmpty()){
                for(Monitoring_Summary__c ms:listms){
                    //Datetime dt = ms.Date__c;
                    MonitoringSummary_API_Wrapper.GetByAreaDivisiDetailModel msdt = new MonitoringSummary_API_Wrapper.GetByAreaDivisiDetailModel();
                    msdt.Tanggal = String.valueOf(ms.Date__c);
                    msdt.AnomalyCategory_RecordType = ms.Anomali_Category__r.RecordType.Name;
                    msdt.Area = ms.Area__c;
                    msdt.Divisi = ms.Divisi__c;
                    msdt.AnomalyCategory_Name = ms.Anomali_Category__r.Name;
                    msdt.MonitoringSummary_Name = ms.Name;
                    msdt.User_Name = ms.User__r.Name;
                    msdt.Total = String.valueOf(ms.Total__c);
                    MonitoringSummary.add(msdt);
                }
                rc = maprc?.get('Success');
            }
            else{
                rc = maprc?.get('Data_Not_Found');
            }
        }else {
            rc = maprc?.get('Mandatory');
        }
        jres.MonitoringSummary = MonitoringSummary;
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        String return_json = MonitoringSummary_API_Ctrl.returnAPIGetByAreaDivisi(jres);
        return return_json;
    }

    Public Static String returnAPIGetByAreaDivisi(MonitoringSummary_API_Wrapper.GetByAreaDivisiResponseModel jres){
        String return_json = '';
        return_json = (String) JSON.serialize(jres,false);
        return_json = return_json.normalizeSpace().trim(); 
        return return_json;
    }
    
// Handle API get by Branch - Cabang

    Public Static String GetByAreaBranch(MonitoringSummary_API_Wrapper.GetByAreaRequestModel jreq){
        //Map<String, SCC_Legacy_API_Mapping_Query__mdt> mapmfc = SCC_Legacy_API_Mapping_Query__mdt.getAll();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();
        //String cond = jreq.Qualification;
        String Area = jreq.Area;
        String GroupBy = jreq.GroupBy;
        MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel jres = new MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel();
        List<MonitoringSummary_API_Wrapper.GetByAreaBranchDetailModel> MonitoringSummary = new List<MonitoringSummary_API_Wrapper.GetByAreaBranchDetailModel>();
        if(GroupBy == 'Branch' && Area == 'Cabang'){
            String cond = 'Area__c != \'Kantor Pusat\' and Branch_Unit__c != null';
            String addfield = ',Anomali_Category__r.RecordType.Name,Anomali_Category__r.Name,User__r.Name';
            String allfield = SOQL_SOBJECT.getallfield('Monitoring_Summary__c');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Monitoring_Summary__c', cond, 'Date__c', 'ASC', '');
            List<Monitoring_Summary__c> listms = Database.query(queries);
            if(!listms.isEmpty()){
                for(Monitoring_Summary__c ms:listms){
                    //Datetime dt = ms.Date__c;
                    MonitoringSummary_API_Wrapper.GetByAreaBranchDetailModel msdt = new MonitoringSummary_API_Wrapper.GetByAreaBranchDetailModel();
                    msdt.Tanggal = String.valueOf(ms.Date__c);
                    msdt.AnomalyCategory_RecordType = ms.Anomali_Category__r.RecordType.Name;
                    msdt.Area = ms.Area__c;
                    msdt.Sub_Area = ms.Sub_Area__c;
                    msdt.Branch_Unit = ms.Branch_Unit__c;
                    msdt.AnomalyCategory_Name = ms.Anomali_Category__r.Name;
                    msdt.MonitoringSummary_Name = ms.Name;
                    msdt.User_Name = ms.User__r.Name;
                    msdt.Total = String.valueOf(ms.Total__c);
                    MonitoringSummary.add(msdt);
                }
                rc = maprc?.get('Success');
            }
            else{
                rc = maprc?.get('Data_Not_Found');
            }
        }else {
            rc = maprc?.get('Mandatory');
        }
        jres.MonitoringSummary = MonitoringSummary;
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        String return_json = MonitoringSummary_API_Ctrl.returnAPIGetByAreaBranch(jres);
        return return_json;
    }

    Public Static String returnAPIGetByAreaBranch(MonitoringSummary_API_Wrapper.GetByAreaBranchResponseModel jres){
        String return_json = '';
        return_json = (String) JSON.serialize(jres,false);
        return_json = return_json.normalizeSpace().trim(); 
        return return_json;
    }
}