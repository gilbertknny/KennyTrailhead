public with sharing class SCC_CaseResolution_CHMSupport {
    public static SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse searchInquiryRoleUser(SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMRequest cdh){
        SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse cps = new  SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse();
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('CHMSupportInquiryRoleUserCHM', JSON.serialize(cdh,true),'','SCC_CaseResolution_CHMSupport');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('data')))){
                cps = (SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse.class);
            }
            else{
                cps.code = Integer.valueOf(mapres.get('code'));
                cps.message = String.valueOf(mapres.get('message'));
                cps.status = Boolean.valueOf(mapres.get('status'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResolution_CHMSupport')); 
        }
        return cps;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse searchTerminalID(SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDRequest cdh){
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse cps = new  SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse();
        String bd =  JSON.serialize(cdh,true);
        bd = bd.replace('"dates"', '"date"');
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('CHMSupportGetTerminalIDData', bd,'','SCC_CaseResolution_CHMSupport');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('data')))){
                cps = (SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse.class);
            }
            else{
                cps.code = Integer.valueOf(mapres.get('code'));
                cps.message = String.valueOf(mapres.get('message'));
                cps.status = Boolean.valueOf(mapres.get('status'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResolution_CHMSupport')); 
        }
        return cps;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse searchTerminalIDList(SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListRequest cdh){
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse cps = new  SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse();
        String bd =  JSON.serialize(cdh,true);
        bd = bd.replace('"dates"', '"date"');
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('CHMSupportGetTerminalIDList', bd,'','SCC_CaseResolution_CHMSupport');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('data')))){
                cps = (SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse.class);
            }
            else{
                cps.code = Integer.valueOf(mapres.get('code'));
                cps.message = String.valueOf(mapres.get('message'));
                cps.status = Boolean.valueOf(mapres.get('status'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResolution_CHMSupport')); 
        }
        return cps;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse paymentResolution(SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceRequest cdh){
        SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse tkn = GenerateTokenCHMS();
        SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse cps = new  SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse();
        String bd =  JSON.serialize(cdh,true);
        bd = bd.replace('"curency"', '"currency"');
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('CHMSupportPaymentResolutionService', bd,tkn?.data?.token,'SCC_CaseResolution_CHMSupport');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('data')))){
                cps = (SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse.class);
            }
            else{
                cps.code = Integer.valueOf(mapres.get('code'));
                cps.message = String.valueOf(mapres.get('message'));
                cps.status = Boolean.valueOf(mapres.get('status'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResolution_CHMSupport')); 
        }
        return cps;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse generateTokenCHMS(){
        SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse cps = new  SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse();
        SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSRequest cdh = new SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSRequest();
        SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance('CHMSupportGenerateTokenCHMS');
        cdh.client_id = eapi.client_id__c;
        cdh.client_secret = eapi.client_secret__c;
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('CHMSupportGenerateTokenCHMS', JSON.serialize(cdh,true),'','SCC_CaseResolution_CHMSupport');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('data')))){
                cps = (SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse.class);
            }
            else{
                cps.code = Integer.valueOf(mapres.get('code'));
                cps.message = String.valueOf(mapres.get('message'));
                cps.status = Boolean.valueOf(mapres.get('status'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResolution_CHMSupport')); 
        }
        return cps;
    }

    //@future(callout=true)
    public static void pembukuanFuture(String csid){
        String cond = 'SCC_Case__c=:csid ';
        String addfield = ',SCC_Case__r.SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Case__r.SCC_Call_Type__r.name,SCC_Case__r.SCC_Call_Type__r.External_id__c,SCC_Case__r.SCC_Transaction_Date__c,SCC_Case__r.terminal_id__r.name,SCC_Case__r.Casenumber';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Queuetrans__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SCC_Queuetrans__c', cond, '', '', '');
        Case dtcs = [SELECT SCC_Nomor_Briva_Tagihan__c FROM Case WHERE Id = :csid LIMIT 1];
        String brivaNum = dtcs.SCC_Nomor_Briva_Tagihan__c;
        System.debug('BrivaNum :'+BrivaNum);
        SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceRequest req = new SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceRequest();
        integer i = 1;
        try {
            List<SCC_Queuetrans__c> listque = Database.query(queries);
            for(SCC_Queuetrans__c qt:listque){
                req.branchcode = qt.branchcode__c; //scc_branchcode__c
                req.no_tt = qt.SCC_Case__r.Casenumber;
                req.fitur_id = qt?.SCC_Case__r?.SCC_Call_Type_Feature__r?.Fitur_ID__c;//scc_fitur_id__c;
                req.trx_date = String.valueof(qt?.SCC_Case__r?.SCC_Transaction_Date__c);
                req.terminal_id = qt?.SCC_Case__r?.terminal_id__r.name;
                String ctnum = '';
                if(String.isnotblank(qt?.SCC_Case__r?.SCC_Call_Type__r.Name)){
                   ctnum =  qt?.SCC_Case__r?.SCC_Call_Type__r.Name.substringbefore('-').trim();
                }
                if(String.isNotBlank(qt?.SCC_Case__r?.SCC_Call_Type__r.External_Id__c)){
                    ctnum = qt?.SCC_Case__r?.SCC_Call_Type__r.External_Id__c;
                }
                req.calltype = ctnum;
                if(i>5){
                    break;
                }
                if(i==5){
                    req.acct_debet5 = qt.scc_acct_debet5__c;
                    req.acct_kredit5 = qt.scc_acct_kredit5__c;
                    req.amt_debet5 = qt.scc_amt_debet5__c;
                    req.amt_kredit5 = qt.scc_amt_kredit5__c;
                }
                else if(i==4){
                    req.acct_debet4 = qt.scc_acct_debet4__c;
                    req.acct_kredit4 = qt.scc_acct_kredit4__c;
                    req.amt_debet4 = qt.scc_amt_debet4__c;
                    req.amt_kredit4 = qt.scc_amt_kredit4__c;
                }
                else if(i==3){
                    req.acct_debet3 = qt.scc_acct_debet3__c;
                    req.acct_kredit3 = qt.scc_acct_kredit3__c;
                    req.amt_debet3 = qt.scc_amt_debet3__c;
                    req.amt_kredit3 = qt.scc_amt_kredit3__c;
                }
                else if(i==2){
                    req.acct_debet2 = qt.scc_acct_debet2__c;
                    req.acct_kredit2 = qt.scc_acct_kredit2__c;
                    req.amt_debet2 = qt.scc_amt_debet2__c;
                    req.amt_kredit2 = qt.scc_amt_kredit2__c;
                }
                else if(i==1){
                    req.acct_debet1 = qt.scc_acct_debet1__c;
                    if(String.isEmpty(BrivaNum)){
                        req.acct_kredit1 = qt.scc_acct_kredit1__c;
                    }else{
                        req.acct_kredit1 = BrivaNum;
                    }
                    req.amt_debet1 = qt.scc_amt_debet1__c;
                    req.amt_kredit1 = qt.scc_amt_kredit1__c;
                }
                i++;
            }
            
            SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse res = SCC_CaseResolution_CHMSupport.PaymentResolution(req);
            for(SCC_Queuetrans__c qt:listque){
                qt.SCC_Status__c = res?.message;
            }
            update listque;
            Case cs = new Case();
            cs.id = csid;
            cs.SCC_Result_Pembukuan__c = res?.message;
            String statusBuku = res?.message;
            if(StatusBuku.contains('Success')){
                cs.Status = 'Closed';
                cs.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                cs.SCC_Closure_Comments__c = label.Closed_CHM;
                cs.SCC_Status_Pembukuan__c = true;
            }
            update cs;
        } 
        catch (Exception exc) {
            SCC_API.InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),new SCC_API.WrapperError('','SCC_CaseResolution_CHMSupport')); 
        }
    }

    @future(callout=true)
    public static void checkTerminal(String csid){
        try{
            String cond = 'id=:csid ';
            String addfield = '';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '1');
            Case cs = Database.query(queries);
            String dt = String.valueOf(cs.SCC_Waktu_Transaksi__c.date()).substringBefore('T');
            CustomLookupController.RecordsData rd = CustomLookupController.GetDataDetail(dt, cs.SCC_Terminal_ID__c);
            cs.terminal_id__c = rd?.value; 
            update cs;
        }
        catch(Exception exc){
            SCC_API.InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),new SCC_API.WrapperError('','SCC_CaseResolution_CHMSupport')); 
        }
    }
}