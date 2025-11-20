public with sharing class SCC_MMS {
    

    public static SCC_MMSWrapper.ResponseCreateMMS createTicketMMS(SCC_MMSWrapper.RequestCreateMMS reqMMS){

        String metaname = 'MMS_Create_Ticket';
        String bodyReq = JSON.serialize(reqMMS, true);
        String token = '';
        String classname = 'SCC_MMS_createTicketMMS';

        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI(metaname, bodyReq, token, classname);
        SCC_MMSWrapper.ResponseCreateMMS res = new SCC_MMSWrapper.ResponseCreateMMS();

        try {
            Map<String,Object> mapres = (Map<String,Object>) JSON.deserializeUntyped(wapi.res.getBody());
            String rc = (String) mapres.get('rc');
            String descs = (String) mapres.get('desc');
            String mssg = (String) mapres.get('msg');
            Object data = (Object) mapres.get('data');

            System.debug('data qris' + data);
            if(rc == '00'){
                res = (SCC_MMSWrapper.ResponseCreateMMS) JSON.deserialize(wapi.res.getBody(), SCC_MMSWrapper.ResponseCreateMMS.class);
                res.descs = descs;
            } else {
                res.rc = rc;
                res.descs = descs;
                if(mssg != null){
                    res.msg = mssg ;
                }
                res.data = null;
            }
            
        } catch (exception exc){
            SCC_API.insertErrorLog(exc, wapi.req, wapi.res, new SCC_API.WrapperError(wapi.urlCurrent, 'SCC_MMS_createTicketMMS'));
        }

        return res;

    }

}