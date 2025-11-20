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
                
                String sccAuxtrc;
                String sccDeskripsiTransaksi;
                String sccGLSign;
                Decimal sccIdNumber;
                Decimal sccIdNumber2;
                Decimal sccIdNumber3;
                Decimal sccJamTransaksi;
                String sccJamTrans;
                String sccKodeTransaksi;
                Decimal sccMutasiDebet;
                Decimal sccMutasiKredit;
                Decimal sccNomorRekening;
                Decimal sccSaldoAkhirMutasi;
                Decimal sccSaldoAwalMutasi;
                Decimal sccSequence;
                String sccSerial;
                String sccTerbilang;
                String sccTanggalEffektif;
                String sccTanggalTransaksi;
                String sccTblds1;
                String sccTblds2;
                String sccTrremk;
                String sccTruser;
                
                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.searchSavingStatement(req, 'System', s.Id);
                if (res.data != null) {
                    Integer matchedConditionCount = 0;
                    Integer matchedKor = 0;

                    for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData smd : res.data) {
                        String wordRmk = smd.trremk.substringBefore(' ');
                        
                        List<String> listKor = new List<String>(masterKorSet);
                        System.debug('kor : ' + listKor[0]);
                        System.debug('work rmk : ' + wordRmk);

                        // Check if the KOR type exists in Master_Kor__c for Case Type 8412
                        if (wordRmk.contains(listKor[0])) {
                            System.debug('matched kor : ' + matchedKor);
                            matchedKor++;
                        }
                        
                        if (wordRmk.contains(listKor[0]) && smd.mutasiKredit == s.SCC_Amount__c) {
                            System.debug('matched condition kor : ' + matchedKor);
                            matchedConditionCount++;
                            
                            sccAuxtrc = smd.auxtrc;
                            sccDeskripsiTransaksi = smd.deskTran;
                            sccGLSign = smd.glsign;
                            sccIdNumber = smd.idNum;
                            sccIdNumber2 = smd.idNum2;
                            sccIdNumber3 = smd.idNum3;
                            sccJamTransaksi = smd.jamTran;
                            sccJamTrans = SCC_CaseResolution_UI.convertjam(smd.jamTran);
                            sccKodeTransaksi = smd.kodeTran;
                            sccMutasiDebet = smd.mutasiDebet;
                            sccMutasiKredit = smd.mutasiKredit;
                            sccNomorRekening = smd.noRek;
                            sccSaldoAkhirMutasi = smd.saldoAkhirMutasi;
                            sccSaldoAwalMutasi = smd.saldoAwalMutasi;
                            sccSequence = smd.seq;
                            sccSerial = smd.serial;
                            sccTerbilang = smd.terbilang;
                            sccTanggalEffektif = smd.tglEfektif;
                            sccTanggalTransaksi = smd.tglTran;
                            sccTblds1 = smd.tlbds1;
                            sccTblds2 = smd.tlbds2;
                            sccTrremk = smd.trremk;
                            sccTruser = smd.truser;
                        }
                        
                        if (matchedKor > 1 || matchedConditionCount > 1){
                            break;
                        }
                    }
                    
                    if (matchedConditionCount == 1 && matchedKor == 1) {
                        s.Status = 'Closed';
                        s.SCC_Status_Transaksi__c = 'Gagal';
                        String amountz = s.SCC_Amount__c.format();
                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                        s.SCC_Drone_Remark_Update__c = 'Berdasarkan penelitian yang kami lakukan, transaksi yang di komplainkan nasabah gagal. '
                            + 'Pengembalian dana telah terkredit ke Rekening Nasabah pada tanggal ' + tgl2
                            + ' sebesar Rp' + amountz
                            + ' Mohon nasabah melakukan pengecekan Mutasi Rekening Koran.';
                        
                        rek.SCC_Case__c = s.id;
                        rek.SCC_auxtrc__c = sccAuxtrc;
                        rek.SCC_Deskripsi_Transaksi__c = sccDeskripsiTransaksi;
                        rek.SCC_GLSign__c = sccGLSign;
                        rek.SCC_ID_Number__c = sccIdNumber;
                        rek.SCC_ID_Number_2__c = sccIdNumber2;
                        rek.SCC_ID_Number_3__c = sccIdNumber3;
                        rek.SCC_Jam_Transaksi__c  = sccJamTransaksi;
                        rek.SCC_Jam_Trans__c = sccJamTrans;
                        rek.SCC_Kode_Transaksi__c = sccKodeTransaksi;
                        rek.SCC_Mutasi_Debet__c = sccMutasiDebet;
                        rek.SCC_Mutasi_Kredit__c = sccMutasiKredit;
                        rek.SCC_Nomor_Rekening__c = sccNomorRekening;
                        rek.SCC_Saldo_Akhir_Mutasi__c = sccSaldoAkhirMutasi;
                        rek.SCC_Saldo_Awal_Mutasi__c = sccSaldoAwalMutasi;
                        rek.SCC_Sequence__c = sccSequence;
                        rek.SCC_Serial__c = sccSerial;
                        rek.SCC_Terbilang__c = sccTerbilang;
                        rek.SCC_Tanggal_Effektif__c = sccTanggalEffektif;
                        rek.SCC_Tanggal_Transaksi__c = sccTanggalTransaksi;
                        rek.SCC_tblds1__c = sccTblds1;
                        rek.SCC_tblds2__c = sccTblds2;
                        rek.SCC_trremk__c = sccTrremk;
                        rek.SCC_Truser__c = sccTruser;
                        
                        listcs.add(s);
                        listrek.add(rek);
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