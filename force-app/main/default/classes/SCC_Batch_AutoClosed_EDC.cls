public with sharing class SCC_Batch_AutoClosed_EDC implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    public SCC_Batch_AutoClosed_EDC(String q) {
        this.query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        try {

        
            List<Case> listcs = new List<Case>();
            List<SCC_Rekening_Koran__c> listrek = new List<SCC_Rekening_Koran__c>();
            List<SCC_Rekening_Koran__c> listdel = new List<SCC_Rekening_Koran__c>();
            SCC_Rekening_Koran__c rek = new SCC_Rekening_Koran__c();
            String url_current = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
            
            Set<String> masterKorSet = new Set<String>();
            for(Master_Kor__c mk : [SELECT Name FROM Master_Kor__c WHERE Case_Type__r.name = '8412']) {
                masterKorSet.add(mk.Name);
            }
            
            for (Case s : scope) {
                if (s.SCC_Call_Type__r.external_id__c != '8412') continue;

                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
                req.channel = 'CHMS';
                req.norekVarchar = s.SCC_Account_Number__c;

                Date todayz = Date.today();
                String tgl = DateTime.newInstance(todayz, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                
                Date tgl2Date = s.SCC_Transaction_Date__c;
                String tgl2 = DateTime.newInstance(tgl2Date, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

                req.tanggalAkhirDatetime = tgl;
                req.tanggalAwalDatetime = tgl2;
                
                listdel = [select id from SCC_Rekening_Koran__c where scc_case__c=:s.id];
                
                
                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.searchSavingStatement(req, 'EDC', s.Id);
                if (res.data != null) {
                    Integer matchedConditionCount = 0;
                    Integer matchedKor = 0;

                    for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData smd : res.data) {
                    
                        String wordRmk = smd.trremk != null ? smd.trremk : '';

                        System.debug('work rmk : ' + wordRmk);
                        System.debug('master list kor : ' + masterKorSet );

                        // Flag untuk track apakah remark match dengan masterKor
                        Boolean matched = false;
                        for (String kor : masterKorSet) {
                            if (wordRmk.startsWith(kor)) {
                                //matchedKor++;
                                matched = true;
                                System.debug('Matched kor : ' + kor);
                                break;
                            }
                        }
                        
                        if (matched && smd.mutasiKredit == s.SCC_Amount__c) {
                            System.debug('matched condition kor : ' + matchedKor);
                            matchedConditionCount++;
                            rek = mapRekeningKoran(smd,s);
                            listrek.add(rek);
                        }
                        
                    }
                    
                    if (matchedConditionCount >= 1) {

                        String rekeningKoranTglTrans;

                        for(SCC_Rekening_Koran__c r : listrek ){

                             if(r.SCC_Tanggal_Transaksi__c != null || String.isNotBlank(r.SCC_Tanggal_Transaksi__c)){
                                String rekeningKoran = r.SCC_Tanggal_Transaksi__c.split('T')[0];
                                
                                if (String.isBlank(rekeningKoranTglTrans)) {
                                     rekeningKoranTglTrans = rekeningKoran;
                                } else {
                                    rekeningKoranTglTrans += ',' + rekeningKoran;
                                }
                            }
                            
                        }

                        s.Status = 'Closed';
                        s.SCC_Status_Transaksi__c = 'Gagal';
                        String amountz = s.SCC_Amount__c.format();
                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                        s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah pada tanggal ' + rekeningKoranTglTrans ;
                        
                        listcs.add(s);
                        matchedConditionCount = 0;
                        matchedKor = 0;
                    }
                    else {
                        matchedConditionCount = 0;
                        matchedKor = 0;
                    }
                }
            }

            if (!listcs.isEmpty()) {
                update listcs;
            }

            if(!listrek.isEmpty()) {
                insert listrek;
            }


        } catch (Exception exc) {
            InsertErrorLog(exc);
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Finish method is empty as we removed the chain to other batch processes
        if (!Test.isRunningTest()) {
            String cond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8434\' and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\') and CreatedDate = LAST_WEEK';
            String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(queries), 200);
        }
    }
   


    private SCC_Rekening_Koran__c mapRekeningKoran(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data , Case cs){
       
        SCC_Rekening_Koran__c rekeningKoran = new SCC_Rekening_Koran__c();
        rekeningKoran.SCC_Case__c = cS.id;
        rekeningKoran.SCC_auxtrc__c = data.auxtrc;
        rekeningKoran.SCC_Deskripsi_Transaksi__c = data.deskTran;
        rekeningKoran.SCC_GLSign__c = data.glsign;
        rekeningKoran.SCC_ID_Number__c = data.idNum;
        rekeningKoran.SCC_ID_Number_2__c = data.idNum2;
        rekeningKoran.SCC_ID_Number_3__c = data.idNum3;
        rekeningKoran.SCC_Jam_Transaksi__c  = data.jamTran;
        rekeningKoran.SCC_Jam_Trans__c = SCC_CaseResolution_UI.convertjam(data.jamTran);
        rekeningKoran.SCC_Kode_Transaksi__c = data.kodeTran;
        rekeningKoran.SCC_Mutasi_Debet__c = data.mutasiDebet;
        rekeningKoran.SCC_Mutasi_Kredit__c = data.mutasiKredit;
        rekeningKoran.SCC_Nomor_Rekening__c  = data.noRek;
        rekeningKoran.SCC_Saldo_Akhir_Mutasi__c = data.saldoAkhirMutasi;
        rekeningKoran.SCC_Saldo_Awal_Mutasi__c = data.saldoAwalMutasi;
        rekeningKoran.SCC_Sequence__c = data.seq;
        rekeningKoran.SCC_Serial__c = data.serial;
        rekeningKoran.SCC_Terbilang__c = data.terbilang;
        rekeningKoran.SCC_Tanggal_Effektif__c = data.tglEfektif;
        rekeningKoran.SCC_Tanggal_Transaksi__c = data.tglTran;
        rekeningKoran.SCC_tblds1__c = data.tlbds1;
        rekeningKoran.SCC_tblds2__c = data.tlbds2;
        rekeningKoran.SCC_trremk__c = data.trremk;
        rekeningKoran.SCC_Truser__c = data.truser;

        return rekeningKoran;
        
    }

    public class RekeningKoranEdcWrapper{
        public Boolean matchedKorRemark{get;set;} 
        public Boolean matchedConditionAmount{get; set;}
        public RekeningKoranEdcWrapper(Boolean matchedKorRemark , Boolean matchedConditionAmount){
            this.matchedKorRemark = matchedKorRemark;
            this.matchedConditionAmount = matchedConditionAmount;
        }
     }


     private RekeningKoranEdcWrapper checkRekeningKoranEdc(Case cS,  SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data, Map<String, Set<String>> mapKor){

        //get call type
        String caseType = cS.SCC_Call_Type__r.external_id__c;
        String brivaNumber = cS.SCC_Nomor_Briva_Tagihan__c;
        Boolean matchedKorRemark = false;
        Boolean matchedConditionAmount = (cS.SCC_Amount__c == data.mutasiKredit);
        System.debug('matchedConditionAmount rekening koran : '+matchedConditionAmount);
        String remark = data.trremk;

        if (!matchedConditionAmount) {
            return new RekeningKoranEdcWrapper(false, false);
        }
        else {
            Set<String> masterKorSet = mapKor.get(caseType);
            if(masterKorSet != null && !masterKorSet.isEmpty() && remark != null){
                Integer countKor = 0;
                for(String korType: masterKorSet){
                    System.debug('remark kor rekening koran : '+remark.toUpperCase());
                    System.debug('remark kor korType : '+korType.toUpperCase());
                    if(remark.toUpperCase().contains(korType.toUpperCase())){
                        System.debug('Kor Sama');
                        countKor++;
                    }
                }
                if(countKor == 1){
                    matchedKorRemark = true;
                }
            }
        }
        return new RekeningKoranEdcWrapper(matchedKorRemark, matchedConditionAmount);
     }
    

    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}