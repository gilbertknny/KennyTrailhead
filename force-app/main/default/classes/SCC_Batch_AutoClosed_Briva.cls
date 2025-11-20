public with sharing class SCC_Batch_AutoClosed_Briva implements Database.Batchable<sObject>, Database.AllowsCallouts {
   
    public String Query;

    public SCC_Batch_AutoClosed_Briva(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }

     public void execute(Database.BatchableContext bc, List<Case> scope){

       
        try {

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

            String brivaNumber = '';
            List<Case> listCase = new List<Case>();
            List<SCC_Rekening_Koran__c> listRekeningKoran = new List<SCC_Rekening_Koran__c>();
            SCC_Rekening_Koran__c rekeningKoran = new SCC_Rekening_Koran__c();
            SCC_Rekon__c rekon = new SCC_Rekon__c();
            List<SCC_Rekon__c> listRekon = new List<SCC_Rekon__c>();
            SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest reqSavingMutation = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
            SCC_BrivaWrapper.ReportBrivaRequest reqBrivaReport = new SCC_BrivaWrapper.ReportBrivaRequest();
            String channel = 'CHMS';
            Set<String> brivaKor = new Set<String>();


            //get calltype for kor
            for(Case ss : scope){
                callTypes.add(ss.SCC_Call_Type__r.external_id__c);
            }

            //get kors
            if(!callTypes.isEmpty()){
                List<Master_Kor__c> masterKors = [SELECT Name FROM Master_Kor__c WHERE Case_Type__r.name IN :callTypes];
                brivaKor = convertToSet(masterKors);
                System.debug('kor briva' + brivaKor);
            }
            
            
            for(Case s : scope){
                system.debug('Ticket Numer: ' + s.CaseNumber);
                // Check if amount is less than 4000, if so close directly
                if (s.SCC_Amount__c != null && s.SCC_Amount__c <= 6500) {
                    s.Status = 'Closed';
                    s.SCC_Status_Transaksi__c = 'Tidak Kirim Notifikasi';
                    // String amountz = s.SCC_Amount__c.format();
                    s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                    s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                    s.SCC_Drone_Remark_Update__c = 'Nominal yang diinput adalah nominal fee transaksi. Mohon pastikan kembali nominal transaksi nasabah yang sesuai. Terima kasih.';
                    listCase.add(s);
                    continue; 
                }

                Integer matchedKorNon = 0;
                Integer matchedConditionNon = 0;
                Integer matchedCondition = 0;
                Integer matchedConditionReport = 0;
                String featureId = '';
                brivaNumber = s.SCC_Nomor_Briva_Tagihan__c;
                reqSavingMutation.channel = channel;
                reqSavingMutation.norekVarchar = s.SCC_Account_Number__c;
                reqSavingMutation.tanggalAwalDatetime =  DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                reqSavingMutation.tanggalAkhirDatetime = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');                //call api saving statement
                SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse resSavingMutation = SCC_CaseResoultion_DataHub.searchSavingStatement(reqSavingMutation, 'Auto Closed Briva', s.Id);
                List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData> listSavingMutationData = resSavingMutation.data;


                //check briva
                if(String.isNotBlank(s.SCC_Nomor_Briva_Tagihan__c)){
                    System.debug('Case BRiva');
                    reqBrivaReport.pageNumber =  Integer.valueOf(Label.pageNumberBriva); //label
                    reqBrivaReport.rowsPerPage = Integer.valueOf(Label.rowsPerPageBriva); //label
                    // reqBrivaReport.tanggalAwal =  DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                    // reqBrivaReport.tanggalAkhir = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                    reqBrivaReport.tanggalAwal = DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd HH:mm:ss');
                    reqBrivaReport.tanggalAkhir = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd HH:mm:ss');

                    reqBrivaReport.uniqcode = Label.uniqcodeBriva; //label
                    reqBrivaReport.corpCode = getCorpCode(s.SCC_Nomor_Briva_Tagihan__c);
                    System.debug('reqBrivaReport' + reqBrivaReport);

                    SCC_BrivaWrapper.ReportBrivaResponse resBrivaReport = SCC_InquiryBriva.getReportBriva(reqBrivaReport, 'Auto Close Briva Report', s.Id);
                    System.debug('response :' + resBrivaReport);
                    List<SCC_BrivaWrapper.DataReportBriva> listDataReportBriva = resBrivaReport.data;

                    if(listDataReportBriva != null){
                        for(SCC_BrivaWrapper.DataReportBriva dataReport : listDataReportBriva){

                            if(String.isNotBlank(s.SCC_Nomor_Briva_Tagihan__c)){
                                SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper resultReport = checkReportBriva(s, dataReport);
                                Boolean matchedBrivaNumber = resultReport.matchedNumberBriva;
                                Boolean matchedAmountBriva = resultReport.matchedConditionAmount;

                                if(matchedBrivaNumber && matchedAmountBriva){
                                    matchedConditionReport++;
                                }

                                if(matchedConditionReport > 1){
                                    break;
                                }
                            }

                    }

                    if(matchedConditionReport == 1){
                        
                        //add case record to list
                        String tglTransaksi = DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                        s.Status = 'Closed';
                        s.SCC_Status_Transaksi__c = 'Berhasil';
                        String amountFormated = s.SCC_Amount__c.format();
                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                        s.SCC_Drone_Remark_Update__c = 'Transaksi briva sukses, dana sudah dilimpahkan ke rek briva. Harap nasabah konfirmasi ke penyedia layanan.';


                        listCase.add(s);
                    }
                 }

                } else{
                        //Check non briva
                    if(listSavingMutationData != null){

                        Set<String> fiturIdRekon = new Set<String>();
                        for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dataMutation : listSavingMutationData){

                            System.debug('data mutation remark ' + dataMutation.trremk);
                            System.debug('Case Non Briva');
                            RekeningKoranBrivaWrapper resultKor = checkRekeningKoranBriva(s, dataMutation, mapKorByCaseType);

                            if(resultKor.matchedKorRemark && resultKor.matchedConditionAmount){
                                matchedCondition++;
                                rekeningKoran = mapRekeningKoran(dataMutation, s);
                                listRekeningKoran.add(rekeningKoran);
                            }
                            System.debug('matched condition ' + matchedCondition);

                            // memanggil SCC_MasterMappingFeature.getFeature untuk mapping fiturId
                            SCC_MasterMappingFeature.MappingMasterWrapper resultFeature = SCC_MasterMappingFeature.getFeature(s, dataMutation, mapFeaturesByCaseType);
                            System.debug('Case Non Briva resultWrapper = '+resultFeature);
                            if(resultFeature != null && resultFeature.matchedConditionAmount){
                                System.debug('Case Non Briva matchedConditionAmountNon');
                                matchedConditionNon++;
                                // Example of using the feature
                                System.debug('Found feature: ' + resultFeature.featureId + ' for Case: ' + s.Id);
                                featureId = resultFeature.featureId;
                                fiturIdRekon.add(resultFeature.featureId);
                                // rekeningKoran = mapRekeningKoran(dataMutation,s);
                            }
                            else {
                                System.debug('No feature found for Case: ' + s.Id);
                                // Handle the case when no feature is found
                            }
                        }

                        //briva
                        if(matchedCondition >= 1){
                            
                            //add case record to list
                            s.Status = 'Closed';
                            s.SCC_Status_Transaksi__c = 'Gagal';
                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                            s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                            listCase.add(s);
                        }
                        else{
                            System.debug('list case : ' + listCase);
                            System.debug('list rekening koran : ' + listRekeningKoran);
                            Integer countFitur = fiturIdRekon.size();
                            //non briva
                            if(countFitur == 1){
                                //lanjut eksekusi rekon
                                SCC_RekonWrapper.RekonTokenRequest reqRekon = new SCC_RekonWrapper.RekonTokenRequest();
                                reqRekon.featureId = featureId;
                                reqRekon.transactionDate = String.valueOf(s.SCC_Transaction_Date__c);
                                reqRekon.billingNumber = s.scc_Billing_Number__c;
                                SCC_RekonWrapper.RekonTokenResponse resRekon = SCC_Rekon.searchRekonToken(reqRekon, '', '');
                                if(resRekon != null && resRekon.responseData != null && resRekon.responseData.detailData != null) {
                                    Integer matchCount = 0;
                                    List<String> statusMatch = new List<String>();
                                    List<SCC_RekonWrapper.RekonTokenDetailData> matchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                    List<SCC_RekonWrapper.RekonTokenDetailData> unmatchDetails = new List<SCC_RekonWrapper.RekonTokenDetailData>();
                                    for(SCC_RekonWrapper.RekonTokenDetailData detail : resRekon.responseData.detailData) {
                                        Decimal rkNominal = (detail.Nominal != null) ? Decimal.valueOf(detail.Nominal) : null;
                                        if(rkNominal == s.SCC_Amount__c){
                                            if(detail.StatusRecon == 'Match'){
                                                matchCount++;
                                                statusMatch.add('1');
                                                matchDetails.add(detail);
                                                // rekon = insertMapRekon(s,detail);
                                                // listRekon.add(rekon);
                                            }
                                            else if(detail.StatusRecon != null &&
                                            detail.StatusRecon.toLowerCase().contains('unmatch') && detail.StatusMCS == '00') {
                                                matchCount++;
                                                statusMatch.add('0');
                                                unmatchDetails.add(detail);
                                                // rekon = insertMapRekon(s,detail);
                                                // listRekon.add(rekon);
                                            }
                                        }
                                    }
                            
                                    if(matchCount >= 1) {
                                        if(statusMatch.contains('0')){
                                            s.Status = 'Closed';
                                            s.SCC_Status_Transaksi__c = 'Gagal';
                                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                            s.SCC_Drone_Remark_Update__c = 'Transaksi gagal dana sudah dikembalikan ke rekening nasabah.';
                                            for (SCC_RekonWrapper.RekonTokenDetailData detail : unmatchDetails) {
                                                rekon = insertMapRekon(s,detail);
                                                listRekon.add(rekon);
                                            }
                                        }else{
                                            s.Status = 'Closed';
                                            s.SCC_Status_Transaksi__c = 'Berhasil';
                                            s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                            s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                            s.SCC_Drone_Remark_Update__c = 'Transaksi pembayaran tagihan sukses. Harap nasabah konfirmasi ke penyedia layanan.';
                                            for (SCC_RekonWrapper.RekonTokenDetailData detail : matchDetails) {
                                                rekon = insertMapRekon(s,detail);
                                                listRekon.add(rekon);
                                            }
                                        }
                                        listCase.add(s);
                                    }
                                }
                            }
                        }

                    }
                }
            }
            //update case condition
            if(!listCase.isEmpty()){
                update listCase;
            }

            //update rekening koran
            if(!listRekeningKoran.isEmpty()){
                insert listRekeningKoran;
            }

            if(!listRekon.isEmpty()){
                insert listRekon;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
     }

     public void finish(Database.BatchableContext bc){
        System.debug('Batch SCC_Batch_AutoClosed_Briva has completed its execution.');
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

     //Set KOR 
     private Set<String> convertToSet(List<Master_Kor__c> listKors){
        Set<String> setKors = new Set<String>();
    
        for(Master_Kor__c kor : listKors){
            setKors.add(kor.Name);
        }

        return setKors;
     }


     //check rekening koran Briva
     private RekeningKoranBrivaWrapper checkRekeningKoranBriva(Case cS,  SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data, Map<String, Set<String>> mapKor){

        //get call type
        String caseType = cS.SCC_Call_Type__r.external_id__c;
        String brivaNumber = cS.SCC_Nomor_Briva_Tagihan__c;
        Boolean matchedKorRemark = false;
        Boolean matchedConditionAmount = (cS.SCC_Amount__c == data.mutasiKredit);
        System.debug('matchedConditionAmount rekening koran : '+matchedConditionAmount);
        String remark = data.trremk;

        if (!matchedConditionAmount) {
            return new RekeningKoranBrivaWrapper(false, false);
        }

        if(String.isNotBlank(brivaNumber) && remark != null && remark.contains(brivaNumber)){
            matchedKorRemark = true;
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


      public class BrivaReportWrapper{
        public Boolean matchedNumberBriva {get;set;}
        public Boolean matchedConditionAmount {get;set;}
        public BrivaReportWrapper(Boolean matchedNumberBriva , Boolean matchedConditionAmount){
            this.matchedConditionAmount = matchedConditionAmount;
            this.matchedNumberBriva = matchedNumberBriva;
        }
    }


    public static String getCorpCode(String brivaNumber) {
        if (String.isBlank(brivaNumber) || brivaNumber.length() < 5) {
            return null;
        }
        return brivaNumber.substring(0, 5);
    }

    private SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper checkReportBriva(Case cs ,SCC_BrivaWrapper.DataReportBriva data ){
        String brivaNumber = cs.SCC_Nomor_Briva_Tagihan__c;
        Boolean matchedBrivaNumber = false;
        Boolean matchedConditionAmount = false;
        String tremkBriva = data.trremk;



        if(brivaNumber != null){
            if(tremkBriva.contains(brivaNumber)){
                matchedBrivaNumber = true;

                if(cs.SCC_Amount__c == data.amount){
                    matchedConditionAmount = true;
                }
            }
        }

        SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper result = new SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper(matchedBrivaNumber,matchedConditionAmount);
        return result;

    }

    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed_Briva';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }

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

}