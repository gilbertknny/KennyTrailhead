/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 21-05-2025
 * @last modified by  : Ardyta Yudianto
**/
public with sharing class SCC_Batch_AutoClosed_MPN implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    public SCC_Batch_AutoClosed_MPN(String q) {
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
            
            for (Case s : scope) {
                Set<String> checkList = new Set<String>();
                if (s.scc_Billing_Number__c != null) {
                    checkList.add(s.scc_Billing_Number__c);
                }
                
                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
                req.channel = 'CHMS';
                req.norekVarchar = s.SCC_Account_Number__c;

                // Date todayz = Date.today();
                // String tgl = DateTime.newInstance(todayz, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                
                Date tgl2Date = s.SCC_Transaction_Date__c;
                String tgl2 = DateTime.newInstance(tgl2Date, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

                // req.tanggalAkhirDatetime = tgl;
                req.tanggalAkhirDatetime = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                req.tanggalAwalDatetime = tgl2;
                
                // listdel = [select id from SCC_Rekening_Koran__c where scc_case__c=:s.id];
                
                // String sccAuxtrc;
                // String sccDeskripsiTransaksi;
                // String sccGLSign;
                // Decimal sccIdNumber;
                // Decimal sccIdNumber2;
                // Decimal sccIdNumber3;
                // Decimal sccJamTransaksi;
                // String sccJamTrans;
                // String sccKodeTransaksi;
                // Decimal sccMutasiDebet;
                // Decimal sccMutasiKredit;
                // Decimal sccNomorRekening;
                // Decimal sccSaldoAkhirMutasi;
                // Decimal sccSaldoAwalMutasi;
                // Decimal sccSequence;
                // String sccSerial;
                // String sccTerbilang;
                // String sccTanggalEffektif;
                // String sccTanggalTransaksi;
                // String sccTblds1;
                // String sccTblds2;
                // String sccTrremk;
                // String sccTruser;
                
                // SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.searchSavingStatement(req, 'System', s.Id);
                // if (res.data != null) {
                //     Integer matchedConditionCount = 0;
                //     System.debug('Billing Number : '+s.scc_Billing_Number__c);
                //     System.debug('Ammount Case : '+s.SCC_Amount__c);
                //     for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData smd : res.data) {
                //         // String wordRmk = smd.trremk.substringBefore(' ');
                //         String wordRmk = smd.trremk;
                //         System.debug('Remark Rekening Koran : '+wordRmk);
                //         System.debug('Ammount Rekening Koran : '+smd.mutasiKredit);
                //         if(wordRmk.contains(s.scc_Billing_Number__c)){
                //             System.debug('billing number sama');
                //         }
                //         if(smd.mutasiKredit != s.SCC_Amount__c){
                //             System.debug('amount beda');
                //             continue;
                //         }
                //         if (wordRmk.contains(s.scc_Billing_Number__c) && smd.mutasiKredit == s.SCC_Amount__c ) { 
                //         // if (checkList.contains(wordRmk) && smd.mutasiKredit == s.SCC_Amount__c ){
                //             matchedConditionCount++;
                //             System.debug('Remark Rekening Koran : '+wordRmk);
                //             System.debug('matchedConditionCount Rekening Koran : '+matchedConditionCount);
                            
                //             sccAuxtrc = smd.auxtrc;
                //             sccDeskripsiTransaksi = smd.deskTran;
                //             sccGLSign = smd.glsign;
                //             sccIdNumber = smd.idNum;
                //             sccIdNumber2 = smd.idNum2;
                //             sccIdNumber3 = smd.idNum3;
                //             sccJamTransaksi = smd.jamTran;
                //             sccJamTrans = SCC_CaseResolution_UI.convertjam(smd.jamTran);
                //             sccKodeTransaksi = smd.kodeTran;
                //             sccMutasiDebet = smd.mutasiDebet;
                //             sccMutasiKredit = smd.mutasiKredit;
                //             sccNomorRekening = smd.noRek;
                //             sccSaldoAkhirMutasi = smd.saldoAkhirMutasi;
                //             sccSaldoAwalMutasi = smd.saldoAwalMutasi;
                //             sccSequence = smd.seq;
                //             sccSerial = smd.serial;
                //             sccTerbilang = smd.terbilang;
                //             sccTanggalEffektif = smd.tglEfektif;
                //             sccTanggalTransaksi = smd.tglTran;
                //             sccTblds1 = smd.tlbds1;
                //             sccTblds2 = smd.tlbds2;
                //             sccTrremk = smd.trremk;
                //             sccTruser = smd.truser;
                //         }
                        
                //         /*if (checkList.contains(wordRmk) && smd.mutasiKredit == s.SCC_Amount__c) {
                //             matchedConditionCount++;
                            
                //             sccAuxtrc = smd.auxtrc;
                //             sccDeskripsiTransaksi = smd.deskTran;
                //             sccGLSign = smd.glsign;
                //             sccIdNumber = smd.idNum;
                //             sccIdNumber2 = smd.idNum2;
                //             sccIdNumber3 = smd.idNum3;
                //             sccJamTransaksi = smd.jamTran;
                //             sccJamTrans = SCC_CaseResolution_UI.convertjam(smd.jamTran);
                //             sccKodeTransaksi = smd.kodeTran;
                //             sccMutasiDebet = smd.mutasiDebet;
                //             sccMutasiKredit = smd.mutasiKredit;
                //             sccNomorRekening = smd.noRek;
                //             sccSaldoAkhirMutasi = smd.saldoAkhirMutasi;
                //             sccSaldoAwalMutasi = smd.saldoAwalMutasi;
                //             sccSequence = smd.seq;
                //             sccSerial = smd.serial;
                //             sccTerbilang = smd.terbilang;
                //             sccTanggalEffektif = smd.tglEfektif;
                //             sccTanggalTransaksi = smd.tglTran;
                //             sccTblds1 = smd.tlbds1;
                //             sccTblds2 = smd.tlbds2;
                //             sccTrremk = smd.trremk;
                //             sccTruser = smd.truser;
                //         }*/
                        
                //         // if (matchedConditionCount > 1){
                //         //     break;
                //         // }
                //     }
                //     System.debug('matchedConditionCount : '+matchedConditionCount);
                    
                //     if (matchedConditionCount > 0) {
                //         s.Status = 'Closed';
                //         s.SCC_Status_Transaksi__c = 'Gagal';
                //         String amountz = s.SCC_Amount__c.format();
                //         s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                //         s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                //         s.SCC_Drone_Remark_Update__c = 'Transaksi Gagal Dana sudah dikembalikan ke rekening nasabah';
                        
                //         rek.SCC_Case__c = s.id;
                //         rek.SCC_auxtrc__c = sccAuxtrc;
                //         rek.SCC_Deskripsi_Transaksi__c = sccDeskripsiTransaksi;
                //         rek.SCC_GLSign__c = sccGLSign;
                //         rek.SCC_ID_Number__c = sccIdNumber;
                //         rek.SCC_ID_Number_2__c = sccIdNumber2;
                //         rek.SCC_ID_Number_3__c = sccIdNumber3;
                //         rek.SCC_Jam_Transaksi__c  = sccJamTransaksi;
                //         rek.SCC_Jam_Trans__c = sccJamTrans;
                //         rek.SCC_Kode_Transaksi__c = sccKodeTransaksi;
                //         rek.SCC_Mutasi_Debet__c = sccMutasiDebet;
                //         rek.SCC_Mutasi_Kredit__c = sccMutasiKredit;
                //         rek.SCC_Nomor_Rekening__c = sccNomorRekening;
                //         rek.SCC_Saldo_Akhir_Mutasi__c = sccSaldoAkhirMutasi;
                //         rek.SCC_Saldo_Awal_Mutasi__c = sccSaldoAwalMutasi;
                //         rek.SCC_Sequence__c = sccSequence;
                //         rek.SCC_Serial__c = sccSerial;
                //         rek.SCC_Terbilang__c = sccTerbilang;
                //         rek.SCC_Tanggal_Effektif__c = sccTanggalEffektif;
                //         rek.SCC_Tanggal_Transaksi__c = sccTanggalTransaksi;
                //         rek.SCC_tblds1__c = sccTblds1;
                //         rek.SCC_tblds2__c = sccTblds2;
                //         rek.SCC_trremk__c = sccTrremk;
                //         rek.SCC_Truser__c = sccTruser;
                        
                //         listcs.add(s);
                //         listrek.add(rek);
                //         matchedConditionCount = 0;
                //     }
                //     else{
                //         matchedConditionCount = 0;
                //     }
                // }

                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.searchSavingStatement(req, 'System', s.Id);
                System.debug('Response Rekening Koran : '+res);
                if(res != null && res.data != null && !res.data.isEmpty()){
                    Integer matchedConditionCount = 0;
                    SCC_Rekening_Koran__c matchedRekeningKoran = new SCC_Rekening_Koran__c();
                    for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : res.data){
                        String rekorRemark = dataMutation.trremk;
                        if (rekorRemark.contains(s.scc_Billing_Number__c) && dataMutation.mutasiKredit == s.SCC_Amount__c ){
                            matchedConditionCount++;
                            matchedRekeningKoran = mapRekeningKoran(dataMutation, s);
                            System.debug('matchedConditionCount Rekening Koran in loop: '+matchedConditionCount);
                            // if(dataMutation.tglTran != null || String.isNotBlank(dataMutation.tglTran)){
                            //     rekeningKoranTglTrans = dataMutation.tglTran.split('T')[0];
                            // }
                            
                        }
                    }
                    System.debug('matchedConditionCount Rekening Koran : '+matchedConditionCount);
                    if(matchedConditionCount >= 1){
                        s.Status = 'Closed';
                        s.SCC_Status_Transaksi__c = 'Gagal';
                        String amountz = s.SCC_Amount__c.format();
                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                        s.SCC_Drone_Remark_Update__c = 'Transaksi Gagal Dana sudah dikembalikan ke rekening nasabah';
                        listcs.add(s);
                        listrek.add(matchedRekeningKoran);
                    }
                }
            }

            if(!listcs.isEmpty()){
                update listcs;
            }
            if(!listrek.isEmpty()){
                insert listrek;
            }
            // if (!listcs.isEmpty()) {
            //     update listcs;
            //     if(!listrek.isempty()){
            //         if(!listdel.isempty()){
            //             delete listdel;
            //         }
            //         insert listrek;
            //     }
            // }
        } catch (Exception exc) {
            InsertErrorLog(exc);
        }
    }

     //map rekening koran
     private SCC_Rekening_Koran__c mapRekeningKoran(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data, Case cS){
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

    public void finish(Database.BatchableContext bc) {
            System.debug('===== SCC_Batch_AutoClosed_MPN: Batch job completed =====');
    }
   
    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed_MPN';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}