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
}