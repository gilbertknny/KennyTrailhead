/**
* @description       : Service Brizzi Partner Trx History
* @last modified on  : 06/02/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_Brizzi_PartnerTrxHistory {
    @TestVisible
    private static Boolean useDummyResponseInTest = false;

    public static SCC_BrizziWrapper.CardHistoryPartnerResponse searchPtrTrxHistory(SCC_BrizziWrapper.CardHistoryPartnerRequest cdh,String menu,String recid){
        SCC_BrizziWrapper.CardHistoryPartnerResponse cps = new  SCC_BrizziWrapper.CardHistoryPartnerResponse();

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
        String jsonBodyI = 'data=' + EncodingUtil.urlEncode('[{"cardNumber": "' + cdh.data[0].cardNumber + '", "userMaker": "' + cdh.data[0].userMaker + '", "limit": "' + cdh.data[0].limits + '", "offset": "' + cdh.data[0].offset + '"}]', 'UTF-8');
        system.debug('jsonBodyI = '+jsonBodyI);

        SCC_API.WrapperRequest wr = setWrapperRequest(jsonBodyI, 'Brizzi_Partner_History', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody();
            cps = (SCC_BrizziWrapper.CardHistoryPartnerResponse) JSON.deserialize(rbody, SCC_BrizziWrapper.CardHistoryPartnerResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
            cps = Object_Test_Brizzi.ptrTrxHistoryResponse();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_Brizzi_PartnerTrxHistory';
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