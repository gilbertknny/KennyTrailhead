/**
* @description       : Service Find RTGS
* @last modified on  : 18-02-2025
* @last modified by  : Ardyta Yudianto
**/

public with sharing class SCC_CaseResolution_FindRTGS {
    @TestVisible
    private static Boolean useDummyResponseInTest = false;

    public static SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse searchRTGS(SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest cdh,String menu,String recid){
        SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse cps = new  SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse();

        System.debug('request API = '+JSON.serialize(cdh,true));
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'Find_RTGS', menu, recid);
        System.debug('API wr = '+wr);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            System.debug('masuk 1');
            String rbody = wapi.res.getBody();
            cps = (SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse) JSON.deserialize(rbody, SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse.class);
            System.debug('cps'+ cps);
        }
        catch(exception exc){
            System.debug('masuk 2');
            SCC_API.insertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
            cps = Object_Test_RTGS.findRTGSResponse();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_CaseResolution_FindRTGS';
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