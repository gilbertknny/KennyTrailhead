/**
* @description       : Service Brizzi Pembukuan
* @last modified on  : 11/02/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_Brizzi_Pembukuan_API {
    public static SCC_BrizziWrapper.BrizziPembukuanResponse doPembukuan(SCC_BrizziWrapper.BrizziPembukuanRequest cdh){
        SCC_BrizziWrapper.BrizziPembukuanResponse cps = new  SCC_BrizziWrapper.BrizziPembukuanResponse();
        String bd =  JSON.serialize(cdh,true);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('BrizziPembukuan', bd,'','SCC_Brizzi_Pembukuan_API');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            system.debug('mapres = '+mapres);
            if(String.isNotBlank(String.valueOf(mapres.get('data')))){
                cps = (SCC_BrizziWrapper.BrizziPembukuanResponse) JSON.deserialize(wapi.res.getBody(), SCC_BrizziWrapper.BrizziPembukuanResponse.class);
            }
            else{
                cps.code = Integer.valueOf(mapres.get('code'));
                cps.message = String.valueOf(mapres.get('message'));
                cps.status = Boolean.valueOf(mapres.get('status'));
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_Brizzi_Pembukuan_API')); 
        }
        return cps;
    }
}