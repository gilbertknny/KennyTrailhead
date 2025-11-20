public with sharing class SCC_Rekon {
    public static SCC_RekonWrapper.ResponseRekon searchRekon(SCC_RekonWrapper.RequestRekon cdh,String calltype){
        SCC_RekonWrapper.ResponseRekon cps = new  SCC_RekonWrapper.ResponseRekon();
        String cond = 'MasterLabel=:calltype';
        String addfield = ',SCC_Rekon__R.DeveloperName';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Call_Type_Maping__mdt');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SCC_Call_Type_Maping__mdt', cond, '', '', '1');
        SCC_Call_Type_Maping__mdt ctm = Database.query(queries);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI(ctm?.SCC_Rekon__R?.DeveloperName, JSON.serialize(cdh,true),'','SCC_Rekon');
        try{
        	Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('RESPONSE_DATA')))){
                cps = (SCC_RekonWrapper.ResponseRekon) JSON.deserialize(wapi.res.getBody(), SCC_RekonWrapper.ResponseRekon.class);
            }
            else{
                cps.ERROR_CODE = String.valueOf(mapres.get('ERROR_CODE'));
                cps.RESPONSE_CODE = String.valueOf(mapres.get('RESPONSE_CODE'));
                cps.RESPONSE_MESSAGE = String.valueOf(mapres.get('RESPONSE_MESSAGE'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_Rekon')); 
        }
        return cps;
    }

    public static SCC_RekonWrapper.ResponseBeritaAcaraOpname searchBAO(SCC_RekonWrapper.RequestBeritaAcaraOpname cdh){
        SCC_RekonWrapper.ResponseBeritaAcaraOpname cps = new  SCC_RekonWrapper.ResponseBeritaAcaraOpname();
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('RekonBeritaAcaraOpname', JSON.serialize(cdh,true),'','SCC_Rekon');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('RESPONSE_DATA')))){
                cps = (SCC_RekonWrapper.ResponseBeritaAcaraOpname) JSON.deserialize(wapi.res.getBody(), SCC_RekonWrapper.ResponseBeritaAcaraOpname.class);
            }
            else{
                cps.ERROR_CODE = String.valueOf(mapres.get('ERROR_CODE'));
                cps.RESPONSE_CODE = String.valueOf(mapres.get('RESPONSE_CODE'));
                cps.RESPONSE_MESSAGE = String.valueOf(mapres.get('RESPONSE_MESSAGE'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_Rekon')); 
        }
        return cps;
    }

    @AuraEnabled
    public static SCC_RekonWrapper.ResponseFlagDataRekon flagDataRekon(SCC_RekonWrapper.RequestFlagDataRekon cdh){
        SCC_RekonWrapper.ResponseFlagDataRekon cps = new  SCC_RekonWrapper.ResponseFlagDataRekon();
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('FlagDataRekon', JSON.serialize(cdh,true),'','SCC_Rekon');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapres.get('RESPONSE_DATA')))){
                cps = (SCC_RekonWrapper.ResponseFlagDataRekon) JSON.deserialize(wapi.res.getBody(), SCC_RekonWrapper.ResponseFlagDataRekon.class);
            }
            else{
                cps.ERROR_CODE = String.valueOf(mapres.get('ERROR_CODE'));
                cps.RESPONSE_CODE = String.valueOf(mapres.get('RESPONSE_CODE'));
                cps.RESPONSE_MESSAGE = String.valueOf(mapres.get('RESPONSE_MESSAGE'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_Rekon')); 
        }
        return cps;
    }

    //@future (callout=true)
    public static SCC_RekonWrapper.ResponseFlagDataRekon flagDataRekonFuture(List<SCC_Rekon__c> listrek, String csid,String tgl){
        String kode ='';
        String cond = 'id=:csid ';
        String allfield = SOQL_SOBJECT.getallfield('case');
        String addfield = ',(select '+SOQL_SOBJECT.getallfield('SCC_Rekon__c')+' FROM SCC_Rekon__r)';
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        SCC_RekonWrapper.RequestFlagDataRekon req = new SCC_RekonWrapper.RequestFlagDataRekon();
        SCC_RekonWrapper.ResponseFlagDataRekon res = new  SCC_RekonWrapper.ResponseFlagDataRekon();
        List<String> listuuid = new List<String>();
        try{
            Case cs = Database.query(queries);
            req.NoTicket = cs.CaseNumber;
            req.TransactionDate = tgl;//String.valueof(cs.SCC_Transaction_Date__c);
            if(!listrek.isempty()){
                for(SCC_Rekon__c sr:listrek){
                    req.Status = sr.SCC_Table_Rekon__c;
                    listuuid.add(sr.scc_uuid__c);
                }
            }
            req.UUID = listuuid;
            res = FlagDataRekon(req);
            //kode = res.RESPONSE_CODE;
        }
        catch (Exception exc) {
            SCC_API.InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),new SCC_API.WrapperError('','SCC_Rekon')); 
        }
        return res;
    }

    @AuraEnabled
    public static SCC_RekonWrapper.RekonTokenResponse searchRekonToken(SCC_RekonWrapper.RekonTokenRequest cdh,String menu,String recid){
        SCC_RekonWrapper.RekonTokenResponse cps = new  SCC_RekonWrapper.RekonTokenResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'RekonToken', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        //SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('RekonToken',JSON.serialize(cdh, true), '', 'SCC_Rekon');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            System.debug('mapres 1 = '+ mapres);
            if(String.valueOf(mapres.get('responseCode'))=='00'){
                System.debug('mapres 2 = '+ mapres);
                System.debug('mapres 3 = '+ mapres.get('responseData'));
                cps = (SCC_RekonWrapper.RekonTokenResponse) JSON.deserialize(wapi.res.getBody(), SCC_RekonWrapper.RekonTokenResponse.class);
                //System.debug('cps = '+ cps);
            }
            else{
                cps.errorCode = String.valueOf(mapres.get('errorCode'));
                cps.responseCode = String.valueOf(mapres.get('responseCode'));
                cps.responseMessage = String.valueOf(mapres.get('responseMessage'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        // if(label.Dummy_Response=='true'){
        //     cps = Object_Test3.setRekonTokenResponse();
        // }
        System.debug('CPS New Rekon : '+ cps);
        return cps;
    }

    @AuraEnabled
    public static SCC_RekonWrapper.RekonTokenEdcResponse searchRekonTokenEdc(SCC_RekonWrapper.RekonTokenEdcRequest cdh, String menu, String recid){
        SCC_RekonWrapper.RekonTokenEdcResponse cps = new SCC_RekonWrapper.RekonTokenEdcResponse();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'RekonToken', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('RekonToken',JSON.serialize(cdh, true), '', 'SCC_Rekon');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            System.debug('mapres 1 = '+ mapres);
            if(String.valueOf(mapres.get('responseCode'))=='00'){
                System.debug('mapres 2 = '+ mapres);
                System.debug('mapres 3 = '+ mapres.get('responseData'));
                cps = (SCC_RekonWrapper.RekonTokenEdcResponse) JSON.deserialize(wapi.res.getBody(), SCC_RekonWrapper.RekonTokenEdcResponse.class);
                //System.debug('cps = '+ cps);
            }
            else{
                cps.errorCode = String.valueOf(mapres.get('errorCode'));
                cps.responseCode = String.valueOf(mapres.get('responseCode'));
                cps.responseMessage = String.valueOf(mapres.get('responseMessage'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }

        System.debug('CPS New Rekon Edc : '+ cps);
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_Rekon';
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