public with sharing class SCC_Batch_AutoClosed_RekeningKoran implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    public SCC_Batch_AutoClosed_RekeningKoran(String q) {
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
                
				//id SCCCase;
                String SCCauxtrc;
                String SCCDeskripsiTransaksi;
                String SCCGLSign;
               	Decimal SCCIDNumber;
                Decimal SCCIDNumber2;
                Decimal SCCIDNumber3;
                Decimal SCCJamTransaksi;
                String SCCJamTrans;
                String SCCKodeTransaksi;
                Decimal SCCMutasiDebet;
                Decimal SCCMutasiKredit;
                Decimal SCCNomorRekening;
                Decimal SCCSaldoAkhirMutasi;
                Decimal SCCSaldoAwalMutasi;
                Decimal SCCSequence;
                String SCCSerial;
                String SCCTerbilang;
                String SCCTanggalEffektif;
                String SCCTanggalTransaksi;
                String SCCtblds1;
                String SCCtblds2;
                String SCCtrremk;
                String SCCTruser;
                
                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = SCC_CaseResoultion_DataHub.searchSavingStatement(req, 'System', s.Id);
                if (res.data != null) {
                    Integer matchedConditionCount = 0;
                    Integer matchedKor = 0;
                    for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData smd : res.data) {
                        Set<String> checkList = new Set<String>{'KOR3', 'KOR4', 'KORNRS', 'KORNRS1', 'KOM5'};
                        String wordRmk = smd.trremk.substringBefore(' ');
                        
                        if (checkList.contains(wordRmk)){
                            matchedKor++;
                        }
                        
                        if (checkList.contains(wordRmk) && smd.mutasiKredit == s.SCC_Amount__c) {
                            matchedConditionCount++;
                            
                            SCCauxtrc = smd.auxtrc;
                            SCCDeskripsiTransaksi = smd.deskTran;
                            SCCGLSign = smd.glsign;
                            SCCIDNumber = smd.idNum;
                            SCCIDNumber2 = smd.idNum2;
                            SCCIDNumber3 = smd.idNum3;
                            SCCJamTransaksi = smd.jamTran;
                            SCCJamTrans = SCC_CaseResolution_UI.convertjam(smd.jamTran);
                            SCCKodeTransaksi = smd.kodeTran;
                            SCCMutasiDebet = smd.mutasiDebet;
                            SCCMutasiKredit = smd.mutasiKredit;
                            SCCNomorRekening = smd.noRek;
                            SCCSaldoAkhirMutasi = smd.saldoAkhirMutasi;
                            SCCSaldoAwalMutasi = smd.saldoAwalMutasi;
                            SCCSequence = smd.seq;
                            SCCSerial = smd.serial;
                            SCCTerbilang = smd.terbilang;
                            SCCTanggalEffektif = smd.tglEfektif;
                            SCCTanggalTransaksi = smd.tglTran;
                            SCCtblds1 = smd.tlbds1;
                            SCCtblds2 = smd.tlbds2;
                            SCCtrremk = smd.trremk;
                            SCCTruser = smd.truser;
                        }
                        
                        if (matchedKor > 1 || matchedConditionCount > 1){
                            break;
                        }

                    }

                    
                    if (matchedConditionCount == 1 && matchedKor == 1) {

                        String rekeningKoranTglTrans;
                        if(SCCTanggalTransaksi != null || String.isNotBlank(SCCTanggalTransaksi)){
                            rekeningKoranTglTrans = SCCTanggalTransaksi.split('T')[0];
                        }
                        s.Status = 'Closed';
                        s.SCC_Status_Transaksi__c = 'Gagal';
                        String amountz = s.SCC_Amount__c.format();
                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                        s.SCC_Drone_Remark_Update__c = 'Berdasarkan penelitian yang kami lakukan, transaksi yang di komplainkan nasabah gagal. '
                            + 'Pengembalian dana telah terkredit ke Rekening Nasabah pada tanggal ' + rekeningKoranTglTrans
                            + ' sebesar Rp' + amountz
                            + ' Mohon nasabah melakukan pengecekan Mutasi Rekening Koran.';

                        
                        rek.SCC_Case__c = s.id;
                        rek.SCC_auxtrc__c = SCCauxtrc;
                            rek.SCC_Deskripsi_Transaksi__c = SCCDeskripsiTransaksi;
                            rek.SCC_GLSign__c = SCCGLSign;
                            rek.SCC_ID_Number__c = SCCIDNumber;
                            rek.SCC_ID_Number_2__c = SCCIDNumber2;
                            rek.SCC_ID_Number_3__c = SCCIDNumber3;
                            rek.SCC_Jam_Transaksi__c  = SCCJamTransaksi;
                            rek.SCC_Jam_Trans__c = SCCJamTrans;
                            rek.SCC_Kode_Transaksi__c = SCCKodeTransaksi;
                            rek.SCC_Mutasi_Debet__c = SCCMutasiDebet;
                            rek.SCC_Mutasi_Kredit__c = SCCMutasiKredit;
                            rek.SCC_Nomor_Rekening__c = SCCNomorRekening;
                            rek.SCC_Saldo_Akhir_Mutasi__c = SCCSaldoAkhirMutasi;
                            rek.SCC_Saldo_Awal_Mutasi__c = SCCSaldoAwalMutasi;
                            rek.SCC_Sequence__c = SCCSequence;
                            rek.SCC_Serial__c = SCCSerial;
                            rek.SCC_Terbilang__c = SCCTerbilang;
                            rek.SCC_Tanggal_Effektif__c = SCCTanggalEffektif;
                            rek.SCC_Tanggal_Transaksi__c = SCCTanggalTransaksi;
                            rek.SCC_tblds1__c = SCCtblds1;
                            rek.SCC_tblds2__c = SCCtblds2;
                            rek.SCC_trremk__c = SCCtrremk;
                            rek.SCC_Truser__c = SCCTruser;
                        
                        listcs.add(s);
                        listrek.add(rek);
                        matchedConditionCount = 0;
                        matchedKor = 0;
                    }
                    else{
                        matchedConditionCount = 0;
                        matchedKor = 0;
                    }
                }
            }

            if (!listcs.isEmpty()) {
                update listcs;
                if(!listrek.isempty()){
                    if(!listdel.isempty()){
                        delete listdel;
                    }
                    insert listrek;
                }
            }
        } catch (Exception exc) {
            InsertErrorLog(exc);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            String cond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8222\' and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\') and CreatedDate = LAST_WEEK';
            String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Database.executeBatch(new SCC_Batch_AutoClosed_RTGS(queries), 200);
        }
    }

    public static void InsertErrorLog(Exception exc){
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