public with sharing class SCC_BRINotif {
    public static SCC_BRINotif_Wrapper.WANotifResponse SendWANotif(SCC_BRINotif_Wrapper.WANotifRequest cdh){
        String url_current = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        SCC_BRINotif_Wrapper.WANotifResponse cps = new  SCC_BRINotif_Wrapper.WANotifResponse();
        map<String,SCC_BRINotif_Wrapper.WANotifPesan> m = new map<String,SCC_BRINotif_Wrapper.WANotifPesan>();
        for(SCC_BRINotif_Wrapper.WANotifPesan psn:cdh.pesanWA){
            m.put(psn.type,psn);
        }
        SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance('BRINotifWA');
        //String bodyreq = JSON.serialize(cdh,true);
        JSONGenerator gentoken = JSON.createGenerator(true);
        gentoken.writeStartObject();
        gentoken.writeStringField('rekening', cdh.rekening);
        gentoken.writeStringField('produk', cdh.produk);
        gentoken.writeStringField('phoneNumber', cdh.phoneNumber);
        gentoken.writeStringField('pesan', cdh.pesan);
        gentoken.writeFieldName('pesanWa');
        gentoken.writeStartArray();
        if(m.containsKey('header')){
            SCC_BRINotif_Wrapper.WANotifPesan h = m.get('header');
            setJsonRequest(h, gentoken);
        }
        if(m.containsKey('body')){
            SCC_BRINotif_Wrapper.WANotifPesan b = m.get('body');
            setJsonRequest(b, gentoken);
        }
        gentoken.writeEndArray();
        gentoken.writeStringField('sendTime', cdh.sendTime);
        gentoken.writeEndObject();
        String bodyreq = gentoken.getAsString();
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('BRINotifWA', bodyreq,'','SCC_BRINotif');
        try{
            cps = (SCC_BRINotif_Wrapper.WANotifResponse) JSON.deserialize(wapi.res.getBody(), SCC_BRINotif_Wrapper.WANotifResponse.class);
        }
        catch(exception exc){
            InsertErrorLog(exc,wapi.req,wapi.res,url_current);
        }
        return cps;
    }

    public static void setJsonRequest(SCC_BRINotif_Wrapper.WANotifPesan wa, JSONGenerator gentoken){
        gentoken.writeStartObject();
        gentoken.writeStringField('type', wa.type);
        gentoken.writeFieldName('parameters');
        gentoken.writeStartArray();
        for(SCC_BRINotif_Wrapper.WANotifParameter prm:wa.parameters){
            gentoken.writeStartObject();
            gentoken.writeStringField('type', prm.type);
            if(prm.type=='text'){
                gentoken.writeStringField('text', prm.text);
            }
            if(prm.type=='image'){
                gentoken.writeStringField('image', prm.image);
            }
            gentoken.writeEndObject();
        }
        gentoken.writeEndArray();
        gentoken.writeEndObject();
    }

    public static SCC_BRINotif_Wrapper.WANotifRequest setWANotifRequest(String csid){
        SCC_BRINotif_Wrapper.WANotifRequest warequest = new SCC_BRINotif_Wrapper.WANotifRequest();
        List<SCC_BRINotif_Wrapper.WANotifParameter> listprmhd = new List<SCC_BRINotif_Wrapper.WANotifParameter>();
        List<SCC_BRINotif_Wrapper.WANotifParameter> listprmbd = new List<SCC_BRINotif_Wrapper.WANotifParameter>();
        SCC_BRINotif_Wrapper.WANotifPesan psnhd = new SCC_BRINotif_Wrapper.WANotifPesan();
        SCC_BRINotif_Wrapper.WANotifPesan psnbd = new SCC_BRINotif_Wrapper.WANotifPesan();
        List<SCC_BRINotif_Wrapper.WANotifPesan> listpsn = new List<SCC_BRINotif_Wrapper.WANotifPesan>();
        String phn = '';
        try{
            String cond = 'id =: csid';
            String addfield = ',SCC_Call_Type__r.Name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,Account.phone,Account.PersonMobilePhone ';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Case cs = Database.query(queries);
            if(String.isNotBlank(cs?.account?.PersonMobilePhone)){
                phn = cs?.account?.PersonMobilePhone;
            }
            else if(String.isNotBlank(cs?.account?.phone)){
                phn = cs?.account?.phone;
            }
            if(String.isnotblank(cs?.Cust_Current_Phone__c)){
                phn = cs?.Cust_Current_Phone__c;
            }
            else if(String.isnotblank(cs?.SCC_Cust_Phone1__c)){
                phn = cs?.SCC_Cust_Phone1__c;
            }
            String ct = '';
            if(String.isnotblank(cs?.SCC_Call_Type__r?.Name)){
            	ct = '%'+cs?.SCC_Call_Type__r?.Name.substringbefore('-').trim()+'%';
            }
            if(String.isnotblank(cs?.SCC_Call_Type__r?.External_id__c)){
            	ct = '%'+cs?.SCC_Call_Type__r?.External_id__c+'%';
            }
            system.debug('ct : ' + ct);
            //String ct = '%'+cs.SCC_Call_Type__r.Name+'%';
            String notif = cs.SCC_Status_Transaksi__c;
            system.debug('status : ' + cs.SCC_Status_Transaksi__c);
            String cond2 = 'call_type__c  like : ct and Notif_Pengiriman__c = :notif';
            String allfield2 = SOQL_SOBJECT.getallfield('SCC_WA_Template__mdt');
            String queries2 = SOQL_SOBJECT.SOQL(allfield2, '', 'SCC_WA_Template__mdt', cond2, '', '', '1');
            SCC_WA_Template__mdt watmp = Database.query(queries2);
            system.debug('watmp  : ' + watmp);
            if(watmp.Count_Param_Header__c>0){
                for(integer i=1;i<=watmp.Count_Param_Header__c;i++){
                    String tipe = String.valueOf(watmp.get('Type_Header_'+i+'__c'));
                    String fld = String.valueOf(watmp.get('Value_Header_'+i+'__c'));
                    SCC_BRINotif_Wrapper.WANotifParameter prm = setparam(tipe, fld, cs);
                    listprmhd.add(prm);
                }
                psnhd.type = 'header';
                psnhd.parameters = listprmhd;
            }
            if(watmp.Count_Param_Body__c>0){
                for(integer j=1;j<=watmp.Count_Param_Body__c;j++){
                    String tipe = String.valueOf(watmp.get('Type_Body_'+j+'__c'));
                    String fld = String.valueOf(watmp.get('Value_Body_'+j+'__c'));
                    SCC_BRINotif_Wrapper.WANotifParameter prm = setparam(tipe, fld, cs);
                    listprmbd.add(prm);
                }
                psnbd.type = 'body';
                psnbd.parameters = listprmbd;
            }
            if(!listprmhd.isEmpty()){
                listpsn.add(psnhd);
            }
            if(!listprmbd.isEmpty()){
                listpsn.add(psnbd);
            }
            warequest.rekening = cs.SCC_Account_Number__c;
            warequest.produk = watmp.MasterLabel ;
            warequest.phoneNumber = phn;
            warequest.pesan = 'BRI-NOTIF';
            warequest.pesanWA = listpsn;
            warequest.sendtime = String.valueof(system.now());
        }
        catch(exception exc){
            InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),'');
        }
        return warequest;
    }

    public static void SendWANotifCase(String csid){
        try{
            SCC_BRINotif_Wrapper.WANotifRequest req = SCC_BRINotif.setWANotifRequest(csid);
            SCC_BRINotif_Wrapper.WANotifResponse res = SCC_BRINotif.SendWANotif(req);
            Case cs = new Case();
            cs.id = csid;
            cs.SCC_BRINotif_reffNumber__c = res?.responseMessage;
            update cs;
        }
        catch(Exception exc){
            InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),'');
        }
    }

    @future(callout=true)
    public static void SendWANotifFuture(String csid){
        SendWANotifCase(csid);
    }

    public static SCC_BRINotif_Wrapper.WANotifParameter setparam(String tipe,String fld,Case cs){
        SCC_BRINotif_Wrapper.WANotifParameter prm = new SCC_BRINotif_Wrapper.WANotifParameter();
        prm.type=tipe;
        if(tipe =='text') {
            prm.text = String.valueOf(cs.get(fld));
        }
        if(tipe =='image'){
            prm.image = String.valueOf(cs.get(fld));
        }
        return prm;
    }

    public static void InsertErrorLog(Exception exc,HttpRequest req,HTTPResponse res,String url_current){
        SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError(url_current,'SCC_BRINotif'));
    }
}