public with sharing class SCC_CaseResolution_UI {
    @AuraEnabled
    public static Case getCaseDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = ',SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Case cs = Database.query(queries);
        return cs;
    }

    @AuraEnabled
    public static List<SCC_Rekening_Koran__c> getListRekeningKoran(String idcs) {
        String cond = 'scc_case__c=:idcs';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Rekening_Koran__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Rekening_Koran__c', cond, '', '', '');
        List<SCC_Rekening_Koran__c> listrk = Database.query(queries);
        return listrk;
    }
    
    @AuraEnabled
    public static List<SCC_Rekon__c> getListRekon(String idcs) {
        String cond = 'scc_case__c=:idcs';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Rekon__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Rekon__c', cond, '', '', '');
        List<SCC_Rekon__c> listrk = Database.query(queries);
        return listrk;
    }
    
    @AuraEnabled
    public static List<SCC_Berita_Acara_Opname__c> getListBAO(String idcs) {
        String cond = 'scc_case__c=:idcs';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Berita_Acara_Opname__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Berita_Acara_Opname__c', cond, '', '', '');
        List<SCC_Berita_Acara_Opname__c> listrk = Database.query(queries);
        return listrk;
    }

    // Additional Code By : Herbing
    // Start
    @AuraEnabled
    public static List<Aktivitas_Kartu__c> getListAktivitasKartu(String idcs) {
        String cond = 'case__c=:idcs';
        String allfield = SOQL_SOBJECT.getallfield('Aktivitas_Kartu__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Aktivitas_Kartu__c', cond, '', '', '');
        List<Aktivitas_Kartu__c> listrk = Database.query(queries);
        return listrk;
    }
    // End

    @AuraEnabled
    public static List<SCC_Queuetrans__c> getListQueuetrans(String idcs) {
        String cond = 'scc_case__c=:idcs';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Queuetrans__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SCC_Queuetrans__c', cond, '', '', '');
        List<SCC_Queuetrans__c> listrk = Database.query(queries);
        return listrk;
    }

    @AuraEnabled
    public static CustomLookupController.RecordsData getCallTypeDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('SSC_Call_Type__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SSC_Call_Type__c', cond, '', '', '');
        SSC_Call_Type__c ct = Database.query(queries);
        CustomLookupController.RecordsData rd = new CustomLookupController.RecordsData(ct.SCC_Case_Type_Detail__c,ct.id);
        return rd;
    }

    @AuraEnabled
    public static CustomLookupController.RecordsData getFiturDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Call_Type_Feature__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SCC_Call_Type_Feature__c', cond, '', '', '');
        SCC_Call_Type_Feature__c ct = Database.query(queries);
        CustomLookupController.RecordsData rd = new CustomLookupController.RecordsData(ct.SCC_Fitur_Detail__c,ct.id);
        return rd;
    }

    @AuraEnabled
    public static CustomLookupController.RecordsData getTerminalDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('SCC_Terminal_ID__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SCC_Terminal_ID__c', cond, '', '', '');
        SCC_Terminal_ID__c ct = Database.query(queries);
        CustomLookupController.RecordsData rd = new CustomLookupController.RecordsData(ct.name,ct.id);
        return rd;
    }

    @AuraEnabled
    public static String getNotifWA(Case cs) {
        String ctnum = '%'+getcalltypenumber(cs)+'%';
        String ntf = cs.SCC_Status_Transaksi__c;
        String cond = 'Call_Type__c LIKE :ctnum and Notif_Pengiriman__c=:ntf';
        String addfield = '';
        String allfield = SOQL_SOBJECT.getallfield('SCC_WA_Template__mdt');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'SCC_WA_Template__mdt', cond, '', '', '1');
        SCC_WA_Template__mdt ct = Database.query(queries);
        String psn = ct.Isi_Pesan__c;
        if(ct.Count_Param_Body__c>0){
            for(integer i =1; i<=ct.Count_Param_Body__c;i++){
                String fld = String.valueOf(ct.get('Value_Body_'+i+'__c'));
                psn = psn.replace('{{'+i+'}}', String.valueOf(cs.get(fld)));
            }
        }
        return psn;
    }

    @AuraEnabled 
    public static List<RekeningKoran> getRekeningKoran(String accnum,String strdt,String enddt, Case cs){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
        req.norekVarchar = accnum;
        req.tanggalAwalDatetime = strdt;
        req.tanggalAkhirDatetime = enddt;
        req.channel = 'ALL CHANNEL';
        String menu = 'Case - Resolution Center';
        String recid = cs.Id;
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse();     
        if(label.Dummy_Response=='true'){
            res = Object_Test.SavingMutationResponse();
        } 
        else{
            res = SCC_CaseResoultion_DataHub.SearchSavingMutation(req,menu,recid);
        }
        List<RekeningKoran> listsmd = new List<RekeningKoran>();
        Integer i =0;
        if(res?.data!=null){
            for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt:res?.data){
                i++;
                RekeningKoran smd = new RekeningKoran(false,String.valueOf(i),dt);
                listsmd.add(smd);
            }
        }
        return listsmd; 
    }

    @AuraEnabled 
    public static List<Rekon> getRekon(Case cs,String tgl,String trmid,String ctid){
        SCC_RekonWrapper.RequestRekon req = new SCC_RekonWrapper.RequestRekon();
        req.AccountNumber = cs.SCC_Account_Number__c;
        req.Amount = String.valueof(integer.valueOf(cs.SCC_Amount__c));
        req.TerminalID = trmid;
        req.TransactionDate = tgl;
        req.Page = 1;
        String ctnum = getcalltypenumber(cs);
        SCC_RekonWrapper.ResponseRekon res = new SCC_RekonWrapper.ResponseRekon();     
        if(label.Dummy_Response=='true'){
            res = Object_Test.ResponseRekon();
        } 
        else{
            res = SCC_Rekon.SearchRekon(req,ctnum);
        }
        List<Rekon> listsmd = new List<Rekon>();
        Integer i =0;
        if(res?.RESPONSE_DATA?.result!=null){
            for(SCC_RekonWrapper.ResponseRekonResult dt:res?.RESPONSE_DATA?.result){
                i++;
                Rekon smd = new Rekon(false,String.valueOf(i),dt);
                listsmd.add(smd);
            }
        }
        return listsmd; 
    }

    @AuraEnabled 
    public static List<BeritaAcaraOpname> getBAO(String tgl,String trmid){
        SCC_RekonWrapper.RequestBeritaAcaraOpname req = new SCC_RekonWrapper.RequestBeritaAcaraOpname();
        req.TanggalTransaksi = tgl;
        req.TerminalID = trmid;
        req.Page = 1;
        SCC_RekonWrapper.ResponseBeritaAcaraOpname res = new SCC_RekonWrapper.ResponseBeritaAcaraOpname();     
        if(label.Dummy_Response=='true'){
            res = Object_Test.ResponseBeritaAcaraOpname();
        } 
        else{
            res = SCC_Rekon.SearchBAO(req);
        }
        List<BeritaAcaraOpname> listsmd = new List<BeritaAcaraOpname>();
        Integer i =0;
        if(res?.RESPONSE_DATA?.result!=null){
            for(SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult dt:res?.RESPONSE_DATA?.result){
                i++;
                BeritaAcaraOpname smd = new BeritaAcaraOpname(false,String.valueOf(i),dt);
                listsmd.add(smd);
            }
        }
        return listsmd; 
    }

    // Addtional Code By : Herbing
    // Start
    @AuraEnabled 
    public static List<AktivitasKartu> getAktivitasKartu(Case cs, String posisiawal, String posisiakhir, String fitur, String nomor, String scope){
        
        // Create a new request object
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardActivityRequest();
        req.posisiawal = posisiawal;
        req.posisiakhir = posisiakhir;
        req.fitur = Integer.valueof(fitur);
        req.nomor = nomor;
        req.scope = Integer.valueof(scope);
        
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
            res = Object_Test.CardActivityResponse();
            //System.debug(res);
        } 
        else{
            String mtd = SCC_Endpoint_API__mdt.getInstance('DataHubCardActivity').MasterLabel;
            res = SCC_CaseResoultion_DataHub.CardActivity(req,mtd,menu,recid);
        }

        // Create a list to hold the AktivitasKartu objects
        List<AktivitasKartu> listsmd = new List<AktivitasKartu>();
        Integer i =0;

        // Process the response data
        if(res?.data!=null){
            system.debug(res);
            System.debug(res.responseMessage);
            for(SCC_CaseResoultion_DataHub_Wrapper.CardActivityData dt:res?.data){
                i++;
                AktivitasKartu smd = new AktivitasKartu(false,String.valueOf(i),dt,res.responseMessage);
                listsmd.add(smd);
            }
        }

        // Return the list of AktivitasKartu objects
        return listsmd; 
    }

    @AuraEnabled 
    public static List<EJOL> getEJLog(String tid, String dateReq){
        
        // Create a new request object
        SCC_CaseResolution_EJOLWrapper.EJLogRequest req = new SCC_CaseResolution_EJOLWrapper.EJLogRequest();
        Integer tidInt = Integer.valueOf(tid);
        String tidStr = String.valueOf(tidInt);
        req.tid = tidStr;
        //req.ipAddress = ipAdress;
        req.dateRequest = dateReq;
        
        // Initialize the response object
        SCC_CaseResolution_EJOLWrapper.EJLogResponse res = new SCC_CaseResolution_EJOLWrapper.EJLogResponse();
        SCC_CaseResolution_EJOLWrapper.EJLogResponseError resError = new SCC_CaseResolution_EJOLWrapper.EJLogResponseError();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
            res = Object_Test.EJLogResponse();
            resError = Object_Test.EJLogResponseError();//System.debug(res);
            System.debug('response error =' + resError);
            System.debug('response sukses =' + res);
        } 
        else{
            res = SCC_CaseResolution_EJOL.SearchEJ(req);
        }

        // Create a list to hold the AktivitasKartu objects
        List<EJOL> listsmd = new List<EJOL>();
        Integer i =0;

        // Process the response data
        if(res?.data!=null){
            if(res.code == 200){
                // Initialize an empty list to store the objects
                List<Map<String, String>> logArray = new List<Map<String, String>>();
                
                String body = res.data.ejlog;
				Decimal jum = 500000;
                Decimal bodysize = body.length();
                Decimal x = (bodysize/jum).round(System.RoundingMode.CEILING);
                for(integer j=0;j<x;j++){
                    Integer k = j*Integer.valueOf(jum);
                    Integer l = 0;
                    
                    if(j != x-1 && x != 1) l = (j+1)*Integer.valueOf(jum);
                    else l = Integer.valueOf(bodysize);
                    
                    String bodynew = body.substring(k,l);

                    // Keep original body for saving
                    String originalBody = bodynew;
                    // Create lowercase version only for splitting
                    String lowercaseBody = bodynew.toLowerCase();

                    List<String> logLines = new List<String>();
                    Integer startIndex = 0;
                    Integer previousStartIndex = 0;
                    
                    // Define search patterns for both variations
                    String[] searchPatterns = new String[]{'transaction end', 'transaction_end'};
                    
                    // Search for both patterns
                    while (true) {
                        Integer minIndex = -1;
                        String matchedPattern = '';
                        
                        // Find the earliest occurrence of any pattern
                        for (String pattern : searchPatterns) {
                            Integer currentIndex = lowercaseBody.indexOf(pattern, startIndex);
                            if (currentIndex != -1 && (minIndex == -1 || currentIndex < minIndex)) {
                                minIndex = currentIndex;
                                matchedPattern = pattern;
                            }
                        }
                        
                        // If no pattern is found, break the loop
                        if (minIndex == -1) {
                            break;
                        }
                        
                        // Add the log line using the found pattern
                        logLines.add(originalBody.substring(previousStartIndex, minIndex));
                        startIndex = minIndex + matchedPattern.length();
                        previousStartIndex = startIndex;
                    }
                    
                    // Add the remaining part if exists
                    if(previousStartIndex < originalBody.length()) {
                        logLines.add(originalBody.substring(previousStartIndex));
                    }
                    
                    System.debug(logLines);
                    // Loop through the log lines and create objects
                    for(String line : logLines) {
                        if(String.isNotBlank(line)) { // Ignore empty lines
                            Map<String, String> logMap = new Map<String, String>();
                            logMap.put('ejlog', line.trim() + ' TRANSACTION END');
                            logArray.add(logMap);
                        }
                    }
                }
                // Loop through the log lines and create objects
                for(Map<String, String> logMap : logArray){
                    i++;
                    // Create an EJOL object using the string from the map
                    String logLine = logMap.get('ejlog');
                    EJOL smd = new EJOL(false, String.valueOf(i),res?.message,res?.code,logLine); // Assuming EJOL constructor takes a string
                    listsmd.add(smd);
                }
            }
            else{
                EJOL smd = new EJOL(false,String.valueOf(i),res?.message,res?.code,res?.data);
                listsmd.add(smd);
                System.debug(listsmd);
            }
        }

        // Return the list of EJ objects
        return listsmd; 
    }

    @AuraEnabled
    public static List<EJ__c> getListEJ(String idcs) {
        String cond = 'case__c=:idcs';
        String allfield = SOQL_SOBJECT.getallfield('EJ__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'EJ__c', cond, '', '', '');
        List<EJ__c> listrk = Database.query(queries);
        return listrk;
    }

    @AuraEnabled
    public static Case updateCase(Case cs,String rmk){
        Case cs2 = getCaseDetail(cs.id);
        cs2.SCC_Call_Type__c = cs.SCC_Call_Type__c;
        cs2.SCC_Call_Type_Feature__c = cs.SCC_Call_Type_Feature__c;
        cs2.Terminal_ID__c = cs.Terminal_ID__c;
        cs2.SCC_Status_Transaksi__c = cs.SCC_Status_Transaksi__c;
        cs2.SCC_Waktu_Transaksi__c = cs.SCC_Waktu_Transaksi__c;
        if(String.isBlank(cs2.SCC_Drone_Remark_Update__c)) {
            cs2.SCC_Drone_Remark_Update__c = cs.Description;
        }
        if(String.isNotBlank(rmk)){
            String setrmk = '['+String.valueOf(system.now())+' '+UserInfo.getName()+'] '+rmk;
            cs2.SCC_Drone_Remark_Update__c = cs2.SCC_Drone_Remark_Update__c+'\n'+setrmk;
        }
        if(String.isNotBlank(cs2.Terminal_ID__c)){
            List<SCC_Terminal_ID__c> ltid = [select id,name from SCC_Terminal_ID__c where id =:cs2.Terminal_ID__c];
            cs2.SCC_Terminal_ID__c = !ltid.isempty() ? ltid[0].name : label.tid;
        }
        update cs2;
        return cs2;
    }

    @AuraEnabled 
    public static List<SCC_Rekening_Koran__c> insertRekeningKoran(Case cs,List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData> listrekening){
        List<SCC_Rekening_Koran__c> listrek = new List<SCC_Rekening_Koran__c>();
        List<SCC_Rekening_Koran__c> listdel = [select id from SCC_Rekening_Koran__c where scc_case__c=:cs.id];
        for(SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData rk : listrekening){
            SCC_Rekening_Koran__c rek = new SCC_Rekening_Koran__c();
            rek.scc_case__c = cs.id;
            rek.SCC_auxtrc__c = rk.auxtrc;
            rek.SCC_Deskripsi_Transaksi__c = rk.deskTran;
            rek.SCC_GLSign__c = rk.glsign;
            rek.SCC_ID_Number__c = rk.idNum;
            rek.SCC_ID_Number_2__c = rk.idNum2;
            rek.SCC_ID_Number_3__c = rk.idNum3;
            rek.SCC_Jam_Transaksi__c  = rk.jamTran;
            rek.SCC_Jam_Trans__c = convertjam(rk.jamTran);
            rek.SCC_Kode_Transaksi__c = rk.kodeTran;
            rek.SCC_Mutasi_Debet__c = rk.mutasiDebet;
            rek.SCC_Mutasi_Kredit__c = rk.mutasiKredit;
            rek.SCC_Nomor_Rekening__c = rk.noRek;
            rek.SCC_Saldo_Akhir_Mutasi__c = rk.saldoAkhirMutasi;
            rek.SCC_Saldo_Awal_Mutasi__c = rk.saldoAwalMutasi;
            rek.SCC_Sequence__c = rk.seq;
            rek.SCC_Serial__c = rk.serial;
            rek.SCC_Terbilang__c = rk.terbilang;
            rek.SCC_Tanggal_Effektif__c = rk.tglEfektif;
            rek.SCC_Tanggal_Transaksi__c = rk.tglTran;
            rek.SCC_tblds1__c = rk.tlbds1;
            rek.SCC_tblds2__c = rk.tlbds2;
            rek.SCC_trremk__c = rk.trremk;
            rek.SCC_Truser__c = rk.truser;
            listrek.add(rek);
        }
        if(!listrek.isempty()){
            if(!listdel.isempty()){
                delete listdel;
            }
            insert listrek;    
        }
        return listrek;
    }

    @AuraEnabled 
    public static SCC_RekonWrapper.ResponseFlagDataRekon insertRekon(Case cs,List<SCC_RekonWrapper.ResponseRekonResult> listrekon,String tgl){
        Boolean unm = false;
        List<SCC_Rekon__c> listrek = new List<SCC_Rekon__c>();
        List<SCC_Rekon__c> listrekun = new List<SCC_Rekon__c>();
        List<SCC_Queuetrans__c> listque = new List<SCC_Queuetrans__c>();
        List<SCC_Rekon__c> listdel = [select id from SCC_Rekon__c where scc_case__c=:cs.id];
        List<SCC_Queuetrans__c> listdelque = [select id from SCC_Queuetrans__c where scc_case__c=:cs.id];
        SCC_RekonWrapper.ResponseFlagDataRekon res = new SCC_RekonWrapper.ResponseFlagDataRekon();
        String ctnum = getcalltypenumber(cs);
        for(SCC_RekonWrapper.ResponseRekonResult rk : listrekon){
            SCC_Rekon__c rek = new SCC_Rekon__c();
            rek.SCC_Account_Number__c = rk.account_no;
            rek.SCC_Amount__c = rk.amount;
            rek.SCC_Card_Number__c = rk.card_no;
            rek.SCC_Credit_Account__c = rk.CreditAccount;
            rek.SCC_Credit_Account_Type__c = rk.CreditAccountType;
            rek.SCC_Debet_Account__c = rk.DebetAccount;
            rek.SCC_Penyelesaian_Rekon__c = rk.PenyelesaianRekon;
            rek.SCC_Seq_No__c = rk.seq_no;
            rek.SCC_Status_Penyelesaian__c  = rk.StatusPenyelesaian;
            rek.SCC_Status_Rekon__c = rk.StatusRekon;
            rek.SCC_Table_Rekon__c = rk.TableRekon;
            rek.SCC_Terminal_Id__c = rk.terminal_id;
            rek.SCC_Tanggal_Transaksi__c = rk.trx_date;
            rek.SCC_UUID__c = rk.uuid;
            rek.scc_case__c = cs.id;
            listrek.add(rek);
            SCC_Queuetrans__c que = new SCC_Queuetrans__c();
            if(rk.StatusRekon=='Unmatch'){
                unm = true;
                listrekun.add(rek);
                que.scc_no_tt__c = cs.CaseNumber;
                que.scc_fitur_id__c = cs.SCC_Call_Type_Feature__r.Fitur_ID__c; 
                //que.scc_acct_debet1__c	= rk.DebetAccount;
                que.scc_acct_kredit1__c = rk.CreditAccount;
                que.scc_amt_debet1__c = String.valueOf(rk.amount);
                que.scc_amt_kredit1__c = String.valueOf(rk.amount);
                que.scc_calltype__c  = ctnum;
                que.scc_case__c = cs.id;
                listque.add(que);
            }
        }
        
        if(label.Dummy_Response=='true'){
            res = Object_Test.ResponseFlagDataRekon();
        } 
        else{
            res = SCC_Rekon.FlagDataRekonFuture(listrek,cs.id,tgl);
        }
        if(res.RESPONSE_CODE == '00'){
            upsertdata dat = new upsertdata();
            dat.cs = cs;
            dat.listdel = listdel;
            dat.listdelque = listdelque;
            dat.listque = listque;
            dat.listrek = listrek;
            dat.listrekun = listrekun;
            upsertdatarekon(dat);
        }
        return res;
    }

    Public class upsertdata{
        public List<SCC_Rekon__c> listrek {get;set;}
        public List<SCC_Rekon__c> listrekun {get;set;}
        public List<SCC_Queuetrans__c> listque {get;set;}
        public List<SCC_Rekon__c> listdel {get;set;}
        public List<SCC_Queuetrans__c> listdelque {get;set;}
        public Case cs {get;set;}
    }

    public static void upsertdatarekon(upsertdata dt){
        if(!dt.listrek.isempty()){
            if(!dt.listdel.isempty()){
                delete dt.listdel;
            }
            insert dt.listrek;    
            dt.cs.SCC_Is_Manual_Recon__c = true;
        }
        else{
            dt.cs.SCC_Is_Manual_Recon__c = false;
        }
        if(!dt.listdelque.isempty()){
            delete dt.listdelque;
        }
        if(!dt.listque.isempty()){
            insert dt.listque;    
        }
        update dt.cs;
    }

    @AuraEnabled 
    public static List<SCC_Berita_Acara_Opname__c> insertBAO(Case cs,List<SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult> listbao){
        List<SCC_Berita_Acara_Opname__c> listrek = new List<SCC_Berita_Acara_Opname__c>();
        List<SCC_Berita_Acara_Opname__c> listdel = [select id from SCC_Berita_Acara_Opname__c where scc_case__c=:cs.id];
        for(SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult rk : listbao){
            SCC_Berita_Acara_Opname__c rek = new SCC_Berita_Acara_Opname__c();
            rek.scc_case__c = cs.id;
            rek.SCC_Branch__c = rk.branch;
            rek.SCC_Terminal_ID__c = rk.id_terminal;
            rek.SCC_Jenis_Terminal__c = rk.JenisTerminal;
            rek.SCC_Kurang_Fisik__c = rk.KurangFisik;
            rek.SCC_Kurang_Kas__c = rk.KurangKas;
            rek.SCC_Lebih_Fisik__c	= rk.LebihFisik;
            rek.SCC_Lebih_Kas__c = rk.LebihKas;
            rek.SCC_Status_Id__c = rk.StatusId;
            rek.SCC_Status_Name__c = rk.StatusName;
            rek.SCC_Waktu_Opname__c = rk.WaktuOpname;
            listrek.add(rek);
        }
        if(!listrek.isempty()){
            if(!listdel.isempty()){
                delete listdel;
            }
            insert listrek;    
        }
        return listrek;
    }

    @AuraEnabled
    public static void insertFile(String csid,String condocid){
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = condocid;
        cDe.LinkedEntityId = csid; // you can use objectId,GroupId etc
        cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
    }

    @AuraEnabled
    public static void deleteBAO(List<SCC_Berita_Acara_Opname__c> listbao){
        List<SCC_Berita_Acara_Opname__c> listdel = new List<SCC_Berita_Acara_Opname__c>();
        for(SCC_Berita_Acara_Opname__c bao : listbao){
            if(bao.IsDeleted__c){
                listdel.add(bao);
            }
        }
        if(!listdel.isempty()){
            delete listdel;
        }
    }

    @AuraEnabled
    public static void deleteRekon(List<SCC_Rekon__c> listrek,Case cs){
        List<SCC_Rekon__c> listdel = new List<SCC_Rekon__c>();
        List<SCC_Queuetrans__c> listque = new List<SCC_Queuetrans__c>();
        List<SCC_Rekon__c> listrekon = new List<SCC_Rekon__c>();
        List<SCC_Queuetrans__c> listdelque = [select id from SCC_Queuetrans__c where scc_case__c=:cs.id];
        String ctnum = getcalltypenumber(cs);
        for(SCC_Rekon__c rek : listrek){
            if(rek.IsDeleted__c){
                listdel.add(rek);
            }

            SCC_Queuetrans__c que = new SCC_Queuetrans__c();
            if(rek.SCC_Status_Rekon__c=='Unmatch' && !rek.IsDeleted__c){
                que.scc_no_tt__c = cs.CaseNumber;
                que.scc_fitur_id__c = cs.SCC_Call_Type_Feature__r.Fitur_ID__c; 
                que.scc_acct_debet1__c	= rek.SCC_Debet_Account__c;
                que.scc_acct_kredit1__c = rek.SCC_Credit_Account__c;
                que.scc_amt_debet1__c = String.valueOf(rek.SCC_Amount__c);
                que.scc_amt_kredit1__c = String.valueOf(rek.SCC_Amount__c);
                que.scc_calltype__c  = ctnum;
                que.scc_case__c = cs.id;
                listque.add(que);
            }
        }
        if(!listdel.isempty()){
            delete listdel;
        }
        if(!listdelque.isempty()){
            delete listdelque;
        }
        if(!listque.isempty()){
            insert listque;
        }
    }

    @AuraEnabled
    public static void deleteRekeningKoran(List<SCC_Rekening_Koran__c> listrek){
        List<SCC_Rekening_Koran__c> listdel = new List<SCC_Rekening_Koran__c>();
        for(SCC_Rekening_Koran__c rek : listrek){
            if(rek.IsDeleted__c){
                listdel.add(rek);
            }
        }
        if(!listdel.isempty()){
            delete listdel;
        }
    }

    @AuraEnabled
    public static CustomerProfile CustomerProfileDetail(Case cs){
        User us = [select id,EmployeeNumber from user where id=:userinfo.getUserId()];
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
        req.acctNo = cs.SCC_Account_Number__c;
        req.channelId = 'CHMS';
        req.personalNumber = us.EmployeeNumber;
        String menu = 'Case - Resolution Center';
        String recid = cs.Id;
        if(label.Dummy_Response=='true'){
            res = Object_Test.CustomerProfileResponse();
        } 
        else{
            res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req,menu,recid);
        }
        String nm = '';
        String acc_num = '';
        if(res?.data!=null){
            acc_num = cs.SCC_Account_Number__c;
            for(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData dt:res?.data){
                if(dt?.demografi?.namaSesuaiId!=null){
                    nm = dt?.demografi?.namaSesuaiId;
                }
                if(dt?.demografi?.namaSesuaiIdentitas!=null){
                    nm = dt?.demografi?.namaSesuaiIdentitas;
                } 
            } 
        }
        CustomerProfile cp = new CustomerProfile(nm,acc_num);
        return cp;
    }

    public class RekeningKoran {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public String num {get;set;}
        @AuraEnabled public String jamtran {get;set;}
        @AuraEnabled public String tgltran {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data {get;set;}
        public RekeningKoran(boolean isChecked,String num, SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data){
            this.jamtran = convertjam(data.jamTran);
            this.tgltran = data.tglTran.substringBefore('T');
            this.isChecked = isChecked;
            this.num = num;
            this.data = data;
        }
    }

    public class Rekon {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public String num {get;set;}
        @AuraEnabled public SCC_RekonWrapper.ResponseRekonResult data {get;set;}
        @AuraEnabled public boolean isDisabled {get;set;}
        public Rekon(boolean isChecked,String num, SCC_RekonWrapper.ResponseRekonResult data){
            this.isChecked = isChecked;
            this.num = num;
            this.data = data;
            if(data?.StatusPenyelesaian=='Sedang Dikerjakan') {
                this.isDisabled = true;
            }
            else{
                this.isDisabled = false;
            }
        }
    }

    public class BeritaAcaraOpname {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public String num {get;set;}
        @AuraEnabled public SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult data {get;set;}
        public BeritaAcaraOpname(boolean isChecked,String num, SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult data){
            this.isChecked = isChecked;
            this.num = num;
            this.data = data;
        }
    }

    // ADDTIONAL CODE BY : HERBING
    // START
    public class AktivitasKartu {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public String num {get;set;}
        @AuraEnabled public String jam {get;set;}
        @AuraEnabled public String tanggal {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.CardActivityData data {get;set;}
        //@AuraEnabled public SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse resp {get;set;}
        public AktivitasKartu(boolean isChecked,String num, SCC_CaseResoultion_DataHub_Wrapper.CardActivityData data, String msg){
            //this.jam = convertjam(data.jam);
            this.description = msg;
            this.tanggal = data.tanggal.substringBefore('T');
            this.isChecked = isChecked;
            this.num = num;
            this.data = data;
        }
    }

    @AuraEnabled 
    public static List<Aktivitas_Kartu__c> insertAktivitasKartu(Case cs,List<SCC_CaseResoultion_DataHub_Wrapper.CardActivityData> listrekening, String msg){
        List<Aktivitas_Kartu__c> listrek = new List<Aktivitas_Kartu__c>();
        List<Aktivitas_Kartu__c> listdel = [select id from Aktivitas_Kartu__c where case__c=:cs.id];
        for(SCC_CaseResoultion_DataHub_Wrapper.CardActivityData rk : listrekening){
            Aktivitas_Kartu__c rek = new Aktivitas_Kartu__c();
            rek.case__c = cs.id;
            rek.amount__c = rk.amount;
            rek.channelId__c = rk.channelId;
            rek.fiturId__c = rk.fiturId;
            rek.groupFitur__c = rk.groupFitur;
            rek.Jam_Transaksi__c = rk.jam;
            rek.journalSeq__c  = rk.journalSeq;
            rek.namaFitur__c = rk.namaFitur;
            rek.noHandphone__c = rk.noHandphone;
            rek.noKartu__c = rk.noKartu;
            rek.noRekening__c = rk.noRekening;
            rek.responseCode__c = rk.responseCode;
            rek.status__c = rk.status;
            rek.Tanggal_Transaksi__c = rk.tanggal;
            rek.tellerId__c = rk.tellerId;
            rek.terminalId__c = rk.terminalId;
            rek.Response_Description__c = msg;
            listrek.add(rek);
        }
        if(!listrek.isempty()){
            if(!listdel.isempty()){
                delete listdel;
            }
            insert listrek;    
        }
        return listrek;
    }

    @AuraEnabled
    public static void deleteAktivitasKartu(List<Aktivitas_Kartu__c> listrek){
        List<Aktivitas_Kartu__c> listdel = new List<Aktivitas_Kartu__c>();
        for(Aktivitas_Kartu__c rek : listrek){
            if(rek.IsDeleted__c){
                listdel.add(rek);
            }
        }
        if(!listdel.isempty()){
            delete listdel;
        }
    }

    public class EJOL {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public String num {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public SCC_CaseResolution_EJOLWrapper.EJLogData data {get;set;}
        public EJOL(boolean isChecked,String num, String message, Integer code, SCC_CaseResolution_EJOLWrapper.EJLogData data){
            this.code = code;
            this.message = message;
            this.isChecked = isChecked;
            this.num = num;
            this.data = data;
        }

        public EJOL(Boolean isChecked, String num, String message, Integer code, String logLine) {
            // Assuming you may want to process or store logLine differently
            // You might need to parse or map it into your data structure
            this.message = message;
            this.code = code;
            this.isChecked = isChecked;
            this.num = num;
            this.data = new SCC_CaseResolution_EJOLWrapper.EJLogData(); // Initialize appropriately
            this.data.ejlog = logLine; // Set the appropriate field or handle the logLine
        }
    }

    @AuraEnabled 
    public static List<EJ__c> insertEJ(Case cs,List<SCC_CaseResolution_EJOLWrapper.EJLogData> listrekening){
        List<EJ__c> listrek = new List<EJ__c>();
        List<EJ__c> listdel = [select id from EJ__c where case__c=:cs.id];
        for(SCC_CaseResolution_EJOLWrapper.EJLogData rk : listrekening){
            EJ__c rek = new EJ__c();
            rek.case__c = cs.id;
            rek.EJ_log__c = rk.ejlog;
            listrek.add(rek);
        }
        System.debug(listrek);
        if(!listrek.isempty()){
            if(!listdel.isempty()){
                delete listdel;
            }
            insert listrek;    
        }
        return listrek;
    }
    
    @AuraEnabled
    public static void deleteEJ(List<EJ__c> listrek){
        List<EJ__c> listdel = new List<EJ__c>();
        for(EJ__c rek : listrek){
            if(rek.IsDeleted__c){
                listdel.add(rek);
            }
        }
        if(!listdel.isempty()){
            delete listdel;
        }
    }

    @AuraEnabled
    public static List<EJ__c> updateEJ(List<EJ__c> ejList) {
        System.debug('highlight method called: ' + ejList);
        Set<Id> ejIds = new Set<Id>();
        for(EJ__c ej : ejList) {
            ejIds.add(ej.Id);
        }
        
        List<EJ__c> ejsToUpdate = [SELECT Id, Highlight__c 
                                FROM EJ__c 
                                WHERE Id IN :ejIds];
        
        for(EJ__c ej : ejsToUpdate) {
            // Toggle the Highlight__c value
            ej.Highlight__c = !ej.Highlight__c;
            // Remove this line: ejsToUpdate.add(ej);
        }

        System.debug('updated: ' + ejsToUpdate);
        
        update ejsToUpdate;
        
        return ejsToUpdate;
    }

    @AuraEnabled
    public static String deleteAllEJRecords(Id caseId) {
        try {
            // Query for all EJ__c records related to the given Case
            List<EJ__c> ejRecordsToDelete = [SELECT Id FROM EJ__c WHERE Case__c = :caseId];
            
            // Check if we have delete permission on EJ__c
            if (!Schema.sObjectType.EJ__c.isDeletable()) {
                return 'Error: Anda tidak memiliki akses untuk menghapus data EJ.';
            }
            
            // Delete the records
            if (!ejRecordsToDelete.isEmpty()) {
                delete ejRecordsToDelete;
                return 'Delete Berhasil ' + ejRecordsToDelete.size() + ' EJ records.';
            } else {
                return 'Tidak ada data EJ yang ditemukan untuk Case ini.';
            }
        } catch (Exception e) {
            // Log the error and return an error message
            System.debug('Proses hapus semua EJ Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    // END

    public class CustomerProfile {
        @AuraEnabled public String nama {get;set;}
        @AuraEnabled public String acc_num {get;set;}
        public CustomerProfile(String nama,String acc_num){
            this.nama = nama;
            this.acc_num = acc_num;
        }
    }

    public static String convertjam(Decimal jam){
        String jm = String.valueof(jam);
        jm = jm.leftPad(6, '0');
        jm = jm.substring(0, 2)+':'+jm.substring(2, 4)+':'+jm.substring(4, 6);
        return jm;
    }

    public static String getcalltypenumber(Case cs){
        String ctnum = cs.SCC_Call_Type__r.Name.substringbefore('-').trim();
        if(String.isNotBlank(cs.SCC_Call_Type__r.External_Id__c)){
            ctnum = cs.SCC_Call_Type__r.External_Id__c;
        }
        return ctnum;
    }
}