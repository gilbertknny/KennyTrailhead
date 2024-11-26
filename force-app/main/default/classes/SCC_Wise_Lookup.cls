/**
 * @description       : 
 * @author            : Dwiki Cahyo
 * @group             : 
 * @last modified on  : 09-11-2024
 * @last modified by  : Dwiki Cahyo
**/
public with sharing class SCC_Wise_Lookup {
    public static SCC_WiseWrapper.ResponseWiLookup getWorkingInstructionLookup(String path){
        String metaWi = 'Lookup_WI';
        String classWi = 'SCC_Wise_Lookup_WI';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseWiLookup resWi = new SCC_WiseWrapper.ResponseWiLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                resWi = (SCC_WiseWrapper.ResponseWiLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseWiLookup.class);
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }

    public static SCC_WiseWrapper.ResponseProgramLookup getProgramLookup(String path){
        String metaWi = 'Lookup_Program';
        String classWi = 'SCC_Wise_Lookup_Program';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseProgramLookup resWi = new SCC_WiseWrapper.ResponseProgramLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
           
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                Map<String, Object> dataMap = (Map<String, Object>) mapResponse.get('data');
                resWi = (SCC_WiseWrapper.ResponseProgramLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseProgramLookup.class);
                //get end date
                if (dataMap.containsKey('end')) {
                    resWi.data.ends = (String) dataMap.get('end');
                }
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }

    public static SCC_WiseWrapper.ResponsePromoLookup getPromoLookup(String path){
        String metaWi = 'Lookup_Promo';
        String classWi = 'SCC_Wise_Lookup_Promo';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponsePromoLookup resWi = new SCC_WiseWrapper.ResponsePromoLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                Map<String, Object> dataMap = (Map<String, Object>) mapResponse.get('data');
                resWi = (SCC_WiseWrapper.ResponsePromoLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponsePromoLookup.class);
                
                if (dataMap.containsKey('end')) {
                    resWi.data.ends = (String) dataMap.get('end');
                }
           
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }

    public static SCC_WiseWrapper.ResponseProdukLookup getProdukLookup(String path){
        String metaWi = 'Lookup_Produk';
        String classWi = 'SCC_Wise_Lookup_Produk';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseProdukLookup resWi = new SCC_WiseWrapper.ResponseProdukLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                Map<String, Object> dataMap = (Map<String, Object>) mapResponse.get('data');
                resWi = (SCC_WiseWrapper.ResponseProdukLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseProdukLookup.class);
                
                if(dataMap.containsKey('limit')){
                    resWi.data.limits = (String) datamap.get('limit');
                }
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }
}