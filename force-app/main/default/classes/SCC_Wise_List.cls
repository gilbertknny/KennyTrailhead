/**
 * @description       : 
 * @author            : Dwiki Cahyo
 * @group             : 
 * @last modified on  : 09-11-2024
 * @last modified by  : Dwiki Cahyo
**/
public with sharing class SCC_Wise_List {

    public static SCC_WiseWrapper.ResponseWorkingInstruction getWorkingInstructionList(SCC_WiseWrapper.RequestWorkingInstruction reqWi){
        String metaWi = 'Wise_WorkingInstruction';
        String classWi = 'SCC_Wise_List_WI';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseWorkingInstruction resWi = new SCC_WiseWrapper.ResponseWorkingInstruction();


        String serReqWi = JSON.serialize(reqWi,true);
        serReqWi = serReqWi.replace('"limits"', '"limit"');

        System.debug(serReqWi);
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, serReqWi, '', classWi, '');

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                System.debug('request list : ' + resultApi.req);
                resWi = (SCC_WiseWrapper.ResponseWorkingInstruction) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseWorkingInstruction.class);
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

    public static SCC_WiseWrapper.ResponseProduk getProdukList(SCC_WiseWrapper.RequestProduk reqProduk){
        String metaProduk = 'Wise_Produk';
        String classWi = 'SCC_Wise_List_Produk';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseProduk resProduk = new SCC_WiseWrapper.ResponseProduk();


        String serReqProduk = JSON.serialize(reqProduk, true);
        serReqProduk = serReqProduk.replace('"limits"', '"limit"');

        System.debug(serReqProduk);

        resultApi = SCC_Wise_API.getResponseWise(metaProduk, serReqProduk, '', classWi, '');

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                System.debug('request list : ' + resultApi.req);
                resProduk = (SCC_WiseWrapper.ResponseProduk) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseProduk.class);
            } 
            else {
                resProduk.status_code = String.valueOf(mapResponse.get('status_code'));
                resProduk.errors = String.valueOf(mapResponse.get('errors'));
                resProduk.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resProduk.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resProduk;
    }

    public static SCC_WiseWrapper.ResponseProgram getProgramList(SCC_WiseWrapper.RequestProgram reqProgram){
        String metaProgram = 'Wise_Program';
        String classWi = 'SCC_Wise_List_Program';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseProgram resProgram = new SCC_WiseWrapper.ResponseProgram();


        String serReqProgram = JSON.serialize(reqProgram, true);
        serReqProgram = serReqProgram.replace('"limits"', '"limit"');

        System.debug(serReqProgram);

        resultApi = SCC_Wise_API.getResponseWise(metaProgram, serReqProgram, '', classWi, '');

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                System.debug('request list : ' + resultApi.req);
                resProgram = (SCC_WiseWrapper.ResponseProgram) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseProgram.class);
            } 
            else {
                resProgram.status_code = String.valueOf(mapResponse.get('status_code'));
                resProgram.errors = String.valueOf(mapResponse.get('errors'));
                resProgram.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resProgram.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resProgram;
    }

    public static SCC_WiseWrapper.ResponsePromo getPromoList(SCC_WiseWrapper.RequestPromo reqPromo){
        String metaPromo = 'Wise_Promo';
        String classWi = 'SCC_Wise_List_Promo';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponsePromo resPromo = new SCC_WiseWrapper.ResponsePromo();


        String serReqPromo = JSON.serialize(reqPromo, true);
        serReqPromo = serReqPromo.replace('"limits"', '"limit"');

        System.debug(serReqPromo);

        resultApi = SCC_Wise_API.getResponseWise(metaPromo, serReqPromo, '', classWi, '');

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                System.debug('request list : ' + resultApi.req);
                resPromo = (SCC_WiseWrapper.ResponsePromo) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponsePromo.class);
            } 
            else {
                resPromo.status_code = String.valueOf(mapResponse.get('status_code'));
                resPromo.errors = String.valueOf(mapResponse.get('errors'));
                resPromo.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resPromo.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resPromo;
    }
}