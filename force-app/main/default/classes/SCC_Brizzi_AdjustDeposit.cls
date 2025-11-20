/**
* @description       : Service Brizzi Adjust Deposit
* @last modified on  : 22/01/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_Brizzi_AdjustDeposit {
    public static SCC_BrizziWrapper.AdjustDepositResponse adjustDeposit(SCC_BrizziWrapper.AdjustDepositRequest cdh, String menu, String csid){
        SCC_BrizziWrapper.AdjustDepositResponse cps = new  SCC_BrizziWrapper.AdjustDepositResponse();

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
        String jsonBodyI = 'data=' + EncodingUtil.urlEncode('[{"cardNumber": "' + cdh.data[0].cardNumber + '", "amount": "' + cdh.data[0].amount + '", "userMaker": "' + cdh.data[0].userMaker + '", "userSigner": "' + cdh.data[0].userSigner + '", "hostBalanceCorrection": "' + cdh.data[0].hostBalanceCorrection + '"}]', 'UTF-8');
        system.debug('jsonBodyI = '+jsonBodyI);

        SCC_API.WrapperRequest wr = setWrapperRequest(jsonBodyI, 'Brizzi_AdjustDeposit', menu, csid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody();
            cps = (SCC_BrizziWrapper.AdjustDepositResponse) JSON.deserialize(rbody, SCC_BrizziWrapper.AdjustDepositResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test_Brizzi.adjustDepositResponse();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_Brizzi_AdjustDeposit';
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