/**
* @description       : Service Brizzi Card Change
* @last modified on  : 22/01/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_Brizzi_CardChange {
    public static SCC_BrizziWrapper.CardChangeResponse changeCard(SCC_BrizziWrapper.CardChangeRequest cdh, String menu, String csid){
        SCC_BrizziWrapper.CardChangeResponse cps = new  SCC_BrizziWrapper.CardChangeResponse();

         // Create the custom JSON structure
        Map<String, Object> requestBody = new Map<String, Object>();
        
        // First deserialize to a map
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cdh));
        List<Object> dataList = (List<Object>)deserializedMap.get('data');
        requestBody.put('data', dataList);
        
        // Convert to string with the desired format
        String jsonBody = 'data=' + JSON.serialize(dataList, false);
        system.debug('jsonBodyI = '+jsonBody);
        //update json body x-form-urlencoded
        String jsonBodyI = 'data=' + EncodingUtil.urlEncode('[{"oldCardNumber": "' + cdh.data[0].oldCardNumber + '", "newCardNumber": "' + cdh.data[0].newCardNumber + '", "oldCardBalance": "' + cdh.data[0].oldCardBalance + '", "userMaker": "' + cdh.data[0].userMaker + '", "userSigner": "' + cdh.data[0].userSigner + '"}]', 'UTF-8');
        system.debug('jsonBodyI = '+jsonBodyI);
        SCC_API.WrapperRequest wr = setWrapperRequest(jsonBody, 'Brizzi_Change', menu, csid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody();
            cps = (SCC_BrizziWrapper.CardChangeResponse) JSON.deserialize(rbody, SCC_BrizziWrapper.CardChangeResponse.class);
        }
        catch(exception exc){
            SCC_API.insertErrorLog(exc,wapi.req,wapi.res,new SCC_API.WrapperError(wapi.urlCurrent,'SCC_Brizzi_CardChange')); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test_Brizzi.cardChangeResponse();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_Brizzi_CardChange';
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