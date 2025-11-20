/**
* @description       : Service Brizzi Card Inquiry
* @last modified on  : 17/01/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_Brizzi_CardInquiry {

    public static SCC_BrizziWrapper.CardInquiryResponse searchCard(SCC_BrizziWrapper.CardInquiryRequest cdh,String mdh,String menu,String recid){
        SCC_BrizziWrapper.CardInquiryResponse cps = new  SCC_BrizziWrapper.CardInquiryResponse();

        // Create the custom JSON structure
        Map<String, Object> requestBody = new Map<String, Object>();
        
        // First deserialize to a map
        Map<String, Object> deserializedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cdh));
        List<Object> dataList = (List<Object>)deserializedMap.get('data');
        requestBody.put('data', dataList);
        
        // Convert to string with the desired format
        String jsonBody = 'data=' + JSON.serialize(dataList, false);

        //update json body x-form-urlencoded
        String jsonBodyI = 'data=' + EncodingUtil.urlEncode('[{"cardNumber": "' + cdh.data[0].cardNumber + '", "userMaker": "' + cdh.data[0].userMaker + '"}]', 'UTF-8');
        system.debug('jsonBodyI = '+jsonBodyI);
        SCC_API.WrapperRequest wr = setWrapperRequest(jsonBodyI, 'Brizzi_Inquiry', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody();
            cps = (SCC_BrizziWrapper.CardInquiryResponse) JSON.deserialize(rbody, SCC_BrizziWrapper.CardInquiryResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test_Brizzi.cardInquiryResponse();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_Brizzi_CardInquiry';
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