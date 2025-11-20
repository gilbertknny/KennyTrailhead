/** 
    Apex Name          : SCC_Batch_AutoClosed_RekeningKoran.cls
    Created Date       : 01 November 2024
    @description       : This is class ..
    @author            : Lucas Kalasuvich, Reinaldy Thando, Alvin Vigo
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   01/11/2024   Alvin Vigo , Dwiki                FIX PMD Naming Style
    1.0   12/02/2025   Rakeyan Nuramria                  Add condition for call type 8809
    1.0   13/02/2025   Christian Vieri                   Add condition for call type 8834
    1.0   04/03/2025   Herbing                           Add condition for call type 8222
**/

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

                    // String CaseType = s.SCC_Call_Type__r.external_id__c;
                    // //Penampung untuk Kor yang akan digunakan bedasarkan case typenya
                    // Set<String> masterKorSet = (new Set<String>());
                    // if(CaseType == '8834'){
                    //     for(master_kor__c mk : [SELECT Name FROM master_kor__c WHERE Case_Type__r.name =: CaseType]){
                    //         masterKorSet.add(mk.Name);
                    //     }
                    // }else if(CaseType == '8808' || CaseType == '8809'){
                    //     for(master_kor__c mk : [SELECT Name FROM master_kor__c WHERE Case_Type__r.name =: CaseType]){
                    //         masterKorSet.add(mk.Name);
                    //     }
                    // }

                    //Seharusnya nanti akan pakai ini tidak perlu hardcode case typenya karena Kornya sudah disimpan di dalam Objet Master Kor --Vieri--
                    /* 
                    for(master_kor__c mk : [SELECT Name FROM master_kor__c WHERE Case_Type__r.name =: CaseType]){
                            masterKorSet.add(mk.Name);
                        }
                    */

                    for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData smd : res.data) {

                        // Set<String> checkList;

                        //Seharusnya kedepannya akan pakai ini karena Kor sudah di simpan di dalam object Master Kor -- Vieri--
                        /* Set<String> checkList = masterKorSet; */

                        // if (s.SCC_Call_Type__r.external_id__c == '8809' || s.SCC_Call_Type__r.external_id__c == '8808' ) {
                        //     checkList = masterKorSet;
                        // } else if(CaseType == '8834'){
                        //     checkList = masterKorSet;
                        // }else{
                        //     checkList = new Set<String>{'KOR3', 'KOR4', 'KORNRS', 'KORNRS1', 'KOM5', 'KORPLN'};
                        // }

                        Set<String> checkList = new Set<String>{'KOR3', 'KOR4', 'KORNRS', 'KORNRS1', 'KOM5', 'KORPLN'};
                        
                        String wordRmk = smd.trremk.substringBefore(' ');
                        
                        if (checkList.contains(wordRmk)){
                            matchedKor++;
                        }
                        
                        if (checkList.contains(wordRmk) && smd.mutasiKredit == s.SCC_Amount__c) {
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
                    else{
                        matchedConditionCount = 0;
                        matchedKor = 0; //disini manggil rekon dan harus cek casetype apa yang manggilnya
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
        /*
        String nextBatchCond = '(isclosed = false OR IsClosed__c = false) and (SCC_Call_Type__r.external_id__c=\'8834\' or SCC_Call_Type__r.external_id__c=\'8808\' or SCC_Call_Type__r.external_id__c=\'8809\') and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\')';
        String nextAddField = ',SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
        String nextAllfield = SOQL_SOBJECT.getallfield('Case');
        String nextQuery = SOQL_SOBJECT.SOQL(nextAllfield, nextAddField, 'Case', nextBatchCond, '', '', '');
        
        // Memanggil batch class SCC_Batch_AutoClosed_Pulsa_Token
        Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(nextQuery), 1);
        */
        String nextBatchCond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8222\' and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\')';
        String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String nextQuery = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', nextBatchCond, '', '', '');
        Database.executeBatch(new SCC_Batch_AutoClosed_RTGS(nextQuery), 1);
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