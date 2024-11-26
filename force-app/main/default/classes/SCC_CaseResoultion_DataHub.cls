public with sharing class SCC_CaseResoultion_DataHub {
    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse searchCustomerProfile(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'DataHubCustomerProfile', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            cps = (SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CustomerProfileResponse();
        }
        return cps;
    }
    
    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse searchSavingMutation(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'EDMSavingMutation', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            cps = (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.SavingMutationResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse searchSavingStatement(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'EDMSavingStatement', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            cps = (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.SavingMutationResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse cardLinkCardNumber(SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
        clr.cardNumber = cdh.cardNumber;
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), 'DataHubCardlinkCardNumber', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody()) ;
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('response')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
                cps.responseCode = String.valueOf(mapres.get('responseCode'));
                cps.responseDesc = String.valueOf(mapres.get('responseDesc'));
                cps.responseMessage = String.valueOf(mapres.get('responseMessage'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CardLinkCardNumberResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse cardLinkPhoneNumber(SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
        clr.phoneNumber = cdh.phoneNumber;
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), 'DataHubCardlinkPhoneNumber', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody()) ;
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('response')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
                cps.responseCode = String.valueOf(mapres.get('responseCode'));
                cps.responseDesc = String.valueOf(mapres.get('responseDesc'));
                cps.responseMessage = String.valueOf(mapres.get('responseMessage'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CardLinkPhoneNumberResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse cardLinkNIK(SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
        clr.nik = cdh.nik;
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), 'DataHubCardlinkNIK', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody()) ;
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('response')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
                cps.responseCode = String.valueOf(mapres.get('responseCode'));
                cps.responseDesc = String.valueOf(mapres.get('responseDesc'));
                cps.responseMessage = String.valueOf(mapres.get('responseMessage'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CardLinkNIKResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse cardLinkCustomerNumber(SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
        clr.customerNumber = cdh.customerNumber;
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), 'DataHubCardLinkCustomerNumber', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody()) ;
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('response')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
                cps.responseCode = String.valueOf(mapres.get('responseCode'));
                cps.responseDesc = String.valueOf(mapres.get('responseDesc'));
                cps.responseMessage = String.valueOf(mapres.get('responseMessage'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CardLinkCustomerNumberResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse briLinkProfile(SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse();
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest();
        if(String.isnotblank(cdh.tid)){
            clr.tid = cdh.tid;
        }
        if(String.isnotblank(cdh.mid)){
            clr.mid = cdh.mid;
        }
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('BRILINK_PROFILE')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
           cps = Object_Test.BRILinkProfileResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne merchantProfile(SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne cps = new  SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne();
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest();
        if(String.isnotblank(cdh.tid)){
            clr.tid = cdh.tid;
        }
        if(String.isnotblank(cdh.mid)){
            clr.mid = cdh.mid;
        }
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('MERCHANT_PROFILE')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
           cps = Object_Test.MerchantProfileResposne();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse dplk(SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse();
        SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest();
        if(String.isnotblank(cdh.acctNo)){
            clr.acctNo = cdh.acctNo;
        }
        if(String.isnotblank(cdh.idNumber)){
            clr.idNumber = cdh.idNumber;
        }
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('SI_DPLK'))) || String.isNotBlank(String.valueOf(mapres.get('TRX_DPLK')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
           cps = Object_Test.DPLKResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse cardActivity(SCC_CaseResoultion_DataHub_Wrapper.CardActivityRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody();
            cps = (SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
           cps = Object_Test.CardActivityResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse pctd(SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('CPAHF')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
           cps = Object_Test.PCTDResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse searchDataMachine(SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse();
        SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest();
        if(String.isnotblank(cdh.alamatMesin)){
            clr.alamatMesin = cdh.alamatMesin;
        }
        /*
        if(String.isnotblank(cdh.tid)){
            clr.tid = cdh.tid;
        }
        */
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('machineDataByAddress')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.DataMachineResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse cardApplication(SCC_CaseResoultion_DataHub_Wrapper.CardApplicationRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'DataHubCardApplication', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('CUSTPERSONAL')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CardApplicationResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse briMola(SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse();
        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest();
        if(String.isnotblank(cdh.idPangkalan)){
            clr.idPangkalan = cdh.idPangkalan;
        }
        if(String.isnotblank(cdh.startDate)){
            clr.startDate = cdh.startDate;
        }
        if(String.isnotblank(cdh.endDate)){
            clr.endDate = cdh.endDate;
        }
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            rbody = rbody.replace('"desc"', '"descr"');
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('chmGraphql')))){
                Map<String,Object> mapres1 = (Map<String, Object>) mapres.get('chmGraphql');
                if(mapres1.containsKey('inquiryBrimolaPangkalan')){
                    Map<String,Object> mapres2 = (Map<String, Object>) mapres1.get('inquiryBrimolaPangkalan');
                    if(String.valueOf(mapres2.get('rc'))=='00' || String.valueOf(mapres2.get('descr'))=='Success'){
                        cps = (SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse.class);
                    }
                    else{
                        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaIdPangkalan bm = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaIdPangkalan();
                        bm.descr = String.valueOf(mapres2.get('descr'));
                        bm.rc = String.valueOf(mapres2.get('rc'));
                        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaInquiry bmi = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaInquiry();
                        bmi.inquiryBrimolaPangkalan = bm;
                        cps.chmGraphql = bmi;
                    }    
                }
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.BRIMolaResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardResponse cardDetailDebit(SCC_CaseResoultion_DataHub_Wrapper.CardRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.CardResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.CardResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'DataHubCardDebitDetail', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            rbody = rbody.replace('"data "', '"data"');
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(rbody);
            if(String.isNotBlank(String.valueOf(mapres.get('chmGraphql')))){
                cps = (SCC_CaseResoultion_DataHub_Wrapper.CardResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.CardResponse.class);
            }
            else{
                cps.error = String.valueOf(mapres.get('error'));
                cps.path = String.valueOf(mapres.get('path'));
                cps.code = String.valueOf(mapres.get('code'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.CardResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse trxMerchant(SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest cdh,String mdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse();
        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest clr = new SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest();
        if(String.isnotblank(cdh.appCodeOrReffNum)){
            clr.appCodeOrReffNum = cdh.appCodeOrReffNum;
        }
        if(String.isnotblank(cdh.midOrMpan)){
            clr.midOrMpan = cdh.midOrMpan;
        }
        if(String.isnotblank(cdh.tidOrStoreId)){
            clr.tidOrStoreId = cdh.tidOrStoreId;
        }
        if(String.isnotblank(cdh.trxDate)){
            clr.trxDate = cdh.trxDate;
        }
        if(String.isnotblank(cdh.trxTime)){
            clr.trxTime = cdh.trxTime;
        }
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(clr,true), mdh, menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            rbody = rbody.replace('"switch"', '"switchs"');
            cps = (SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.TrxMerchantResponse();
        }
        return cps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse holdStatus(SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest cdh,String menu,String recid){
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse cps = new  SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse();
        cdh.channelId = 'CHMS';
        cdh.externalId = String.valueOf(UUID.randomUUID()) ;
        cdh.serviceId = '0002P';
        cdh.tellerId = '0206051';
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'DataHubHoldStatus', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = getreplace(wapi.res.getBody());
            cps = (SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse) JSON.deserialize(rbody, SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResoultion_DataHub')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.HoldStatusResponse();
        }
        return cps;
    }

    public static String getreplace(String rbody){
        if(rbody.contains('\""') && rbody.contains('"error"')){
            rbody = rbody.replace(' \"', ' ');
            rbody = rbody.replace('\""', '"');
        }
        return rbody;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_CaseResoultion_DataHub';
        wr.menu = menu;
        wr.metaname = metanm;
        wr.recid = recid;
        wr.token = '';
        if(String.isNotBlank(recid)){
            Id idsf = id.valueOf(recid);
            wr.objnm =  idsf.getSObjectType().getDescribe().getName();
        }
        return wr;
    }

    public static SCC_API.WrapperError setWrapperError(SCC_API.WrapperRequest wr){
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        SCC_API.WrapperError we = new SCC_API.WrapperError(urlCurrent,wr.clsName);
        we.menu = wr.menu;
        we.recid = wr.recid;
        we.objnm = wr.objnm;
        return we;
    }
}