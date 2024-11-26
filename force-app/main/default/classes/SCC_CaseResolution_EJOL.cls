public with sharing class SCC_CaseResolution_EJOL {
    public static SCC_CaseResolution_EJOLWrapper.EJLogResponse searchEJ(SCC_CaseResolution_EJOLWrapper.EJLogRequest cdh){
        SCC_CaseResolution_EJOLWrapper.EJLogResponse cps = new  SCC_CaseResolution_EJOLWrapper.EJLogResponse();
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('EJOL', JSON.serialize(cdh,true),'','SCC_CaseResolution_EJOL');
        try{
            Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
            if(integer.valueOf(mapres.get('code'))==200){
                cps = (SCC_CaseResolution_EJOLWrapper.EJLogResponse) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_EJOLWrapper.EJLogResponse.class);
            }
            else{
                SCC_CaseResolution_EJOLWrapper.EJLogResponseError err = (SCC_CaseResolution_EJOLWrapper.EJLogResponseError) JSON.deserialize(wapi.res.getBody(), SCC_CaseResolution_EJOLWrapper.EJLogResponseError.class);
                cps.code = (Integer) mapres.get('code');
                cps.message = (String) mapres.get('message');
                for(SCC_CaseResolution_EJOLWrapper.EJLogData ejl : err.data){
                    cps.data = ejl;
                }
            }
        }
        catch(exception exc){
            SCC_API.insertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_CaseResolution_EJOL')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test.EJLogResponse();
        }
        return cps;
    }
}