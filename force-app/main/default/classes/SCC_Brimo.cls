public with sharing class SCC_Brimo {
    public static SCC_Brimo_Wrapper.ResponseInquiryUserBrimo searchUserBrimo(SCC_Brimo_Wrapper.RequestBrimo cdh,String menu,String recid){
        SCC_Brimo_Wrapper.ResponseInquiryUserBrimo cps = new  SCC_Brimo_Wrapper.ResponseInquiryUserBrimo();
        BRIMO__c br = BRIMO__c.getinstance('inquiry user brimo');
        cdh.request_refnum = setreffnum(Integer.valueOf(br.request_refnum__c));
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'BRImoInquiryUser', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            br.request_refnum__c = decimal.valueOf(cdh.request_refnum);
            update br;
            String rbody = wapi.res.getBody();
            cps = (SCC_Brimo_Wrapper.ResponseInquiryUserBrimo) JSON.deserialize(rbody, SCC_Brimo_Wrapper.ResponseInquiryUserBrimo.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test2.setResponseInquiryUserBrimo();
        }
        return cps;
    }

    public static SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo searchOnboardingBrimo(SCC_Brimo_Wrapper.RequestBrimo cdh,String menu,String recid){
        SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo cps = new  SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo();
        BRIMO__c br = BRIMO__c.getinstance('inquiry onboarding brimo');
        cdh.request_refnum = setreffnum(Integer.valueOf(br.request_refnum__c));
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'BRImoInquiryOnboarding', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            br.request_refnum__c = decimal.valueOf(cdh.request_refnum);
            update br;
            String rbody = wapi.res.getBody();
            cps = (SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo) JSON.deserialize(rbody, SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test2.setResponseInquiryOnboardingBrimo();
        }
        return cps;
    }

    public static SCC_Brimo_Wrapper.ResponseDeleteUserBrimo deleteUserBrimo(SCC_Brimo_Wrapper.RequestBrimo cdh,String menu,String recid){
        SCC_Brimo_Wrapper.ResponseDeleteUserBrimo cps = new  SCC_Brimo_Wrapper.ResponseDeleteUserBrimo();
        BRIMO__c br = BRIMO__c.getinstance('delete user brimo');
        cdh.request_refnum = setreffnum(Integer.valueOf(br.request_refnum__c));
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'BRImoDeleteUser', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            br.request_refnum__c = decimal.valueOf(cdh.request_refnum);
            update br;
            String rbody = wapi.res.getBody();
            cps = (SCC_Brimo_Wrapper.ResponseDeleteUserBrimo) JSON.deserialize(rbody, SCC_Brimo_Wrapper.ResponseDeleteUserBrimo.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        if(label.Dummy_Response=='true'){
            cps = Object_Test2.setResponseDeleteUserBrimo();
        }
        return cps;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_Brimo';
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

    public static String setreffnum(Integer num){
        String x = String.valueOf(num+1);
        String y = x.leftPad(12, '0');
        return y;
    }
}