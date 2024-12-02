public with sharing class SCC_HomePageSearch {
    @AuraEnabled
    public static List<CustomerProfile> getCustomerProfile(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req){
        List<CustomerProfile> listcp = new List<CustomerProfile>();
        try{
            User us = [select id,EmployeeNumber from user where id=:userinfo.getUserId()];
            req.channelId = 'CHMS';
            req.personalNumber = label.Personal_Number;
            if(String.isNotBlank(us.EmployeeNumber)){
                req.personalNumber = us.EmployeeNumber;
            }
            SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req,'Home','');
            CustomerProfile cp = new CustomerProfile();
            cp.msg = res.responseMessage;
            cp.res = res;
            String allfieldacc = SOQL_SOBJECT.getallfield('Account');
            Account acc = new Account();
            if(res?.data!=null){
                for(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData dt:res?.data){
                    String cifno = dt.cifno;
                    String condacc = 'SCC_cifno__c=:cifno';
                    String queriesacc = SOQL_SOBJECT.SOQL(allfieldacc, '', 'Account', condacc, '', '', '1');
                    List<Account> listacc = Database.query(queriesacc);
                    SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi demographicInfo = dt?.demografi;
                    if(!listacc.isEmpty()){
                        acc = SCC_LegacyCaseAPICtrl.returnAccount(demographicInfo, listacc[0].id, dt?.cifno);
                    }
                    else{   
                        acc = SCC_LegacyCaseAPICtrl.returnAccount(demographicInfo, null, dt?.cifno);
                    }
                }
                String accid= acc.id;
                String cond2 = 'id=:accid';
                String qacc = SOQL_SOBJECT.SOQL(allfieldacc, '', 'Account', cond2, '', '', '1');
                Account acct = Database.query(qacc);
                cp.acc = acct;
            }
            listcp.add(cp);
        }
        catch(exception exc){
        	listcp = setListError(exc.getMessage());
        }
        return listcp;
    }

    @AuraEnabled
    public static List<CustomerProfile> getCardLink(String cardNo, String phoneNumber,String customerNumber,String nik){
        List<CustomerProfile> listcp = new List<CustomerProfile>();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData> listcus = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData>();
        Map<String,SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData> mapclcd = new Map<String,SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData>();
        Map<String,Account> mapacc = new Map<String,Account>();
        String rtperson = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String rtbu = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        try{
            String msg = '';
            SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
            req.cardNumber = cardNo;
            req.customerNumber = customerNumber;
            req.nik = nik;
            req.phoneNumber = phoneNumber;
            if(String.isNotBlank(cardNo)){
                SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse res = SCC_CaseResoultion_DataHub.CardLinkCardNumber(req,'Home','');
                if(res?.response!= Null){
                    if(!res?.response?.data?.isEmpty()){
                        for(SCC_CaseResoultion_DataHub_Wrapper.CardLinkResponseData clrd:res.response.data){
                            if(!clrd?.customerData.isEmpty()){
                                listcus.addAll(clrd.customerData);
                            }
                        }
                    }
                }
                else {
                    msg = 'Data Not Found';
                	if(String.isNotBlank(res?.error)){
                        msg = res.error;
                    }
                    if(String.isNotBlank(res?.responseMessage)){
                        msg = res.responseMessage;
                    }
                }
            }
            if(String.isNotBlank(phoneNumber)){
                SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse res = SCC_CaseResoultion_DataHub.CardLinkPhoneNumber(req,'Home','');
                if(res?.response!=null){
                    if(!res?.response?.customerData?.isEmpty()){
                        listcus.addAll(res?.response?.customerData);
                    }
                }
                else {
                    msg = 'Data Not Found';
                	if(String.isNotBlank(res?.error)){
                        msg = res.error;
                    }   
                    if(String.isNotBlank(res?.responseMessage)){
                        msg = res.responseMessage;
                    }
                }
            }
            if(String.isNotBlank(nik)){
                SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse res = SCC_CaseResoultion_DataHub.CardLinkNIK(req,'Home','');
                if(res?.response!=null){
                    if(!res?.response?.customerData?.isEmpty()){
                        listcus.addAll(res?.response?.customerData);
                    }
                }
                else {
                    msg = 'Data Not Found';
                    if(String.isNotBlank(res?.error)){
                        msg = res.error;
                    }
                    if(String.isNotBlank(res?.responseMessage)){
                        msg = res.responseMessage;
                    }
                }
            }
            if(String.isNotBlank(customerNumber)){
                SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse res = SCC_CaseResoultion_DataHub.CardLinkCustomerNumber(req,'Home','');
                if(res?.response!=null){
                    if(!res?.response?.customerData?.isEmpty()){
                        listcus.addAll(res?.response?.customerData);
                    }
                }
                else {
                    msg = 'Data Not Found';
                	if(String.isNotBlank(res?.error)){
                        msg = res.error;
                    }
                    if(String.isNotBlank(res?.responseMessage)){
                        msg = res.responseMessage;
                    }
                }
            }
            if(!listcus.isEmpty()){
                List<String> listcifno = new List<String>();
                map<String,String> mapexist2 = new Map<String,String>();
                map<String,String> mapexist = new Map<String,String>();
                for(SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData clcd:listcus){
                    mapexist2.put(clcd.customerNumber,null);
                }
                mapexist = setmapexist(mapexist2);
                for(SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData clcd:listcus){
                    mapclcd.put(clcd.customerNumber,clcd);
                    String rtexist = mapexist.get(clcd.customerNumber); 
                    Account acc = new Account();
                    String nama = String.isNotBlank(clcd.namaLengkap) ? clcd.namaLengkap.trim() : clcd.namaDepan.trim()+' '+clcd.namaTengah.trim()+' '+clcd.namaBelakang.trim() ;
                    if(!String.isBlank(clcd.nomorHandphoneTerdaftar)) {
                        acc.Phone = setphone(clcd.nomorHandphoneTerdaftar);
                    }
                    acc.SCC_cifno__c = clcd.customerNumber;
                    if(!String.isBlank(clcd.alamatEmail)) {
                        acc.SCC_Primary_Email__c = SCC_LegacyCaseAPICtrl.validateAndSetEmail(clcd.alamatEmail);
                    }
                    if(!clcd.customerNumber.startsWithIgnoreCase(label.CardLink_Corporate) && (rtexist==null || rtexist==rtperson)){
                        if(!String.isBlank(clcd.alamatEmail)) {
                            acc.PersonEmail = SCC_LegacyCaseAPICtrl.validateAndSetEmail(clcd.alamatEmail);
                        }
                        acc.Lastname  =  nama;
                        acc.SCC_Tipe_Nasabah__c = 'Individu';
                        acc.RecordTypeId = rtperson;
                    }
                    else{
                        acc.name  = nama;
                        acc.SCC_Tipe_Nasabah__c = 'Non-Individu';
                        acc.RecordTypeId = rtbu;
                    }
                    mapacc.put(clcd.customerNumber,acc);
                }
                if(!mapacc.isEmpty()){
                    upsert mapacc.values() SCC_cifno__c;
                    for(Account acc:mapacc.values()){
                        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData cld = mapclcd.get(acc.SCC_cifno__c);
                        CustomerProfile cp = new CustomerProfile();
                        cp.cld = cld;
                        cp.acc = acc;
                        listcp.add(cp);
                    }
                }
            }
            else{
                listcp = setListError(msg);    
            }
            system.debug(msg);
        }
        catch(exception exc){
            system.debug(exc.getmessage());
            system.debug(exc.getStackTraceString());
            listcp = setListError(exc.getMessage());
        }
        return listcp;
    }

    @AuraEnabled
    public static List<CustomerProfile> getDPLK(String idNumber, String acctNo){
        Map<String,SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK> mapdplk = new Map<String,SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK>();
        Map<String,Account> mapacc = new Map<String,Account>();
        List<CustomerProfile> listcp = new List<CustomerProfile>();
        SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest req = new SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest();
        SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse res = new SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse();
        String rtperson = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String rtbu = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        try{
            req.acctNo = acctNo;
            req.idNumber = idNumber;
            if(String.isNotBlank(idNumber)){
                res = SCC_CaseResoultion_DataHub.DPLK(req, 'DataHubDPLKIdNumber','Home','');
            }
            if(String.isNotBlank(acctNo)){  
                res = SCC_CaseResoultion_DataHub.DPLK(req, 'DataHubDPLKAccountNumber','Home','');
            }
            if(!res?.SI_DPLK.isEmpty()){
                map<String,String> mapexist2 = new Map<String,String>();
                map<String,String> mapexist = new Map<String,String>();
                for(SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK si:res?.SI_DPLK){
                    mapexist2.put(si.cifno,null);
                }
                mapexist = setmapexist(mapexist2);
                for(SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK si:res?.SI_DPLK){
                    mapdplk.put(si.cifno,si);
                    String rtid = null;
                    if(mapexist.containsKey(si.cifno)){
                        rtid = mapexist.get(si.cifno);
                    }   
                    else{
                        rtid = rtperson;
                    }
                    Account acc = new Account();
                    acc.RecordTypeId = rtid;
                    acc.SCC_cifno__c = si.cifno;
                    if(!String.isBlank(si.nomor_handphone)){
                        acc.Phone =setphone(si.nomor_handphone);
                    }
                    if(rtid == rtperson){
                        acc.LastName = si.nama_nasabah;
                        acc.SCC_Tipe_Nasabah__c = 'Individu';
                        if(!String.isBlank(si.alamat_email)){
                            acc.PersonEmail = SCC_LegacyCaseAPICtrl.validateAndSetEmail(si.alamat_email);
                            acc.SCC_Primary_Email__c = SCC_LegacyCaseAPICtrl.validateAndSetEmail(si.alamat_email);
                        }
                    }
                    else{
                        acc.Name = si.nama_nasabah;
                        acc.SCC_Tipe_Nasabah__c = 'Non-Individu';
                        if(!String.isBlank(si.alamat_email)){
                            acc.SCC_Primary_Email__c = SCC_LegacyCaseAPICtrl.validateAndSetEmail(si.alamat_email);
                        }
                    }
                    mapacc.put( si.cifno,acc);
                }
                if(!mapacc.isEmpty()){
                    upsert mapacc.values() SCC_cifno__c;
                    for(Account acc:mapacc.values()){
                        SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK dplk = mapdplk.get(acc.SCC_cifno__c);
                        CustomerProfile cp = new CustomerProfile();
                        cp.si = dplk;
                        cp.acc = acc;
                        listcp.add(cp);
                    }
                }
            }
        }
        catch(exception exc){
            listcp = setListError(exc.getMessage());
        }
        return listcp;
    }
 
    @AuraEnabled
    public static List<CustomerProfile> getMerchant(String tid, String mid){
        List<CustomerProfile> listcp = new List<CustomerProfile>();
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest();
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne res = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne();
        Map<String,SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile> mapm = new Map<String,SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile>();
        Map<String,Account> mapacc = new Map<String,Account>();
        String rtperson = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String rtbu = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        String mdh = '';
        String msg = '';
        try{
            req.mid = mid;
            req.tid = tid;
            if(String.isNotBlank(tid)){
                mdh ='DataHubMerchantProfileTID';
            }
            if(String.isNotBlank(mid)){
                mdh ='DataHubMerchantProfileMID';
            }
            res = SCC_CaseResoultion_DataHub.MerchantProfile(req, mdh,'Home','');
            if(res?.MERCHANT_PROFILE!=NULL){
                map<String,String> mapexist2 = new Map<String,String>();
                map<String,String> mapexist = new Map<String,String>();
                for(SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile mp:res?.MERCHANT_PROFILE){
                    mapexist2.put(mp.cifno,null);
                }
                mapexist = setmapexist(mapexist2);
                for(SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile mp : res.MERCHANT_PROFILE){
                    mapm.put(mp.cifno,mp);
                    String rtid = null;
                    if(mapexist.containsKey(mp.cifno)){
                        rtid = mapexist.get(mp.cifno);
                    }   
                    else{
                        rtid = rtbu;
                    }
                    String nama = '';
                    if(String.isNotBlank(mp?.nama_merchant_edc) && mp?.nama_merchant_edc!='NULL'){
                        nama = mp.nama_merchant_edc;
                    }
                    else if(String.isNotBlank(mp?.nama_merchant_qris)){
                        nama = mp.nama_merchant_qris;
                    }
                    Account acc = new Account();
                    acc.RecordTypeId = rtid;
                    acc.SCC_cifno__c = mp.cifno;
                    if(!String.isBlank(mp.telpon)){
                        acc.Phone = setphone(mp.telpon);
                    }
                    if(rtid == rtperson){
                        acc.Lastname = nama;
                        acc.SCC_Tipe_Nasabah__c = 'Individu';
                        if(!String.isBlank(mp.email)){
                            acc.PersonEmail = SCC_LegacyCaseAPICtrl.validateAndSetEmail(mp.email);
                            acc.SCC_Primary_Email__c = SCC_LegacyCaseAPICtrl.validateAndSetEmail(mp.email);
                        }
                    }
                    else{
                        acc.name = nama;
                        acc.SCC_Tipe_Nasabah__c = 'Non-Individu';
                        if(!String.isBlank(mp.email)){
                            acc.SCC_Primary_Email__c = SCC_LegacyCaseAPICtrl.validateAndSetEmail(mp.email);
                        }
                    }
                    mapacc.put( mp.cifno,acc);
                }
                if(!mapacc.isEmpty()){
                    upsert mapacc.values() scc_cifno__c;
                    for(Account acc:mapacc.values()){
                        CustomerProfile cp = new CustomerProfile();
                        cp.mp = mapm.get(acc.scc_cifno__c);
                        cp.acc = acc;
                        listcp.add(cp);
                    }
                }
            }
            else{
                msg = 'Data Not Found';
                if(String.isNotBlank(res?.error)){
                    msg = res?.error;
                }
            }
        }
        catch(Exception exc){
            listcp = setListError(exc.getMessage());
        }
        return listcp;
    }

    @AuraEnabled
    public static List<CustomerProfile> getBRILink(String tid, String mid){
        List<CustomerProfile> listcp = new List<CustomerProfile>();
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest();
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse();
        Map<String,SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile> mapb = new Map<String,SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile>();
        Map<String,Account> mapacc = new Map<String,Account>();
        String rtperson = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String rtbu = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        String mdh = '';
        String msg = '';
        try{
            req.mid = mid;
            req.tid = tid;
            if(String.isNotBlank(tid)){
                mdh ='DataHubBRILinkProfileTID';
            }
            if(String.isNotBlank(mid)){
                mdh ='DataHubBRILinkProfileMID';
            }
            res = SCC_CaseResoultion_DataHub.BRILinkProfile(req, mdh,'Home','');
            if(res?.BRILINK_PROFILE!=NULL){
                map<String,String> mapexist2 = new Map<String,String>();
                map<String,String> mapexist = new Map<String,String>();
                for(SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile bp:res?.BRILINK_PROFILE){
                    mapexist2.put(bp.cifno,null);
                }
                mapexist = setmapexist(mapexist2);
                for(SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile bp : res.BRILINK_PROFILE){
                    mapb.put(bp.cifno,bp);
                    String rtid = null;
                    if(mapexist.containsKey(bp.cifno)){
                        rtid = mapexist.get(bp.cifno);
                    }   
                    else{
                        rtid = rtbu;
                    }
                    String nama = '';
                    if(String.isNotBlank(bp?.nama_lengkap)){
                        nama = bp.nama_lengkap;
                    }
                    else if(String.isNotBlank(bp?.nama_merchant)){
                        nama = bp.nama_merchant;
                    }
                    Account acc = new Account();
                    acc.RecordTypeId = rtid;
                    acc.SCC_cifno__c = bp.cifno;
                    if(!String.isBlank(bp.telepon)){
                        acc.Phone = setphone(bp.telepon);
                    }
                    if(rtid == rtperson){
                        acc.Lastname = nama;
                        acc.SCC_Tipe_Nasabah__c = 'Individu';
                    }
                    else{
                        acc.name = nama;
                        acc.SCC_Tipe_Nasabah__c = 'Non-Individu';
                    }
                    mapacc.put( bp.cifno,acc);
                }
                if(!mapacc.isEmpty()){
                    upsert mapacc.values() scc_cifno__c;
                    for(Account acc:mapacc.values()){
                        CustomerProfile cp = new CustomerProfile();
                        cp.bp = mapb.get(acc.scc_cifno__c);
                        cp.acc = acc;
                        listcp.add(cp);
                    }
                }
            }
            else{
                msg = 'Data Not Found';
                if(String.isNotBlank(res?.error)){
                    msg = res?.error;
                }
            }
        }
        catch(Exception exc){
            listcp = setListError(exc.getMessage());
        }
        return listcp;
    }

    public static list<CustomerProfile> setListError(String msg) {
        List<CustomerProfile> listcp = new List<CustomerProfile>();
        CustomerProfile cp = new CustomerProfile();
        cp.msg = msg;
        listcp.add(cp);
        return listcp;
    }

    public static String setPhone (String telp){
        String ph = '';
        telp = telp.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|-|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '').deleteWhitespace();
        if(String.isnotblank(telp)){
            if(telp.isnumeric()){
                ph = telp;
            }
        }
        return ph;
    }
    
    public static map<String,String> setmapexist(map<String,String> mapexist){
        map<String,String> mapex = new map<String,String>();
        if(!mapexist.isEmpty()){
            List<Account> listacc = [select id,RecordTypeId,SCC_cifno__c from account where SCC_cifno__c in :mapexist.keySet()];
            if(!listacc.isEmpty()){
                for(Account acc:listacc){
                    mapex.put(acc.SCC_cifno__c,acc.RecordTypeId);
                }
            }
        }
        return mapex;
    }

    public class CustomerProfile{
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData cld {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK si {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile mp {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile bp {get;set;}
        @AuraEnabled public Account acc {get;set;}
        @AuraEnabled public String msg {get;set;}
    }
}