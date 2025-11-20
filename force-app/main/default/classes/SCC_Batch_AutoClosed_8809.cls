/**
 * @description       : autoclosed 8808, 8809
 * @author            : Suherbing
 * @last modified on  : 20-07-2025
 * @last modified by  : Bing
**/
public with sharing class SCC_Batch_AutoClosed_8809 implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    public SCC_Batch_AutoClosed_8809(String q) {
        this.query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        try {
            // =================================================================================
            // BAGIAN 1: PERSIAPAN DATA SECARA MASSAL (BULKIFICATION)
            // =================================================================================

            Set<String> callTypes = new Set<String>();
            for(Case s : scope){
                if (s.SCC_Call_Type__c != null && s.SCC_Call_Type__r.external_id__c != null) {
                    callTypes.add(s.SCC_Call_Type__r.external_id__c);
                }
            }

            Map<String, Set<String>> mapKorByCaseType = new Map<String, Set<String>>();
            if(!callTypes.isEmpty()){
                for(Master_Kor__c mk : [SELECT Name, Case_Type__r.Name FROM Master_Kor__c WHERE Case_Type__r.Name IN :callTypes]) {
                    if (!mapKorByCaseType.containsKey(mk.Case_Type__r.Name)) {
                        mapKorByCaseType.put(mk.Case_Type__r.Name, new Set<String>());
                    }
                    mapKorByCaseType.get(mk.Case_Type__r.Name).add(mk.Name);
                }
            }

            Map<String, List<Master_Mapping_Feature__c>> mapFeaturesByCaseType = new Map<String, List<Master_Mapping_Feature__c>>();
            if(!callTypes.isEmpty()){
                for(Master_Mapping_Feature__c mmf : [
                    SELECT Id, Feature__r.Fitur_ID__c, Remark__c, Remark_2__c, Case_Type__r.Name
                    FROM Master_Mapping_Feature__c
                    WHERE Case_Type__r.Name IN :callTypes
                ]){
                    if(!mapFeaturesByCaseType.containsKey(mmf.Case_Type__r.Name)){
                        mapFeaturesByCaseType.put(mmf.Case_Type__r.Name, new List<Master_Mapping_Feature__c>());
                    }
                    mapFeaturesByCaseType.get(mmf.Case_Type__r.Name).add(mmf);
                }
            }

            String featureId8808 = '';
            List<Master_Mapping_Feature__c> featureMappings8808 = mapFeaturesByCaseType.get('8808');
            if (featureMappings8808 != null && featureMappings8808.size() == 1) {
                featureId8808 = featureMappings8808[0].Feature__r.Fitur_ID__c;
            }

            List<Case> casesToUpdate = new List<Case>();
            List<SCC_Rekening_Koran__c> rekorsToInsert = new List<SCC_Rekening_Koran__c>();
            List<SCC_Rekon__c> rekonsToInsert = new List<SCC_Rekon__c>();

            // =================================================================================
            // BAGIAN 2: PROSES UTAMA DENGAN LOGIKA TERPISAH
            // =================================================================================
            for(Case s : scope){

                if (s.SCC_Call_Type__r == null) continue;

                system.debug('Ticket Numer: ' + s.CaseNumber);
                // Check if amount is less than 4000, if so close directly
                if (s.SCC_Amount__c != null && s.SCC_Amount__c <= 6000) {
                    s.Status = 'Closed';
                    s.SCC_Status_Transaksi__c = 'Tidak Kirim Notifikasi';
                    // String amountz = s.SCC_Amount__c.format();
                    s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                    s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                    s.SCC_Drone_Remark_Update__c = 'Nominal yang diinput adalah nominal fee transaksi. Mohon pastikan kembali nominal transaksi nasabah yang sesuai. Terima kasih.';
                    
                    casesToUpdate.add(s);
                    continue; 
                }

                boolean isCaseHandled = false;

                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest reqSavingMutation = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
                reqSavingMutation.channel = 'CHMS';
                reqSavingMutation.norekVarchar = s.SCC_Account_Number__c;
                reqSavingMutation.tanggalAwalDatetime =  DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                reqSavingMutation.tanggalAkhirDatetime = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

                System.debug('Auto Close CaseType PLN ; '+reqSavingMutation);

                //-----------------------------------------------------
                // LOGIKA KHUSUS UNTUK CASE TYPE 8808
                //-----------------------------------------------------
                if(s.SCC_Call_Type__r.external_id__c == '8808'){

                    // Jalur 1: Coba via Rekon jika Feature ID sudah pasti dan ada Billing Number
                    if(String.isNotBlank(s.scc_Billing_Number__c)){
                        if(String.isNotBlank(featureId8808)){

                            SCC_RekonWrapper.RekonTokenRequest reqRekon = new SCC_RekonWrapper.RekonTokenRequest();
                            reqRekon.featureId = featureId8808;
                            reqRekon.transactionDate = String.valueOf(s.SCC_Transaction_Date__c);
                            reqRekon.billingNumber = s.scc_Billing_Number__c;
                            SCC_RekonWrapper.RekonTokenResponse resRekon = SCC_Rekon.searchRekonToken(reqRekon, '', '');
                            System.debug('resRekon 8809 test: '+resRekon);
                            if(resRekon != null && resRekon.responseData != null && resRekon.responseData.detailData != null) {
                                System.debug('eksekusi 8808 resRekon not null');
                                Integer matchCount = 0;
                                String nmrTokenMatch = '';
                                String nmrTokenUnmatch = '';
                                // String statusMatch = '';
                                SCC_Rekon__c rekonData = new SCC_Rekon__c();
                                List<String> statusMatch = new List<String>();
                                List<SCC_RekonWrapper.RekonTokenDetailData> matchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                List<SCC_RekonWrapper.RekonTokenDetailData> unmatchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                for(SCC_RekonWrapper.RekonTokenDetailData detail : resRekon.responseData.detailData) {
                                    Decimal rkNominal = (detail.Nominal != null) ? Decimal.valueOf(detail.Nominal) : null;
                                    if(String.isNotBlank(detail.NoToken) && rkNominal == s.SCC_Amount__c) {
                                        if(detail.StatusRecon == 'Match'){
                                            matchCount++;
                                            statusMatch.add('1');
                                            matchDetails.add(detail);
                                            // rekonData = insertMapRekon(s, detail);
                                        }
                                        else if (detail.StatusRecon.toLowerCase().contains('unmatch') && detail.StatusMCS == '00'){
                                            matchCount++;
                                            statusMatch.add('0');
                                            unmatchDetails.add(detail);
                                            // rekonData = insertMapRekon(s, detail);
                                        }
                                    }
                                }
                                System.debug('cek matchCount : '+matchCount);
    
                                // cek autoclose dari rekon
                                if(matchCount >= 1) {
                                    System.debug('eksekusi 8808 statusMacth : '+statusMatch);
                                    if(statusMatch.contains('1')){
                                        System.debug('eksekusi 8808 status : Match');
                                        for (SCC_RekonWrapper.RekonTokenDetailData detail : matchDetails){
                                            System.debug('detail rekon : '+detail);
                                            rekonData = insertMapRekon(s, detail);
                                            System.debug('insertMapRekon : '+rekonData);
                                            rekonsToInsert.add(rekonData);
                                            String token = detail.NoToken;
                                            if (String.isNotBlank(detail.NoToken)){
                                                token = detail.NoToken.replaceAll('(\\d{4})(?=\\d)', '$1 ');
                                            }
                                            if(nmrTokenMatch == ''){
                                                nmrTokenMatch = token;
                                            }else{
                                                nmrTokenMatch = nmrTokenMatch+' || '+token;
                                            }
                                        }
                                        s.Status = 'Closed';
                                        s.SCC_Status_Transaksi__c = 'Berhasil';
                                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                        s.Nomor_Token_PLN__c = nmrTokenMatch;
                                        s.SCC_Drone_Remark_Update__c = 'Transaksi sukses dengan nomor token : '+nmrTokenMatch;
                                    }else{
                                        System.debug('eksekusi 8808 status : Unmatch');
                                        for (SCC_RekonWrapper.RekonTokenDetailData detail : unmatchDetails){
                                            rekonData = insertMapRekon(s, detail);
                                            rekonsToInsert.add(rekonData);
                                            String token = detail.NoToken;
                                            if (String.isNotBlank(detail.NoToken)){
                                                token = detail.NoToken.replaceAll('(\\d{4})(?=\\d)', '$1 ');
                                            }
                                            if(nmrTokenUnmatch == ''){
                                                nmrTokenUnmatch = token;
                                            }else{
                                                nmrTokenUnmatch = nmrTokenUnmatch+' || '+token;
                                            }
                                        }
                                        s.Status = 'Closed';
                                        s.SCC_Status_Transaksi__c = 'Gagal';
                                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                        s.Nomor_Token_PLN__c = nmrTokenUnmatch;
                                        s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                    }
                                    casesToUpdate.add(s);
                                    isCaseHandled = true;
                                }
    
                                // cek autoclose dari rekening koran
                                else{
                                    SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse resSavingMutation = SCC_CaseResoultion_DataHub.searchSavingStatement(reqSavingMutation, 'Auto Closed Briva', s.Id);
                                    if(resSavingMutation != null && resSavingMutation.data != null && !resSavingMutation.data.isEmpty()){
                                        Integer matchedKorCount = 0;
                                        SCC_Rekening_Koran__c matchedRekeningKoran = new SCC_Rekening_Koran__c();
    
                                        for (SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : resSavingMutation.data) {
                                            RekeningKoranBrivaWrapper resultKor = checkRekeningKoranBriva(s, dataMutation, mapKorByCaseType);
                                            if (resultKor.matchedKorRemark && resultKor.matchedConditionAmount) {
                                                matchedKorCount++;
                                                matchedRekeningKoran = mapRekeningKoran(dataMutation, s);
                                                rekorsToInsert.add(matchedRekeningKoran);
                                            }
                                        }
    
                                        if(matchedKorCount >= 1){
                            
                                            //add case record to list
                                            s.Status = 'Closed';
                                            s.SCC_Status_Transaksi__c = 'Gagal';
                                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                            s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                            casesToUpdate.add(s);
                                            // rekorsToInsert.add(matchedRekeningKoran);
                                            isCaseHandled = true;
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            //call api saving statement
                            SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse resSavingMutation = SCC_CaseResoultion_DataHub.searchSavingStatement(reqSavingMutation, 'Auto Closed Briva', s.Id);
                            if(resSavingMutation != null && resSavingMutation.data != null && !resSavingMutation.data.isEmpty()){

                                Integer matchedKorCount = 0;
                                Integer matchedFeatureCount = 0;
                                SCC_Rekening_Koran__c matchedRekeningKoran = new SCC_Rekening_Koran__c();
                                Set<String> fiturIdRekon = new Set<String>();
                                String foundFeatureId = '';
                                List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData> matchDataMutation = new List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData>();
                                for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : resSavingMutation.data){

                                    SCC_MasterMappingFeature.MappingMasterWrapper resultFeature = SCC_MasterMappingFeature.getFeature(s, dataMutation, mapFeaturesByCaseType);
                                    System.debug('resultFeature 8808 via rekening koran 1 : '+resultFeature);
                                    System.debug('resultFeature 8808 via rekening koran 2 : '+resultFeature.matchedConditionAmount);
                                    if (resultFeature != null && resultFeature.matchedConditionAmount) {
                                        matchedFeatureCount++;
                                        fiturIdRekon.add(resultFeature.FeatureId);
                                        foundFeatureId = resultFeature.FeatureId;
                                    }

                                    RekeningKoranBrivaWrapper resultKor = checkRekeningKoranBriva(s, dataMutation, mapKorByCaseType);
                                    System.debug('resultKor 8808 via rekening koran 1 : '+resultKor);
                                    System.debug('resultKor 8808 via rekening koran 2 : '+resultKor.matchedConditionAmount);
                                    if(resultKor.matchedKorRemark && resultKor.matchedConditionAmount){
                                        matchedKorCount++;
                                        matchDataMutation.add(dataMutation);
                                        // matchedRekeningKoran = mapRekeningKoran(dataMutation, s);
                                    }
                                }
                                Integer countFitur = fiturIdRekon.size();
                                if(countFitur == 1){
                                    SCC_RekonWrapper.RekonTokenRequest reqRekon = new SCC_RekonWrapper.RekonTokenRequest();
                                    //lanjut eksekusi rekon
                                    reqRekon.featureId = foundFeatureId;
                                    reqRekon.transactionDate = String.valueOf(s.SCC_Transaction_Date__c);
                                    reqRekon.billingNumber = s.scc_Billing_Number__c;
                                    SCC_RekonWrapper.RekonTokenResponse resRekon = SCC_Rekon.searchRekonToken(reqRekon, '', '');

                                    if(resRekon != null && resRekon.responseData != null && resRekon.responseData.detailData != null) {
                                        Integer matchCount = 0;
                                        String nmrTokenMatch = '';
                                        String nmrTokenUnmatch = '';
                                        List<String> statusMatch = new List<String>();
                                        SCC_Rekon__c rekonData = new SCC_Rekon__c();
                                        List<SCC_RekonWrapper.RekonTokenDetailData> matchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                        List<SCC_RekonWrapper.RekonTokenDetailData> unmatchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                        for(SCC_RekonWrapper.RekonTokenDetailData detail : resRekon.responseData.detailData) {
                                            Decimal rkNominal = (detail.Nominal != null) ? Decimal.valueOf(detail.Nominal) : null;
                                            if(String.isNotBlank(detail.NoToken) && rkNominal == s.SCC_Amount__c) {
                                                if(detail.StatusRecon == 'Match'){
                                                    matchCount++;
                                                    statusMatch.add('1');
                                                    matchDetails.add(detail);
                                                    // rekonData = insertMapRekon(s, detail);
                                                }
                                                else if (detail.StatusRecon.toLowerCase().contains('unmatch') && detail.StatusMCS == '00') {
                                                    matchCount++;
                                                    statusMatch.add('0');
                                                    unmatchDetails.add(detail);
                                                    // rekonData = insertMapRekon(s, detail);
                                                }
                                            }
                                        }
                                        if(matchCount >= 1) {
                                            System.debug('eksekusi 8808 statusMacth 2 : '+statusMatch);
                                            if(statusMatch.contains('1')){
                                                for(SCC_RekonWrapper.RekonTokenDetailData detail : matchDetails){
                                                    rekonData = insertMapRekon(s, detail);
                                                    rekonsToInsert.add(rekonData);
                                                    String token = detail.NoToken;
                                                    if (String.isNotBlank(detail.NoToken)){
                                                        token = detail.NoToken.replaceAll('(\\d{4})(?=\\d)', '$1 ');
                                                    }
                                                    if(nmrTokenMatch == ''){
                                                        nmrTokenMatch = token;
                                                    }else{
                                                        nmrTokenMatch = nmrTokenMatch+' || '+token;
                                                    }
                                                }
                                                s.Status = 'Closed';
                                                s.SCC_Status_Transaksi__c = 'Berhasil';
                                                s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                                s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                                s.Nomor_Token_PLN__c = nmrTokenMatch;
                                                s.SCC_Drone_Remark_Update__c = 'Transaksi sukses dengan nomor token : '+nmrTokenMatch;
                                            }else{
                                                System.debug('eksekusi 8808 status : Unmatch');
                                                for(SCC_RekonWrapper.RekonTokenDetailData detail : unmatchDetails){
                                                    rekonData = insertMapRekon(s, detail);
                                                    rekonsToInsert.add(rekonData);
                                                    String token = detail.NoToken;
                                                    if (String.isNotBlank(detail.NoToken)){
                                                        token = detail.NoToken.replaceAll('(\\d{4})(?=\\d)', '$1 ');
                                                    }
                                                    if(nmrTokenUnmatch == ''){
                                                        nmrTokenUnmatch = token;
                                                    }else{
                                                        nmrTokenUnmatch = nmrTokenUnmatch+' || '+token;
                                                    }
                                                }
                                                s.Status = 'Closed';
                                                s.SCC_Status_Transaksi__c = 'Gagal';
                                                s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                                s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                                s.Nomor_Token_PLN__c = nmrTokenUnmatch;
                                                s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                            }
                                            casesToUpdate.add(s);
                                            isCaseHandled = true;
                                        }

                                        // cek autoclose dari rekening koran
                                        else {
                                            if(matchedKorCount >= 1){
                                
                                                //add case record to list
                                                s.Status = 'Closed';
                                                s.SCC_Status_Transaksi__c = 'Gagal';
                                                s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                                s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                                s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                                for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : matchDataMutation){
                                                    matchedRekeningKoran = mapRekeningKoran(dataMutation, s);
                                                    rekorsToInsert.add(matchedRekeningKoran);
                                                }
                                                casesToUpdate.add(s);
                                                isCaseHandled = true;
                                            }
                                        }
                                    }
                                }
                                else{
                                    if(matchedKorCount >= 1){
                                
                                        //add case record to list
                                        s.Status = 'Closed';
                                        s.SCC_Status_Transaksi__c = 'Gagal';
                                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                        s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                        for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : matchDataMutation){
                                            matchedRekeningKoran = mapRekeningKoran(dataMutation, s);
                                            rekorsToInsert.add(matchedRekeningKoran);
                                        }
                                        casesToUpdate.add(s);
                                        isCaseHandled = true;
                                    }
                                }
                            }
                        }
                    }
                }
                //cek jika casetypenya 8809
                else if(s.SCC_Call_Type__r.external_id__c == '8809'){
                    System.debug('Auto Close CaseType 8809');
                    //call api saving statement
                    SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse resSavingMutation = SCC_CaseResoultion_DataHub.searchSavingStatement(reqSavingMutation, 'Auto Closed 8809', s.Id);
                    System.debug('Auto Close CaseType 8809 resSavingMutation : '+resSavingMutation);
                    //cek jika listSavingMutationData tidak null
                    if(resSavingMutation != null && resSavingMutation.data != null && !resSavingMutation.data.isEmpty()){
                        Set<String> fiturIdRekon = new Set<String>();
                        Integer matchedKorCount = 0;
                        Integer matchedFeatureCount = 0;
                        SCC_Rekening_Koran__c matchedRekeningKoran = new SCC_Rekening_Koran__c();
                        String foundFeatureId = '';
                        String rekeningKoranTglTrans = '';
                        
                        for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : resSavingMutation.data){
                            RekeningKoranBrivaWrapper resultKor = checkRekeningKoranBriva(s, dataMutation, mapKorByCaseType);
                            System.debug('Check 8809 resultKor : '+resultKor);
                            if(resultKor.matchedKorRemark && resultKor.matchedConditionAmount){
                                System.debug('Check 8809 rekening koran match');
                                matchedKorCount++;
                                matchedRekeningKoran = mapRekeningKoran(dataMutation, s);
                                System.debug('cek tgl kor : '+dataMutation.tglTran);
                                // if(rekeningKoranTglTrans == ''){
                                //     if(dataMutation.tglTran != null || String.isNotBlank(dataMutation.tglTran)){
                                //         rekeningKoranTglTrans = dataMutation.tglTran.split('T')[0];
                                //     }
                                // }
                                if(dataMutation.tglTran != null || String.isNotBlank(dataMutation.tglTran)){
                                    rekeningKoranTglTrans = dataMutation.tglTran.split('T')[0];
                                }
                                rekorsToInsert.add(matchedRekeningKoran);
                            }

                            SCC_MasterMappingFeature.MappingMasterWrapper resultFeature = SCC_MasterMappingFeature.getFeature(s, dataMutation, mapFeaturesByCaseType);
                            System.debug('Check 8809 resultFeature : '+resultFeature);
                            System.debug('Check 8809 matchedConditionAmount : '+resultFeature.matchedConditionAmount);
                            if (resultFeature != null && resultFeature.matchedConditionAmount) {
                                System.debug('Check 8809 rekon match');
                                matchedFeatureCount++;
                                foundFeatureId = resultFeature.FeatureId;
                                fiturIdRekon.add(resultFeature.FeatureId);
                            }
                        }

                        Integer countFitur = fiturIdRekon.size();
                        System.debug('Check 8809 countFitur rekon : '+countFitur);
                        if(matchedKorCount >= 1){
                            System.debug('Auto Close CaseType 8809 Rekening Koran');
                            System.debug('Cek list tanggal : '+rekeningKoranTglTrans);
                            String tglTransaksi = DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                            s.Status = 'Closed';
                            s.SCC_Status_Transaksi__c = 'Gagal';
                            String amountFormated = s.SCC_Amount__c.format();
                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                            s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah sebesar '+amountFormated+' pada tanggal '+rekeningKoranTglTrans;
                            casesToUpdate.add(s);
                            isCaseHandled = true;
                        }
                        else{
                            System.debug('Masuk Auto Close CaseType 8809 Rekon');
                            if(countFitur == 1){
                                System.debug('Auto Close CaseType 8809 Rekon countFitur : '+countFitur);
                                // lanjut eksekusi rekon
                                SCC_RekonWrapper.RekonTokenRequest reqRekon = new SCC_RekonWrapper.RekonTokenRequest();
                                reqRekon.featureId = foundFeatureId;
                                reqRekon.transactionDate = String.valueOf(s.SCC_Transaction_Date__c);
                                reqRekon.billingNumber = s.scc_Billing_Number__c;
                                System.debug('reqRekon :'+reqRekon);
                                SCC_RekonWrapper.RekonTokenResponse resRekon = SCC_Rekon.searchRekonToken(reqRekon, '', '');
                                System.debug('resRekon :'+resRekon);
                                if(resRekon != null && resRekon.responseData != null && resRekon.responseData.detailData != null) {
                                    Integer matchCount = 0;
                                    System.debug('masuk untuk prepare close rekon');
                                    List<String> statusMatch = new List<String>();
                                    SCC_Rekon__c rekonData = new SCC_Rekon__c();
                                    List<SCC_RekonWrapper.RekonTokenDetailData> matchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                    List<SCC_RekonWrapper.RekonTokenDetailData> unmatchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                    for(SCC_RekonWrapper.RekonTokenDetailData detail : resRekon.responseData.detailData) {
                                        Decimal rkNominal = (detail.Nominal != null) ? Decimal.valueOf(detail.Nominal) : null;
                                        if(rkNominal == s.SCC_Amount__c) {
                                            if(detail.StatusRecon == 'Match'){
                                                System.debug('masuk rekon match');
                                                matchCount++;
                                                matchDetails.add(detail);
                                                statusMatch.add('1');
                                                // rekonData = insertMapRekon(s,detail);
                                            }
                                            else if(detail.StatusRecon.toLowerCase().contains('unmatch') && detail.StatusMCS == '00'){
                                                System.debug('masuk rekon unmatch');
                                                matchCount++;
                                                unmatchDetails.add(detail);
                                                statusMatch.add('0');
                                                // rekonData = insertMapRekon(s,detail);
                                            }
                                        }
                                    }
                                    System.debug('matchCount :'+matchCount);
                                    if(matchCount >= 1) {
                                        if(statusMatch.contains('0')){
                                            System.debug('update close rekon');
                                            String tglTransaksi = DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                                            s.Status = 'Closed';
                                            s.SCC_Status_Transaksi__c = 'Gagal';
                                            String amountFormated = s.SCC_Amount__c.format();
                                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                            s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah sebesar '+amountFormated+' pada tanggal '+tglTransaksi;
                                            for (SCC_RekonWrapper.RekonTokenDetailData detail : unmatchDetails) {
                                                rekonData = insertMapRekon(s,detail);
                                                System.debug('Data Rekon 1 : '+rekonData);
                                                rekonsToInsert.add(rekonData);
                                                System.debug('Data Rekon 2 : '+rekonsToInsert);
                                            }
                                        }else{
                                            System.debug('update close rekon');
                                            s.Status = 'Closed';
                                            s.SCC_Status_Transaksi__c = 'Berhasil';
                                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                            s.SCC_Drone_Remark_Update__c = 'Transaksi sukses, mohon nasabah konfirmasi ke pihak PLN.';
                                            for (SCC_RekonWrapper.RekonTokenDetailData detail : matchDetails) {
                                                rekonData = insertMapRekon(s,detail);
                                                System.debug('Data Rekon 1 : '+rekonData);
                                                rekonsToInsert.add(rekonData);
                                                System.debug('Data Rekon 2 : '+rekonsToInsert);
                                            }
                                        }
                                        casesToUpdate.add(s);
                                        isCaseHandled = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================================
            // BAGIAN 3: EKSEKUSI DML
            // =================================================================================
            if(!casesToUpdate.isEmpty()){
                update casesToUpdate;
            }
            if(!rekorsToInsert.isEmpty()){
                insert rekorsToInsert;
            }
            System.debug('Data Rekon 3 : '+rekonsToInsert);
            if(!rekonsToInsert.isEmpty()){
                insert rekonsToInsert;
            }
        } 
        catch (Exception exc) {
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

    //check rekening koran Briva
    private RekeningKoranBrivaWrapper checkRekeningKoranBriva(Case cS,  SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data, Map<String, Set<String>> mapKor){

        //get call type
        String caseType = cS.SCC_Call_Type__r.external_id__c;
        Boolean matchedKorRemark = false;
        Boolean matchedConditionAmount = (cS.SCC_Amount__c == data.mutasiKredit);
        String remark = data.trremk;
        System.debug('Nominal Case : '+cS.SCC_Amount__c);
        System.debug('Nominal RekeningKoran : '+data.mutasiKredit);
        if (cS.SCC_Amount__c == data.mutasiKredit) {
            System.debug('Nominal SAMA');
        } else {
            System.debug('Nominal BERBEDA');
        }

        if (!matchedConditionAmount) {
            return new RekeningKoranBrivaWrapper(false, false);
        }
        
        Set<String> masterKorSet = mapKor.get(caseType);
        if(masterKorSet != null && !masterKorSet.isEmpty() && remark != null){
            Integer countKor = 0;
            for(String korType: masterKorSet){
                if(remark.contains(korType)){
                    countKor++;
                }
            }
            if(countKor == 1){
                matchedKorRemark = true;
            }
        }
        return new RekeningKoranBrivaWrapper(matchedKorRemark, matchedConditionAmount);
    }

    public class RekeningKoranBrivaWrapper{
        public Boolean matchedKorRemark{get;set;} 
        public Boolean matchedConditionAmount{get; set;}
        public RekeningKoranBrivaWrapper(Boolean matchedKorRemark , Boolean matchedConditionAmount){
            this.matchedKorRemark = matchedKorRemark;
            this.matchedConditionAmount = matchedConditionAmount;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch SCC_Batch_AutoClosed_8809 has completed its execution.');
        if (!Test.isRunningTest()) {
            String cond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8810\' and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\') and CreatedDate = LAST_WEEK';
            String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Database.executeBatch(new SCC_Batch_AutoClosed_NTPN(queries), 200);
        }
    }
   
    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed_8809';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }

    public SCC_Rekon__c insertMapRekon(Case cs , SCC_RekonWrapper.RekonTokenDetailData rk){
        System.debug('Case id : '+cs.id);
        SCC_Rekon__c rek = new SCC_Rekon__c();
        rek.SCC_Account_Number__c = rk.RekDebet;
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
}