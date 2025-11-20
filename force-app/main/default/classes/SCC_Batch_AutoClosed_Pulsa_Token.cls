/**
 * @description       : autoclosed 8434, 8808, 8809
 * @author            : Christian Vieri
 * @last modified on  : 12-08-2025
 * @last modified by  : Christian Vieri
**/
public with sharing class SCC_Batch_AutoClosed_Pulsa_Token implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    public SCC_Batch_AutoClosed_Pulsa_Token(String q) {
        this.query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {

        Set<String> callTypes = new Set<String>();
        for(Case s : scope){
            if (s.SCC_Call_Type__c != null && s.SCC_Call_Type__r.external_id__c != null) {
                    callTypes.add(s.SCC_Call_Type__r.external_id__c);
            }
        }

          Map<String, List<Master_Mapping_Feature__c>> mapFeaturesByCaseType = new Map<String, List<Master_Mapping_Feature__c>>();
            if(!callTypes.isEmpty()){
                for(Master_Mapping_Feature__c mmf : [
                    SELECT Id, Feature__r.Fitur_ID__c, Remark__c, Remark_2__c, Case_Type__r.Name, Provider__c
                    FROM Master_Mapping_Feature__c
                    WHERE Case_Type__r.Name IN :callTypes
                ]){
                    if(!mapFeaturesByCaseType.containsKey(mmf.Case_Type__r.Name)){
                        mapFeaturesByCaseType.put(mmf.Case_Type__r.Name, new List<Master_Mapping_Feature__c>());
                    }
                    mapFeaturesByCaseType.get(mmf.Case_Type__r.Name).add(mmf);
                }
            }




        try {
            List<Case> listcs = new List<Case>();
            List<SCC_Rekening_Koran__c> listrek = new List<SCC_Rekening_Koran__c>();
            List<SCC_Rekening_Koran__c> listdel = new List<SCC_Rekening_Koran__c>();
            Set<String> featureIds = new Set<String>();
            SCC_Rekening_Koran__c rek = new SCC_Rekening_Koran__c();
            SCC_Rekon__c rekon = new SCC_Rekon__c();
            Boolean matchedConditionAmountFeature;
            String providerFeature ='';
            List<SCC_Rekon__c> listRekon = new List<SCC_Rekon__c>();
            String url_current = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
            for (Case s : scope) {
                system.debug('Ticket Numer: ' + s.CaseNumber);
                // Check if amount is less than 4000, if so close directly
                if (s.SCC_Amount__c != null && s.SCC_Amount__c <= 4000) {
                    s.Status = 'Closed';
                    s.SCC_Status_Transaksi__c = 'Berhasil';
                    String amountz = s.SCC_Amount__c.format();
                    s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                    s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                    s.SCC_Drone_Remark_Update__c = 'Nominal yang diinput adalah nominal fee transaksi. Mohon pastikan kembali nominal transaksi nasabah yang sesuai';
                    
                    listcs.add(s);
                    continue; 
                }
                
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
                System.debug('response data : ' + res.data);
                if (res.data != null) {
                    Integer matchedConditionCount = 0;
                    Integer matchedKor = 0;
                    Integer matchedKorUn = 0;
                    Integer matchedKorUnNon = 0;
                    Integer matchedProvider =0;
                    Boolean hasPULorPLS = false;
                    String notificationType;

                    String CaseType = s.SCC_Call_Type__r.external_id__c;
                    System.debug('case type:'  + CaseType);
                    System.debug('Case :' + s.Id);
                    Set<String> masterKorSet = (new Set<String>()); //Penampung untuk Kor yang akan digunakan bedasarkan case typenya
                    Map<String,String> korAndProvider = new  Map<String, String>();

                    for(master_kor__c mk : [SELECT Name, Provider__c FROM master_kor__c WHERE Case_Type__r.name =: CaseType]){
                        masterKorSet.add(mk.Name);
                        system.debug('Master Kor: ' + mk.Name);
                        korAndProvider.put(mk.Name, mk.Provider__c);  
                    }


                    
                    // Only proceed if PUL or PLS exists in at least one record
                        system.debug('masuk sini check layer 3');
                        for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData smd : res.data) {
                            System.debug(smd.trremk);
                            if (smd.trremk == null) continue;

                            // // //collect featureId from remark
                            SCC_MasterMappingFeature.MappingMasterWrapper featureId = SCC_MasterMappingFeature.getFeature(s, smd,mapFeaturesByCaseType);
                            System.debug('featureId: ' + featureId);

                            if(featureId != null){
                                matchedConditionAmountFeature = featureId.matchedConditionAmount;
                                providerFeature = featureId.provider;
                                String notesProvider = providerNotes(s);
                                if(matchedConditionAmountFeature && (providerFeature == notesProvider)){
                                    featureIds.add(featureId.FeatureId);
                                }

                            }
                            
                            Set<String> checkList = masterKorSet;
                            System.debug('checklist: ' + checkList); 
                            
                            // Get the string before the first space to handle space-delimited formats
                            String wordRmk = smd.trremk.substringBefore(' ');
                            System.debug('wordRmk:' + wordRmk);
                            
                            // IMPROVED MATCHING LOGIC - Begin
                            // Initialize variables
                            boolean isMatched = false;
                            String matchedKorType = '';
                            
                            // Loop through each item in the checklist and try different matching strategies
                            for(String korType : checkList) {


                                System.debug('Checking korType: ' + korType + ' against wordRmk: ' + wordRmk);

                                String providerFromMap = korAndProvider.get(korType) != null ? korAndProvider.get(korType).toUpperCase() : null;

                                System.debug('providerFromMap: ' + providerFromMap);

                                String providerFromNotes = providerNotes(s);
                                Boolean isProviderNotes = (providerFromMap != null && providerFromNotes != null && providerFromNotes == providerFromMap);

                                System.debug('isProviderNotes: ' + isProviderNotes);
                                
                                // Strategy 1: Direct contains check
                                if(wordRmk.contains(korType) && isProviderNotes) {
                                    isMatched = true;
                                    matchedKorType = korType;
                                    System.debug('Match found! wordRmk contains korType: ' + korType);
                                    break;
                                }
                                
                                // Strategy 2: Check if any part of wordRmk (split by colon) matches
                                if(wordRmk.contains(':') && isProviderNotes) {
                                    List<String> parts = wordRmk.split(':');
                                    for(String part : parts) {
                                        if(part.equals(korType)) {
                                            isMatched = true;
                                            matchedKorType = korType;
                                            System.debug('Match found! Part of wordRmk (' + part + ') equals korType: ' + korType);
                                            break;
                                        }
                                    }
                                    if(isMatched) break; // Exit outer loop if match found
                                }
                                
                                // Strategy 3: Check if korType is exactly equal to wordRmk
                                if(wordRmk.equals(korType) && isProviderNotes) {
                                    isMatched = true;
                                    matchedKorType = korType;
                                    System.debug('Exact match found! wordRmk equals korType: ' + korType);
                                    break;
                                }
                            }
                            
                            // Now proceed with the matched item if found
                            if(isMatched) {
                                matchedKor++;
                            }
                            // Keep the existing check for matching amount separate but use isMatched flag
                            //range

                            Integer maxRangeNominal = (s.SCC_Amount__c != null ? s.SCC_Amount__c.intValue() : 0) + 2000;

                            if (isMatched && (smd.mutasiKredit >= s.SCC_Amount__C && smd.mutasiKredit <= maxRangeNominal )) {
                                matchedConditionCount++;
                                System.debug('Amount match found! Incremented matchedConditionCount to: ' + matchedConditionCount);
                                
                                // sccAuxtrc = smd.auxtrc;
                                // sccDeskripsiTransaksi = smd.deskTran;
                                // sccGLSign = smd.glsign;
                                // sccIdNumber = smd.idNum;
                                // sccIdNumber2 = smd.idNum2;
                                // sccIdNumber3 = smd.idNum3;
                                // sccJamTransaksi = smd.jamTran;
                                // sccJamTrans = SCC_CaseResolution_UI.convertjam(smd.jamTran);
                                // sccKodeTransaksi = smd.kodeTran;
                                // sccMutasiDebet = smd.mutasiDebet;
                                // sccMutasiKredit = smd.mutasiKredit;
                                // sccNomorRekening = smd.noRek;
                                // sccSaldoAkhirMutasi = smd.saldoAkhirMutasi;
                                // sccSaldoAwalMutasi = smd.saldoAwalMutasi;
                                // sccSequence = smd.seq;
                                // sccSerial = smd.serial;
                                // sccTerbilang = smd.terbilang;
                                // sccTanggalEffektif = smd.tglEfektif;
                                // sccTanggalTransaksi = smd.tglTran;
                                // sccTblds1 = smd.tlbds1;
                                // sccTblds2 = smd.tlbds2;
                                // sccTrremk = smd.trremk;
                                // sccTruser = smd.truser;

                                rek = mapRekeningKoran(smd,s);
                                listrek.add(rek);

                            }
                            // IMPROVED MATCHING LOGIC - End        
                        }
                        
                        if (matchedConditionCount >= 1 && matchedKor >= 1) {
                            s.Status = 'Closed';
                            s.SCC_Status_Transaksi__c = 'Gagal';
                            String amountz = s.SCC_Amount__c.format();
                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                            s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                        
                            
                            // rek.SCC_Case__c = s.id;
                            // rek.SCC_auxtrc__c = sccAuxtrc;
                            // rek.SCC_Deskripsi_Transaksi__c = sccDeskripsiTransaksi;
                            // rek.SCC_GLSign__c = sccGLSign;
                            // rek.SCC_ID_Number__c = sccIdNumber;
                            // rek.SCC_ID_Number_2__c = sccIdNumber2;
                            // rek.SCC_ID_Number_3__c = sccIdNumber3;
                            // rek.SCC_Jam_Transaksi__c  = sccJamTransaksi;
                            // rek.SCC_Jam_Trans__c = sccJamTrans;
                            // rek.SCC_Kode_Transaksi__c = sccKodeTransaksi;
                            // rek.SCC_Mutasi_Debet__c = sccMutasiDebet;
                            // rek.SCC_Mutasi_Kredit__c = sccMutasiKredit;
                            // rek.SCC_Nomor_Rekening__c = sccNomorRekening;
                            // rek.SCC_Saldo_Akhir_Mutasi__c = sccSaldoAkhirMutasi;
                            // rek.SCC_Saldo_Awal_Mutasi__c = sccSaldoAwalMutasi;
                            // rek.SCC_Sequence__c = sccSequence;
                            // rek.SCC_Serial__c = sccSerial;
                            // rek.SCC_Terbilang__c = sccTerbilang;
                            // rek.SCC_Tanggal_Effektif__c = sccTanggalEffektif;
                            // rek.SCC_Tanggal_Transaksi__c = sccTanggalTransaksi;
                            // rek.SCC_tblds1__c = sccTblds1;
                            // rek.SCC_tblds2__c = sccTblds2;
                            // rek.SCC_trremk__c = sccTrremk;
                            // rek.SCC_Truser__c = sccTruser;
                            
                            listcs.add(s);
                            // listrek.add(rek);
                            matchedConditionCount = 0;
                            matchedKor = 0;
                        }
                        else{
                            System.debug('Masuk Rekon');
                            matchedConditionCount = 0;
                            matchedKor = 0; //disini manggil rekon dan harus cek casetype apa yang manggilnya
                            matchedKorUn = 0;
                            
                            System.debug('feature ids : ' + featureIds);

                            if(featureIds != null && featureIds.size() == 1){
                                //check rekon
                                for(String mw: featureIds){
                                    SCC_RekonWrapper.RekonTokenRequest reqRekon = new SCC_RekonWrapper.RekonTokenRequest();

                                    reqRekon.billingNumber = String.isNotBlank(s.scc_Billing_Number__c) 
                                        ? s.scc_Billing_Number__c 
                                        : s.Cust_Current_Phone__c;

                                    
                                    reqRekon.featureId = mw;
                                    reqRekon.transactionDate = DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');


                                    SCC_RekonWrapper.RekonTokenResponse resRekon = SCC_Rekon.searchRekonToken(reqRekon,'Drone', s.Id);

                                    
                                    if(resRekon.responseCode == '00' && resRekon != null){
                                        List<SCC_RekonWrapper.RekonTokenDetailData> listDetailData = resRekon.responseData.detailData;
                                        //SCC_RekonWrapper.RekonTokenDetailData dataRekon = resRekon.responseData.detailData;
                                        // String rekonStatus = dataRekon.StatusRecon;

                                        if(listDetailData != null && listDetailData.size()>0){
                                            for(SCC_RekonWrapper.RekonTokenDetailData detail : listDetailData) {

                                                if(detail.StatusRecon == 'Match' && s.SCC_Amount__c == Decimal.valueOf(detail.Nominal)){
                                                    matchedKor ++;
                                                    rekon = insertMapRekon(s,detail);
                                                    listRekon.add(rekon);
                                                }else if(detail.StatusRecon.contains('Unmatch') && detail.StatusMCS == '00' && s.SCC_Amount__c == Decimal.valueOf(detail.Nominal)){
                                                    matchedKorUn ++;
                                                    rekon = insertMapRekon(s,detail);
                                                    listRekon.add(rekon);
                                                }else if(detail.StatusRecon.contains('Unmatch') && detail.StatusMCS != '00' && s.SCC_Amount__c == Decimal.valueOf(detail.Nominal)){
                                                    matchedKorUnNon ++;
                                                    rekon = insertMapRekon(s,detail);
                                                    listRekon.add(rekon);
                                                }
                                                
                                            }

                                            if(matchedKor >= 1 && matchedKorUn >= 1 && matchedKorUnNon == 0){
                                                notificationType = 'Gagal';
                                            }else if(matchedKorUn>=1 && matchedKorUnNon >= 1){
                                                notificationType ='Gagal';
                                            }else if(matchedKor >= 1 && matchedKorUnNon == 0){
                                                notificationType = 'Berhasil';
                                            }else if(matchedKorUn >= 1){
                                                notificationType = 'Gagal';
                                            }


                                            if(notificationType == 'Gagal'){

                                                s.Status = 'Closed';
                                                s.SCC_Status_Transaksi__c = 'Gagal';
                                                String amountz = s.SCC_Amount__c.format();
                                                s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                                s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                                s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                                
                                                // listRekon.add(rekon);
                                                listcs.add(s);

                                            }else if(notificationType == 'Berhasil'){

                                                s.Status = 'Closed';
                                                s.SCC_Status_Transaksi__c = 'Berhasil';
                                                String amountz = s.SCC_Amount__c.format();
                                                s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                                s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                                s.SCC_Drone_Remark_Update__c = 'Transaksi sukses masuk ke Provider. Harap nasabah menghubungi Provider untuk konfirmasi.';
                                            
                                                
                                                // listRekon.add(rekon);
                                                listcs.add(s);
                                            }
                                        }

                                    }
                                }
                            }
  
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

                if(!listRekon.isEmpty()){
                    insert listRekon;
                }
            }
        } catch (Exception exc) {
            InsertErrorLog(exc);
        }
    }

    public void finish(Database.BatchableContext bc) {
        String nextBatchCond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8434\' and IsLocked__c=false and Exc_Autoclose__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\')';
        String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String nextQuery = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', nextBatchCond, '', '', '');
        Database.executeBatch(new SCC_Batch_Auto_Closed_Pulsa_Token_SLA(nextQuery), 1);
    }
   
    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed_Pulsa_token';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }

    // public Boolean getProviderByKor(Case cs , String kor, String CaseType ){

    //     Boolean isProviderTrue = false;

    //     List<master_kor__c> masterKorList = [SELECT Provider__c FROM master_kor__c WHERE Name =: kor AND Case_Type__r.Name =: CaseType LIMIT 1];
    //     system.debug('masterkorList for kor ' + kor + ': ' + masterKorList);
                                
    //     if (!masterKorList.isEmpty()) {
            
    //         String providerFromNotes = null;

    //             try {
    //                 if (String.isNotBlank(cs.scc_Notes__c)) {
    //                     Map<String, Object> notesMap = (Map<String, Object>) JSON.deserializeUntyped(cs.scc_Notes__c);
    //                         if (notesMap.containsKey('Provider') && notesMap.get('Provider') != null) {
    //                              providerFromNotes = String.valueOf(notesMap.get('Provider')).toUpperCase();
    //                         }
    //                     }
    //             } catch (Exception e) {
    //                 System.debug('Error parsing scc_Notes__c JSON: ' + e.getMessage());
    //             }

    //             if (masterKorList[0].Provider__c != null && masterKorList[0].Provider__c != '') {
    //                 if (providerFromNotes != null && providerFromNotes == masterKorList[0].Provider__c.toUpperCase()) {
    //                     isProviderTrue = true;
    //                 } 
    //             } 
    //     }    

    //     return isProviderTrue;
    // }


    public SCC_Rekon__c insertMapRekon(Case cs , SCC_RekonWrapper.RekonTokenDetailData rk){

        SCC_Rekon__c rek = new SCC_Rekon__c();
        rek.SCC_Account_Number__c = rk.RekKredit;
        rek.SCC_Amount__c = Decimal.valueOf(rk.Nominal);
        rek.SCC_Card_Number__c = rk.BillingCode;
        rek.SCC_Credit_Account__c = rk.RekKredit;
        //rek.SCC_Credit_Account_Type__c = rk.CreditAccountType;
        rek.SCC_Debet_Account__c = rk.RekDebet;
        rek.SCC_Penyelesaian_Rekon__c = rk.TanggalTrans;
        rek.SCC_Seq_No__c = Decimal.valueOf(rk.Seq);
        rek.SCC_Status_Penyelesaian__c  = rk.StatusMCSDesc;
        rek.SCC_Status_Rekon__c = rk.StatusRecon;
        // rek.SCC_Table_Rekon__c = rk.StatusRecon;
        //rek.SCC_Terminal_Id__c = rk.terminal_id;
        rek.SCC_Tanggal_Transaksi__c = rk.TanggalTrans;
        rek.SCC_UUID__c = String.valueOf(rk.ID);
        rek.scc_case__c = cs.id;

        return rek;
    }

    private String providerNotes(Case s){
        String providerFromNotes = null;
        try {
            if (String.isNotBlank(s.scc_Notes__c)) {
                Map<String, Object> notesMap = (Map<String, Object>) JSON.deserializeUntyped(s.scc_Notes__c);
                if (notesMap.containsKey('Provider') && notesMap.get('Provider') != null) {
                    providerFromNotes = String.valueOf(notesMap.get('Provider')).toUpperCase();
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing scc_Notes__c JSON: ' + e.getMessage());
        }

        return providerFromNotes;
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
}