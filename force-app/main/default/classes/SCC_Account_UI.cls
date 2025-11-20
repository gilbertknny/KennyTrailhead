public with sharing class SCC_Account_UI {
    public class CustomerProfile{
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse cpg {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse clcd {get;set;}
        @AuraEnabled public Account acc {get;set;}
        @AuraEnabled public String msg {get;set;}
    }

    @AuraEnabled//(cacheable=true)
    public static CustomerProfile getInformasiCustomer(String idacc){
        CustomerProfile cp =new Customerprofile();
        try{
            String cond = 'id =:idacc';
            String allfield = SOQL_SOBJECT.getallfield('Account');
            String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Account', cond, '', '', '1');
            Account acc = Database.query(queries);
            String cifno = acc.scc_cifno__c;
            cp.acc = acc;
            if(String.isNotBlank(cifno)){
                if(cifno.length()==16){
                    SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
                    req.customerNumber = cifno;
                    SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse res = SCC_CaseResoultion_DataHub.CardLinkCustomerNumber(req, 'Account', idacc);
                    cp.clcd = res;
                    cp.msg = res.error;
                }
                else{
                    SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
                    req.cifNo = cifno;
                    User us = [select id,EmployeeNumber from user where id=:userinfo.getUserId()];
                    req.channelId = 'CHMS';
                    req.personalNumber = label.Personal_Number;
                    if(String.isNotBlank(us.EmployeeNumber)){
                        req.personalNumber = us.EmployeeNumber;
                    }
                    SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req, 'Account', idacc);
                    cp.cpg = res;
                    cp.msg = res.responseMessage;
                }
            }
        }
        catch(Exception exc){
            cp.msg = exc.getMessage();
        }
        return cp;
    }

    @AuraEnabled//(cacheable=true)
    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse getInformasiFinansial(String idacc){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
        User us = [select id,EmployeeNumber from user where id=:userinfo.getUserId()];
        req.channelId = 'CHMS';
        req.personalNumber = label.Personal_Number;
        if(String.isNotBlank(us.EmployeeNumber)){
            req.personalNumber = us.EmployeeNumber;
        }
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new  SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        String cond = 'id =:idacc';
        String allfield = SOQL_SOBJECT.getallfield('Account');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Account', cond, '', '', '1');
        Account acc = Database.query(queries);
        String cifno = acc.scc_cifno__c;
        if(String.isnotBlank(cifno)){
            if(cifno.length()==16){
                req.cardNo = cifno;
            }
            else{
                req.cifNo = cifno;
            }
            res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req, 'Account', idacc);
        }
        return res;
    }

    @AuraEnabled//(cacheable=true)
    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse getMutasiRekening(String norek,String tglawal,String tglakhr,String idacc){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
        req.channel = 'CHMS';
        req.norekVarchar = norek;
        req.tanggalAkhirDatetime = tglakhr;
        req.tanggalAwalDatetime = tglawal;
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.searchSavingStatement(req, 'Account', idacc);
        return res;
    }

    @AuraEnabled//(cacheable=true)
    public static SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse getMutasiKartu(String nokar,String idacc){
        SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest req = new SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest();
        req.cardNumber = nokar;
        SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse res = SCC_CaseResoultion_DataHub.PCTD(req,'DataHubPCTD', 'Account', idacc);
        return res;
    }

    @AuraEnabled//(cacheable=true)
    public static SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse getHoldStatus(String norek,String idacc){
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest req = new SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest();
        req.acctNo = norek;
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse res = SCC_CaseResoultion_DataHub.HoldStatus(req, 'Account', idacc);
        return res;
    }
}