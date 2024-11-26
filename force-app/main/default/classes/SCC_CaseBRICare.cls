public with sharing class SCC_CaseBRICare {
    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse getPortofolio(String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new  SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        String cifNo = '';
        String cardnumber = '';
        String norek = '';
        User us = [select id,EmployeeNumber from user where id=:userinfo.getUserId()];
        req.channelId = 'CHMS';
        req.personalNumber = label.Personal_Number;
        if(String.isNotBlank(us.EmployeeNumber)){
            req.personalNumber = us.EmployeeNumber;
        }
        Case cs = getCaseDetail(idcs);
        cardnumber = cs.SCC_Card_Number__c;
        norek = cs.SCC_Account_Number__c;
        if(String.isNotBlank(cs?.Account?.scc_cifno__c)){
            cifNo = cs?.Account?.scc_cifno__c;
        }
        if(String.isnotBlank(cifNo)){
            res = getPortofoliobyId('', '', cifNo, idcs);
        }
        else if(String.isnotBlank(norek)){
            res = getPortofoliobyId(norek, '', '', idcs);
        }
        else if(String.isnotBlank(cardnumber)){
            res = getPortofoliobyId('', cardnumber, '', idcs);
        }
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse getPortofoliobyId(String norek, String cardnumber, String cifNo, String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new  SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        User us = [select id,EmployeeNumber from user where id=:userinfo.getUserId()];
        req.channelId = 'CHMS';
        req.personalNumber = label.Personal_Number;
        if(String.isNotBlank(us.EmployeeNumber)){
            req.personalNumber = us.EmployeeNumber;
        }
        if(String.isnotBlank(cifNo)){
            if(cifNo.length()==16){
                req.cardNo = cifNo;
            }
            else{
                req.cifNo = cifNo;
            }
        }
        else if(String.isnotBlank(norek)){
            req.acctNo = norek;
        }
        else if(String.isnotBlank(cardnumber)){
            req.cardNo = cardnumber;
        }
        res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse getMutation(String norekVarchar,String tanggalAwalDatetime,String tanggalAkhirDatetime,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest(); 
        req.norekVarchar = norekVarchar;
        req.tanggalAkhirDatetime = tanggalAkhirDatetime; 
        req.tanggalAwalDatetime = tanggalAwalDatetime;
        req.channel = 'CHMS';
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.SearchSavingMutation(req, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.CardResponse getCardDetailDebit(String cardNo,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.CardRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardRequest(); 
        req.cardNo = cardNo;
        SCC_CaseResoultion_DataHub_Wrapper.CardResponse res = SCC_CaseResoultion_DataHub.CardDetailDebit(req, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse getCustomer(String acctNo,String cardNo,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new  SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        if(String.isNotBlank(acctNo)){
            res = getPortofoliobyId(acctNo, '', '', idcs);
        }
        if(String.isNotBlank(cardNo)){
            res = getPortofoliobyId('', cardNo, '', idcs);
        }
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse getMachine(String alamatMesin,String tid,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest req = new SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest();
        req.alamatMesin = alamatMesin;
        SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse res = SCC_CaseResoultion_DataHub.SearchDataMachine(req, 'DataHubDataMachine', 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse getCardLink(String idcs){
        Case cs = getCaseDetail(idcs);
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse res = getCardLinkbyCardNumber(cs.SCC_Card_Number__c, idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse getCardLinkbyCardNumber(String CardNumber,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
        req.cardNumber = CardNumber;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse res = SCC_CaseResoultion_DataHub.CardLinkCardNumber(req, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse getTrxCredit(String cardNumber,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest req = new SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest();
        req.cardNumber = cardNumber;
        SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse res = SCC_CaseResoultion_DataHub.PCTD(req, 'DataHubPCTD', 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse getPengajuanKartu(String idNumber,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.CardApplicationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardApplicationRequest();
        req.idNumber = idNumber;
        SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse res = SCC_CaseResoultion_DataHub.CardApplication(req, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse getBRILink(String tid,String mid,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest();
        String mdh = '';
        if(String.isNotBlank(tid)){
            req.tid = tid;
            mdh= 'DataHubBRILinkProfileTID';
        }
        if(String.isNotBlank(mid)){
            req.mid = mid;
            mdh= 'DataHubBRILinkProfileMID';
        }
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse res = SCC_CaseResoultion_DataHub.BRILinkProfile(req,mdh, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne getMerchant(String tid,String mid,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest();
        String mdh = '';
        if(String.isNotBlank(tid)){
            req.tid = tid;
            mdh= 'DataHubMerchantProfileTID';
        }
        if(String.isNotBlank(mid)){
            req.mid = mid;
            mdh= 'DataHubMerchantProfileMID';
        }
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne res = SCC_CaseResoultion_DataHub.MerchantProfile(req,mdh, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse getMerchantTrx(SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest cdh,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest req = new SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest();
        String mdh = 'DataHubTransactionHistory';
        req.midOrMpan = cdh.midOrMpan;
        req.tidOrStoreId = cdh.tidOrStoreId;
        req.trxDate = cdh.trxDate;
        if(String.isNotBlank(cdh.appCodeOrReffNum) && String.isNotBlank(cdh.trxTime)){
            req.appCodeOrReffNum = cdh.appCodeOrReffNum;
            req.trxTime = cdh.trxTime;
            mdh = 'DataHubDetailTransaction';
        }
        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse res = SCC_CaseResoultion_DataHub.TrxMerchant(req, mdh, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse getWholeSaleBRIMola(String idPangkalan,String startDate,String endDate,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest req = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest();
        req.idPangkalan = idPangkalan;
        req.endDate = endDate;
        req.startDate = startDate;
        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse res = SCC_CaseResoultion_DataHub.BRIMola(req, 'DataHubBRIMolaIdTrx', 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled
    public static SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse getDPLK(String acctNo,String idNumber,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest req = new SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest();
        String mdh = '';
        if(String.isNotBlank(acctNo)){
            req.acctNo = acctNo;
            mdh = 'DataHubDPLKAccountNumber';
        }
        if(String.isNotBlank(idNumber)){
            req.idNumber = idNumber;
            mdh = 'DataHubDPLKIdNumber';
        }
        SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse res = SCC_CaseResoultion_DataHub.DPLK(req, mdh, 'Case - BRICare', idcs);
        return res;
    }

    public static case getCaseDetail(String idcs){
        String condcs = 'id =:idcs';
        String allfieldcs = SOQL_SOBJECT.getallfield('Case');
        String queriescs = SOQL_SOBJECT.SOQL(allfieldcs, ',Account.scc_cifno__c', 'Case', condcs, '', '', '1');
        Case cs = Database.query(queriescs);
        return cs;
    }

    @AuraEnabled//(cacheable=true)
    public static SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse getHoldStatus(String norek,String idcs){
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest req = new SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest();
        req.acctNo = norek;
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse res = SCC_CaseResoultion_DataHub.HoldStatus(req, 'Case - BRICare', idcs);
        return res;
    }

    @AuraEnabled//(cacheable=true)
    public static Branch_Unit__c getBranch(String kode){
        Branch_Unit__c res = new Branch_Unit__c();
        try{
            String cond = 'Branch_Code__c =:kode';
            String allfield = SOQL_SOBJECT.getallfield('Branch_Unit__c');
            String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Branch_Unit__c', cond, '', '', '1');
            res = Database.query(queries);
        }
        catch(Exception exc){
            ErrorLog(exc);
        }
        return res;
    }

    @AuraEnabled//(cacheable=true)
    public static List<Customer_Verification__c> getCustomerVerification(String norek,String idcs){ //bisa norek & nokartu
        List<Customer_Verification__c> res = new List<Customer_Verification__c>();
        try{
            String cond = 'name = :norek and case__c = :idcs';
            String allfield = SOQL_SOBJECT.getallfield('Customer_Verification__c');
            String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Customer_Verification__c', cond, '', '', '1');
            res = Database.query(queries);
        }
        catch(Exception exc){
            ErrorLog(exc);
        }
        return res;
    }

    @AuraEnabled//(cacheable=true)
    public static ResponseVerification UpdateVerification(Customer_Verification__c cv){
        try{
            if(String.isNotBlank(cv?.id)){
                update cv;
            }
            else{
                insert cv;
            }
            return new ResponseVerification(cv.id,'Success');
        }
        catch(Exception exc){
            return ErrorLog(exc);
        }
    }

    @AuraEnabled//(cacheable=true)
    public static String getTID(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data){
        String tid = '';
        String trancd = data.kodeTran;
        String auxtrc = data.auxtrc;
        String trremk = data.trremk.trim();
        String norek = String.valueOf(Integer.valueOf(data.noRek));
        Integer lngtrremk = trremk.length();
        Integer lngnoRek = noRek.length();
        Integer lng = 0;
        if(trancd == '8501' || trancd == '8553' || auxtrc == '8501' || auxtrc == '8553'){
            lng = lngtrremk;
            if(lng>=24){
                lng = 24;
            }
            tid = trremk.substring(16,lng);
        }
        else if(trancd=='2501' || auxtrc=='2501'){
            List<String> liststr = trremk.split(' ');
            if(liststr.size()>1){
                tid = liststr[1];
            }
        }
        else if(trancd=='8554' || auxtrc=='8554'){    
            lng = lngnoRek+8;
            tid = trremk.substring(lngnoRek,lng);
        }
        return tid;
    }

    public static ResponseVerification errorLog(Exception exc){
        ErrorLogRecord.DebugLog dls = new ErrorLogRecord.DebugLog();
        dls.message = exc.getMessage();
        dls.trace = exc.getStackTraceString();
        dls.typename = exc.getTypeName();
        dls.linenumber = string.valueOf(exc.getLineNumber());
        dls.errorcause = string.valueOf(exc.getCause());
        dls.classname = 'SCC_CaseBRICare';
        ErrorLogRecord.seteventerror(JSON.serialize(dls));
        return new ResponseVerification('',exc.getMessage());
    }

    public class ResponseVerification{
        @AuraEnabled public String idsf {get;set;}
        @AuraEnabled public String msg {get;set;}
        public ResponseVerification(String idsf,String msg){
            this.idsf = idsf;
            this.msg = msg;
        }
    }
}