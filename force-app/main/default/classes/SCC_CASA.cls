/**
 * @description       : CASA API Class
 * @author            : Femy
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
public with sharing class SCC_CASA {
    /*
    public static SCC_CASA_Wrapper.OauthCasaResponse OauthCasa(String menu,String recid){
        SCC_CASA_Wrapper.OauthCasaResponse ores = new SCC_CASA_Wrapper.OauthCasaResponse();
        SCC_CASA_Wrapper.OauthCasaRequest oreq = new SCC_CASA_Wrapper.OauthCasaRequest();
        SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance('casaOauth');
        oreq.client_id = eapi.client_id__c;
        oreq.client_secret = eapi.client_secret__c;
        oreq.grant_type = eapi.grant_type__c;
        oreq.scope = eapi.scope__c;
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(oreq,true), 'casaOauth', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody();
            ores = (SCC_CASA_Wrapper.OauthCasaResponse) JSON.deserialize(rbody, SCC_CASA_Wrapper.OauthCasaResponse.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            //cps = Object_Test.CustomerProfileResponse();
        }
        return ores;
    }
    */
    public static SCC_CASA_Wrapper.ResponseHoldAmount holdAmount(SCC_CASA_Wrapper.DetailRequestHoldAmount reqdt,String menu,String recid){
        String tellerid = getTellerId('051');
        BRIMO__c br = BRIMO__c.getinstance('extidCasaHold');
        reqdt.externalId  = setreffnum(Integer.valueOf(br.request_refnum__c));
        reqdt.serviceId = '0002S';
        reqdt.channelId = 'CHMS';
        reqdt.tellerId = label.TellerId_Hold;
        reqdt.holdType = 'HG';
        reqdt.tellerHold = label.TellerId_Hold; //(tellerid.startsWith('0000')) ?  '' : tellerid;
        SCC_CASA_Wrapper.RequestHoldAmount cdh = new SCC_CASA_Wrapper.RequestHoldAmount();
        cdh.request = reqdt;
        SCC_CASA_Wrapper.ResponseHoldAmount cps = new  SCC_CASA_Wrapper.ResponseHoldAmount();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'casaHoldAmount', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            updateRefferenceId(br, Decimal.valueOf(reqdt.externalId));
            String rbody = wapi.res.getBody();
            cps = (SCC_CASA_Wrapper.ResponseHoldAmount) JSON.deserialize(rbody, SCC_CASA_Wrapper.ResponseHoldAmount.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test2.setResponseHoldAmount();
        }
        return cps;
    }

    public static SCC_CASA_Wrapper.ResponseUnholdAmount unholdAmount(SCC_CASA_Wrapper.DetailRequestUnholdAmount reqdt,String menu,String recid){
        String tellerid = getTellerId('891');
        BRIMO__c br = BRIMO__c.getinstance('extidCasaUnhold');
        reqdt.externalId  = setreffnum(Integer.valueOf(br.request_refnum__c));
        reqdt.serviceId = '0002M';
        reqdt.channelId = 'CHMS';
        reqdt.tellerId = label.TellerId_Hold; //tellerid;
        SCC_CASA_Wrapper.RequestUnholdAmount cdh = new SCC_CASA_Wrapper.RequestUnholdAmount();
        cdh.request = reqdt;
        SCC_CASA_Wrapper.ResponseUnholdAmount cps = new  SCC_CASA_Wrapper.ResponseUnholdAmount();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'casaUnholdAmount', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            updateRefferenceId(br, Decimal.valueOf(reqdt.externalId));
            String rbody = wapi.res.getBody();
            cps = (SCC_CASA_Wrapper.ResponseUnholdAmount) JSON.deserialize(rbody, SCC_CASA_Wrapper.ResponseUnholdAmount.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test2.setResponseUnholdAmount();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_CASA';
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

    public static String getTellerId(String kode){
        User us = [select id,BranchCode__c,SCC_HILFM__c from user where id=:UserInfo.getUserId()];
        String jbt = String.isNotBlank(us?.SCC_HILFM__c) ? us?.SCC_HILFM__c : kode;
        String tellerid = us.BranchCode__c.right(4)+jbt;
        return tellerid;
    }

    public static String setreffnum(Integer num){
        String x = String.valueOf(num+1);
        String y = x.leftPad(10, '0');
        return y;
    }

    public static void updateRefferenceId(BRIMO__c br,Decimal reffnum){
        br.request_refnum__c = reffnum;
        update br;
    }
}