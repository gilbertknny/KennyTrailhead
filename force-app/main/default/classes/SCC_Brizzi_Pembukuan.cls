/**
* @description       : Service Brizzi Pembukuan
* @last modified on  : 11/02/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_Brizzi_Pembukuan {
    public static void pembukuanBrizzi(String csid, String resAd, Boolean retry){
        String cond = 'SCC_Case__c=:csid ';
        String addfield = ',SCC_Case__r.SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Case__r.SCC_Call_Type__r.name,SCC_Case__r.SCC_Call_Type__r.External_id__c,SCC_Case__r.SCC_Transaction_Date__c,SCC_Case__r.terminal_id__r.name,SCC_Case__r.Casenumber';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Queuetrans__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SCC_Queuetrans__c', cond, '', '', '');
        Case dtcs = [SELECT SCC_Nomor_Briva_Tagihan__c, SCC_Case_Type_for_Suggested_Article__c, SCC_Result_Adjust_Deposit__c, SCC_Result_Replace_Card__c, Count_Replace_Card__c, SCC_Result_Pembukuan__c,Count_Adjust_Deposit__c FROM Case WHERE Id = :csid LIMIT 1];
        SCC_BrizziWrapper.BrizziPembukuanRequest req = new SCC_BrizziWrapper.BrizziPembukuanRequest();
        integer i = 1;
        try {
            List<SCC_Queuetrans__c> listque = Database.query(queries);
            for(SCC_Queuetrans__c qt:listque){
                req.nott = qt.SCC_Case__r.Casenumber;
                req.trxDate = String.valueof(qt?.SCC_Case__r?.SCC_Transaction_Date__c);
                String ctnum = '';
                if(String.isnotblank(qt?.SCC_Case__r?.SCC_Call_Type__r.Name)){
                ctnum =  qt?.SCC_Case__r?.SCC_Call_Type__r.Name.substringbefore('-').trim();
                }
                if(String.isNotBlank(qt?.SCC_Case__r?.SCC_Call_Type__r.External_Id__c)){
                    ctnum = qt?.SCC_Case__r?.SCC_Call_Type__r.External_Id__c;
                }
                req.calltype = ctnum;
                req.accountCredit = qt.scc_acct_kredit1__c;
                req.amountTopup = String.valueOf(qt.scc_amt_kredit1__c);
                req.type = qt.Channel_Topup__c;
                i++;
            }
            
            SCC_BrizziWrapper.BrizziPembukuanResponse res = SCC_Brizzi_Pembukuan_API.doPembukuan(req);
            for(SCC_Queuetrans__c qt:listque){
                qt.SCC_Status__c = res?.message;
            }
            update listque;
            Case cs = new Case();
            cs.id = csid;
            cs.SCC_Result_Pembukuan__c = res?.message;
            String statusBuku = res?.message;
            String resAdj = resAd;
            System.debug('response brizzi = '+resAdj);
            System.debug('retry pembukuan = '+retry);
            if (retry == false && dtcs.Count_Replace_Card__c > 0){
                cs.SCC_Result_Replace_Card__c = resAdj;
                resAdj = resAdj;
                System.debug('masuk A');
            }
            else if(retry == false && dtcs.Count_Adjust_Deposit__c > 0){
                cs.SCC_Result_Adjust_Deposit__c = resAdj;
                resAdj = resAdj;
                System.debug('masuk B');
            }
            else if(retry == true && dtcs.Count_Adjust_Deposit__c > 0){
                resAdj = cs.SCC_Result_Adjust_Deposit__c;
                System.debug('masuk C');
            }
            else if(retry == true && dtcs.Count_Replace_Card__c > 0){
                resAdj = cs.SCC_Result_Replace_Card__c;
                System.debug('masuk D');
            }
            else{
                resAdj = 'success';
                System.debug('masuk E');
            }
            
            if(StatusBuku.contains('Successfully')){
                if(resAdj == 'success'){
                    cs.Status = 'Closed';
                    cs.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                    cs.SCC_Closure_Comments__c = label.Closed_CHM;
                    cs.SCC_Status_Pembukuan__c = true;
                    System.debug('masuk F');
                }
                else{
                    cs.SCC_Status_Pembukuan__c = true;
                    System.debug('masuk G');
                }
            }

            System.debug('update case = '+cs);
            update cs;
        } 
        catch (Exception exc) {
            SCC_API.InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),new SCC_API.WrapperError('','SCC_Brizzi_Pembukuan')); 
        }
    }
}