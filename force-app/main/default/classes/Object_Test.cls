/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
// @istest
public with sharing class Object_Test {
    public static SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel createCaseRequestModel(String ctid,String nm,String nokar,String ori){
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc = new SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel();
        rcc.NamaPIC=nm;
        rcc.CallTypeID =ctid;
        rcc.NoTelpPIC ='0856473637';
        rcc.User ='Call';
        rcc.Gateway ='Twitter';
        rcc.TID ='';
        rcc.Assignee ='';
        rcc.TipeIntegrasi =ori;
        rcc.Notes ='Kartu ATM rusak';
        rcc.UniqueID ='MMS001';
        rcc.NomorKartu =nokar;
        rcc.NoRekening ='123456789012345';
        rcc.Nominal ='0';
        rcc.TglTransaksi =system.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        rcc.Email ='lala@gmail.com';
        return rcc;
    }
    public static SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel createCaseResponseModel(){
        SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel rcc2 = new SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel();
        rcc2.Response='Tiket berhasil dibuat';
        rcc2.CreateDate =system.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        rcc2.responseCode ='00';
        rcc2.responseMessage ='Call';
        rcc2.TroubleTicketID ='TICKET00001';
        return rcc2;
    }

    public static SCC_LegacyCaseAPIWrapper.GetCaseRequestModel getCaseRequestModel(String query){
        SCC_LegacyCaseAPIWrapper.GetCaseRequestModel rgc = new SCC_LegacyCaseAPIWrapper.GetCaseRequestModel();
        rgc.Qualification=query;
        rgc.maxLimit ='100';
        rgc.startRecord ='0';
        return rgc;
    }
        
    public static SCC_LegacyCaseAPIWrapper.GetCaseResponseModel getCaseResponseModel(){
        SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel rgctd = new SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel();
        rgctd.TicketId='TICKET00001';
        rgctd.Create_Date ='2024-04-01T16:06:17+07:00';
        rgctd.Status_Ticket ='Closed';
        rgctd.Status_SLA ='Met';
        rgctd.Calltype='';
        rgctd.CalltypeID ='3200';
        rgctd.TglTransaksi ='2021-11-21T00:00:00+07:00';
        rgctd.Nominal ='500000';
        rgctd.NoTelpNasabah ='08976566575';
        rgctd.Details ='Deskripsi';
        rgctd.close_date = String.valueOf(system.now());
        List<SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel> listrgctd = new List<SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel>();
        listrgctd.add(rgctd);

        SCC_LegacyCaseAPIWrapper.GetCaseResponseModel rgcs = new SCC_LegacyCaseAPIWrapper.GetCaseResponseModel();
        rgcs.TicketList = listrgctd;
        rgcs.responseMessage = 'Success';
        rgcs.responseCode = '00';
        return rgcs;
    }

    public static SSC_Call_Type__c setCallType(String ctid){
        SSC_Call_Type__c ct = new SSC_Call_Type__c();
        ct.Active__c = true;
        ct.SSC_Case_Description__c = 'Cek';
        ct.name = ctid;
        ct.External_Id__c = ctid;
        ct.SCC_Customer_Segment__c = 'UMKM';
        ct.SSC_Product_L1__c = 'Servicing';
        ct.SSC_Product_L2__c = 'Cash Management';
        ct.SSC_Case_Category__c = 'Request';
        ct.SCC_Additional_Details__c = 'Description Case';
        return ct;
    }

    public static Case setCase(String ctid){
        Case cs = new Case();
        cs.subject = 'test';
        cs.SCC_Call_Type__c = ctid;
        cs.Description = 'Test';
        cs.Status = 'New';
        cs.Origin  = 'MMS';
        cs.SCC_Terminal_ID__c = '123456';
        cs.SCC_Waktu_Transaksi__c = system.now();
        cs.SCC_Transaction_Date__c = system.today();
        cs.SCC_Status_Transaksi__c = 'Berhasil';
        return cs ;
    }

    public static Id setFile(){
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'text.ppt'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'text'; // Display name of the files
        conVer.VersionData = Blob.valueOf('text'); // converting your binary string to Blog
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        return condoc;
    }

    public static SCC_Rekening_Koran__c setRekeningKoran(String csid){
        SCC_Rekening_Koran__c rk = new SCC_Rekening_Koran__c();
        rk.scc_case__c = csid;
        return rk ;
    }

    public static SCC_Rekon__c setRekon(String csid){
        SCC_Rekon__c rk = new SCC_Rekon__c();
        rk.scc_case__c = csid;
        return rk ;
    }

    public static SCC_Berita_Acara_Opname__c setBeritaAcaraOpname(String csid){
        SCC_Berita_Acara_Opname__c rk = new SCC_Berita_Acara_Opname__c();
        rk.scc_case__c = csid;
        return rk ;
    }

    public static SCC_Queuetrans__c setQueueTrans(String csid){
        SCC_Queuetrans__c rk = new SCC_Queuetrans__c();
        rk.scc_case__c = csid;
        return rk ;
    }

    public static SCC_Call_Type_Feature__c setFitur(String ctid){
        SCC_Call_Type_Feature__c rk = new SCC_Call_Type_Feature__c();
        rk.Call_Type__c = ctid;
        rk.Fitur_ID__c = '1000';
        return rk ;
    }

    public static SCC_Terminal_ID__c setTerminalID(){
        SCC_Terminal_ID__c rk = new SCC_Terminal_ID__c();
        rk.name = '1000';
        rk.SCC_Branch_Code__c = '20';
        return rk ;
    }

    Public static SCC_Rekon__c setRekon(String csid,SCC_RekonWrapper.ResponseRekonResult rk){
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
        rek.scc_case__c = csid;
        return rek;
    }

    public static Account setAccount(String rtnm){
        Account acc = new Account();
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(rtnm).getRecordTypeId();
        if(rtnm=='PersonAccount'){
            acc.LastName = 'Individu';
            acc.SCC_Tipe_Nasabah__c = 'Individu';
            acc.scc_cifno__c = 'AO0001';
        }
        if(rtnm=='IndustriesBusiness'){
            acc.Name = 'Perusahaan';      
            acc.SCC_Tipe_Nasabah__c = 'Non-Individu';
            acc.scc_cifno__c = '1234567890123456';
        }
        return acc;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMRequest inquiryRoleUserCHMRequest(){
        SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMRequest irq = new SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMRequest();
        irq.is_request_all = '1';  
        return irq;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse inquiryRoleUserCHMResponse(){
        SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse irq = new SCC_CaseResolution_CHMSupport_Wrapper.InquiryRoleUserCHMResponse();
        irq.code = 200;
        irq.status = true;
        irq.message = 'Succes to get User Data';
        List<String> liststr = new List<String>();
        liststr.add('Type|FederationId|Pernr|Nama|CorpTitle|Hilfm|Htext|TipeUker|Area|SubArea|CostCenter|Orgeh|AreaDesc|SubAreaDesc|CostCenterDesc|OrgehDesc|Branch|DatePosition');
        liststr.add('T|00002896|00002613|Tetty Siagian|A|066|Customer Service|UN|KW02|RB02|WB33670|50562519|Regional Office Medan|Medan Iskandar|UNIT MEDAN LABUHAN|TERAS PASAR RAMBE|05321|2024-05-07T00:00:00+07:00');
        liststr.add('T|00002896|00002808|Nurmiani|A|066|Customer Service|KCP|KW02|RB17|WB36701|70360348|Regional Office Medan|Sisingamangarja|KCP AKSARA|FUNGSI OPERASIONAL & LAYANAN|00693|2024-05-07T00:00:00+07:00');
        liststr.add('C|00002896|00002813|Netty Herawaty Sitorus|A|066|Customer Service|KCP|KW02|RB17|WB36706|70360336|Regional Office Medan|Sisingamangarja|KCP SUKARAMAI|FUNGSI OPERASIONAL & LAYANAN|01086|2024-05-07T00:00:00+07:00');
        liststr.add('A|00002896|00002815|Elizabeth Riris Siagian|A|066|Customer Service|KC|KW02|RB20|WB40410|50415410|Regional Office Medan|Medan Gatsu|KK RS HELVETIA|KANTOR KAS RS HELVETIA|00404|2024-05-07T00:00:00+07:00');
        liststr.add('C|00002896|00002896|Agus Irwansyah Hutabarat|A|066|Customer Service|UN|KW02|RB03|WB08523|50427380|Regional Office Medan|Sibolga|BRI UNIT PANDAN|TERAS PANDAN|03827|2024-05-07T00:00:00+07:00');
        irq.data = liststr;
        return irq;  
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDRequest terminalIDRequest(String x){
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDRequest irq = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDRequest();
        irq.dates = '2024-01-01';
        irq.terminal_id = x;  
        return irq;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse terminalIDResponse(String x){
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDData tid = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDData();
        tid.acct_no = '100010000016';
        tid.terminal_id = x;
        tid.teller_id = '21965';
        tid.branch_code = '21';
        tid.add_time = '2024-01-01T00:00:00+07:00';
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse irq = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse();
        irq.code = 200;
        irq.status = true;
        irq.message = 'Succes get Data Terminal';
        irq.data = tid;
        return irq;  
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListRequest terminalIDListRequest(String x){
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListRequest irq = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListRequest();
        irq.dates = '2024-01-01';
        irq.input_text = x;  
        return irq;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse terminalIDListResponse(String x){
        List<String> liststr = new List<String>();
        liststr.add(x);
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse irq = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse();
        irq.code = 200;
        irq.status = true;
        irq.message = 'Succes get Data Terminal';
        irq.data = liststr;
        return irq;  
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceRequest paymentResolutionServiceRequest(){
        SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceRequest irq = new SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceRequest();
        irq.no_tt = 'TTB000000000002106';
        irq.calltype = '8812';
        irq.fitur_id = '1';
        irq.trx_date = '2024-04-18';
        irq.branchcode = '22';
        irq.terminal_id = '00060021';
        irq.acct_debet1 = '';
        irq.amt_debet1 = '100000.00'; 
        irq.acct_debet2 = '';
        irq.amt_debet2 = '';
        irq.acct_debet3 = '';
        irq.amt_debet3 = '';
        irq.acct_debet4 = '';
        irq.amt_debet4 = '';
        irq.acct_debet5 = '';
        irq.amt_debet5 = '';   
        irq.acct_kredit1 = '';
        irq.amt_kredit1 = '100000.00';
        irq.acct_kredit2 = '';
        irq.amt_kredit2 = '';
        irq.acct_kredit3 = '';
        irq.amt_kredit3 = '';
        irq.acct_kredit4 = '';
        irq.amt_kredit4 = '';
        irq.acct_kredit5 = '';
        irq.amt_kredit5 = '';
        return irq;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse paymentResolutionServiceResponse(){
        SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceData tid = new SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceData();
        tid.errorCode = 'AS-000';
        tid.responseCode = '00';
        tid.responseMessage = 'Transaction Successfully';
        tid.trancode = '8884';
        tid.journalSequence = '9951050';
        tid.needApproval = 'N';
        tid.currencyCode = '';
        tid.accountNumber = '6500154454356345';
        tid.shortName = '';
        tid.accountCurrency = 'IDR';
        tid.status = '1';
        tid.fullName = '';
        tid.branchCode = '';
        tid.accountName = 'BPG 123 xxxxxxxxxxxxx';
        tid.corporateName = 'Kexxxxxxxxxxxxx';
        tid.accType = '';
        tid.namaGiroPenarikan = 'RxxxxxxxxxxxxxDAH';
        tid.nomorGiroPenarikan = '02061014028305';
        tid.namaGiroSetoran = '';
        tid.nomorGiroSetoran = '';
        SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse irq = new SCC_CaseResolution_CHMSupport_Wrapper.PaymentResolutionServiceResponse();
        irq.code = 200;
        irq.status = true;
        irq.message = 'Succes get Data Terminal';
        irq.data = tid;
        return irq;  
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePinjaman customerProfilePinjaman(){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePinjaman pnj = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePinjaman();
        // Set values for old fields
        pnj.acctno = 'ACCT123456';
        pnj.saldo = '1000000';
        pnj.mataUang = 'IDR';
        pnj.per = '2024';
        pnj.produk = 'Personal Loan';
        pnj.tipeProduk = 'Standard';
        pnj.deskripsiProduk = 'Standard personal loan with fixed interest';
        pnj.groupProduk = 'Loans';
        pnj.openAccountDate = '2024-01-01';
        // Set values for new fields
        pnj.productType = 'Personal Loan';
        pnj.productDescription = 'Standard personal loan with fixed interest rates';
        pnj.product = 'Personal Loan Standard';
        pnj.cifno = 'CIF12345678';
        pnj.balance = 1000000.00;
        pnj.accountNumber = 'ACCT123456';
        return pnj;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileCardLink customerProfileCardLink(){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileCardLink cl = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileCardLink();
        // Set values for old fields
        cl.idNumber = 'ID123456';
        // cl.nomorKartu = 'CARD789012';
        cl.nomorKartu = '5534123456789876';
        cl.mataUang = 'USD';
        cl.kolektibilitas = 'Good';
        cl.produk = 'Credit Card';
        cl.tipeProduk = 'Premium';
        cl.deskripsiProduk = 'Premium credit card with various benefits';
        cl.groupProduk = 'Credit Cards';
        cl.openAccountDate = '2024-01-01';
        // Set values for new fields
        cl.status = '1';
        cl.productType = 'Credit Card';
        cl.productDescription = 'Premium credit card with enhanced features';
        cl.product = 'Premium Credit Card';
        cl.cifno = 'CIF12345678';
        // cl.cardNumber = 'CARD789012';
        cl.cardNumber = '5534123456789876';
        // cl.cardNo = 'CARD789012';
        cl.cardNo = '5534123456789876';
        return cl;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileInvestasi customerProfileInvestasi(){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileInvestasi inv = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileInvestasi();
        // Set values for old fields
        inv.acctno = 'INV123456';
        inv.jumlah = '1000000';
        inv.grup = 'Investment Group A';
        inv.tipeProduk = 'Equity';
        inv.deskripsiProduk = 'Equity Investment in Tech Sector';
        inv.groupProduk = 'Equity Investments';
        // Set values for new fields
        inv.status = '1';
        inv.productType = 'Equity Fund';
        inv.productDescription = 'Investment in diversified equity fund';
        inv.product = 'Tech Fund';
        inv.cifno = 'CIFINV12345';
        inv.balance = 1000000.00;
        inv.accountNumber = 'INV7891011';
        return inv;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSimpanan customerProfileSimpanan(){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSimpanan ps = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSimpanan();
        // Set values for old fields
        ps.acctno = '1234567890';
        ps.rataSaldo = '50000';
        ps.saldo = '150000';
        ps.mataUang = 'IDR';
        ps.per = 'Monthly';
        ps.produk = 'Savings Account';
        ps.tipeProduk = 'Standard';
        ps.deskripsiProduk = 'Standard Savings Account';
        ps.groupProduk = 'Personal Banking';
        ps.openAccountDate = '2023-01-01';
        
        // Set values for new fields
        ps.status = '1';
        ps.productType = 'Savings';
        ps.productDescription = 'Regular Savings Account';
        ps.product = 'Savings Account';
        ps.cifno = 'CIF123456';
        ps.balance = 150000.00;
        ps.accountNumber = '9876543210';
        ps.brimo = '0';
        return ps;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse customerProfileResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi dmg = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi();
        dmg.cfbrnn = 'CFBRNN123';
        dmg.namaSesuaiId = 'John Doe';
        dmg.gelarSesudahNama = 'S.E.';
        dmg.namaLengkap = 'John Doe';
        dmg.idNumber = '123456789';
        dmg.idType = 'KTP';
        dmg.idDesc = 'Kartu Tanda Penduduk';
        dmg.idIssue = '01-01-2020';
        dmg.idExp = '01-01-2030';
        dmg.namaIbuKandung = 'Jane Doe';
        dmg.statusNikah = 'Married';
        dmg.agama = 'Christian';
        dmg.alamatId1 = 'Jl. Mawar No. 10';
        dmg.alamatId2 = 'Kecamatan X';
        dmg.alamatId3 = 'Kelurahan Y';
        dmg.alamatId4 = 'Kota Z';
        dmg.rtId = '001';
        dmg.rwId = '002';
        dmg.kelurahanId = 'Kelurahan01';
        dmg.kecamatanId = 'Kecamatan01';
        dmg.kotaId = 'Kota01';
        dmg.propinsiIid = 'Propinsi01';
        dmg.kodeposId = '12345';
        dmg.alamatDomisili1 = 'Jl. Melati No. 20';
        dmg.alamatDomisili3 = 'Kecamatan A';
        dmg.alamatDomisili4 = 'Kota B';
        dmg.alamatKantor1 = 'Jl. Anggrek No. 30';
        dmg.alamatKantor3 = 'Kecamatan C';
        dmg.alamatKantor4 = 'Kota D';
        dmg.alamatSurat = 'Jl. Kenanga No. 40';
        dmg.kodePajak = 'PJK123456';
        dmg.prioritas = 'High';
        dmg.prioritasPbo = 'Medium';
        dmg.prioritasPboContact = 'Low';
        dmg.pepJabatan = 'Manager';
        dmg.pepKeluarga = 'Spouse';
        dmg.pepStatusKeluarga = 'Active';
        dmg.telpRumah = '08123456789';
        dmg.telpKantor = '0212345678';
        dmg.fax = '0212345679';
        dmg.kodePendidikan = 'S1';
        dmg.pendidikan = 'Bachelor';
        dmg.kodeJenisPekerjaan = 'Employee';
        dmg.namaKantor = 'ABC Corp';
        dmg.kodeBidangPekerjaan = 'Finance';
        dmg.kodeJabatan = 'Mgr';
        dmg.jabatan = 'Finance Manager';
        dmg.lamaBekerjaTahun = '5';
        dmg.lamaBekerjaBulan = '6';
        dmg.kodePenghasilanPerBulan = '5000';
        dmg.penghasilanPerBulan = '5000';
        dmg.kodeOmsetPerBulan = '6000';
        dmg.omsetPerBulan = '6000';
        dmg.kodeTrxNormalHarian = '7000';
        dmg.trxNormalHarian = '7000';
        dmg.kodeSumberPenghasilan = 'Salary';
        dmg.sumberPenghasilan = 'Salary';
        dmg.kodeTujuanBukaRekening = 'Saving';
        dmg.tujuanBukaRekening = 'Savings Account';
        dmg.tanggalBukaCif = '2024-01-01';
        dmg.tanggalMaintenanceCif = '2024-01-01';
        dmg.notesBeneficialOwner = 'N/A';
        dmg.notesIbuKandung = 'N/A';
        dmg.notesTanggalLahir = 'N/A';
        dmg.tipeIdDescCorp = 'Legal Entity';
        dmg.tanggalTerbitCorp = '2024-01-01';
        dmg.tanggalKadaluarsaCorp = '2025-01-01';
        dmg.noAktaPerubahan = 'A123';
        dmg.tanggalAktaPerubahan = '2024-01-01';
        dmg.namaPengurus1 = 'Alice Smith';
        dmg.jabatanPengurus1 = 'Director';
        dmg.teleponPengurus1 = '08234567890';
        dmg.emailPengurus1 = 'alice.smith@example.com';
        dmg.namaPengurus2 = 'Bob Brown';
        dmg.jabatanPengurus2 = 'Manager';
        dmg.teleponPengurus2 = '08345678901';
        dmg.emailPengurus2 = 'bob.brown@example.com';
        dmg.namaPengurus3 = 'Charlie Davis';
        dmg.jabatanPengurus3 = 'Assistant Manager';
        dmg.teleponPengurus3 = '08456789012';
        dmg.emailPengurus3 = 'charlie.davis@example.com';
        dmg.jumlahTanggungan = '3';
        dmg.statusKepemilikanTempatTinggal = 'Own';
        dmg.namaLengkapKontakDarurat = 'Eve White';
        dmg.nomorHandphoneKontakDarurat = '08567890123';
        dmg.NPWP = '123456789012345';
        dmg.PEP = 'Yes';
        dmg.alamatDomisili = 'Jl. Melati No. 20';
        dmg.alamatDomisili2 = 'Kecamatan A';
        dmg.alamatKantor = 'Jl. Anggrek No. 30';
        dmg.alamatKantor2 = 'Kecamatan C';
        dmg.alamatSesuaiID = 'Jl. Mawar No. 10';
        dmg.alamatSesuaiID2 = 'Kecamatan X';
        dmg.alamatSuratMenyurat = 'Jl. Kenanga No. 40';
        dmg.bidangPekerjaan = 'Finance';
        dmg.bidangUsaha = 'Banking';
        dmg.createdDate = '2024-01-01';
        dmg.email = 'john.doe@example.com';
        dmg.email1 = 'john.doe1@example.com';
        dmg.email2 = 'john.doe2@example.com';
        dmg.email3 = 'john.doe3@example.com';
        dmg.gelarSebelumNama = 'Dr.';
        dmg.gelarSetelahNama = 'PhD';
        dmg.handphone = '08123456789';
        dmg.jabatan1 = 'Finance Manager';
        dmg.jabatan2 = 'Team Lead';
        dmg.jabatan3 = 'Senior Analyst';
        dmg.jenisIdentitas = 'KTP';
        dmg.jenisKelamin = 'Male';
        dmg.jenisPekerjaan = 'Full-time';
        dmg.kecamatanDomisili = 'Kecamatan A';
        dmg.kecamatanKantor = 'Kecamatan C';
        dmg.kecamatanSesuaiID = 'Kecamatan X';
        dmg.kelurahanDomisili = 'Kelurahan A';
        dmg.kelurahanKantor = 'Kelurahan C';
        dmg.kelurahanSesuaiID = 'Kelurahan X';
        dmg.keteranganAgama = 'Christian';
        dmg.kewarganegaraan = 'Indonesian';
        dmg.kodeBidangUsaha = 'Banking';
        dmg.kodePosDomisili = '12345';
        dmg.kodePosKantor = '67890';
        dmg.kodePosSesuaiID = '54321';
        dmg.kotaDomisili = 'Kota B';
        dmg.kotaKantor = 'Kota D';
        dmg.kotaSesuaiID = 'Kota Z';
        dmg.lastModifiedDate = '2024-01-01';
        dmg.nama1 = 'John Doe';
        dmg.nama2 = 'John Smith';
        dmg.nama3 = 'John Johnson';
        dmg.namaGadisIbuKandung = 'Jane Doe';
        dmg.namaSesuaiIdentitas = 'John Doe';
        dmg.namaTempatBekerja = 'ABC Corp';
        dmg.nasabahPrioritas = 'Yes';
        dmg.negara = 'Indonesia';
        dmg.noAktaPendirian = 'B123';
        dmg.noIdCorp = 'ID123456';
        dmg.nomorIdentitas = '123456789';
        dmg.pendidikanTerakhir = 'Bachelor';
        dmg.propinsiDomisili = 'Propinsi01';
        dmg.propinsiKantor = 'Propinsi01';
        dmg.propinsiSesuaiID = 'Propinsi01';
        dmg.rtDomisili = '001';
        dmg.rtKantor = '002';
        dmg.rtSesuaiID = '003';
        dmg.rwDomisili = '001';
        dmg.rwKantor = '002';
        dmg.rwSesuaiID = '003';
        dmg.statusPerkawinan = 'Married';
        dmg.tanggalAktaPendirian = '2024-01-01';
        dmg.tanggalLahir = '1990-01-01';
        dmg.tanggalTerbit = '2024-01-01';
        dmg.telepon = '08123456789';
        dmg.telepon1 = '08234567890';
        dmg.telepon2 = '08345678901';
        dmg.telepon3 = '08456789012';
        dmg.teleponKantor = '0212345678';
        dmg.tempatLahir = 'Jakarta';
        dmg.tempatPendirian = 'Surabaya';
        dmg.tipeIdCorp = 'Legal Entity';
        dmg.tipeNasabah = 'Corporate';
        dmg.tipeNasabahDesc = 'Corporation';
        dmg.umur = 34;
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePinjaman pnj = CustomerProfilePinjaman();
        List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePinjaman> listpnj = new List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePinjaman>();
        listpnj.add(pnj);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileCardLink cl = CustomerProfileCardLink();
        List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileCardLink> listcl = new List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileCardLink>();
        listcl.add(cl);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileInvestasi inv = CustomerProfileInvestasi();
        List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileInvestasi> listinv = new List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileInvestasi>();
        listinv.add(inv);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDukcapil pd = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDukcapil();
        pd.nik= '4020104013720826';
        pd.urut= 'URUT';
        pd.namaSesuaiId= 'Artanto Iswahyudi';
        pd.namaIbuKandung= 'NAMA_IBU_KANDUNG';
        pd.tempatLahir= 'TEMPAT_LAHIR';
        pd.tanggalLahir= 'TANGGAL_LAHIR';
        pd.propinsiId= 'PROPINSI_ID';
        pd.kotaId= 'KOTA_ID';
        pd.kecamatanId= 'KECAMATAN_ID';
        pd.kelurahanId= 'KELURAHAN_ID';
        pd.alamat= 'ALAMAT';
        pd.batas= 'BATAS';
        pd.nikSiak= 'NIK_SIAK';
        pd.namaLgkpSiak= 'NAMA_LGKP_SIAK';
        pd.namaLgkpIbuSiak= 'NAMA_LGKP_IBU_SIAK';
        pd.tmptLhrSiak= 'TMPT_LHR_SIAK';
        pd.tglLhrSiak= 'TGL_LHR_SIAK';
        pd.alamatSiak= 'ALAMAT_SIAK';
        pd.noProp= 'NO_PROP';
        pd.namaProp= 'NAMA_PROP';
        pd.noKab= 'NO_KAB';
        pd.namaKab= 'NAMA_KAB';
        pd.noKec= 'NO_KEC';
        pd.namaKec= 'NAMA_KEC';
        pd.noKel= 'NO_KEL';
        pd.namaKel= 'NAMA_KEL';
        pd.sanding= 'SANDING';
        pd.kk= 'KK';
        pd.updatedAt= 'UPDATED_AT';
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSavingCard sc = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSavingCard();
        sc.cardNo= '1234567890';
        sc.jenisKartu= 'X';
        sc.kodeStatus= 'X';
        sc.tipeKartu= 'X';
        List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSavingCard> listsc = new List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSavingCard>();
        listsc.add(sc);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSimpanan ps = CustomerProfileSimpanan();
        ps.cardList =listsc;
        List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSimpanan> listps = new List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileSimpanan>();
        listps.add(ps);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePortofolioPerbankan pp = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfilePortofolioPerbankan();
        pp.cardlink= listcl;
        pp.investasi= listinv;
        pp.pinjaman= listpnj;
        pp.simpanan= listps;
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData rd = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData();
        rd.cifno= 'X';
        rd.demografi= dmg;
        rd.portofolioPerbankan= pp;
        rd.profileDukcapil= pd;
        List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData> listrd = new List<SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData>();
        listrd.add(rd);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
        res.statusCode= 200;
        res.errorCode= '000';
        res.responseCode= '00';
        res.responseMessage= 'Success';
        res.errors= null;
        res.data = listrd;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest customerProfileRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
        req.cardNo = '123';
        req.acctNo = '123';
        req.cifNo = '123';
        req.phoneNumber = '087836764367';
        req.feature = '1';
        req.idType='KT';
        req.idValue='4020104013720826';
        req.personalNumber='12345678';
        req.channelId='INDS';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest savingMutationRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationRequest();
        req.norekVarchar = '123';
        req.tanggalAwalDatetime = '2022-01-01';
        req.tanggalAkhirDatetime = '2022-01-01';
        req.channel = 'ALL CHANNEL';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData savingMutationData(integer md,integer mk,String tgl){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        dt.idNum3=0;
        dt.idNum2=0;
        dt.seq=0;
        dt.idNum =1;
        dt.noRek=123456;
        dt.tglTran=tgl;
        dt.tglEfektif='2022-08-29T00:00:00Z';
        dt.jamTran=0;
        dt.kodeTran='';
        dt.deskTran='Transaksi tidak ditemukan';
        dt.saldoAwalMutasi=0;
        dt.mutasiDebet=md;
        dt.mutasiKredit=mk;
        dt.saldoAkhirMutasi=0;
        dt.truser='';
        dt.glsign ='';
        dt.terbilang ='';
        dt.trremk ='';
        dt.auxtrc ='';
        dt.serial ='';
        dt.tlbds1 ='';
        dt.tlbds2 ='';
        return dt;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse savingMutationResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt1 = savingMutationData(100000,0,'2022-08-29T00:00:00Z');
        dt1.auxtrc = '2501';
        dt1.kodeTran = '2501';
        dt1.trremk = '089656675766 00861145 861145025100';
        dt1.tlbds1 = 'tlbds1';
        dt1.tlbds2 = 'tlbds2';
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt2 = savingMutationData(0,100000,'2022-08-29T00:00:00Z');
        dt2.auxtrc = '8554';
        dt2.kodeTran = '8554';
        dt2.noRek = Decimal.valueOf('1116010021215330');
        dt2.trremk = '11160100212153300861145861145025103';
        dt2.tlbds1 = 'tlbds1';
        dt2.tlbds2 = 'tlbds2';
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt3 = savingMutationData(100000,0,'2022-08-30T00:00:00Z');
        dt3.auxtrc = '8501';
        dt3.kodeTran = '8501';
        dt3.trremk = '601301324190401500861161';
        dt3.tlbds1 = 'tlbds1';
        dt3.tlbds2 = 'tlbds2';
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt4 = savingMutationData(0,100000,'2022-08-30T00:00:00Z');
        dt4.auxtrc = '8553';
        dt4.kodeTran = '8553';
        dt4.trremk = '601301324190401500861115';
        dt4.tlbds1 = 'tlbds1';
        dt4.tlbds2 = 'tlbds2';
        List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData> listdt = new List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData>();
        listdt.add(dt1);
        listdt.add(dt2);
        listdt.add(dt3);
        listdt.add(dt4);
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse();
        res.statusCode = 200;
        res.errorCode = '2022-01-01';
        res.responseCode = '2022-01-01';
        res.responseMessage = 'ALL CHANNEL';
        res.errors = null;
        res.data = listdt;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest dataMachineRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest req = new SCC_CaseResoultion_DataHub_Wrapper.DataMachineRequest();
        req.alamatMesin = 'benda';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse dataMachineResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.DataMachine dm = new SCC_CaseResoultion_DataHub_Wrapper.DataMachine();
        dm.tid = '520033';
        dm.jenisMesin = 'ATM';
        dm.nomorMesin = 'YBJD87878';
        dm.alamatMesin = 'Rajabasa Raya, Rajabasa, Bandar Lampung City, Lampung, Indonesia';
        dm.status = 'UP TUNAI';
        dm.kontakID = '';
        List<SCC_CaseResoultion_DataHub_Wrapper.DataMachine> ldm = new List<SCC_CaseResoultion_DataHub_Wrapper.DataMachine>();
        ldm.add(dm);
        SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse res = new SCC_CaseResoultion_DataHub_Wrapper.DataMachineResponse();
        res.code = 'bad-request';
        res.error = 'Unexpected variable xx';
        res.path = '$';
        res.machineDataByAddress = ldm;
        return res;
    }

    public static SCC_BRINotif_Wrapper.WANotifParameter waNotifParameter(String txt,String img,String tp){
        SCC_BRINotif_Wrapper.WANotifParameter pm = new SCC_BRINotif_Wrapper.WANotifParameter();
        pm.text = txt;
        pm.type = tp;
        pm.image = img;
        return pm;
    }

    public static SCC_BRINotif_Wrapper.WANotifRequest waNotifRequest(){
        SCC_BRINotif_Wrapper.WANotifParameter pm = waNotifParameter('123','','text');
        SCC_BRINotif_Wrapper.WANotifParameter pm2 = waNotifParameter('','123','text');
        List<SCC_BRINotif_Wrapper.WANotifParameter> listpm = new List<SCC_BRINotif_Wrapper.WANotifParameter>();
        listpm.add(pm);
        listpm.add(pm2);
        List<SCC_BRINotif_Wrapper.WANotifParameter> listpm2 = new List<SCC_BRINotif_Wrapper.WANotifParameter>();
        listpm2.add(pm);
        SCC_BRINotif_Wrapper.WANotifPesan ps = new SCC_BRINotif_Wrapper.WANotifPesan();
        ps.type = 'body';
        ps.parameters = listpm;
        SCC_BRINotif_Wrapper.WANotifPesan ps2 = new SCC_BRINotif_Wrapper.WANotifPesan();
        ps2.type = 'header';
        ps2.parameters = listpm2;
        List<SCC_BRINotif_Wrapper.WANotifPesan> listps = new List<SCC_BRINotif_Wrapper.WANotifPesan>();
        listps.add(ps);
        listps.add(ps2);
        SCC_BRINotif_Wrapper.WANotifRequest req = new SCC_BRINotif_Wrapper.WANotifRequest();
        req.rekening = '123';
        req.produk = 'xxx';
        req.phoneNumber = '0817678462378';
        req.pesan = 'BRI-NOTIF';
        req.pesanWA = listps;
        req.sendtime = String.valueof(system.now());
        return req;
    }

    public static SCC_BRINotif_Wrapper.WANotifResponse waNotifResponse(){
        SCC_BRINotif_Wrapper.WANotifResponse res = new SCC_BRINotif_Wrapper.WANotifResponse();
        res.errorCode = 'ES-000';
        res.reffNumber = '00';
        res.responseCode = 'Success';
        res.responseMessage = 'CLSXXXXXXXXXX';
        return res;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse generateTokenCHMSResponse(){
        SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSData dat = new SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSData();
        dat.client_id = '123';
        dat.token_type = 'Bearer';
        dat.expires_in = 720;
        dat.token = 'ajhfjbdnczxfhafjksfjsabjd';
        SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse res = new SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSResponse();
        res.status = true;
        res.code = 200;
        res.message = 'Success Login';
        res.data = dat;
        return res;
    }

    public static SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSRequest generateTokenCHMSRequest(){
        SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSRequest res = new SCC_CaseResolution_CHMSupport_Wrapper.GenerateTokenCHMSRequest();
        res.client_id = 'ES-000';
        res.client_secret = '00';
        return res;
    }

    public static  SCC_RekonWrapper.ResponseRekonResult responseRekonResult(Integer amn,String sr,String sp,String trxdt){
        SCC_RekonWrapper.ResponseRekonResult dat = new SCC_RekonWrapper.ResponseRekonResult();
        dat.account_no = '123456789';
        dat.amount = amn;
        dat.card_no = '123456789';
        dat.CreditAccount = '123456789';
        dat.CreditAccountType = 'SA';
        dat.DebetAccount = '987654321';
        dat.PenyelesaianRekon = '000-00-00 00:00:00';
        dat.seq_no = 1234;
        dat.StatusPenyelesaian = sp;
        dat.StatusRekon = sr;
        dat.TableRekon = sr+'BrinetsH1';
        dat.terminal_id = '727';
        dat.trx_date = trxdt;
        dat.uuid = '884738297428974';
        return dat;
    }

    public static SCC_RekonWrapper.ResponseRekon responseRekon(){
        SCC_RekonWrapper.ResponseRekonResult dat = responseRekonResult(200000,'Match','Sedang Dikerjakan','2022-07-09T17:00:00.000Z');
        SCC_RekonWrapper.ResponseRekonResult dat2 = responseRekonResult(300000,'Match','','2022-07-09T18:00:00.000Z');
        SCC_RekonWrapper.ResponseRekonResult dat3 = responseRekonResult(400000,'Unmatch','Tidak Dikerjakan','2022-07-09T19:00:00.000Z');
        SCC_RekonWrapper.ResponseRekonResult dat4 = responseRekonResult(400000,'Match','Transaction Successful','2022-07-09T19:00:00.000Z');
        SCC_RekonWrapper.ResponseRekonResult dat5 = responseRekonResult(500000,'Match','Sedang Proses','2022-07-09T21:00:00.000Z');
        List<SCC_RekonWrapper.ResponseRekonResult> listdat = new List<SCC_RekonWrapper.ResponseRekonResult>();
        listdat.add(dat);
        listdat.add(dat2);
        listdat.add(dat3);
        listdat.add(dat4);
        listdat.add(dat5);
        SCC_RekonWrapper.ResponseRekonData resdat = new SCC_RekonWrapper.ResponseRekonData();
        resdat.result = listdat;
        SCC_RekonWrapper.ResponseRekon res = new SCC_RekonWrapper.ResponseRekon();
        res.ERROR_CODE = 'RA-00';
        res.RESPONSE_CODE = '00';
        res.RESPONSE_MESSAGE = 'Transaction Successful';
        res.RESPONSE_DATA = resdat;
        return res;
    }

    public static SCC_RekonWrapper.RequestRekon requestRekon(){
        SCC_RekonWrapper.RequestRekon req = new SCC_RekonWrapper.RequestRekon();
        req.TerminalID = '727';
        req.TransactionDate = '2022-07-10';
        req.AccountNumber = '78216738612';
        req.Amount = '20000';
        req.Page = 1;
        return req;
    }

    public static SCC_RekonWrapper.ResponseBeritaAcaraOpname responseBeritaAcaraOpname(){
        SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult dat = new SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult();
        dat.branch = 285;
        dat.id_terminal = '12345';
        dat.JenisTerminal = 'CRM';
        dat.WaktuOpname = '2022-01-01 09:09:09';
        dat.KurangFisik = 0;
        dat.KurangKas = 0;
        dat.LebihFisik = 0;
        dat.LebihKas = 0;
        dat.StatusId = '00';
        dat.StatusName = 'Sukses Buku';
        List<SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult> listdat = new List<SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult>();
        listdat.add(dat);
        SCC_RekonWrapper.ResponseBeritaAcaraOpnameData resdat = new SCC_RekonWrapper.ResponseBeritaAcaraOpnameData();
        resdat.result = listdat;
        SCC_RekonWrapper.ResponseBeritaAcaraOpname res = new SCC_RekonWrapper.ResponseBeritaAcaraOpname();
        res.ERROR_CODE = 'RA-00';
        res.RESPONSE_CODE = '00';
        res.RESPONSE_MESSAGE = 'Transaction Successful';
        res.RESPONSE_DATA = resdat;
        return res;
    }

    public static SCC_RekonWrapper.RequestBeritaAcaraOpname requestBeritaAcaraOpname(){
        SCC_RekonWrapper.RequestBeritaAcaraOpname req = new SCC_RekonWrapper.RequestBeritaAcaraOpname();
        req.Page = 1;
        req.TanggalTransaksi = '2022-07-10';
        req.TerminalID = '78216738612';
        return req;
    }

    public static SCC_RekonWrapper.RequestFlagDataRekon requestFlagDataRekon(){
        SCC_RekonWrapper.RequestFlagDataRekon req = new SCC_RekonWrapper.RequestFlagDataRekon();
        req.NoTicket = '3748927';
        req.TransactionDate = '2022-07-10';
        req.Status = 'New';
        List<String> liststr = new List<String>();
        liststr.add('11232321');
        liststr.add('11232322');
        req.UUID = liststr;
        return req;
    }

    public static SCC_RekonWrapper.ResponseFlagDataRekon responseFlagDataRekon(){
        SCC_RekonWrapper.DataFlagDataRekon dt = new SCC_RekonWrapper.DataFlagDataRekon();
        dt.message = 'Success';
        SCC_RekonWrapper.ResponseFlagDataRekon res = new SCC_RekonWrapper.ResponseFlagDataRekon();
        res.ERROR_CODE = 'RA-00';
        res.RESPONSE_CODE = '00';
        res.RESPONSE_MESSAGE = 'Transaction Success';
        res.RESPONSE_DATA = dt;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData cardLinkAdditionalData(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData adba = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData();
        adba.namaLengkapIbuKandung= 'Udon';
        adba.nominalPendapatanPerBulan = '0009800000';
        return adba;
    }
    
    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData cardLinkCardHolderData(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData ch = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData();
        ch.limitKartuKredit = '1000000';
        ch.expiredKartu = '2025-12-31';
        ch.tanggalCetakCycle = '2024-09-01';
        ch.tanggalJatuhTempo = '2024-09-30';
        ch.sisaLimitKartu = '500000';
        ch.limitTarikTunaiKartu = '200000';
        ch.sisaLimitTarikTunaiKartu = '100000';
        ch.limitCicilanKartu = '300000';
        ch.sisaLimitCicilanKartu = '150000';
        // ch.customerNumber = 'CUST123456';
        ch.customerNumber = '5534123456789876';
        ch.tanggalTerakhirMaintenanceKartu = '2024-08-15';
        ch.namaCetakKartu = 'John Doe';
        ch.nominalFullPayment = '1000000';
        ch.nominalFullPaymentRtl = '1000000 RTL';
        ch.nominalMinimumPayment = '50000';
        ch.nominalTagihanBerjalan = '200000';
        ch.nominalPembayaranTerakhir = '100000';
        ch.tanggalPembayaranTerakhir = '2024-08-20';
        ch.alasanPemblokiran = 'Lost Card';
        ch.fixPayment = 'Yes';
        ch.jenisKartu = 'Platinum';
        ch.namaDataKartuTambahan = 'Jane Doe';
        ch.noKartuTambahan = '1234 5678 9012 3456';
        ch.postingFlag = 'Active';
        ch.tagihanTercetakBulanIni = 'Yes';
        return ch;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkSaving cardLinkSaving(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkSaving saving = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkSaving();
        saving.acctno = '1234567890';
        saving.balance = '1000000';
        saving.cifno = 'CIF12345';
        saving.product = 'Savings';
        saving.productDescription = 'Regular Savings Account';
        saving.productType = 'Savings';
        saving.status = 'Active';
        return saving;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkLoan cardLinkLoan(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkLoan loan = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkLoan();
        loan.acctno = '9876543210';
        loan.balance = '5000000';
        loan.cifno = 'CIF54321';
        loan.product = 'Loan';
        loan.productDescription = 'Personal Loan';
        loan.productType = 'Loan';
        loan.status = 'Active';
        return loan;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkInvestasi cardLinkInvestasi(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkInvestasi investasi = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkInvestasi();
        investasi.acctno = '1122334455';
        investasi.balance = '2000000';
        investasi.cifno = 'CIF11223';
        investasi.product = 'Investment';
        investasi.productDescription = 'Mutual Fund';
        investasi.productType = 'Investment';
        investasi.status = 'Active';
        return investasi;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCreditCard cardLinkCreditCard(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCreditCard creditCard = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCreditCard();
        creditCard.cardNumber = '4111111111111111';
        creditCard.cifno = 'CIF67890';
        creditCard.product = 'Credit Card';
        creditCard.productDescription = 'Visa Platinum';
        creditCard.productType = 'Credit Card';
        creditCard.status = 'Active';
        return creditCard;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkfinancialInformation cardLinkfinancialInformation(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkfinancialInformation testCardInfo = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkfinancialInformation();
        testCardInfo.tagihanBulanLalu = '1000';
        testCardInfo.totalTagihanBulanIni = '1500';
        testCardInfo.nominalTransaksiTarikTunai = '200';
        testCardInfo.bungaDitagihkan = '50';
        return testCardInfo;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkPortofolio cardLinkPortofolio(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCreditCard creditCard1 = CardLinkCreditCard();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCreditCard> creditCardList = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCreditCard>{creditCard1};
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkInvestasi investasi1 = CardLinkInvestasi();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkInvestasi> investasiList = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkInvestasi>{investasi1};
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkLoan loan1 = CardLinkLoan();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkLoan> loanList = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkLoan>{loan1};
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkSaving saving1 = CardLinkSaving();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkSaving> savingList = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkSaving>{saving1};
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPortofolio testPortofolio = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkPortofolio();
        testPortofolio.creditCard = creditCardList;
        testPortofolio.investasi = investasiList;
        testPortofolio.loan = loanList;
        testPortofolio.saving = savingList;
        return testPortofolio;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData cardLinkCustomerData(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData customerData = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData();
        customerData.namaDepan = 'John';
        customerData.namaTengah = 'Doe';
        customerData.namaBelakang = 'Smith';
        customerData.nomorHandphoneTerdaftar = '081234567890';
        customerData.nomorTelephoneKerabatTidakSerumah = '02123456789';
        customerData.nomorTelephoneRumah = '02198765432';
        customerData.nomorTelephoneKantor = '0216543210';
        customerData.namaKerabatTidakSerumah = 'Jane Doe';
        customerData.nomorNik = '1234567890123456';
        customerData.nomorNpwp = '123456789012345';
        customerData.sisaLimitNasabah = '2000000';
        customerData.limitTarikTunaiNasabah = '500000';
        customerData.sisaLimitTarikTunaiNasabah = '200000';
        customerData.limitCicilanNasabah = '3000000';
        customerData.sisaLimitCicilanNasabah = '1500000';
        customerData.jenisKelamin = 'Laki-Laki';
        customerData.jabatanKerja = 'Manager';
        customerData.alamatKantorDepan = 'Jl. Raya Kantor No. 1';
        customerData.alamatKantorTengah = 'Kantor Tengah, Blok B';
        customerData.alamatKantorBelakang = 'Gedung C, Lantai 3';
        customerData.alamatRumahDepan = 'Jl. Rumah No. 12';
        customerData.alamatRumahBelakang = 'RT 01/RW 02, Kelurahan A';
        customerData.alamatEmail = 'john.doe@example.com';
        customerData.alamatPengirimanKartu = 'Jl. Kirim Kartu No. 5';
        customerData.tanggalLahir = '1980-01-01';
        customerData.kota1 = 'Jakarta';
        customerData.kota2 = 'Bandung';
        customerData.kodePos = '12345';
        customerData.customerNumber = 'X000001';
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData ch = CardLinkCardHolderData();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData> cardHolderData = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData>();
        cardHolderData.add(ch);
        customerData.cardHolderData = cardHolderData;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData ad = CardLinkAdditionalData();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData> additionalData = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData>();
        additionalData.add(ad);
        customerData.additionalData = additionalData;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkfinancialInformation fi = CardLinkfinancialInformation();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkfinancialInformation> financialInformation = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkfinancialInformation>();
        financialInformation.add(fi);
        customerData.financialInformation = financialInformation;
        customerData.portofolio = CardLinkPortofolio();
        return customerData;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse cardLinkCardNumberResponse(){
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData> ladba = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData>();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkAdditionalData adba = cardLinkAdditionalData();
        ladba.add(adba);
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData> lch = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData>();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardHolderData ch = cardLinkCardHolderData();
        lch.add(ch);
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData> lcd = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData>();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData customerData = cardLinkCustomerData();
        lcd.add(customerData);
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkResponseData> ldt = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkResponseData>();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkResponseData dt = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkResponseData();
        dt.customerData = lcd;
        dt.cardHolderData = lch;
        dt.additionalData = ladba;
        ldt.add(dt);
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPortofolio porto = cardLinkPortofolio();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponseData ss = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponseData();
        ss.data = ldt;
        ss.portofolio = porto;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCardNumberResponse();
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        res.response = ss;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse cardLinkPhoneNumberResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData customerData = cardLinkCustomerData();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData> lcustomerData = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData>();
        lcustomerData.add(customerData);
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponseData rd = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponseData();
        rd.customerData = lcustomerData;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkPhoneNumberResponse();
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        res.response = rd;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse cardLinkNIKResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData customerData = cardLinkCustomerData();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData> lcustomerData = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData>();
        lcustomerData.add(customerData);
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPortofolio pf = cardLinkPortofolio();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponseData rd = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponseData();
        rd.customerData = lcustomerData;
        rd.portofolio = pf;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkNIKResponse();
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        res.response = rd;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse cardLinkCustomerNumberResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData customerData = cardLinkCustomerData();
        List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData> lcustomerData = new List<SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerData>();
        lcustomerData.add(customerData);
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkPortofolio pf = cardLinkPortofolio();
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponseData rd = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponseData();
        rd.customerData = lcustomerData;
        rd.portofolio = pf;
        rd.additionalData = customerData.additionalData;
        rd.cardHolderData = customerData.cardHolderData;
        rd.financialInformation = customerData.financialInformation;
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkCustomerNumberResponse();
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        res.response = rd;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest cardLinkRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest();
        req.cardNumber = '1234567890123456';
        req.phoneNumber = '087637647364';
        req.nik = '1234567890';
        req.customerNumber = '1234567890123456';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse briLinkProfileResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile profile = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile();
        profile.cifno = 'BRI00001';
        profile.tid = 'TID123';
        profile.jenis_jaringan = 'NetworkType';
        profile.alamat_agen = '123 Agent Street';
        profile.jenis_usaha = 'BusinessType';
        profile.kode_agen = 'A001';
        profile.kode_channel = 'C001';
        profile.kode_merchant = 'M001';
        profile.kode_uker_pengelola = 'UK001';
        profile.limit_transaksi = '1000';
        profile.mid = 'MID123';
        profile.modifikasi_oleh = 'ModUser';
        profile.nama_agen = 'AgentName';
        profile.nama_ibu_kandung = 'MotherName';
        profile.nama_lengkap = 'FullName';
        profile.nama_merchant = 'MerchantName';
        profile.nomor_kartu_debit = '1234567890123456';
        profile.nomor_kontak_pab = '9876543210';
        profile.nomor_ktp = 'ID1234567890';
        profile.nomor_rekening = 'Acc123456';
        profile.nomor_rekening_pelimpahan = 'AccPel123456';
        profile.nomor_rekening_pinjaman = 'AccPinjaman123456';
        profile.nomor_siup = 'SIUP123456';
        profile.pic_uker = 'PIC123';
        profile.region_office_pengelola = 'Region1';
        profile.sharing_fee = '10%';
        profile.status = 'Active';
        profile.tanggal_dibuat = '2024-01-01';
        profile.tanggal_lahir = '1990-01-01';
        profile.tanggal_modifikasi = '2024-02-01';
        profile.telepon = '0800123456';
        List<SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile> lprofile = new List<SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile>();
        lprofile.add(profile);
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse();
        res.BRILINK_PROFILE = lprofile;
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        return res;
    } 

    public static SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest briLinkProfileRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest();
        req.tid = '123';
        req.mid = '123';
        req.outletCode = '12345678';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne merchantProfileResposne(){
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile wrapper = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile();
        wrapper.cifno = 'XXX001';
        wrapper.tid = 'TID12345';
        wrapper.mid = 'MID67890';
        wrapper.alamat_merchant = '456 Merchant Avenue';
        wrapper.channel_merchant = 'ChannelX';
        wrapper.code_reffnum = 'REF001';
        wrapper.data_promo = 'PromoData';
        wrapper.detail = 'Merchant Details';
        wrapper.detail_edc = 'EDC Details';
        wrapper.email = 'merchant@example.com';
        wrapper.jenis_merchant = 'MerchantType';
        wrapper.jenis_usaha_merchant = 'BusinessType';
        wrapper.kantor_wilayah = 'OfficeRegion';
        wrapper.kanwil = 'Kanwil01';
        wrapper.kode_unit_kerja = 'UnitCode01';
        wrapper.mcc_master = 'MCC001';
        wrapper.mcc_npg = 'MCCNPG001';
        wrapper.mcc_visa = 'MCCVISA001';
        wrapper.mdr_debit_npg = 'MDRDebitNPG001';
        wrapper.mdr_debit_pl = 'MDRDebitPL001';
        wrapper.mdr_mastercard = 'MDRMastercard001';
        wrapper.mdr_offus = 'MDROffus001';
        wrapper.mdr_onus = 'MDROnus001';
        wrapper.mdr_unik = 'MDRUnik001';
        wrapper.modifikasi_oleh = 'ModifiedBy';
        wrapper.nama_merchant_edc = 'MerchantEDCName';
        wrapper.nama_merchant_qris = 'MerchantQRISName';
        wrapper.nama_pic_unit_kerja = 'PICUnitName';
        wrapper.no_batch = 'Batch001';
        wrapper.nomor_rekening_penampungan = 'Account123456';
        wrapper.nomor_telepon_merchant = '0800123456';
        wrapper.perangkat = 'DeviceType';
        wrapper.pic_merchant = 'PICMerchant';
        wrapper.pn_pic_unit_kerja = 'PNPICUnit';
        wrapper.rc = 'RC001';
        wrapper.regional_office_pengelola = 'RegionalOffice';
        wrapper.status_pemasangan = 'InstallationStatus';
        wrapper.status_ticket = 'TicketStatus';
        wrapper.tanggal_dibuat = '2024-01-01';
        wrapper.tanggal_modifikasi_terakhir = '2024-02-01';
        wrapper.tanggal_pasang = '2024-03-01';
        wrapper.tanggal_update_data = '2024-04-01';
        wrapper.telpon = '0800987654';
        wrapper.tipe = 'TypeA';
        wrapper.tipe_merchant = 'MerchantTypeA';
        wrapper.user_pemrakarsa = 'UserInitiator';
        wrapper.vendor_pemasang = 'VendorInstaller';
        List<SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile> lwrapper = new List<SCC_CaseResoultion_DataHub_Wrapper.MerchantProfile>();
        lwrapper.add(wrapper);
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne res = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileResposne();
        res.MERCHANT_PROFILE = lwrapper;
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest merchantProfileRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest();
        req.tid = '123';
        req.mid = '123';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse dplkResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK siDplk = new SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK();
        siDplk.alamat_email = 'email@example.com';
        siDplk.anggota_korporat_individu = 'IndividualCorpMember';
        siDplk.cif_dplk = 'CIF123456';
        siDplk.iuran = '1000';
        siDplk.jenis_investasi = 'InvestmentType';
        siDplk.kantor_pembukaan_cabang = 'BranchOffice';
        siDplk.nama_nasabah = 'CustomerName';
        siDplk.no_pegawai_korporat = 'EmployeeNumber';
        siDplk.nomor_akun_dplk = 'AccountNumber';
        siDplk.nomor_handphone = '08123456789';
        siDplk.pengalihan = 'Transfer';
        siDplk.pengembangan = 'Development';
        siDplk.sistem_pembayaran_iuran = 'PaymentSystem';
        siDplk.status_dplk = 'Active';
        siDplk.tanggal_lahir = '1990-01-01';
        siDplk.tgl_registrasi = '2024-01-01';
        siDplk.total_saldo = '50000';
        siDplk.nomor_kartu_dplk = 'CardNumber';
        siDplk.nomor_rekening_bri = 'BRIAccountNumber';
        siDplk.nik = '1234567890123456';
        siDplk.cifno = '1234567';
        List<SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK> lsiDplk = new List<SCC_CaseResoultion_DataHub_Wrapper.SI_DPLK>();
        lsiDplk.add(siDplk);
        SCC_CaseResoultion_DataHub_Wrapper.TRX_DPLK trxDplk = new SCC_CaseResoultion_DataHub_Wrapper.TRX_DPLK();
        trxDplk.branch_code = 'Branch001';
        trxDplk.id_transaksi = 'TXN123456';
        trxDplk.iscommited = 'Yes';
        trxDplk.keterangan = 'Transaction Description';
        trxDplk.kode_jenis_transaksi = 'TransactionType';
        trxDplk.nama_nasabah = 'CustomerName';
        trxDplk.nama_transaksi = 'TransactionName';
        trxDplk.nomor_handphone = '08123456789';
        trxDplk.tanggal_transaksi = '2024-05-01';
        trxDplk.nomor_kartu_dplk = 'CardNumber';
        trxDplk.no_rekening = 'AccountNumber';
        trxDplk.nik = '1234567890123456';
        trxDplk.cifno = '1234567';
        List<SCC_CaseResoultion_DataHub_Wrapper.TRX_DPLK> ltrxDplk = new List<SCC_CaseResoultion_DataHub_Wrapper.TRX_DPLK>();
        ltrxDplk.add(trxDplk);
        SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse res = new SCC_CaseResoultion_DataHub_Wrapper.DPLKResponse();
        res.SI_DPLK = lsiDplk;
        res.TRX_DPLK = ltrxDplk;
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest dplkRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest req = new SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest();
        req.acctNo = '123';
        req.idNumber = '123';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse cardActivityResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityData data = new SCC_CaseResoultion_DataHub_Wrapper.CardActivityData();
        data.tanggal = '2024-08-30';
        data.jam = '10:00:00';
        data.noRekening = '123456789';
        data.noKartu = '987654321';
        data.noHandphone = '08123456789';
        data.groupFitur = 'Group A';
        data.fiturId = 'F001';
        data.namaFitur = 'Feature A';
        data.channelId = 'Channel1';
        data.tellerId = 'Teller1';
        data.terminalId = 'Terminal1';
        data.amount = '1000';
        data.status = 'Success';
        data.responseCode = '00';
        data.journalSeq = 'Seq1';
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse response = new SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse();
        response.statusCode = 200;
        response.responseCode = '00';
        response.responseMessage = 'OK';
        response.errorCode = '000';
        response.errors = new List<String>{'Error1'};
        response.data = new List<SCC_CaseResoultion_DataHub_Wrapper.CardActivityData>{data};
        return response;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardActivityRequest cardActivityRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityRequest request = new SCC_CaseResoultion_DataHub_Wrapper.CardActivityRequest();
        request.posisiawal = '2024-01-01';
        request.posisiakhir = '2024-01-02';
        request.fitur = 1;
        request.nomor = '123456';
        request.scope = 1;
        return request;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse pctdResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.PCTDdata pctdData = new SCC_CaseResoultion_DataHub_Wrapper.PCTDdata();
        pctdData.detailTransaksi = 'Detail Transaksi Test';
        pctdData.tanggalTransaksi = '2024-09-06';
        pctdData.waktuTransaksi = '14:00:00';
        pctdData.nominalTransaksi = '1000';
        pctdData.keteranganTransaksi = 'Keterangan Test';
        pctdData.approvalCode = 'Approval123';
        pctdData.tanggalPostingTransaksi = '2024-09-06';
        pctdData.kodeTransaksi = 'Kode123';
        pctdData.refferenceNumber = 'Ref123';
        pctdData.akumulasiJumlahTransaksi = '5000';
        pctdData.tanggalPostingTagihan = '2024-09-07';
        pctdData.deskripsiTransaksi = 'Deskripsi Test';
        pctdData.tanggalTransaksiMenggantung = '2024-09-08';
        pctdData.nominalTransaksiMenggantung = '1500';
        pctdData.waktuSisaPenagihanMerchant = '30 Minutes';
        pctdData.jenisTransaksi = 'Jenis Test';
        list<SCC_CaseResoultion_DataHub_Wrapper.PCTDdata> ldata = new List<SCC_CaseResoultion_DataHub_Wrapper.PCTDdata>();
        ldata.add(pctdData);
        SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse res = new SCC_CaseResoultion_DataHub_Wrapper.PCTDResponse();
        res.CPAHF = ldata;
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest pctdRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest req = new SCC_CaseResoultion_DataHub_Wrapper.PCTDRequest();
        req.cardNumber = '1234123412341234';
        return req;
    }

    public static SCC_CaseResolution_EJOLWrapper.EJLogResponse ejLogResponse(){
        SCC_CaseResolution_EJOLWrapper.EJLogData dt = new SCC_CaseResolution_EJOLWrapper.EJLogData();
        dt.last_ejlog = '';
        dt.ejlog = '20/12/2024 00:03:50 CAMERA1 D:\\IMAGE\\20241220\\1_00034988__INTERVAL_CAPTURE.JPG \n20/12/2024 00:08:50 CAMERA1 D:\\IMAGE\\20241220\\1_00085013__INTERVAL_CAPTURE.JPG \n \n20/12/2024 00:09:56 -\u003e Transaction start \n20/12/2024 00:09:56 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:09:56 CAMERA1 D:\\IMAGE\\20241220\\1_00095609__START.JPG \n20/12/2024 00:09:56 CAMERA1 D:\\IMAGE\\20241220\\1_00095626_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:09:57 EMV CANDIDATES: 1 \n20/12/2024 00:09:59 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:10:05 PIN ENTERED \n20/12/2024 00:10:05 CAMERA1 D:\\IMAGE\\20241220\\1_00100512_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:10:08 ***** Tran Request State ***** \n20/12/2024 00:10:08 TRANSACTION REQUEST AF \n20/12/2024 00:10:09 Transaction reply next 523 function 5157 \n20/12/2024 00:10:09 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:47:39 \nATM ID : 190015 NO.REF: 19580 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:10:09 ***** Tran Request State ***** \n20/12/2024 00:10:09 ***** Accept Cash State ***** \n20/12/2024 00:10:09 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:10:10 ----- Clear Cash-In Device ---- \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101005_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:10:10 ----- Insert Notes ---- \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101032_601301XXXXXX6089_Insert_Notes.JPG \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101062_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101085_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:11 CAMERA2 D:\\IMAGE\\20241220\\2_00101114_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:11 CAMERA2 D:\\IMAGE\\20241220\\2_00101153_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:11 CAMERA2 D:\\IMAGE\\20241220\\2_00101176_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:12 CAMERA2 D:\\IMAGE\\20241220\\2_00101200_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:12 CAMERA2 D:\\IMAGE\\20241220\\2_00101228_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:12 CAMERA2 D:\\IMAGE\\20241220\\2_00101273_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:13 CAMERA2 D:\\IMAGE\\20241220\\2_00101314_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:13 CAMERA2 D:\\IMAGE\\20241220\\2_00101342_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:14 CAMERA2 D:\\IMAGE\\20241220\\2_00101388_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:14 CAMERA2 D:\\IMAGE\\20241220\\2_00101433_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:14 CAMERA2 D:\\IMAGE\\20241220\\2_00101474_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:15 CAMERA2 D:\\IMAGE\\20241220\\2_00101501_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:15 CAMERA2 D:\\IMAGE\\20241220\\2_00101543_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:15 CAMERA2 D:\\IMAGE\\20241220\\2_00101580_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:16 CAMERA2 D:\\IMAGE\\20241220\\2_00101617_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:16 Notes INSERTED \n20/12/2024 00:10:16 CAMERA2 D:\\IMAGE\\20241220\\2_00101641_601301XXXXXX6089_Notes_INSERTED.JPG \n20/12/2024 00:10:16 ----- Identify Notes ---- \n20/12/2024 00:10:27 INVALID NOTES RECOGNIZED \n20/12/2024 00:10:29 Notes IDENTIFIED : (IDR,50000,1) \n20/12/2024 00:10:29 Notes IDENTIFIED : (IDR,100000,29) \n20/12/2024 00:10:30 Notes REFUSED : 4 \n20/12/2024 00:10:30 ----- Remove Notes ---- \n20/12/2024 00:10:37 NOTE(S) PRESENTING STARTED \n20/12/2024 00:11:10 Output Shutter JAMMED \n EMERGENCY RECEIPT \n SEDANG TERJADI GANGGUAN \n MESIN ATAU JARINGAN KOMUNIKASI \n SILAKAN CEK SALDO ANDA \n DAN HUBUNGI KANTOR BRI TERDEKAT\n RINCIAN TRANSAKSI ANDA: \n NO KARTU: 601301******6089 \n TGL/JAM: 12/20/2024 00:11 \n TID: 190015 \n IDR 50000 X 0 \n IDR 100000 X 0 \n TOTAL = IDR \n CONTACT BRI \n 1500017 \n20/12/2024 00:11:11 ***** Accept Cash State ***** \n20/12/2024 00:11:11 ***** Close Tran State ***** \n20/12/2024 00:11:11 ***** Close Tran State ***** \n20/12/2024 00:11:22 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:11:22 \u003c- Transaction end \n \n20/12/2024 00:11:22 CAMERA1 D:\\IMAGE\\20241220\\1_00112241_601301XXXXXX6089_END.JPG \n20/12/2024 00:11:22 Card State: (1001;00000;00;--------) \n20/12/2024 00:11:22 ----- Clear Cash-In Device ---- \n20/12/2024 00:11:22 CAMERA2 D:\\IMAGE\\20241220\\2_00112272__CASH_OTHERS.JPG \n20/12/2024 00:11:24 Device PROBLEM \n20/12/2024 00:11:27 Previous Identified Notes : (IDR,50000,1) \n20/12/2024 00:11:27 Previous Identified Notes : (IDR,100000,29) \n20/12/2024 00:11:39 SERIAL NUMBERS SUCCESSFULLY STORED FOR 30 GENUINE NOTES \n20/12/2024 00:11:39 IDR 50000 S/N: SEE371483 \n20/12/2024 00:11:39 IDR 100000 S/N: EDG082772,ANW700764,BME519965,CMJ223459,CMM235449,QOK669444,PHR654590,LRV623137,GPM502448,JKF662661,ZFG443777,MFK402963,JMA106121,GKK886445,FDE730240,RFZ767334,EDF783210,VHE736715,MQC639499,EBE596899,BGP644173,NAZ889183,HHO740886,KNK561936,BBJ206459,CPE301503,SOG402171,UPO334447,WFF868840 \n20/12/2024 00:11:39 Application LOCKED \n20/12/2024 00:11:39 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:11:39 CONFIG-ID : 2002 \n20/12/2024 00:11:39 SERIAL NUMBERS SUCCESSFULLY STORED FOR 30 GENUINE NOTES \n20/12/2024 00:11:39 IDR 50000 S/N: SEE371483 \n20/12/2024 00:11:39 IDR 100000 S/N: EDG082772,ANW700764,BME519965,CMJ223459,CMM235449,QOK669444,PHR654590,LRV623137,GPM502448,JKF662661,ZFG443777,MFK402963,JMA106121,GKK886445,FDE730240,RFZ767334,EDF783210,VHE736715,MQC639499,EBE596899,BGP644173,NAZ889183,HHO740886,KNK561936,BBJ206459,CPE301503,SOG402171,UPO334447,WFF868840\n20/12/2024 00:11:39 DEP ERROR: 00006446 00000023 00000009 LYNX CASHIN: Maximum cash in retracts reached \n20/12/2024 00:11:39 DEVICE CCCashInFW STATUS 4 SUPPLY 1 \n \n20/12/2024 00:11:43 -\u003e Transaction start \n20/12/2024 00:11:43 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:11:43 CAMERA1 D:\\IMAGE\\20241220\\1_00114321__START.JPG \n20/12/2024 00:11:43 CAMERA1 D:\\IMAGE\\20241220\\1_00114349_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:11:44 EMV CANDIDATES: 1 \n20/12/2024 00:11:46 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:11:51 PIN ENTERED \n20/12/2024 00:11:51 CAMERA1 D:\\IMAGE\\20241220\\1_00115153_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:11:58 ***** Close Tran State ***** \n20/12/2024 00:11:58 ***** Close Tran State ***** \n20/12/2024 00:11:59 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:12:04 \u003c- Transaction end \n \n20/12/2024 00:12:04 CAMERA1 D:\\IMAGE\\20241220\\1_00120444_601301XXXXXX6089_END.JPG \n20/12/2024 00:12:04 Card State: (1001;00000;00;--------) \n20/12/2024 00:12:04 ----- Clear Cash-In Device ---- \n20/12/2024 00:12:04 CAMERA2 D:\\IMAGE\\20241220\\2_00120476__CASH_OTHERS.JPG \n20/12/2024 00:12:04 Device PROBLEM \n20/12/2024 00:12:05 Cassette PROBLEM \n20/12/2024 00:12:05 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:12:05 CONFIG-ID : 2002 \n \n20/12/2024 00:12:08 -\u003e Transaction start \n20/12/2024 00:12:08 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:12:08 CAMERA1 D:\\IMAGE\\20241220\\1_00120832__START.JPG \n20/12/2024 00:12:08 CAMERA1 D:\\IMAGE\\20241220\\1_00120849_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:12:10 EMV CANDIDATES: 1 \n20/12/2024 00:12:11 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED\n20/12/2024 00:12:16 PIN ENTERED \n20/12/2024 00:12:16 CAMERA1 D:\\IMAGE\\20241220\\1_00121618_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:12:20 ***** Tran Request State ***** \n20/12/2024 00:12:21 TRANSACTION REQUEST A BA \n20/12/2024 00:12:21 Transaction reply next 264 function 5108 \n20/12/2024 00:12:21 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:49:51 \nATM ID : 190015 NO.REF: 19581 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 19.858.698 \nRESPON : 00 Sukses \n20/12/2024 00:12:21 ***** Tran Request State ***** \n20/12/2024 00:12:29 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:12:35 PIN ENTERED \n20/12/2024 00:12:35 CAMERA1 D:\\IMAGE\\20241220\\1_00123514_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:12:38 ***** Tran Request State ***** \n20/12/2024 00:12:38 TRANSACTION REQUEST AF \n20/12/2024 00:12:38 Transaction reply next 523 function 5157 \n20/12/2024 00:12:39 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:50:09 \nATM ID : 190015 NO.REF: 19582 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:12:39 ***** Tran Request State *****\n20/12/2024 00:12:39 ***** Accept Cash State ***** \n20/12/2024 00:12:39 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:12:39 ----- Clear Cash-In Device ---- \n20/12/2024 00:12:39 CAMERA2 D:\\IMAGE\\20241220\\2_00123978_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:12:39 Device PROBLEM \n20/12/2024 00:12:40 Cassette PROBLEM \n20/12/2024 00:12:40 ***** Accept Cash State ***** \n20/12/2024 00:12:40 ***** Close Tran State ***** \n20/12/2024 00:12:40 ***** Close Tran State ***** \n20/12/2024 00:12:42 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:12:46 \u003c- Transaction end \n \n20/12/2024 00:12:46 CAMERA1 D:\\IMAGE\\20241220\\1_00124654_601301XXXXXX6089_END.JPG \n20/12/2024 00:12:46 Card State: (1001;00000;00;--------) \n20/12/2024 00:12:46 ----- Clear Cash-In Device ---- \n20/12/2024 00:12:46 CAMERA2 D:\\IMAGE\\20241220\\2_00124685__CASH_OTHERS.JPG \n20/12/2024 00:12:46 Device PROBLEM \n20/12/2024 00:12:47 Cassette PROBLEM \n20/12/2024 00:12:47 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:12:47 CONFIG-ID : 2002 \n \n20/12/2024 00:13:20 -\u003e Transaction start \n20/12/2024 00:13:20 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:13:20 CAMERA1 D:\\IMAGE\\20241220\\1_00132042__START.JPG \n20/12/2024 00:13:20 CAMERA1 D:\\IMAGE\\20241220\\1_00132070_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:13:22 EMV CANDIDATES: 1 \n20/12/2024 00:13:23 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:13:29 PIN ENTERED \n20/12/2024 00:13:30 CAMERA1 D:\\IMAGE\\20241220\\1_00132993_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:13:34 ***** Tran Request State ***** \n20/12/2024 00:13:34 TRANSACTION REQUEST A BA \n20/12/2024 00:13:35 Transaction reply next 264 function 5108 \n20/12/2024 00:13:35 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:51:05 \nATM ID : 190015 NO.REF: 19583 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 19.858.698 \nRESPON : 00 Sukses \n20/12/2024 00:13:35 ***** Tran Request State ***** \n20/12/2024 00:13:42 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:13:48 PIN ENTERED \n20/12/2024 00:13:49 CAMERA1 D:\\IMAGE\\20241220\\1_00134886_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:13:52 ***** Tran Request State ***** \n20/12/2024 00:13:52 TRANSACTION REQUEST AF \n20/12/2024 00:13:53 Transaction reply next 523 function 5157 \n20/12/2024 00:13:53 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:51:23 \nATM ID : 190015 NO.REF: 19584 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:13:53 ***** Tran Request State ***** \n20/12/2024 00:13:53 ***** Accept Cash State ***** \n20/12/2024 00:13:54 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:13:54 ----- Clear Cash-In Device ---- \n20/12/2024 00:13:54 CAMERA2 D:\\IMAGE\\20241220\\2_00135415_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:13:54 Device PROBLEM \n20/12/2024 00:13:54 Cassette PROBLEM \n20/12/2024 00:13:54 ***** Accept Cash State ***** \n20/12/2024 00:13:54 ***** Close Tran State ***** \n20/12/2024 00:13:54 ***** Close Tran State ***** \n20/12/2024 00:13:56 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:14:00 \u003c- Transaction end \n \n20/12/2024 00:14:01 CAMERA1 D:\\IMAGE\\20241220\\1_00140095_601301XXXXXX6089_END.JPG \n20/12/2024 00:14:01 Card State: (1001;00000;00;--------) \n20/12/2024 00:14:01 ----- Clear Cash-In Device ---- \n20/12/2024 00:14:01 CAMERA2 D:\\IMAGE\\20241220\\2_00140127__CASH_OTHERS.JPG \n20/12/2024 00:14:01 Device PROBLEM \n20/12/2024 00:14:01 Cassette PROBLEM \n20/12/2024 00:14:01 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:14:01 CONFIG-ID : 2002 \n \n20/12/2024 00:16:34 -\u003e Transaction start \n20/12/2024 00:16:34 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:16:34 CAMERA1 D:\\IMAGE\\20241220\\1_00163434__START.JPG \n20/12/2024 00:16:34 CAMERA1 D:\\IMAGE\\20241220\\1_00163451_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:16:36 EMV CANDIDATES: 1 \n20/12/2024 00:16:37 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:16:43 PIN ENTERED \n20/12/2024 00:16:43 CAMERA1 D:\\IMAGE\\20241220\\1_00164354_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:16:46 ***** Tran Request State ***** \n20/12/2024 00:16:46 TRANSACTION REQUEST AF \n20/12/2024 00:16:46 Transaction reply next 523 function 5157 \n20/12/2024 00:16:47 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:54:16 \nATM ID : 190015 NO.REF: 19585\nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:16:47 ***** Tran Request State ***** \n20/12/2024 00:16:47 ***** Accept Cash State ***** \n20/12/2024 00:16:47 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:16:47 ----- Clear Cash-In Device ---- \n20/12/2024 00:16:47 CAMERA2 D:\\IMAGE\\20241220\\2_00164770_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:16:47 Device PROBLEM \n20/12/2024 00:16:47 Cassette PROBLEM \n20/12/2024 00:16:48 ***** Accept Cash State ***** \n20/12/2024 00:16:48 ***** Close Tran State ***** \n20/12/2024 00:16:48 ***** Close Tran State ***** \n20/12/2024 00:16:50 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:16:54 \u003c- Transaction end \n \n20/12/2024 00:16:54 CAMERA1 D:\\IMAGE\\20241220\\1_00165449_601301XXXXXX6089_END.JPG \n20/12/2024 00:16:54 Card State: (1001;00000;00;--------) \n20/12/2024 00:16:54 ----- Clear Cash-In Device ---- \n20/12/2024 00:16:54 Device PROBLEM \n20/12/2024 00:16:55 CAMERA2 D:\\IMAGE\\20241220\\2_00165481__CASH_OTHERS.JPG \n20/12/2024 00:16:55 Cassette PROBLEM \n20/12/2024 00:16:55 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:16:55 CONFIG-ID : 2002 \n \n20/12/2024 00:16:57 -\u003e Transaction start \n20/12/2024 00:16:57 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:16:57 CAMERA1 D:\\IMAGE\\20241220\\1_00165779__START.JPG \n20/12/2024 00:16:58 CAMERA1 D:\\IMAGE\\20241220\\1_00165798_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:16:59 EMV CANDIDATES: 1 \n20/12/2024 00:17:01 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:17:06 PIN ENTERED \n20/12/2024 00:17:06 CAMERA1 D:\\IMAGE\\20241220\\1_00170600_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:17:11 ***** Tran Request State ***** \n20/12/2024 00:17:11 TRANSACTION REQUEST AF \n20/12/2024 00:17:11 Transaction reply next 523 function 5157 \n20/12/2024 00:17:12 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:54:41 \nATM ID : 190015 NO.REF: 19586 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:17:12 ***** Tran Request State ***** \n20/12/2024 00:17:12 ***** Accept Cash State ***** \n20/12/2024 00:17:12 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:17:12 ----- Clear Cash-In Device ---- \n20/12/2024 00:17:12 CAMERA2 D:\\IMAGE\\20241220\\2_00171264_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:17:12 Device PROBLEM \n20/12/2024 00:17:12 Cassette PROBLEM \n20/12/2024 00:17:13 ***** Accept Cash State ***** \n20/12/2024 00:17:13 ***** Close Tran State ***** \n20/12/2024 00:17:13 ***** Close Tran State ***** \n20/12/2024 00:17:15 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:17:19 \u003c- Transaction end \n \n20/12/2024 00:17:19 CAMERA1 D:\\IMAGE\\20241220\\1_00171944_601301XXXXXX6089_END.JPG \n20/12/2024 00:17:19 Card State: (1001;00000;00;--------) \n20/12/2024 00:17:19 ----- Clear Cash-In Device ---- \n20/12/2024 00:17:19 CAMERA2 D:\\IMAGE\\20241220\\2_00171976__CASH_OTHERS.JPG \n20/12/2024 00:17:19 Device PROBLEM \n20/12/2024 00:17:20 Cassette PROBLEM \n20/12/2024 00:17:20 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:17:20 CONFIG-ID : 2002 \n \n20/12/2024 00:17:34 -\u003e Transaction start \n20/12/2024 00:17:34 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:17:34 CAMERA1 D:\\IMAGE\\20241220\\1_00173473__START.JPG \n20/12/2024 00:17:35 CAMERA1 D:\\IMAGE\\20241220\\1_00173489_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:17:36 EMV CANDIDATES: 1 \n20/12/2024 00:17:37 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:17:47 PIN ENTERED \n20/12/2024 00:17:47 CAMERA1 D:\\IMAGE\\20241220\\1_00174742_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:17:57 ***** Close Tran State ***** \n20/12/2024 00:17:57 ***** Close Tran State ***** \n20/12/2024 00:18:00 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:18:03 \u003c- Transaction end \n \n20/12/2024 00:18:03 CAMERA1 D:\\IMAGE\\20241220\\1_00180332_601301XXXXXX6089_END.JPG \n20/12/2024 00:18:03 Card State: (1001;00000;00;--------) \n20/12/2024 00:18:03 ----- Clear Cash-In Device ---- \n20/12/2024 00:18:03 Device PROBLEM \n20/12/2024 00:18:03 CAMERA2 D:\\IMAGE\\20241220\\2_00180364__CASH_OTHERS.JPG \n20/12/2024 00:18:03 Cassette PROBLEM \n20/12/2024 00:18:03 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:18:04 CONFIG-ID : 2002 \n \n20/12/2024 00:18:07 -\u003e Transaction start\n20/12/2024 00:18:07 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:18:07 CAMERA1 D:\\IMAGE\\20241220\\1_00180711__START.JPG \n20/12/2024 00:18:07 CAMERA1 D:\\IMAGE\\20241220\\1_00180728_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:18:08 EMV CANDIDATES: 1 \n20/12/2024 00:18:10 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:18:14 PIN ENTERED \n20/12/2024 00:18:14 CAMERA1 D:\\IMAGE\\20241220\\1_00181483_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:18:35 ***** Tran Request State ***** \n20/12/2024 00:18:35 TRANSACTION REQUEST A BA \n20/12/2024 00:18:36 Transaction reply next 264 function 5108 \n20/12/2024 00:18:36 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:56:06 \nATM ID : 190015 NO.REF: 19587 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 19.858.698 \nRESPON : 00 Sukses \n20/12/2024 00:18:36 ***** Tran Request State ***** \n20/12/2024 00:18:47 ***** Close Tran State ***** \n20/12/2024 00:18:47 ***** Close Tran State ***** \n20/12/2024 00:18:49 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:18:53 \u003c- Transaction end \n \n20/12/2024 00:18:53 CAMERA1 D:\\IMAGE\\20241220\\1_00185339_601301XXXXXX6089_END.JPG \n20/12/2024 00:18:53 Card State: (1001;00000;00;--------) \n20/12/2024 00:18:54 ----- Clear Cash-In Device ---- \n20/12/2024 00:18:54 Device PROBLEM \n20/12/2024 00:18:54 Cassette PROBLEM \n20/12/2024 00:18:54 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 00:18:55 CONFIG-ID : 2002 \n20/12/2024 00:18:55 CAMERA2 D:\\IMAGE\\20241220\\2_00185460__CASH_OTHERS.JPG \n20/12/2024 00:23:53 CAMERA1 D:\\IMAGE\\20241220\\1_00235365__INTERVAL_CAPTURE.JPG \n20/12/2024 00:28:54 CAMERA1 D:\\IMAGE\\20241220\\1_00285387__INTERVAL_CAPTURE.JPG \n20/12/2024 00:33:54 CAMERA1 D:\\IMAGE\\20241220\\1_00335423__INTERVAL_CAPTURE.JPG \n20/12/2024 00:38:54 CAMERA1 D:\\IMAGE\\20241220\\1_00385463__INTERVAL_CAPTURE.JPG \n20/12/2024 00:43:54 CAMERA1 D:\\IMAGE\\20241220\\1_00435487__INTERVAL_CAPTURE.JPG \n20/12/2024 00:48:55 CAMERA1 D:\\IMAGE\\20241220\\1_00485508__INTERVAL_CAPTURE.JPG \n20/12/2024 00:53:55 CAMERA1 D:\\IMAGE\\20241220\\1_00535523__INTERVAL_CAPTURE.JPG \n \n20/12/2024 00:55:55 -\u003e Transaction start \n20/12/2024 00:55:55 TRACK 2 DATA: 601301XXXXXX0133 \n20/12/2024 00:55:55 CAMERA1 D:\\IMAGE\\20241220\\1_00555501__START.JPG \n20/12/2024 00:55:55 CAMERA1 D:\\IMAGE\\20241220\\1_00555521_601301XXXXXX0133_CARD.JPG \n20/12/2024 00:55:56 EMV CANDIDATES: 1 \n20/12/2024 00:55:58 EMV AID A0000006021010 / 601301XXXXXX0133 STARTED \n20/12/2024 00:56:04 PIN ENTERED \n20/12/2024 00:56:04 CAMERA1 D:\\IMAGE\\20241220\\1_00560476_601301XXXXXX0133_PIN.JPG \n20/12/2024 00:56:09 ***** Tran Request State ***** \n20/12/2024 00:56:09 TRANSACTION REQUEST AF \n20/12/2024 00:56:09 Transaction reply next 523 function 5157 \n20/12/2024 00:56:10 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 00:33:40 \nATM ID : 190015 NO.REF: 201 \nCARD : 601301XXXXXX0133 \nREK : 465501017443539 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:56:10 ***** Tran Request State ***** \n20/12/2024 00:56:10 ***** Accept Cash State ***** \n20/12/2024 00:56:10 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:56:10 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:10 Device PROBLEM \n20/12/2024 00:56:10 CAMERA2 D:\\IMAGE\\20241220\\2_00561061_601301XXXXXX0133_CASH_OTHERS.JPG \n20/12/2024 00:56:10 Cassette PROBLEM \n20/12/2024 00:56:11 ***** Accept Cash State ***** \n20/12/2024 00:56:11 ***** Close Tran State *****\n20/12/2024 00:56:11 ***** Close Tran State ***** \n20/12/2024 00:56:16 CARD(601301XXXXXX0133) TAKEN \n20/12/2024 00:56:17 \u003c- Transaction end \n \n20/12/2024 00:56:17 CAMERA1 D:\\IMAGE\\20241220\\1_00561738_601301XXXXXX0133_END.JPG \n20/12/2024 00:56:17 Card State: (1001;00000;00;--------) \n20/12/2024 00:56:17 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:17 Device PROBLEM \n20/12/2024 00:56:17 CAMERA2 D:\\IMAGE\\20241220\\2_00561770__CASH_OTHERS.JPG \n20/12/2024 00:56:17 Cassette PROBLEM \n20/12/2024 00:56:18 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:56:18 CONFIG-ID : 2002 \n \n20/12/2024 00:56:20 -\u003e Transaction start \n20/12/2024 00:56:20 TRACK 2 DATA: 601301XXXXXX0133 \n20/12/2024 00:56:20 CAMERA1 D:\\IMAGE\\20241220\\1_00562007__START.JPG \n20/12/2024 00:56:20 CAMERA1 D:\\IMAGE\\20241220\\1_00562032_601301XXXXXX0133_CARD.JPG \n20/12/2024 00:56:21 EMV CANDIDATES: 1 \n20/12/2024 00:56:23 EMV AID A0000006021010 / 601301XXXXXX0133 STARTED \n20/12/2024 00:56:36 PIN ENTERED \n20/12/2024 00:56:36 CAMERA1 D:\\IMAGE\\20241220\\1_00563650_601301XXXXXX0133_PIN.JPG \n20/12/2024 00:56:39 ***** Tran Request State ***** \n20/12/2024 00:56:40 TRANSACTION REQUEST AF \n20/12/2024 00:56:40 Transaction reply next 523 function 5157 \n20/12/2024 00:56:40 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 00:34:10 \nATM ID : 190015 NO.REF: 202 \nCARD : 601301XXXXXX0133 \nREK : 465501017443539 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:56:40 ***** Tran Request State ***** \n20/12/2024 00:56:40 ***** Accept Cash State ***** \n20/12/2024 00:56:41 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:56:41 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:41 Device PROBLEM \n20/12/2024 00:56:41 CAMERA2 D:\\IMAGE\\20241220\\2_00564118_601301XXXXXX0133_CASH_OTHERS.JPG \n20/12/2024 00:56:41 Cassette PROBLEM \n20/12/2024 00:56:41 ***** Accept Cash State ***** \n20/12/2024 00:56:41 ***** Close Tran State ***** \n20/12/2024 00:56:41 ***** Close Tran State ***** \n20/12/2024 00:56:46 CARD(601301XXXXXX0133) TAKEN \n20/12/2024 00:56:47 \u003c- Transaction end \n \n20/12/2024 00:56:47 CAMERA1 D:\\IMAGE\\20241220\\1_00564792_601301XXXXXX0133_END.JPG \n20/12/2024 00:56:48 Card State: (1001;00000;00;--------) \n20/12/2024 00:56:48 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:48 Device PROBLEM \n20/12/2024 00:56:48 CAMERA2 D:\\IMAGE\\20241220\\2_00564826__CASH_OTHERS.JPG \n20/12/2024 00:56:48 Cassette PROBLEM\n20/12/2024 00:56:48 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:56:48 CONFIG-ID : 2002\n20/12/2024 01:01:48 CAMERA1 D:\\IMAGE\\20241220\\1_01014812__INTERVAL_CAPTURE.JPG \n20/12/2024 01:06:48 CAMERA1 D:\\IMAGE\\20241220\\1_01064835__INTERVAL_CAPTURE.JPG \n20/12/2024 01:11:48 CAMERA1 D:\\IMAGE\\20241220\\1_01114859__INTERVAL_CAPTURE.JPG \n20/12/2024 01:16:48 CAMERA1 D:\\IMAGE\\20241220\\1_01164881__INTERVAL_CAPTURE.JPG \n20/12/2024 01:21:49 CAMERA1 D:\\IMAGE\\20241220\\1_01214905__INTERVAL_CAPTURE.JPG \n20/12/2024 01:26:49 CAMERA1 D:\\IMAGE\\20241220\\1_01264917__INTERVAL_CAPTURE.JPG \n20/12/2024 01:31:49 CAMERA1 D:\\IMAGE\\20241220\\1_01314933__INTERVAL_CAPTURE.JPG \n20/12/2024 01:36:49 CAMERA1 D:\\IMAGE\\20241220\\1_01364944__INTERVAL_CAPTURE.JPG \n20/12/2024 01:41:49 CAMERA1 D:\\IMAGE\\20241220\\1_01414958__INTERVAL_CAPTURE.JPG \n20/12/2024 01:46:49 CAMERA1 D:\\IMAGE\\20241220\\1_01464975__INTERVAL_CAPTURE.JPG \n20/12/2024 01:51:50 CAMERA1 D:\\IMAGE\\20241220\\1_01514998__INTERVAL_CAPTURE.JPG \n20/12/2024 01:56:50 CAMERA1 D:\\IMAGE\\20241220\\1_01565017__INTERVAL_CAPTURE.JPG \n20/12/2024 02:01:50 CAMERA1 D:\\IMAGE\\20241220\\1_02015045__INTERVAL_CAPTURE.JPG \n20/12/2024 02:06:50 CAMERA1 D:\\IMAGE\\20241220\\1_02065066__INTERVAL_CAPTURE.JPG \n20/12/2024 02:11:50 CAMERA1 D:\\IMAGE\\20241220\\1_02115078__INTERVAL_CAPTURE.JPG \n20/12/2024 02:16:51 CAMERA1 D:\\IMAGE\\20241220\\1_02165091__INTERVAL_CAPTURE.JPG \n20/12/2024 02:21:51 CAMERA1 D:\\IMAGE\\20241220\\1_02215111__INTERVAL_CAPTURE.JPG \n \n20/12/2024 02:24:15 -\u003e Transaction start \n20/12/2024 02:24:15 CAMERA1 D:\\IMAGE\\20241220\\1_02241517__START.JPG \n20/12/2024 02:24:34 INFORMATION 100777 ENTERED\n20/12/2024 02:24:41 INFORMATION 081250261150 ENTERED \n20/12/2024 02:24:41 ***** Tran Request State ***** \n20/12/2024 02:24:41 EDM ERROR, CHECK KEYS \n20/12/2024 02:24:41 DEVICE CCEppFW/PIN30 EFC CODE: EV8 0 00 00 \n20/12/2024 02:24:41 TRANSACTION REQUEST A I \n20/12/2024 02:24:42 Transaction reply next 016 function 2024 \n20/12/2024 02:24:42 TRANSACTION 0003 FAILED \n20/12/2024 02:24:42 CDM ERROR: 00006434 0000004C 00000000 LYNX TRX: Shutter closed but cash tray not empty, dispense operation declined \n20/12/2024 02:24:42 DEVICE CCCdmFW STATUS 4 SUPPLY 1 \n20/12/2024 02:24:42 Transaction reply next 015 function 3105 \nTANGGAL: 20/12/24 WAKTU : 02:02:12 \nATM ID : 190015 NO.REF: 203 \nCARD : 6013500000000000 \nREK : 081250261150 \nKODETX : 141 Cardless Default Error Re \nAMOUNT : RP 1,000,000 \nSALDO : \nRESPON : %5 DISPENSE FAIL \nSWITCHING : BRIMO \n20/12/2024 02:24:43 ***** Tran Request State ***** \n20/12/2024 02:24:43 ***** Close Tran State ***** \n20/12/2024 02:24:43 ***** Close Tran State ***** \n20/12/2024 02:24:50 \u003c- Transaction end \n \n20/12/2024 02:24:50 CAMERA1 D:\\IMAGE\\20241220\\1_02245001__END.JPG \n20/12/2024 02:24:50 Card State: (4101;00000;00;--------) \n20/12/2024 02:24:50 ----- Clear Cash-In Device ---- \n20/12/2024 02:24:50 Device PROBLEM \n20/12/2024 02:24:50 CAMERA2 D:\\IMAGE\\20241220\\2_02245034__CASH_OTHERS.JPG \n20/12/2024 02:24:50 Cassette PROBLEM \n20/12/2024 02:24:50 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 02:24:50 CONFIG-ID : 2002 \n \n20/12/2024 02:25:08 -\u003e Transaction start \n20/12/2024 02:25:08 CAMERA1 D:\\IMAGE\\20241220\\1_02250838__START.JPG \n20/12/2024 02:25:12 GO OUT OF SERVICE COMMAND \n20/12/2024 02:25:28 INFORMATION 054218 ENTERED \n20/12/2024 02:25:35 INFORMATION 081250261150 ENTERED \n20/12/2024 02:25:35 ***** Tran Request State ***** \n20/12/2024 02:25:35 EDM ERROR, CHECK KEYS \n20/12/2024 02:25:35 DEVICE CCEppFW/PIN30 EFC CODE: EV8 0 00 00 \n20/12/2024 02:25:35 TRANSACTION REQUEST A I \n20/12/2024 02:25:35 Transaction reply next 015 function 3105 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 203| \nCARD : 6013500000000000 \nREK : \nKODETX : 909 CARDLESS \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 02:25:36 ***** Tran Request State ***** \n20/12/2024 02:25:36 ***** Close Tran State ***** \n20/12/2024 02:25:36 ***** Close Tran State *****\n20/12/2024 02:25:42 \u003c- Transaction end \n \n20/12/2024 02:25:42 CAMERA1 D:\\IMAGE\\20241220\\1_02254286__END.JPG \n20/12/2024 02:25:43 Card State: (4101;00000;00;--------) \n20/12/2024 02:25:43 ----- Clear Cash-In Device ---- \n20/12/2024 02:25:43 CAMERA2 D:\\IMAGE\\20241220\\2_02254339__CASH_OTHERS.JPG \n20/12/2024 02:25:43 Device PROBLEM \n20/12/2024 02:25:43 Cassette PROBLEM \n20/12/2024 02:25:43 GO IN SERVICE COMMAND \n20/12/2024 02:25:45 ----- Clear Cash-In Device ---- \n20/12/2024 02:25:45 CAMERA2 D:\\IMAGE\\20241220\\2_02254573__CASH_OTHERS.JPG \n20/12/2024 02:25:45 Device PROBLEM \n20/12/2024 02:25:45 Cassette PROBLEM \n20/12/2024 02:25:46 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 02:25:46 CONFIG-ID : 2002\n20/12/2024 02:30:43 CAMERA1 D:\\IMAGE\\20241220\\1_02304308__INTERVAL_CAPTURE.JPG \n20/12/2024 02:35:43 CAMERA1 D:\\IMAGE\\20241220\\1_02354343__INTERVAL_CAPTURE.JPG \n20/12/2024 02:40:43 CAMERA1 D:\\IMAGE\\20241220\\1_02404363__INTERVAL_CAPTURE.JPG \n20/12/2024 02:45:43 CAMERA1 D:\\IMAGE\\20241220\\1_02454378__INTERVAL_CAPTURE.JPG \n20/12/2024 02:50:44 CAMERA1 D:\\IMAGE\\20241220\\1_02504404__INTERVAL_CAPTURE.JPG \n20/12/2024 02:55:44 CAMERA1 D:\\IMAGE\\20241220\\1_02554429__INTERVAL_CAPTURE.JPG \n20/12/2024 03:00:44 CAMERA1 D:\\IMAGE\\20241220\\1_03004460__INTERVAL_CAPTURE.JPG \n20/12/2024 03:05:44 CAMERA1 D:\\IMAGE\\20241220\\1_03054480__INTERVAL_CAPTURE.JPG \n20/12/2024 03:10:45 CAMERA1 D:\\IMAGE\\20241220\\1_03104492__INTERVAL_CAPTURE.JPG \n20/12/2024 03:15:45 CAMERA1 D:\\IMAGE\\20241220\\1_03154513__INTERVAL_CAPTURE.JPG \n20/12/2024 03:20:45 CAMERA1 D:\\IMAGE\\20241220\\1_03204541__INTERVAL_CAPTURE.JPG \n20/12/2024 03:25:45 CAMERA1 D:\\IMAGE\\20241220\\1_03254552__INTERVAL_CAPTURE.JPG \n20/12/2024 03:30:45 CAMERA1 D:\\IMAGE\\20241220\\1_03304582__INTERVAL_CAPTURE.JPG \n20/12/2024 03:35:46 CAMERA1 D:\\IMAGE\\20241220\\1_03354598__INTERVAL_CAPTURE.JPG \n20/12/2024 03:40:46 CAMERA1 D:\\IMAGE\\20241220\\1_03404631__INTERVAL_CAPTURE.JPG \n20/12/2024 03:45:46 CAMERA1 D:\\IMAGE\\20241220\\1_03454660__INTERVAL_CAPTURE.JPG \n20/12/2024 03:50:46 CAMERA1 D:\\IMAGE\\20241220\\1_03504677__INTERVAL_CAPTURE.JPG \n20/12/2024 03:55:47 CAMERA1 D:\\IMAGE\\20241220\\1_03554707__INTERVAL_CAPTURE.JPG \n20/12/2024 04:00:47 CAMERA1 D:\\IMAGE\\20241220\\1_04004739__INTERVAL_CAPTURE.JPG \n20/12/2024 04:05:47 CAMERA1 D:\\IMAGE\\20241220\\1_04054773__INTERVAL_CAPTURE.JPG \n20/12/2024 04:10:48 CAMERA1 D:\\IMAGE\\20241220\\1_04104804__INTERVAL_CAPTURE.JPG \n20/12/2024 04:15:48 CAMERA1 D:\\IMAGE\\20241220\\1_04154835__INTERVAL_CAPTURE.JPG \n20/12/2024 04:20:48 CAMERA1 D:\\IMAGE\\20241220\\1_04204848__INTERVAL_CAPTURE.JPG \n20/12/2024 04:20:51 GO IN SERVICE COMMAND\n20/12/2024 04:25:48 CAMERA1 D:\\IMAGE\\20241220\\1_04254884__INTERVAL_CAPTURE.JPG \n20/12/2024 04:30:49 CAMERA1 D:\\IMAGE\\20241220\\1_04304914__INTERVAL_CAPTURE.JPG \n20/12/2024 04:35:49 CAMERA1 D:\\IMAGE\\20241220\\1_04354938__INTERVAL_CAPTURE.JPG \n20/12/2024 04:40:49 CAMERA1 D:\\IMAGE\\20241220\\1_04404967__INTERVAL_CAPTURE.JPG \n20/12/2024 04:45:50 CAMERA1 D:\\IMAGE\\20241220\\1_04455001__INTERVAL_CAPTURE.JPG \n \n20/12/2024 04:48:51 -\u003e Transaction start \n20/12/2024 04:48:51 TRACK 2 DATA: 601301XXXXXX4613 \n20/12/2024 04:48:52 CAMERA1 D:\\IMAGE\\20241220\\1_04485196__START.JPG \n20/12/2024 04:48:52 CAMERA1 D:\\IMAGE\\20241220\\1_04485224_601301XXXXXX4613_CARD.JPG \n20/12/2024 04:48:54 EMV CANDIDATES: 1 \n20/12/2024 04:48:57 EMV AID A0000006021010 / 601301XXXXXX4613 STARTED \n20/12/2024 04:49:13 PIN ENTERED \n20/12/2024 04:49:13 CAMERA1 D:\\IMAGE\\20241220\\1_04491305_601301XXXXXX4613_PIN.JPG \n20/12/2024 04:49:25 AMOUNT 5 ENTERED \n20/12/2024 04:49:27 AMOUNT ENTERED \n20/12/2024 04:49:31 AMOUNT ENTERED \n20/12/2024 04:49:39 AMOUNT 50000 ENTERED\n20/12/2024 04:49:46 ***** Tran Request State ***** \n20/12/2024 04:49:47 TRANSACTION REQUEST A BBC \n20/12/2024 04:49:47 Transaction reply next 009 function 5102 \n20/12/2024 04:49:47 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 04:49:48 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 203 \nCARD : 601301XXXXXX4613 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 04:49:48 ***** Tran Request State ***** \n20/12/2024 04:49:52 ***** Close Tran State ***** \n20/12/2024 04:49:52 ***** Close Tran State ***** \n20/12/2024 04:49:54 CARD(601301XXXXXX4613) TAKEN \n20/12/2024 04:49:58 \u003c- Transaction end \n \n20/12/2024 04:49:58 CAMERA1 D:\\IMAGE\\20241220\\1_04495878_601301XXXXXX4613_END.JPG \n20/12/2024 04:49:58 Card State: (1001;00000;00;--------) \n20/12/2024 04:49:59 ----- Clear Cash-In Device ---- \n20/12/2024 04:49:59 CAMERA2 D:\\IMAGE\\20241220\\2_04495911__CASH_OTHERS.JPG \n20/12/2024 04:49:59 Device PROBLEM \n20/12/2024 04:49:59 Cassette PROBLEM \n20/12/2024 04:49:59 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 04:49:59 CONFIG-ID : 2002 \n \n20/12/2024 04:50:15 -\u003e Transaction start \n20/12/2024 04:50:15 TRACK 2 DATA: 601301XXXXXX4613\n20/12/2024 04:50:15 CAMERA1 D:\\IMAGE\\20241220\\1_04501546__START.JPG \n20/12/2024 04:50:15 CAMERA1 D:\\IMAGE\\20241220\\1_04501577_601301XXXXXX4613_CARD.JPG \n20/12/2024 04:50:18 EMV CANDIDATES: 1 \n20/12/2024 04:50:20 EMV AID A0000006021010 / 601301XXXXXX4613 STARTED \n20/12/2024 04:50:26 PIN ENTERED \n20/12/2024 04:50:27 CAMERA1 D:\\IMAGE\\20241220\\1_04502695_601301XXXXXX4613_PIN.JPG \n20/12/2024 04:50:43 AMOUNT 50000 ENTERED \n20/12/2024 04:50:51 ***** Tran Request State ***** \n20/12/2024 04:50:51 TRANSACTION REQUEST A BBC \n20/12/2024 04:50:51 Transaction reply next 009 function 5102 \n20/12/2024 04:50:51 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 04:50:52 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 203 \nCARD : 601301XXXXXX4613 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 04:50:52 ***** Tran Request State ***** \n20/12/2024 04:50:59 ***** Close Tran State ***** \n20/12/2024 04:50:59 ***** Close Tran State ***** \n20/12/2024 04:51:03 CARD(601301XXXXXX4613) TAKEN \n20/12/2024 04:51:05 \u003c- Transaction end \n \n20/12/2024 04:51:05 CAMERA1 D:\\IMAGE\\20241220\\1_04510563_601301XXXXXX4613_END.JPG \n20/12/2024 04:51:05 Card State: (1001;00000;00;--------) \n20/12/2024 04:51:05 ----- Clear Cash-In Device ---- \n20/12/2024 04:51:06 Device PROBLEM \n20/12/2024 04:51:06 CAMERA2 D:\\IMAGE\\20241220\\2_04510596__CASH_OTHERS.JPG \n20/12/2024 04:51:06 Cassette PROBLEM \n20/12/2024 04:51:06 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 04:51:06 CONFIG-ID : 2002\n20/12/2024 04:56:05 CAMERA1 D:\\IMAGE\\20241220\\1_04560580__INTERVAL_CAPTURE.JPG \n20/12/2024 05:01:06 CAMERA1 D:\\IMAGE\\20241220\\1_05010597__INTERVAL_CAPTURE.JPG \n \n20/12/2024 05:04:20 -\u003e Transaction start \n20/12/2024 05:04:20 TRACK 2 DATA: 601301XXXXXX6016 \n20/12/2024 05:04:20 CAMERA1 D:\\IMAGE\\20241220\\1_05042025__START.JPG \n20/12/2024 05:04:20 CAMERA1 D:\\IMAGE\\20241220\\1_05042036_601301XXXXXX6016_CARD.JPG \n20/12/2024 05:04:23 EMV CANDIDATES: 1 \n20/12/2024 05:04:25 EMV AID A0000006021010 / 601301XXXXXX6016 STARTED \n20/12/2024 05:04:30 PIN ENTERED \n20/12/2024 05:04:30 CAMERA1 D:\\IMAGE\\20241220\\1_05043033_601301XXXXXX6016_PIN.JPG \n20/12/2024 05:04:34 ***** Tran Request State ***** \n20/12/2024 05:04:34 TRANSACTION REQUEST A BB \n20/12/2024 05:04:35 Transaction reply next 264 function 5108 \n20/12/2024 05:04:36 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 04:42:05 \nATM ID : 190015 NO.REF: 204 \nCARD : 601301XXXXXX6016 \nREK : 356701020330535 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 415,250 \nRESPON : 00 Sukses \n20/12/2024 05:04:36 ***** Tran Request State *****\n20/12/2024 05:04:43 EMV AID A0000006021010 / 601301XXXXXX6016 STARTED \n20/12/2024 05:04:47 PIN ENTERED \n20/12/2024 05:04:47 CAMERA1 D:\\IMAGE\\20241220\\1_05044705_601301XXXXXX6016_PIN.JPG \n20/12/2024 05:04:58 AMOUNT 350000 ENTERED \n20/12/2024 05:05:01 ***** Tran Request State ***** \n20/12/2024 05:05:02 TRANSACTION REQUEST A BBC \n20/12/2024 05:05:02 Transaction reply next 009 function 5102 \n20/12/2024 05:05:02 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:05:03 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 204 \nCARD : 601301XXXXXX6016 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:05:03 ***** Tran Request State ***** \n20/12/2024 05:05:09 EMV AID A0000006021010 / 601301XXXXXX6016 STARTED \n20/12/2024 05:05:13 PIN ENTERED \n20/12/2024 05:05:13 CAMERA1 D:\\IMAGE\\20241220\\1_05051365_601301XXXXXX6016_PIN.JPG \n20/12/2024 05:05:17 ***** Tran Request State ***** \n20/12/2024 05:05:18 TRANSACTION REQUEST A B \n20/12/2024 05:05:18 Transaction reply next 009 function 5102 \n20/12/2024 05:05:18 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:05:18 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 204 \nCARD : 601301XXXXXX6016 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:05:18 ***** Tran Request State ***** \n20/12/2024 05:05:24 ***** Close Tran State ***** \n20/12/2024 05:05:24 ***** Close Tran State ***** \n20/12/2024 05:05:25 CARD(601301XXXXXX6016) TAKEN \n20/12/2024 05:05:30 \u003c- Transaction end \n \n20/12/2024 05:05:30 Card State: (1001;00000;00;--------) \n20/12/2024 05:05:30 CAMERA1 D:\\IMAGE\\20241220\\1_05053042_601301XXXXXX6016_END.JPG \n20/12/2024 05:05:30 ----- Clear Cash-In Device ---- \n20/12/2024 05:05:30 CAMERA2 D:\\IMAGE\\20241220\\2_05053076__CASH_OTHERS.JPG \n20/12/2024 05:05:30 Device PROBLEM \n20/12/2024 05:05:30 Cassette PROBLEM \n20/12/2024 05:05:31 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:05:31 CONFIG-ID : 2002\n \n20/12/2024 05:07:05 -\u003e Transaction start \n20/12/2024 05:07:05 TRACK 2 DATA: 522184XXXXXX4426 \n20/12/2024 05:07:06 CAMERA1 D:\\IMAGE\\20241220\\1_05070594__START.JPG \n20/12/2024 05:07:06 CAMERA1 D:\\IMAGE\\20241220\\1_05070610_522184XXXXXX4426_CARD.JPG \n20/12/2024 05:07:07 EMV CANDIDATES: 2 \n20/12/2024 05:07:09 EMV AID A0000006021010 / 522184XXXXXX4426 STARTED \n20/12/2024 05:07:15 PIN ENTERED \n20/12/2024 05:07:15 CAMERA1 D:\\IMAGE\\20241220\\1_05071577_522184XXXXXX4426_PIN.JPG \n20/12/2024 05:07:26 AMOUNT 2500000 ENTERED \n20/12/2024 05:07:31 ***** Tran Request State ***** \n20/12/2024 05:07:32 TRANSACTION REQUEST A BCC \n20/12/2024 05:07:32 Transaction reply next 009 function 5102 \n20/12/2024 05:07:32 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:07:32 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 204 \nCARD : 522184XXXXXX4426 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:07:32 ***** Tran Request State *****\n20/12/2024 05:07:52 EMV AID A0000006021010 / 522184XXXXXX4426 STARTED \n20/12/2024 05:07:59 PIN ENTERED \n20/12/2024 05:07:59 CAMERA1 D:\\IMAGE\\20241220\\1_05075906_522184XXXXXX4426_PIN.JPG \n20/12/2024 05:08:08 ***** Tran Request State ***** \n20/12/2024 05:08:08 TRANSACTION REQUEST A BB \n20/12/2024 05:08:09 Transaction reply next 264 function 5108 \n20/12/2024 05:08:09 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 04:45:39 \nATM ID : 190015 NO.REF: 205 \nCARD : 522184XXXXXX4426 \nREK : 059001010592503 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 367,554,304 \nRESPON : 00 Sukses \n20/12/2024 05:08:09 ***** Tran Request State ***** \n20/12/2024 05:08:17 EMV AID A0000006021010 / 522184XXXXXX4426 STARTED \n20/12/2024 05:08:24 PIN ENTERED \n20/12/2024 05:08:25 CAMERA1 D:\\IMAGE\\20241220\\1_05082483_522184XXXXXX4426_PIN.JPG \n20/12/2024 05:08:34 AMOUNT 2500000 ENTERED\n20/12/2024 05:08:44 ***** Tran Request State ***** \n20/12/2024 05:08:44 TRANSACTION REQUEST A BCD \n20/12/2024 05:08:44 Transaction reply next 009 function 5102 \n20/12/2024 05:08:44 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:08:45 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 205 \nCARD : 522184XXXXXX4426 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:08:45 ***** Tran Request State ***** \n20/12/2024 05:08:52 ***** Close Tran State ***** \n20/12/2024 05:08:52 ***** Close Tran State ***** \n20/12/2024 05:08:54 CARD(522184XXXXXX4426) TAKEN \n20/12/2024 05:08:58 \u003c- Transaction end \n \n20/12/2024 05:08:58 Card State: (1001;00000;00;--------) \n20/12/2024 05:08:58 CAMERA1 D:\\IMAGE\\20241220\\1_05085832_522184XXXXXX4426_END.JPG \n20/12/2024 05:08:58 ----- Clear Cash-In Device ---- \n20/12/2024 05:08:58 Device PROBLEM \n20/12/2024 05:08:58 CAMERA2 D:\\IMAGE\\20241220\\2_05085865__CASH_OTHERS.JPG \n20/12/2024 05:08:58 Cassette PROBLEM \n20/12/2024 05:08:58 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:08:59 CONFIG-ID : 2002\n20/12/2024 05:13:58 CAMERA1 D:\\IMAGE\\20241220\\1_05135865__INTERVAL_CAPTURE.JPG \n20/12/2024 05:17:47 OPERATOR DOOR OPENED \n20/12/2024 05:17:48 SERVICEMODE ENTERED \n20/12/2024 05:17:48 CAMERA1 D:\\IMAGE\\20241220\\1_05174833__SOP.JPG \n20/12/2024 05:17:48 ----- Clear Cash-In Device ---- \n20/12/2024 05:17:48 CAMERA2 D:\\IMAGE\\20241220\\2_05174878__CASH_OTHERS.JPG \n20/12/2024 05:17:48 Device PROBLEM \n20/12/2024 05:17:49 Cassette PROBLEM \n20/12/2024 05:18:00 SAFE DOOR OPENED\n \n \nATM ID : 190015 \nDate/Time : 12/20/24 05:18 \n \n CUR DENO INIT DISP DEP CST RJ \n1RCY IDR 100K 2000 2079 0961 0671 0211 \n2RCY IDR 100K 2000 0000 0000 2000 0000 \n3RCY IDR 50K 2000 1243 0000 0698 0059 \n4RCY IDR 50K 0000 0000 0240 0240 0000 \n5DPC --- ---- ---- ---- 0001 ---- 0000 \n \nINIT AMOUNT: 500000000 IDR \nDISP AMOUNT: 270050000 IDR \nDEP AMOUNT: 108150000 IDR \nCST AMOUNT: 314000000 IDR \n \nNO DENOM REM+ ALLIN = TOTAL \n01 IDR 100000 2882 0000 2882 \n02 IDR 50000 0997 0001 0998 \n03 IDR 20000 0000 0000 0000 \n \nRETRACT COUNT : 0002 \nRETAIN UNKNOWN NOTES (RET) : 0003 \n \nBILL COUNT LAST CLEARED : \n12/18/24 16:30 \n \nCARDS CAPTURED : 00000 \nCARDS CAPTURED LAST CLEARED : \n09/24/21 14:35\n \n20/12/2024 05:18:59 CAMERA1 D:\\IMAGE\\20241220\\1_05185898__INTERVAL_CAPTURE.JPG \n CARDS CAPTURED 00000 \n LAST CLEARED: 12/20/24 05:22 \n \n ACTIVITY COUNT - 00006755\n20/12/2024 05:23:59 CAMERA1 D:\\IMAGE\\20241220\\1_05235920__INTERVAL_CAPTURE.JPG \n \n12/20/24 05:24:00 \nCUSTOMER MONEY CLEARED \nCURRENCY DENOM COUNT \nIDR 100000 3 \n20/12/2024 05:25:12 29 OF 30 ITEM INFOS DELIVERED INCOMPLETE, FILLED WITH DEFAULT SERIAL NUMBER \n20/12/2024 05:25:12 SERIAL NUMBERS SUCCESSFULLY STORED FOR 0 GENUINE NOTES \n20/12/2024 05:25:12 0 S/N: 9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999 \n20/12/2024 05:25:12 IDR 100000 S/N: BGP644173 \n \nCUSTOMER MONEY MOVED TO RETRACT \nCURRENCY DENOM COUNT \nIDR 50000 1 \nIDR 100000 29 \n \n12/20/24 05:25:00 \nCUSTOMER MONEY CLEARED \nCURRENCY DENOM COUNT \nIDR 50000 1 \nIDR 100000 29 \n05:25:29 RETRACT CLEARED RETRACTS : 2, NOTES : 3\n20/12/2024 05:26:17 SAFE DOOR CLOSED \n20/12/2024 05:26:18 OPERATOR DOOR CLOSED \n20/12/2024 05:26:18 SERVICEMODE LEFT \n20/12/2024 05:26:18 GO OUT OF SERVICE COMMAND \n20/12/2024 05:26:18 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:19 Application LOCKED \n20/12/2024 05:26:19 DEVICE CCCdmFW STATUS 0 SUPPLY 1 \n20/12/2024 05:26:19 DEVICE CCCashInFW STATUS 0 SUPPLY 1 \n20/12/2024 05:26:19 GO IN SERVICE COMMAND \n20/12/2024 05:26:19 CAMERA1 D:\\IMAGE\\20241220\\1_05261932__PIN.JPG \n20/12/2024 05:26:20 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:21 Application LOCKED \n20/12/2024 05:26:21 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:26:21 CONFIG-ID : 2002 \n20/12/2024 05:26:26 SAFE DOOR OPENED \n20/12/2024 05:26:27 SERVICEMODE ENTERED \n20/12/2024 05:26:28 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:28 Device PROBLEM \n20/12/2024 05:26:28 Application LOCKED\n20/12/2024 05:26:47 SAFE DOOR CLOSED \n20/12/2024 05:26:47 SERVICEMODE LEFT \n20/12/2024 05:26:49 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:49 Application LOCKED \n20/12/2024 05:26:49 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:26:49 CONFIG-ID : 2002 \n \n20/12/2024 05:26:52 -\u003e Transaction start \n20/12/2024 05:26:52 TRACK 2 DATA: 522184XXXXXX8610 \n20/12/2024 05:26:52 CAMERA1 D:\\IMAGE\\20241220\\1_05265222__END.JPG \n20/12/2024 05:26:52 CAMERA2 D:\\IMAGE\\20241220\\2_05265250_522184XXXXXX8610_CASH_OTHERS.JPG \n20/12/2024 05:26:54 EMV CANDIDATES: 2 \n20/12/2024 05:26:56 EMV AID A0000006021010 / 522184XXXXXX8610 STARTED \n20/12/2024 05:27:01 PIN ENTERED \n20/12/2024 05:27:09 AMOUNT 100000 ENTERED \n20/12/2024 05:27:12 ***** Tran Request State ***** \n20/12/2024 05:27:13 TRANSACTION REQUEST A BCC \n20/12/2024 05:27:13 Transaction reply next 084 function 2110 \n20/12/2024 05:27:14 TVR: 8000040000, TSI: 7000 \n20/12/2024 05:27:14 CAMERA1 D:\\IMAGE\\20241220\\1_05271438_522184XXXXXX8610_SOP.JPG \n20/12/2024 05:27:14 CAMERA2 D:\\IMAGE\\20241220\\2_05271461_522184XXXXXX8610_CASH_OTHERS.JPG \n20/12/2024 05:27:20 SERIAL NUMBERS SUCCESSFULLY STORED FOR 1 GENUINE NOTES \n20/12/2024 05:27:20 IDR 100000 S/N: JOB667752 \n20/12/2024 05:27:20 CASH REQUEST: 01000000 \n05:27:20 CASH 1:1,1; \n20/12/2024 05:27:26 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:04:43 \nATM ID : 190015 NO.REF: 206 \nCARD : 522184XXXXXX8610 \nREK : 001701101186502 \nKODETX : 14 Entry amount int\nAMOUNT : RP 100.000 \nSALDO : RP 1.785.097 \nRESPON : SS Sukses \nSWITCHING : BRI DEBIT\n20/12/2024 05:27:49 GO OUT OF SERVICE COMMAND \n20/12/2024 05:27:51 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:27:55 CASH TAKEN \n20/12/2024 05:27:55 ***** Tran Request State ***** \n20/12/2024 05:28:00 ***** Close Tran State ***** \n20/12/2024 05:28:00 ***** Close Tran State ***** \n20/12/2024 05:28:01 CARD(522184XXXXXX8610) TAKEN \n20/12/2024 05:28:06 \u003c- Transaction end \n \n20/12/2024 05:28:06 Card State: (1001;00000;00;--------) \n20/12/2024 05:28:07 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:07 Application LOCKED \n20/12/2024 05:28:07 GO IN SERVICE COMMAND \n20/12/2024 05:28:09 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:09 Application LOCKED \n20/12/2024 05:28:09 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:28:09 CONFIG-ID : 2002 \n20/12/2024 05:28:12 OPERATOR DOOR OPENED \n20/12/2024 05:28:13 SERVICEMODE ENTERED \n20/12/2024 05:28:14 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:14 Application LOCKED \n20/12/2024 05:28:17 OPERATOR DOOR CLOSED \n20/12/2024 05:28:18 SERVICEMODE LEFT \n20/12/2024 05:28:19 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:19 Application LOCKED \n20/12/2024 05:28:19 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:28:20 CONFIG-ID : 2002 \n20/12/2024 05:28:32 OPERATOR DOOR OPENED \n20/12/2024 05:28:34 SERVICEMODE ENTERED \n20/12/2024 05:28:34 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:35 Application LOCKED\n20/12/2024 05:34:47 1 IDR, 1000 0 \n20/12/2024 05:34:47 2 IDR, 2000 0 \n20/12/2024 05:34:47 3 IDR, 5000 0 \n20/12/2024 05:34:47 4 IDR, 10000 0 \n20/12/2024 05:34:47 5 IDR, 20000 0 \n20/12/2024 05:34:47 6 IDR, 50000 1 \n20/12/2024 05:34:47 7 IDR, 100000 1 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 1 6 30063 0 0 0 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 2 9 35718 IDR 100000 0 670 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 7 IDR 100000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 3 9 00015 IDR 100000 0 2000 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 7 IDR 100000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 4 9 28635 IDR 50000 0 698 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 6 IDR 50000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 5 9 18334 IDR 50000 0 240 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 6 IDR 50000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 6 10 32999 0 0 1 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 1 IDR 1000 \n20/12/2024 05:34:47 2 IDR 2000 \n20/12/2024 05:34:47 3 IDR 5000\n20/12/2024 05:34:47 4 IDR 10000 \n20/12/2024 05:34:47 5 IDR 20000 \n20/12/2024 05:34:47 6 IDR 50000 \n20/12/2024 05:34:47 7 IDR 100000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 7 10 32999 0 0 0 \n20/12/2024 05:34:48 STARTUP LTS: 0006 1 00001 00000 00000 00000 \n20/12/2024 05:34:55 ----- Clear Cash-In Device ---- \n20/12/2024 05:35:02 CAMERA1 OPERATIONAL \n20/12/2024 05:35:02 COMMUNICATION ONLINE \n20/12/2024 05:35:03 GO OUT OF SERVICE COMMAND \n20/12/2024 05:35:03 CAMERA2 OPERATIONAL \n20/12/2024 05:35:03 ----- Clear Cash-In Device ---- \n20/12/2024 05:35:04 DEVICE CCCardFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCCdmFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCCashInFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCRecPrtFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCJourPrtFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCCamFW STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE LOG_CASS_1 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE LOG_CASS_2 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE LOG_CASS_3 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE LOG_CASS_4 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCDocPrtFW STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE ENVELOPE_DISPENSER STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE VOICE STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE CCChequeFW STATUS 0 SUPPLY 0 \n20/12/2024 05:35:05 GO IN SERVICE COMMAND \n20/12/2024 05:35:06 ----- Clear Cash-In Device ---- \n20/12/2024 05:35:06 CAMERA2 D:\\IMAGE\\20241220\\2_05350648__CASH_OTHERS.JPG \n20/12/2024 05:35:07 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 05:35:07 CONFIG-ID : 2002 \n20/12/2024 05:40:03 CAMERA1 D:\\IMAGE\\20241220\\1_05400299__INTERVAL_CAPTURE.JPG \n \n20/12/2024 05:42:05 -\u003e Transaction start \n20/12/2024 05:42:05 TRACK 2 DATA: 601301XXXXXX7150 \n20/12/2024 05:42:05 CAMERA1 D:\\IMAGE\\20241220\\1_05420557__START.JPG \n20/12/2024 05:42:05 CAMERA1 D:\\IMAGE\\20241220\\1_05420586_601301XXXXXX7150_CARD.JPG \n20/12/2024 05:42:07 EMV CANDIDATES: 1 \n20/12/2024 05:42:08 EMV AID A0000006021010 / 601301XXXXXX7150 STARTED \n20/12/2024 05:42:19 PIN ENTERED \n20/12/2024 05:42:19 CAMERA1 D:\\IMAGE\\20241220\\1_05421900_601301XXXXXX7150_PIN.JPG \n20/12/2024 05:42:28 ***** Tran Request State ***** \n20/12/2024 05:42:28 TRANSACTION REQUEST A A \n20/12/2024 05:42:28 Transaction reply next 016 function A024 \n20/12/2024 05:42:28 TVR: 8000040000, TSI: 7000\n20/12/2024 05:42:47 SERIAL NUMBERS SUCCESSFULLY STORED FOR 13 GENUINE NOTES \n20/12/2024 05:42:47 IDR 50000 S/N: LNT102178,CSR756558,DHN462153,FNF769300,DHD665026,SHU715878 \n20/12/2024 05:42:47 IDR 100000 S/N: SNL545042,RCE274359,QCA878313,BEG718840,AEW160478,BBN305032,VBP996047 \n20/12/2024 05:42:47 CASH REQUEST: 07000600 \n05:42:47 CASH 1:1,7;3:3,6; \n20/12/2024 05:42:47 CAMERA2 D:\\IMAGE\\20241220\\2_05424706_601301XXXXXX7150_CASH_REQUEST.JPG \n20/12/2024 05:42:49 CARD(601301XXXXXX7150) TAKEN \n20/12/2024 05:42:53 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:19:57 \nATM ID : 190015 NO.REF: 207 \nCARD : 601301XXXXXX7150 \nREK : 465501017181535 \nKODETX : 3 FAST CASH NO RECEIPT \nAMOUNT : RP 1,000,000 \nSALDO : RP 544,794 \nRESPON : 00 Fash Cash \nSWITCHING : BRI DEBIT \n20/12/2024 05:42:53 CAMERA1 D:\\IMAGE\\20241220\\1_05425375_601301XXXXXX7150_CASH_PRESENT.JPG \n20/12/2024 05:42:53 CAMERA2 D:\\IMAGE\\20241220\\2_05425390_601301XXXXXX7150_CASH_PRESENT.JPG \n20/12/2024 05:42:54 CAMERA2 D:\\IMAGE\\20241220\\2_05425417_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:54 CAMERA1 D:\\IMAGE\\20241220\\1_05425440_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:54 CAMERA2 D:\\IMAGE\\20241220\\2_05425458_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA2 D:\\IMAGE\\20241220\\2_05425486_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA1 D:\\IMAGE\\20241220\\1_05425508_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA2 D:\\IMAGE\\20241220\\2_05425531_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA1 D:\\IMAGE\\20241220\\1_05425576_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA2 D:\\IMAGE\\20241220\\2_05425576_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:56 CAMERA2 D:\\IMAGE\\20241220\\2_05425617_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:56 CAMERA1 D:\\IMAGE\\20241220\\1_05425644_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:56 CAMERA2 D:\\IMAGE\\20241220\\2_05425645_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA2 D:\\IMAGE\\20241220\\2_05425690_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA1 D:\\IMAGE\\20241220\\1_05425713_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA2 D:\\IMAGE\\20241220\\2_05425735_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA2 D:\\IMAGE\\20241220\\2_05425776_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA1 D:\\IMAGE\\20241220\\1_05425781_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA2 D:\\IMAGE\\20241220\\2_05425799_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA2 D:\\IMAGE\\20241220\\2_05425826_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA1 D:\\IMAGE\\20241220\\1_05425849_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA2 D:\\IMAGE\\20241220\\2_05425867_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:59 CAMERA2 D:\\IMAGE\\20241220\\2_05425895_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:59 CAMERA1 D:\\IMAGE\\20241220\\1_05425916_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:59 CAMERA2 D:\\IMAGE\\20241220\\2_05425939_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA2 D:\\IMAGE\\20241220\\2_05425986_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA1 D:\\IMAGE\\20241220\\1_05425985_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA2 D:\\IMAGE\\20241220\\2_05430029_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA1 D:\\IMAGE\\20241220\\1_05430065_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA2 D:\\IMAGE\\20241220\\2_05430076_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:01 CAMERA2 D:\\IMAGE\\20241220\\2_05430121_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:01 CAMERA1 D:\\IMAGE\\20241220\\1_05430145_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:01 CAMERA2 D:\\IMAGE\\20241220\\2_05430166_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA2 D:\\IMAGE\\20241220\\2_05430207_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA1 D:\\IMAGE\\20241220\\1_05430213_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA2 D:\\IMAGE\\20241220\\2_05430230_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA2 D:\\IMAGE\\20241220\\2_05430257_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA1 D:\\IMAGE\\20241220\\1_05430281_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA2 D:\\IMAGE\\20241220\\2_05430303_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA2 D:\\IMAGE\\20241220\\2_05430344_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA1 D:\\IMAGE\\20241220\\1_05430350_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA2 D:\\IMAGE\\20241220\\2_05430371_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA2 D:\\IMAGE\\20241220\\2_05430411_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA1 D:\\IMAGE\\20241220\\1_05430417_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA2 D:\\IMAGE\\20241220\\2_05430434_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA2 D:\\IMAGE\\20241220\\2_05430458_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA1 D:\\IMAGE\\20241220\\1_05430486_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430485_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430526_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430549_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA1 D:\\IMAGE\\20241220\\1_05430552_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430578_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA2 D:\\IMAGE\\20241220\\2_05430617_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA1 D:\\IMAGE\\20241220\\1_05430622_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA2 D:\\IMAGE\\20241220\\2_05430641_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA2 D:\\IMAGE\\20241220\\2_05430668_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA1 D:\\IMAGE\\20241220\\1_05430689_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:07 CAMERA2 D:\\IMAGE\\20241220\\2_05430709_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:07 CAMERA2 D:\\IMAGE\\20241220\\2_05430737_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:07 CAMERA1 D:\\IMAGE\\20241220\\1_05430757_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA2 D:\\IMAGE\\20241220\\2_05430783_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA1 D:\\IMAGE\\20241220\\1_05430825_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA2 D:\\IMAGE\\20241220\\2_05430828_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA2 D:\\IMAGE\\20241220\\2_05430867_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA1 D:\\IMAGE\\20241220\\1_05430899_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA2 D:\\IMAGE\\20241220\\2_05430895_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA2 D:\\IMAGE\\20241220\\2_05430936_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA2 D:\\IMAGE\\20241220\\2_05430958_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA1 D:\\IMAGE\\20241220\\1_05430962_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA2 D:\\IMAGE\\20241220\\2_05430987_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA2 D:\\IMAGE\\20241220\\2_05431025_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA1 D:\\IMAGE\\20241220\\1_05431044_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA2 D:\\IMAGE\\20241220\\2_05431054_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA2 D:\\IMAGE\\20241220\\2_05431101_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA1 D:\\IMAGE\\20241220\\1_05431121_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA2 D:\\IMAGE\\20241220\\2_05431141_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA2 D:\\IMAGE\\20241220\\2_05431168_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA1 D:\\IMAGE\\20241220\\1_05431189_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA2 D:\\IMAGE\\20241220\\2_05431210_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA2 D:\\IMAGE\\20241220\\2_05431237_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA1 D:\\IMAGE\\20241220\\1_05431257_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA2 D:\\IMAGE\\20241220\\2_05431275_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA2 D:\\IMAGE\\20241220\\2_05431306_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA1 D:\\IMAGE\\20241220\\1_05431325_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA2 D:\\IMAGE\\20241220\\2_05431351_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA2 D:\\IMAGE\\20241220\\2_05431392_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA1 D:\\IMAGE\\20241220\\1_05431393_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA2 D:\\IMAGE\\20241220\\2_05431420_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA2 D:\\IMAGE\\20241220\\2_05431461_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA1 D:\\IMAGE\\20241220\\1_05431461_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431488_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA1 D:\\IMAGE\\20241220\\1_05431529_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431534_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431574_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431597_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA1 D:\\IMAGE\\20241220\\1_05431598_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA2 D:\\IMAGE\\20241220\\2_05431625_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA1 D:\\IMAGE\\20241220\\1_05431665_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA2 D:\\IMAGE\\20241220\\2_05431670_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA2 D:\\IMAGE\\20241220\\2_05431711_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA2 D:\\IMAGE\\20241220\\2_05431733_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA1 D:\\IMAGE\\20241220\\1_05431734_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA2 D:\\IMAGE\\20241220\\2_05431761_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA1 D:\\IMAGE\\20241220\\1_05431802_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA2 D:\\IMAGE\\20241220\\2_05431806_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA2 D:\\IMAGE\\20241220\\2_05431847_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA1 D:\\IMAGE\\20241220\\1_05431870_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:43:18 CAMERA2 D:\\IMAGE\\20241220\\2_05431875_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA2 D:\\IMAGE\\20241220\\2_05431914_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA1 D:\\IMAGE\\20241220\\1_05431939_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA2 D:\\IMAGE\\20241220\\2_05431941_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA2 D:\\IMAGE\\20241220\\2_05431983_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA1 D:\\IMAGE\\20241220\\1_05432006_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA2 D:\\IMAGE\\20241220\\2_05432011_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA2 D:\\IMAGE\\20241220\\2_05432050_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA2 D:\\IMAGE\\20241220\\2_05432074_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA1 D:\\IMAGE\\20241220\\1_05432075_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:21 CAMERA2 D:\\IMAGE\\20241220\\2_05432101_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:21 CAMERA2 D:\\IMAGE\\20241220\\2_05432148_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:21 CAMERA1 D:\\IMAGE\\20241220\\1_05432143_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA2 D:\\IMAGE\\20241220\\2_05432194_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA1 D:\\IMAGE\\20241220\\1_05432229_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA2 D:\\IMAGE\\20241220\\2_05432239_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CASH TAKEN \n20/12/2024 05:43:22 CAMERA2 D:\\IMAGE\\20241220\\2_05432280_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA1 D:\\IMAGE\\20241220\\1_05432283_601301XXXXXX7150_CASH_TAKEN.JPG \n20/12/2024 05:43:23 CAMERA2 D:\\IMAGE\\20241220\\2_05432299_601301XXXXXX7150_CASH_TAKEN.JPG \n20/12/2024 05:43:23 ***** Tran Request State ***** \n20/12/2024 05:43:24 ***** Close Tran State ***** \n20/12/2024 05:43:24 ***** Close Tran State ***** \n20/12/2024 05:43:30 \u003c- Transaction end \n \n20/12/2024 05:43:30 CAMERA1 D:\\IMAGE\\20241220\\1_05433033_601301XXXXXX7150_END.JPG \n20/12/2024 05:43:30 Card State: (4101;00000;00;--------) \n20/12/2024 05:43:30 ----- Clear Cash-In Device ---- \n20/12/2024 05:43:30 CAMERA2 D:\\IMAGE\\20241220\\2_05433065__CASH_OTHERS.JPG \n20/12/2024 05:43:31 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 05:43:32 CONFIG-ID : 2002 \n \n20/12/2024 05:43:33 -\u003e Transaction start \n20/12/2024 05:43:33 TRACK 2 DATA: 461699XXXXXX0978 \n20/12/2024 05:43:33 ***** Tran Request State ***** \n20/12/2024 05:43:33 CAMERA1 D:\\IMAGE\\20241220\\1_05433361__START.JPG \n20/12/2024 05:43:33 TRANSACTION REQUEST \n20/12/2024 05:43:33 Transaction reply next 807 function 5098 \nTANGGAL: 20/12/24 WAKTU : 05:21:02 \nATM ID : 190015 NO.REF: 208 \nCARD : 461699XXXXXX0978 \nREK : \nKODETX : 998 flipm \nAMOUNT : RP 0 \nSALDO : \nRESPON : F2 AJ \n20/12/2024 05:43:33 ***** Tran Request State ***** \n20/12/2024 05:43:33 CAMERA1 D:\\IMAGE\\20241220\\1_05433374_461699XXXXXX0978_CARD.JPG \n20/12/2024 05:43:35 EMV CANDIDATES: 2 \n20/12/2024 05:43:38 EMV AID A0000006021010 / 461699XXXXXX0978 STARTED \n20/12/2024 05:43:43 PIN ENTERED \n20/12/2024 05:43:43 CAMERA1 D:\\IMAGE\\20241220\\1_05434313_461699XXXXXX0978_PIN.JPG \n20/12/2024 05:43:54 ***** Tran Request State ***** \n20/12/2024 05:43:55 TRANSACTION REQUEST A BB \n20/12/2024 05:43:55 Transaction reply next 009 function 5102 \n20/12/2024 05:43:55 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:43:56 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : 05:21:24 \nATM ID : 190015 NO.REF: 209 \nCARD : 461699XXXXXX0978 \nREK : \nKODETX : 2 AJ \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : 51 Saldo Tidak Cukup \n20/12/2024 05:43:56 ***** Tran Request State ***** \n20/12/2024 05:44:02 ***** Close Tran State ***** \n20/12/2024 05:44:02 ***** Close Tran State ***** \n20/12/2024 05:44:04 CARD(461699XXXXXX0978) TAKEN \n20/12/2024 05:44:08 \u003c- Transaction end \n \n20/12/2024 05:44:08 CAMERA1 D:\\IMAGE\\20241220\\1_05440878_461699XXXXXX0978_END.JPG \n20/12/2024 05:44:08 Card State: (1001;00000;00;--------) \n20/12/2024 05:44:09 ----- Clear Cash-In Device ---- \n20/12/2024 05:44:09 CAMERA2 D:\\IMAGE\\20241220\\2_05440911__CASH_OTHERS.JPG \n20/12/2024 05:44:10 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:44:10 CONFIG-ID : 2002 \n \n20/12/2024 05:44:32 -\u003e Transaction start \n20/12/2024 05:44:32 TRACK 2 DATA: 601301XXXXXX6753 \n20/12/2024 05:44:32 CAMERA1 D:\\IMAGE\\20241220\\1_05443272__START.JPG \n20/12/2024 05:44:33 CAMERA1 D:\\IMAGE\\20241220\\1_05443298_601301XXXXXX6753_CARD.JPG \n20/12/2024 05:44:34 EMV CANDIDATES: 1 \n20/12/2024 05:44:36 EMV AID A0000006021010 / 601301XXXXXX6753 STARTED \n20/12/2024 05:44:43 PIN ENTERED \n20/12/2024 05:44:43 CAMERA1 D:\\IMAGE\\20241220\\1_05444305_601301XXXXXX6753_PIN.JPG \n20/12/2024 05:44:49 ***** Tran Request State ***** \n20/12/2024 05:44:49 TRANSACTION REQUEST A BB \n20/12/2024 05:44:50 Transaction reply next 264 function 5108 \n20/12/2024 05:44:50 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 05:22:18 \nATM ID : 190015 NO.REF: 2010 \nCARD : 601301XXXXXX6753 \nREK : 612001003550535 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 2,991,372 \nRESPON : 00 Sukses \n20/12/2024 05:44:50 ***** Tran Request State ***** \n20/12/2024 05:44:57 EMV AID A0000006021010 / 601301XXXXXX6753 STARTED \n20/12/2024 05:45:02 PIN ENTERED \n20/12/2024 05:45:02 CAMERA1 D:\\IMAGE\\20241220\\1_05450295_601301XXXXXX6753_PIN.JPG \n20/12/2024 05:45:30 INFORMATION 301341081239789180 ENTERED\n20/12/2024 05:45:45 AMOUNT 1000000 ENTERED \n20/12/2024 05:45:45 ***** Tran Request State ***** \n20/12/2024 05:45:46 TRANSACTION REQUEST A HCB \n20/12/2024 05:45:46 Transaction reply next 455 function 5157 \n20/12/2024 05:45:46 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:45:47 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : 05:23:15 \nATM ID : 190015 NO.REF: 2011 \nCARD : 601301XXXXXX6753 \nREK : \nKODETX : 20 Inq GOPAY \nAMOUNT : RP 1.000.000 \nSALDO : RP 0 \nRESPON : 00 Sukses \n20/12/2024 05:45:47 ***** Tran Request State ***** \n20/12/2024 05:45:54 EMV AID A0000006021010 / 601301XXXXXX6753 STARTED \n20/12/2024 05:45:54 ***** Tran Request State ***** \n20/12/2024 05:45:55 TRANSACTION REQUEST A HCB B \n20/12/2024 05:45:55 Transaction reply next 084 function 5110 \n20/12/2024 05:45:56 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 05:23:23 \nATM ID : 190015 NO.REF: 2012 \nCARD : 601301XXXXXX6753 \nREK : 612001003550535 \nKODETX : 21 Pay GOPAY \nAMOUNT : RP 1.000.000 \nSALDO : RP 0 \nRESPON : 00 Sukses \n20/12/2024 05:45:56 ***** Tran Request State ***** \n20/12/2024 05:46:03 ***** Close Tran State ***** \n20/12/2024 05:46:04 ***** Close Tran State *****\n20/12/2024 05:46:06 CARD(601301XXXXXX6753) TAKEN \n20/12/2024 05:46:10 \u003c- Transaction end \n \n20/12/2024 05:46:10 CAMERA1 D:\\IMAGE\\20241220\\1_05461029_601301XXXXXX6753_END.JPG \n20/12/2024 05:46:10 Card State: (1001;00000;00;--------) \n20/12/2024 05:46:10 ----- Clear Cash-In Device ---- \n20/12/2024 05:46:10 CAMERA2 D:\\IMAGE\\20241220\\2_05461060__CASH_OTHERS.JPG \n20/12/2024 05:46:11 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:46:12 CONFIG-ID : 2002\n \n20/12/2024 05:47:13 -\u003e Transaction start \n20/12/2024 05:47:13 TRACK 2 DATA: 483795XXXXXX7577 \n20/12/2024 05:47:13 ***** Tran Request State ***** \n20/12/2024 05:47:13 CAMERA1 D:\\IMAGE\\20241220\\1_05471394__START.JPG \n20/12/2024 05:47:14 TRANSACTION REQUEST \n20/12/2024 05:47:14 Transaction reply next 800 function 5098 \nTANGGAL: 20/12/24 WAKTU : 05:24:42 \nATM ID : 190015 NO.REF: 2013 \nCARD : 483795XXXXXX7577 \nREK : \nKODETX : 998 flipm \nAMOUNT : RP 0 \nSALDO : \nRESPON : F1 PRIMA \n20/12/2024 05:47:14 ***** Tran Request State ***** \n20/12/2024 05:47:14 CAMERA1 D:\\IMAGE\\20241220\\1_05471409_483795XXXXXX7577_CARD.JPG \n20/12/2024 05:47:16 EMV CANDIDATES: 2 \n20/12/2024 05:47:17 EMV AID A0000006021010 / 483795XXXXXX7577 STARTED \n20/12/2024 05:47:22 PIN ENTERED \n20/12/2024 05:47:22 CAMERA1 D:\\IMAGE\\20241220\\1_05472248_483795XXXXXX7577_PIN.JPG \n20/12/2024 05:47:29 AMOUNT 500000 ENTERED\n20/12/2024 05:47:34 ***** Tran Request State ***** \n20/12/2024 05:47:34 TRANSACTION REQUEST A B C \n20/12/2024 05:47:34 Transaction reply next 820 function 2110 \n20/12/2024 05:47:35 TVR: 8000040000, TSI: 7000 \n20/12/2024 05:47:50 SERIAL NUMBERS SUCCESSFULLY STORED FOR 7 GENUINE NOTES \n20/12/2024 05:47:50 IDR 50000 S/N: RJU936244,CAM950665,SBR806794,FSS053358 \n20/12/2024 05:47:50 IDR 100000 S/N: LCK266920,POV587926,EPU668842 \n20/12/2024 05:47:50 CASH REQUEST: 03000400 \n05:47:50 CASH 1:1,3;3:3,4; \n20/12/2024 05:47:50 CAMERA2 D:\\IMAGE\\20241220\\2_05475034_483795XXXXXX7577_CASH_REQUEST.JPG \n20/12/2024 05:47:56 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:25:03 \nATM ID : 190015 NO.REF: 2014 \nCARD : 483795XXXXXX7577 \nREK : 9000016403520 \nKODETX : 9 PAKET TUNAI OTHER \nAMOUNT : RP 500,000 \nSALDO : RP 1,555,913 \nRESPON : 00 Sukses Prima \nSWITCHING : PRIMA \n20/12/2024 05:47:57 CAMERA1 D:\\IMAGE\\20241220\\1_05475687_483795XXXXXX7577_CASH_PRESENT.JPG \n20/12/2024 05:47:57 CAMERA2 D:\\IMAGE\\20241220\\2_05475715_483795XXXXXX7577_CASH_PRESENT.JPG \n20/12/2024 05:47:57 CAMERA2 D:\\IMAGE\\20241220\\2_05475751_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:57 CAMERA1 D:\\IMAGE\\20241220\\1_05475765_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:57 CAMERA2 D:\\IMAGE\\20241220\\2_05475791_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA2 D:\\IMAGE\\20241220\\2_05475818_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA1 D:\\IMAGE\\20241220\\1_05475834_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA2 D:\\IMAGE\\20241220\\2_05475860_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA2 D:\\IMAGE\\20241220\\2_05475886_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA1 D:\\IMAGE\\20241220\\1_05475902_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA2 D:\\IMAGE\\20241220\\2_05475912_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA2 D:\\IMAGE\\20241220\\2_05475950_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA2 D:\\IMAGE\\20241220\\2_05475974_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA1 D:\\IMAGE\\20241220\\1_05475969_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480001_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480042_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA1 D:\\IMAGE\\20241220\\1_05480039_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480066_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480089_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA1 D:\\IMAGE\\20241220\\1_05480108_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA2 D:\\IMAGE\\20241220\\2_05480117_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA2 D:\\IMAGE\\20241220\\2_05480158_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA1 D:\\IMAGE\\20241220\\1_05480178_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480185_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480225_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480249_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA1 D:\\IMAGE\\20241220\\1_05480246_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480272_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA2 D:\\IMAGE\\20241220\\2_05480300_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA1 D:\\IMAGE\\20241220\\1_05480314_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA2 D:\\IMAGE\\20241220\\2_05480344_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA2 D:\\IMAGE\\20241220\\2_05480370_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA1 D:\\IMAGE\\20241220\\1_05480382_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:04 CAMERA2 D:\\IMAGE\\20241220\\2_05480412_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:04 CAMERA2 D:\\IMAGE\\20241220\\2_05480457_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:04 CAMERA1 D:\\IMAGE\\20241220\\1_05480448_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480478_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480521_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA1 D:\\IMAGE\\20241220\\1_05480519_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480544_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480568_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA1 D:\\IMAGE\\20241220\\1_05480587_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:06 CAMERA2 D:\\IMAGE\\20241220\\2_05480595_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:06 CAMERA2 D:\\IMAGE\\20241220\\2_05480640_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:06 CAMERA1 D:\\IMAGE\\20241220\\1_05480656_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480685_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480725_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA1 D:\\IMAGE\\20241220\\1_05480722_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480749_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480772_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA1 D:\\IMAGE\\20241220\\1_05480791_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA2 D:\\IMAGE\\20241220\\2_05480799_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA2 D:\\IMAGE\\20241220\\2_05480839_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA1 D:\\IMAGE\\20241220\\1_05480859_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA2 D:\\IMAGE\\20241220\\2_05480868_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA2 D:\\IMAGE\\20241220\\2_05480908_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA2 D:\\IMAGE\\20241220\\2_05480931_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA1 D:\\IMAGE\\20241220\\1_05480927_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA2 D:\\IMAGE\\20241220\\2_05480959_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA1 D:\\IMAGE\\20241220\\1_05480996_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481004_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481045_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481069_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA1 D:\\IMAGE\\20241220\\1_05481065_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481091_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA2 D:\\IMAGE\\20241220\\2_05481114_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA1 D:\\IMAGE\\20241220\\1_05481134_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA2 D:\\IMAGE\\20241220\\2_05481142_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA2 D:\\IMAGE\\20241220\\2_05481183_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA1 D:\\IMAGE\\20241220\\1_05481202_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA2 D:\\IMAGE\\20241220\\2_05481210_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA2 D:\\IMAGE\\20241220\\2_05481251_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA1 D:\\IMAGE\\20241220\\1_05481271_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA2 D:\\IMAGE\\20241220\\2_05481274_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481304_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481342_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA1 D:\\IMAGE\\20241220\\1_05481338_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481365_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481388_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA2 D:\\IMAGE\\20241220\\2_05481411_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA1 D:\\IMAGE\\20241220\\1_05481408_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA2 D:\\IMAGE\\20241220\\2_05481439_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA1 D:\\IMAGE\\20241220\\1_05481477_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA2 D:\\IMAGE\\20241220\\2_05481484_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA2 D:\\IMAGE\\20241220\\2_05481525_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA1 D:\\IMAGE\\20241220\\1_05481545_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA2 D:\\IMAGE\\20241220\\2_05481553_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA2 D:\\IMAGE\\20241220\\2_05481594_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA1 D:\\IMAGE\\20241220\\1_05481614_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA2 D:\\IMAGE\\20241220\\2_05481625_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA1 D:\\IMAGE\\20241220\\1_05481681_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA2 D:\\IMAGE\\20241220\\2_05481671_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA2 D:\\IMAGE\\20241220\\2_05481715_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA2 D:\\IMAGE\\20241220\\2_05481753_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA1 D:\\IMAGE\\20241220\\1_05481749_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA2 D:\\IMAGE\\20241220\\2_05481780_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA2 D:\\IMAGE\\20241220\\2_05481807_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA1 D:\\IMAGE\\20241220\\1_05481816_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA2 D:\\IMAGE\\20241220\\2_05481847_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA2 D:\\IMAGE\\20241220\\2_05481869_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA1 D:\\IMAGE\\20241220\\1_05481888_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA2 D:\\IMAGE\\20241220\\2_05481898_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA2 D:\\IMAGE\\20241220\\2_05481936_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA1 D:\\IMAGE\\20241220\\1_05481955_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA2 D:\\IMAGE\\20241220\\2_05481966_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA2 D:\\IMAGE\\20241220\\2_05482005_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA1 D:\\IMAGE\\20241220\\1_05482023_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA2 D:\\IMAGE\\20241220\\2_05482035_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA2 D:\\IMAGE\\20241220\\2_05482075_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA1 D:\\IMAGE\\20241220\\1_05482092_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA2 D:\\IMAGE\\20241220\\2_05482103_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA2 D:\\IMAGE\\20241220\\2_05482142_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA1 D:\\IMAGE\\20241220\\1_05482159_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA2 D:\\IMAGE\\20241220\\2_05482172_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:48:22 CAMERA2 D:\\IMAGE\\20241220\\2_05482213_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:22 CAMERA1 D:\\IMAGE\\20241220\\1_05482228_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:22 CAMERA2 D:\\IMAGE\\20241220\\2_05482240_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA1 D:\\IMAGE\\20241220\\1_05482296_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA2 D:\\IMAGE\\20241220\\2_05482285_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA2 D:\\IMAGE\\20241220\\2_05482327_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA1 D:\\IMAGE\\20241220\\1_05482364_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA2 D:\\IMAGE\\20241220\\2_05482354_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA2 D:\\IMAGE\\20241220\\2_05482401_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA1 D:\\IMAGE\\20241220\\1_05482432_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA2 D:\\IMAGE\\20241220\\2_05482439_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA2 D:\\IMAGE\\20241220\\2_05482464_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA1 D:\\IMAGE\\20241220\\1_05482500_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA2 D:\\IMAGE\\20241220\\2_05482492_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA2 D:\\IMAGE\\20241220\\2_05482533_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA1 D:\\IMAGE\\20241220\\1_05482569_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA2 D:\\IMAGE\\20241220\\2_05482561_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:26 CASH TAKEN \n20/12/2024 05:48:26 CAMERA1 D:\\IMAGE\\20241220\\1_05482601_483795XXXXXX7577_CASH_TAKEN.JPG \n20/12/2024 05:48:27 ***** Tran Request State *****\n20/12/2024 05:48:27 CAMERA2 D:\\IMAGE\\20241220\\2_05482617_483795XXXXXX7577_CASH_TAKEN.JPG \n20/12/2024 05:48:28 ***** Close Tran State ***** \n20/12/2024 05:48:28 ***** Close Tran State ***** \n20/12/2024 05:48:30 CARD(483795XXXXXX7577) TAKEN\n20/12/2024 05:48:34 \u003c- Transaction end \n \n20/12/2024 05:48:35 CAMERA1 D:\\IMAGE\\20241220\\1_05483495_483795XXXXXX7577_END.JPG \n20/12/2024 05:48:35 Card State: (1001;00000;00;--------) \n20/12/2024 05:48:35 ----- Clear Cash-In Device ---- \n20/12/2024 05:48:35 CAMERA2 D:\\IMAGE\\20241220\\2_05483527__CASH_OTHERS.JPG \n20/12/2024 05:48:36 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:48:36 CONFIG-ID : 2002\n \n20/12/2024 05:49:45 -\u003e Transaction start \n20/12/2024 05:49:45 TRACK 2 DATA: 461699XXXXXX4588 \n20/12/2024 05:49:45 ***** Tran Request State ***** \n20/12/2024 05:49:45 TRANSACTION REQUEST \n20/12/2024 05:49:45 Transaction reply next 807 function 5098 \nTANGGAL: 20/12/24 WAKTU : 05:27:14 \nATM ID : 190015 NO.REF: 2015 \nCARD : 461699XXXXXX4588 \nREK : \nKODETX : 998 flipm \nAMOUNT : RP 0 \nSALDO : \nRESPON : F2 AJ \n20/12/2024 05:49:46 ***** Tran Request State ***** \n20/12/2024 05:49:46 CAMERA1 D:\\IMAGE\\20241220\\1_05494579__START.JPG \n20/12/2024 05:49:46 CAMERA1 D:\\IMAGE\\20241220\\1_05494612_461699XXXXXX4588_CARD.JPG \n20/12/2024 05:49:48 EMV CANDIDATES: 2 \n20/12/2024 05:49:50 EMV AID A0000006021010 / 461699XXXXXX4588 STARTED \n20/12/2024 05:49:58 PIN ENTERED \n20/12/2024 05:49:58 CAMERA1 D:\\IMAGE\\20241220\\1_05495811_461699XXXXXX4588_PIN.JPG \n20/12/2024 05:50:03 ***** Tran Request State ***** \n20/12/2024 05:50:04 TRANSACTION REQUEST A B \n20/12/2024 05:50:04 Transaction reply next 016 function A024 \n20/12/2024 05:50:04 TVR: 8000040000, TSI: 7000 \n20/12/2024 05:50:12 SERIAL NUMBERS SUCCESSFULLY STORED FOR 7 GENUINE NOTES \n20/12/2024 05:50:12 IDR 50000 S/N: ZHH704593,GND974895,ELH831906,ARE469026 \n20/12/2024 05:50:12 IDR 100000 S/N: LGP083910,TOD360926,XAH287761 \n20/12/2024 05:50:12 CASH REQUEST: 03000400 \n05:50:12 CASH 1:1,3;3:3,4; \n20/12/2024 05:50:12 CAMERA2 D:\\IMAGE\\20241220\\2_05501261_461699XXXXXX4588_CASH_REQUEST.JPG \n20/12/2024 05:50:14 CARD(461699XXXXXX4588) TAKEN \n20/12/2024 05:50:18 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:27:32 \nATM ID : 190015 NO.REF: 2016 \nCARD : 461699XXXXXX4588 \nREK : 9901 \nKODETX : 15 FAST CASH OTHER \nAMOUNT : RP 500,000 \nSALDO : RP 680,281 \nRESPON : OO Fash Cash \nSWITCHING : AJ ATMBERSAMA \n20/12/2024 05:50:18 CAMERA1 D:\\IMAGE\\20241220\\1_05501873_461699XXXXXX4588_CASH_PRESENT.JPG \n20/12/2024 05:50:19 CAMERA2 D:\\IMAGE\\20241220\\2_05501898_461699XXXXXX4588_CASH_PRESENT.JPG \n20/12/2024 05:50:19 CAMERA2 D:\\IMAGE\\20241220\\2_05501927_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:19 CAMERA1 D:\\IMAGE\\20241220\\1_05501948_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:19 CAMERA2 D:\\IMAGE\\20241220\\2_05501954_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:20 CAMERA2 D:\\IMAGE\\20241220\\2_05502001_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:20 CAMERA2 D:\\IMAGE\\20241220\\2_05502050_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:20 CAMERA1 D:\\IMAGE\\20241220\\1_05502036_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA2 D:\\IMAGE\\20241220\\2_05502082_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA1 D:\\IMAGE\\20241220\\1_05502122_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA2 D:\\IMAGE\\20241220\\2_05502126_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA2 D:\\IMAGE\\20241220\\2_05502175_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA1 D:\\IMAGE\\20241220\\1_05502193_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA2 D:\\IMAGE\\20241220\\2_05502221_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA1 D:\\IMAGE\\20241220\\1_05502263_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA2 D:\\IMAGE\\20241220\\2_05502265_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA2 D:\\IMAGE\\20241220\\2_05502305_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA1 D:\\IMAGE\\20241220\\1_05502324_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA2 D:\\IMAGE\\20241220\\2_05502337_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA2 D:\\IMAGE\\20241220\\2_05502380_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA1 D:\\IMAGE\\20241220\\1_05502400_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA2 D:\\IMAGE\\20241220\\2_05502407_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA2 D:\\IMAGE\\20241220\\2_05502452_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA1 D:\\IMAGE\\20241220\\1_05502469_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502498_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502539_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA1 D:\\IMAGE\\20241220\\1_05502534_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502563_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502586_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA1 D:\\IMAGE\\20241220\\1_05502606_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA2 D:\\IMAGE\\20241220\\2_05502615_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA2 D:\\IMAGE\\20241220\\2_05502657_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA1 D:\\IMAGE\\20241220\\1_05502677_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA2 D:\\IMAGE\\20241220\\2_05502684_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA2 D:\\IMAGE\\20241220\\2_05502729_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA1 D:\\IMAGE\\20241220\\1_05502745_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA2 D:\\IMAGE\\20241220\\2_05502775_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA1 D:\\IMAGE\\20241220\\1_05502814_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA2 D:\\IMAGE\\20241220\\2_05502820_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA2 D:\\IMAGE\\20241220\\2_05502862_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA1 D:\\IMAGE\\20241220\\1_05502882_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:29 CAMERA2 D:\\IMAGE\\20241220\\2_05502911_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:29 CAMERA1 D:\\IMAGE\\20241220\\1_05502950_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:29 CAMERA2 D:\\IMAGE\\20241220\\2_05502956_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA2 D:\\IMAGE\\20241220\\2_05503001_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA1 D:\\IMAGE\\20241220\\1_05503019_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA2 D:\\IMAGE\\20241220\\2_05503047_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA1 D:\\IMAGE\\20241220\\1_05503087_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503092_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503132_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503156_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA1 D:\\IMAGE\\20241220\\1_05503150_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503180_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA2 D:\\IMAGE\\20241220\\2_05503207_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA1 D:\\IMAGE\\20241220\\1_05503224_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA2 D:\\IMAGE\\20241220\\2_05503247_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA2 D:\\IMAGE\\20241220\\2_05503271_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA1 D:\\IMAGE\\20241220\\1_05503292_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:33 CAMERA2 D:\\IMAGE\\20241220\\2_05503298_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:33 CAMERA2 D:\\IMAGE\\20241220\\2_05503343_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:33 CAMERA1 D:\\IMAGE\\20241220\\1_05503359_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA2 D:\\IMAGE\\20241220\\2_05503388_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA2 D:\\IMAGE\\20241220\\2_05503430_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA1 D:\\IMAGE\\20241220\\1_05503428_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA2 D:\\IMAGE\\20241220\\2_05503457_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503497_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA1 D:\\IMAGE\\20241220\\1_05503496_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503521_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503548_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA1 D:\\IMAGE\\20241220\\1_05503564_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503589_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:36 CAMERA2 D:\\IMAGE\\20241220\\2_05503616_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:36 CAMERA1 D:\\IMAGE\\20241220\\1_05503632_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:36 CAMERA2 D:\\IMAGE\\20241220\\2_05503662_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA1 D:\\IMAGE\\20241220\\1_05503701_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA2 D:\\IMAGE\\20241220\\2_05503707_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA2 D:\\IMAGE\\20241220\\2_05503753_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA1 D:\\IMAGE\\20241220\\1_05503769_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA2 D:\\IMAGE\\20241220\\2_05503793_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:38 CAMERA2 D:\\IMAGE\\20241220\\2_05503816_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:38 CAMERA1 D:\\IMAGE\\20241220\\1_05503837_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:38 CAMERA2 D:\\IMAGE\\20241220\\2_05503843_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503888_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA1 D:\\IMAGE\\20241220\\1_05503905_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503930_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503952_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503976_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA1 D:\\IMAGE\\20241220\\1_05503972_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA2 D:\\IMAGE\\20241220\\2_05504003_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA2 D:\\IMAGE\\20241220\\2_05504044_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA1 D:\\IMAGE\\20241220\\1_05504041_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA2 D:\\IMAGE\\20241220\\2_05504071_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA2 D:\\IMAGE\\20241220\\2_05504113_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA1 D:\\IMAGE\\20241220\\1_05504109_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA2 D:\\IMAGE\\20241220\\2_05504140_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA1 D:\\IMAGE\\20241220\\1_05504177_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504185_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504231_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA1 D:\\IMAGE\\20241220\\1_05504246_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504271_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504294_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CAMERA1 D:\\IMAGE\\20241220\\1_05504314_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CAMERA2 D:\\IMAGE\\20241220\\2_05504321_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:50:43 CAMERA2 D:\\IMAGE\\20241220\\2_05504367_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CAMERA1 D:\\IMAGE\\20241220\\1_05504382_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:44 CAMERA2 D:\\IMAGE\\20241220\\2_05504408_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:44 CAMERA2 D:\\IMAGE\\20241220\\2_05504435_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:44 CAMERA1 D:\\IMAGE\\20241220\\1_05504450_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA2 D:\\IMAGE\\20241220\\2_05504481_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA1 D:\\IMAGE\\20241220\\1_05504523_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA2 D:\\IMAGE\\20241220\\2_05504527_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA2 D:\\IMAGE\\20241220\\2_05504567_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA1 D:\\IMAGE\\20241220\\1_05504588_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:46 CAMERA2 D:\\IMAGE\\20241220\\2_05504595_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:46 CAMERA2 D:\\IMAGE\\20241220\\2_05504640_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:46 CAMERA1 D:\\IMAGE\\20241220\\1_05504656_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA2 D:\\IMAGE\\20241220\\2_05504686_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA1 D:\\IMAGE\\20241220\\1_05504724_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA2 D:\\IMAGE\\20241220\\2_05504732_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA2 D:\\IMAGE\\20241220\\2_05504778_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:48 CAMERA1 D:\\IMAGE\\20241220\\1_05504792_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:48 CASH TAKEN \n20/12/2024 05:50:48 CAMERA2 D:\\IMAGE\\20241220\\2_05504823_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:48 CAMERA1 D:\\IMAGE\\20241220\\1_05504839_461699XXXXXX4588_CASH_TAKEN.JPG \n20/12/2024 05:50:48 CAMERA2 D:\\IMAGE\\20241220\\2_05504856_461699XXXXXX4588_CASH_TAKEN.JPG \n20/12/2024 05:50:49 ***** Tran Request State ***** \n20/12/2024 05:50:49 ***** Close Tran State ***** \n20/12/2024 05:50:49 ***** Close Tran State ***** \n20/12/2024 05:50:55 \u003c- Transaction end \n \n20/12/2024 05:50:56 CAMERA1 D:\\IMAGE\\20241220\\1_05505589_461699XXXXXX4588_END.JPG \n20/12/2024 05:50:56 Card State: (4101;00000;00;--------) \n20/12/2024 05:50:56 ----- Clear Cash-In Device ---- \n20/12/2024 05:50:56 CAMERA2 D:\\IMAGE\\20241220\\2_05505622__CASH_OTHERS.JPG \n20/12/2024 05:50:57 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:50:57 CONFIG-ID : 2002\n20/12/2024 05:55:56 CAMERA1 D:\\IMAGE\\20241220\\1_05555613__INTERVAL_CAPTURE.JPG \n \n20/12/2024 05:59:50 -\u003e Transaction start \n20/12/2024 05:59:50 TRACK 2 DATA: 532659XXXXXX6470 \n20/12/2024 05:59:50 CAMERA1 D:\\IMAGE\\20241220\\1_05595056__START.JPG \n20/12/2024 05:59:50 CAMERA1 D:\\IMAGE\\20241220\\1_05595075_532659XXXXXX6470_CARD.JPG \n20/12/2024 05:59:52 EMV CANDIDATES: 2 \n20/12/2024 05:59:54 EMV AID A0000006021010 / 532659XXXXXX6470 STARTED \n20/12/2024 06:00:01 PIN ENTERED \n20/12/2024 06:00:01 CAMERA1 D:\\IMAGE\\20241220\\1_06000161_532659XXXXXX6470_PIN.JPG \n20/12/2024 06:00:03 ***** Tran Request State ***** \n20/12/2024 06:00:04 TRANSACTION REQUEST A B \n20/12/2024 06:00:04 Transaction reply next 016 function A024 \n20/12/2024 06:00:05 TVR: 8000040000, TSI: 7000 \n20/12/2024 06:00:14 SERIAL NUMBERS SUCCESSFULLY STORED FOR 20 GENUINE NOTES \n20/12/2024 06:00:14 IDR 50000 S/N: ZNN654909,VPK239205,VNT638805,RRV401446,JMB255294,LNC544756,RLK133508,OES031962,BQT902509,MCG596000 \n20/12/2024 06:00:14 IDR 100000 S/N: CRJ352020,QNU658606,ENB236559,MQE578753,CNP898272,KNC626696,MQQ085321,JAM052180,PQP378728,KCK853042 \n20/12/2024 06:00:14 CASH REQUEST: 10001000 \n06:00:14 CASH 1:1,10;3:3,10; \n20/12/2024 06:00:14 CAMERA2 D:\\IMAGE\\20241220\\2_06001480_532659XXXXXX6470_CASH_REQUEST.JPG \n20/12/2024 06:00:16 CARD(532659XXXXXX6470) TAKEN \n20/12/2024 06:00:20 CASH PRESENTED \n20/12/2024 06:00:20 CAMERA1 D:\\IMAGE\\20241220\\1_06002024_532659XXXXXX6470_CASH_PRESENT.JPG \nTANGGAL: 20/12/24 WAKTU : 05:37:33 \nATM ID : 190015 NO.REF: 2017 \nCARD : 532659XXXXXX6470 \nREK : 011001003011560 \nKODETX : 3 FAST CASH NO RECEIPT \nAMOUNT : RP 1,500,000 \nSALDO : RP 32,846,515 \nRESPON : 00 Fash Cash\nSWITCHING : BRI DEBIT \n20/12/2024 06:00:20 CAMERA2 D:\\IMAGE\\20241220\\2_06002036_532659XXXXXX6470_CASH_PRESENT.JPG \n20/12/2024 06:00:20 CAMERA2 D:\\IMAGE\\20241220\\2_06002064_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:20 CAMERA1 D:\\IMAGE\\20241220\\1_06002086_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA2 D:\\IMAGE\\20241220\\2_06002109_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA2 D:\\IMAGE\\20241220\\2_06002150_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA1 D:\\IMAGE\\20241220\\1_06002155_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA2 D:\\IMAGE\\20241220\\2_06002178_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:22 CAMERA2 D:\\IMAGE\\20241220\\2_06002219_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:22 CAMERA1 D:\\IMAGE\\20241220\\1_06002222_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:22 CAMERA2 D:\\IMAGE\\20241220\\2_06002246_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA2 D:\\IMAGE\\20241220\\2_06002290_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA1 D:\\IMAGE\\20241220\\1_06002305_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA2 D:\\IMAGE\\20241220\\2_06002338_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA1 D:\\IMAGE\\20241220\\1_06002381_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA2 D:\\IMAGE\\20241220\\2_06002383_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA2 D:\\IMAGE\\20241220\\2_06002429_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA1 D:\\IMAGE\\20241220\\1_06002449_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA2 D:\\IMAGE\\20241220\\2_06002476_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002514_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA1 D:\\IMAGE\\20241220\\1_06002517_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002536_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002560_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002583_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA1 D:\\IMAGE\\20241220\\1_06002585_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA2 D:\\IMAGE\\20241220\\2_06002607_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA2 D:\\IMAGE\\20241220\\2_06002634_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA1 D:\\IMAGE\\20241220\\1_06002653_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA2 D:\\IMAGE\\20241220\\2_06002679_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA1 D:\\IMAGE\\20241220\\1_06002721_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA2 D:\\IMAGE\\20241220\\2_06002724_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA2 D:\\IMAGE\\20241220\\2_06002765_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA2 D:\\IMAGE\\20241220\\2_06002788_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA1 D:\\IMAGE\\20241220\\1_06002790_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:28 CAMERA2 D:\\IMAGE\\20241220\\2_06002815_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:28 CAMERA1 D:\\IMAGE\\20241220\\1_06002858_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:28 CAMERA2 D:\\IMAGE\\20241220\\2_06002860_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA2 D:\\IMAGE\\20241220\\2_06002906_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA1 D:\\IMAGE\\20241220\\1_06002926_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA2 D:\\IMAGE\\20241220\\2_06002947_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA2 D:\\IMAGE\\20241220\\2_06002974_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA1 D:\\IMAGE\\20241220\\1_06002994_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA2 D:\\IMAGE\\20241220\\2_06003020_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA2 D:\\IMAGE\\20241220\\2_06003060_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA1 D:\\IMAGE\\20241220\\1_06003062_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA2 D:\\IMAGE\\20241220\\2_06003083_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA2 D:\\IMAGE\\20241220\\2_06003110_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA1 D:\\IMAGE\\20241220\\1_06003131_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA2 D:\\IMAGE\\20241220\\2_06003156_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA2 D:\\IMAGE\\20241220\\2_06003197_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA1 D:\\IMAGE\\20241220\\1_06003199_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA2 D:\\IMAGE\\20241220\\2_06003224_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA2 D:\\IMAGE\\20241220\\2_06003264_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA1 D:\\IMAGE\\20241220\\1_06003266_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003292_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003333_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA1 D:\\IMAGE\\20241220\\1_06003335_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003355_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003378_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA1 D:\\IMAGE\\20241220\\1_06003403_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA2 D:\\IMAGE\\20241220\\2_06003406_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA2 D:\\IMAGE\\20241220\\2_06003447_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA1 D:\\IMAGE\\20241220\\1_06003471_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA2 D:\\IMAGE\\20241220\\2_06003474_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:35 CAMERA2 D:\\IMAGE\\20241220\\2_06003520_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:35 CAMERA1 D:\\IMAGE\\20241220\\1_06003554_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:35 CAMERA2 D:\\IMAGE\\20241220\\2_06003565_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA2 D:\\IMAGE\\20241220\\2_06003611_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA1 D:\\IMAGE\\20241220\\1_06003630_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA2 D:\\IMAGE\\20241220\\2_06003650_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA2 D:\\IMAGE\\20241220\\2_06003678_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA1 D:\\IMAGE\\20241220\\1_06003698_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA2 D:\\IMAGE\\20241220\\2_06003718_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA2 D:\\IMAGE\\20241220\\2_06003741_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA2 D:\\IMAGE\\20241220\\2_06003764_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA1 D:\\IMAGE\\20241220\\1_06003765_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:38 CAMERA2 D:\\IMAGE\\20241220\\2_06003792_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:38 CAMERA1 D:\\IMAGE\\20241220\\1_06003834_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:38 CAMERA2 D:\\IMAGE\\20241220\\2_06003837_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA2 D:\\IMAGE\\20241220\\2_06003884_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA1 D:\\IMAGE\\20241220\\1_06003902_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA2 D:\\IMAGE\\20241220\\2_06003929_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA1 D:\\IMAGE\\20241220\\1_06003970_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA2 D:\\IMAGE\\20241220\\2_06003974_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA2 D:\\IMAGE\\20241220\\2_06004016_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA2 D:\\IMAGE\\20241220\\2_06004039_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA1 D:\\IMAGE\\20241220\\1_06004038_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA2 D:\\IMAGE\\20241220\\2_06004067_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA1 D:\\IMAGE\\20241220\\1_06004106_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA2 D:\\IMAGE\\20241220\\2_06004112_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA2 D:\\IMAGE\\20241220\\2_06004156_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA1 D:\\IMAGE\\20241220\\1_06004170_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004198_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004222_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004244_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA1 D:\\IMAGE\\20241220\\1_06004243_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004268_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:43 CAMERA2 D:\\IMAGE\\20241220\\2_06004295_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:43 CAMERA1 D:\\IMAGE\\20241220\\1_06004330_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:43 CAMERA2 D:\\IMAGE\\20241220\\2_06004340_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA2 D:\\IMAGE\\20241220\\2_06004385_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA1 D:\\IMAGE\\20241220\\1_06004401_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA2 D:\\IMAGE\\20241220\\2_06004431_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA2 D:\\IMAGE\\20241220\\2_06004472_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA1 D:\\IMAGE\\20241220\\1_06004470_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CAMERA2 D:\\IMAGE\\20241220\\2_06004500_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CASH PRESENT TIMER EXPIRED \n20/12/2024 06:00:45 CAMERA1 D:\\IMAGE\\20241220\\1_06004538_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CAMERA2 D:\\IMAGE\\20241220\\2_06004545_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CAMERA2 D:\\IMAGE\\20241220\\2_06004572_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA1 D:\\IMAGE\\20241220\\1_06004607_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA2 D:\\IMAGE\\20241220\\2_06004614_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA2 D:\\IMAGE\\20241220\\2_06004659_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA1 D:\\IMAGE\\20241220\\1_06004675_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA2 D:\\IMAGE\\20241220\\2_06004705_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA2 D:\\IMAGE\\20241220\\2_06004745_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA1 D:\\IMAGE\\20241220\\1_06004744_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA2 D:\\IMAGE\\20241220\\2_06004772_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA1 D:\\IMAGE\\20241220\\1_06004813_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA2 D:\\IMAGE\\20241220\\2_06004818_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA2 D:\\IMAGE\\20241220\\2_06004860_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA1 D:\\IMAGE\\20241220\\1_06004881_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:49 CAMERA2 D:\\IMAGE\\20241220\\2_06004887_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:49 CASH TAKEN \n20/12/2024 06:00:49 CAMERA2 D:\\IMAGE\\20241220\\2_06004933_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:49 CAMERA1 D:\\IMAGE\\20241220\\1_06004936_532659XXXXXX6470_CASH_TAKEN.JPG \n20/12/2024 06:00:49 CAMERA2 D:\\IMAGE\\20241220\\2_06004964_532659XXXXXX6470_CASH_TAKEN.JPG \n20/12/2024 06:00:50 ***** Tran Request State ***** \n20/12/2024 06:00:50 ***** Close Tran State ***** \n20/12/2024 06:00:50 ***** Close Tran State ***** \n20/12/2024 06:00:56 \u003c- Transaction end \n \n20/12/2024 06:00:57 Card State: (4101;00000;00;--------) \n20/12/2024 06:00:57 CAMERA1 D:\\IMAGE\\20241220\\1_06005681_532659XXXXXX6470_END.JPG \n20/12/2024 06:00:57 ----- Clear Cash-In Device ---- \n20/12/2024 06:00:57 CAMERA2 D:\\IMAGE\\20241220\\2_06005720__CASH_OTHERS.JPG \n20/12/2024 06:00:58 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 06:00:58 CONFIG-ID : 2002\n20/12/2024 06:05:57 CAMERA1 D:\\IMAGE\\20241220\\1_06055722__INTERVAL_CAPTURE.JPG \n \n20/12/2024 06:08:07 -\u003e Transaction start \n20/12/2024 06:08:07 TRACK 2 DATA: 522184XXXXXX4614 \n20/12/2024 06:08:08 CAMERA1 D:\\IMAGE\\20241220\\1_06080786__START.JPG \n20/12/2024 06:08:08 CAMERA1 D:\\IMAGE\\20241220\\1_06080814_522184XXXXXX4614_CARD.JPG \n20/12/2024 06:08:09 EMV CANDIDATES: 2 \n20/12/2024 06:08:11 EMV AID A0000006021010 / 522184XXXXXX4614 STARTED \n20/12/2024 06:08:16 PIN ENTERED \n20/12/2024 06:08:16 CAMERA1 D:\\IMAGE\\20241220\\1_06081678_522184XXXXXX4614_PIN.JPG \n20/12/2024 06:08:21 ***** Tran Request State ***** \n20/12/2024 06:08:21 TRANSACTION REQUEST A B \n20/12/2024 06:08:21 Transaction reply next 016 function A024 \n20/12/2024 06:08:22 TVR: 8000040000, TSI: 7000\n20/12/2024 06:08:40 SERIAL NUMBERS SUCCESSFULLY STORED FOR 3 GENUINE NOTES \n20/12/2024 06:08:40 IDR 50000 S/N: AAU861988,BAL777900 \n20/12/2024 06:08:40 IDR 100000 S/N: CMQ162638 \n20/12/2024 06:08:40 CASH REQUEST: 01000200 \n06:08:40 CASH 1:1,1;3:3,2; \n20/12/2024 06:08:40 CAMERA2 D:\\IMAGE\\20241220\\2_06084049_522184XXXXXX4614_CASH_REQUEST.JPG \n20/12/2024 06:08:42 CARD(522184XXXXXX4614) TAKEN \n20/12/2024 06:08:47 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:45:50 \nATM ID : 190015 NO.REF: 2018 \nCARD : 522184XXXXXX4614 \nREK : 465501000131507 \nKODETX : 3 FAST CASH NO RECEIPT \nAMOUNT : RP 200,000 \nSALDO : RP 166,842 \nRESPON : 00 Fash Cash \nSWITCHING : BRI DEBIT \n20/12/2024 06:08:47 CAMERA1 D:\\IMAGE\\20241220\\1_06084746_522184XXXXXX4614_CASH_PRESENT.JPG \n20/12/2024 06:08:47 CAMERA2 D:\\IMAGE\\20241220\\2_06084771_522184XXXXXX4614_CASH_PRESENT.JPG \n20/12/2024 06:08:48 CAMERA2 D:\\IMAGE\\20241220\\2_06084814_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA1 D:\\IMAGE\\20241220\\1_06084822_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA2 D:\\IMAGE\\20241220\\2_06084842_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA2 D:\\IMAGE\\20241220\\2_06084882_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA1 D:\\IMAGE\\20241220\\1_06084891_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA2 D:\\IMAGE\\20241220\\2_06084905_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA2 D:\\IMAGE\\20241220\\2_06084932_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA1 D:\\IMAGE\\20241220\\1_06084958_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA2 D:\\IMAGE\\20241220\\2_06084977_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA2 D:\\IMAGE\\20241220\\2_06085019_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA1 D:\\IMAGE\\20241220\\1_06085027_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA2 D:\\IMAGE\\20241220\\2_06085042_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA2 D:\\IMAGE\\20241220\\2_06085070_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA1 D:\\IMAGE\\20241220\\1_06085094_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA2 D:\\IMAGE\\20241220\\2_06085110_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA2 D:\\IMAGE\\20241220\\2_06085138_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA1 D:\\IMAGE\\20241220\\1_06085163_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085184_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA1 D:\\IMAGE\\20241220\\1_06085231_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085227_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085271_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085292_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA2 D:\\IMAGE\\20241220\\2_06085316_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA1 D:\\IMAGE\\20241220\\1_06085311_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA2 D:\\IMAGE\\20241220\\2_06085339_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA2 D:\\IMAGE\\20241220\\2_06085361_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA1 D:\\IMAGE\\20241220\\1_06085390_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085389_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085430_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085453_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA1 D:\\IMAGE\\20241220\\1_06085458_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085477_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA2 D:\\IMAGE\\20241220\\2_06085504_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA1 D:\\IMAGE\\20241220\\1_06085527_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA2 D:\\IMAGE\\20241220\\2_06085549_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA2 D:\\IMAGE\\20241220\\2_06085590_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA1 D:\\IMAGE\\20241220\\1_06085595_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA2 D:\\IMAGE\\20241220\\2_06085613_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA2 D:\\IMAGE\\20241220\\2_06085640_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA1 D:\\IMAGE\\20241220\\1_06085663_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085686_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085727_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA1 D:\\IMAGE\\20241220\\1_06085731_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085754_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085794_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA1 D:\\IMAGE\\20241220\\1_06085799_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA2 D:\\IMAGE\\20241220\\2_06085821_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA2 D:\\IMAGE\\20241220\\2_06085867_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA1 D:\\IMAGE\\20241220\\1_06085868_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:59 CAMERA2 D:\\IMAGE\\20241220\\2_06085912_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:59 CAMERA1 D:\\IMAGE\\20241220\\1_06085948_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:59 CAMERA2 D:\\IMAGE\\20241220\\2_06085959_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA2 D:\\IMAGE\\20241220\\2_06085998_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA1 D:\\IMAGE\\20241220\\1_06090026_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA2 D:\\IMAGE\\20241220\\2_06090028_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA2 D:\\IMAGE\\20241220\\2_06090072_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA1 D:\\IMAGE\\20241220\\1_06090094_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA2 D:\\IMAGE\\20241220\\2_06090117_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA2 D:\\IMAGE\\20241220\\2_06090162_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA1 D:\\IMAGE\\20241220\\1_06090162_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA2 D:\\IMAGE\\20241220\\2_06090201_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA1 D:\\IMAGE\\20241220\\1_06090242_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA2 D:\\IMAGE\\20241220\\2_06090231_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA2 D:\\IMAGE\\20241220\\2_06090278_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA1 D:\\IMAGE\\20241220\\1_06090313_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA2 D:\\IMAGE\\20241220\\2_06090323_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA2 D:\\IMAGE\\20241220\\2_06090368_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA1 D:\\IMAGE\\20241220\\1_06090390_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:04 CAMERA2 D:\\IMAGE\\20241220\\2_06090413_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:04 CAMERA1 D:\\IMAGE\\20241220\\1_06090459_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:04 CAMERA2 D:\\IMAGE\\20241220\\2_06090459_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:05 CAMERA2 D:\\IMAGE\\20241220\\2_06090505_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:05 CAMERA1 D:\\IMAGE\\20241220\\1_06090544_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:05 CAMERA2 D:\\IMAGE\\20241220\\2_06090548_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:06 CAMERA2 D:\\IMAGE\\20241220\\2_06090595_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:06 CAMERA1 D:\\IMAGE\\20241220\\1_06090617_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:06 CAMERA2 D:\\IMAGE\\20241220\\2_06090640_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA2 D:\\IMAGE\\20241220\\2_06090684_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA1 D:\\IMAGE\\20241220\\1_06090698_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA2 D:\\IMAGE\\20241220\\2_06090727_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA2 D:\\IMAGE\\20241220\\2_06090754_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA1 D:\\IMAGE\\20241220\\1_06090777_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA2 D:\\IMAGE\\20241220\\2_06090799_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA2 D:\\IMAGE\\20241220\\2_06090840_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA1 D:\\IMAGE\\20241220\\1_06090845_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA2 D:\\IMAGE\\20241220\\2_06090863_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA2 D:\\IMAGE\\20241220\\2_06090890_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA1 D:\\IMAGE\\20241220\\1_06090913_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA2 D:\\IMAGE\\20241220\\2_06090935_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA2 D:\\IMAGE\\20241220\\2_06090976_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA1 D:\\IMAGE\\20241220\\1_06090981_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA2 D:\\IMAGE\\20241220\\2_06090999_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA2 D:\\IMAGE\\20241220\\2_06091026_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA1 D:\\IMAGE\\20241220\\1_06091049_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA2 D:\\IMAGE\\20241220\\2_06091067_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA2 D:\\IMAGE\\20241220\\2_06091095_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA1 D:\\IMAGE\\20241220\\1_06091117_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA2 D:\\IMAGE\\20241220\\2_06091135_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA2 D:\\IMAGE\\20241220\\2_06091162_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA1 D:\\IMAGE\\20241220\\1_06091186_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:12 CAMERA2 D:\\IMAGE\\20241220\\2_06091209_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:12 CAMERA2 D:\\IMAGE\\20241220\\2_06091249_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:12 CASH PRESENT TIMER EXPIRED \n20/12/2024 06\n20/12/2024 00:03:50 CAMERA1 D:\\IMAGE\\20241220\\1_00034988__INTERVAL_CAPTURE.JPG \n20/12/2024 00:08:50 CAMERA1 D:\\IMAGE\\20241220\\1_00085013__INTERVAL_CAPTURE.JPG \n \n20/12/2024 00:09:56 -\u003e Transaction start \n20/12/2024 00:09:56 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:09:56 CAMERA1 D:\\IMAGE\\20241220\\1_00095609__START.JPG \n20/12/2024 00:09:56 CAMERA1 D:\\IMAGE\\20241220\\1_00095626_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:09:57 EMV CANDIDATES: 1 \n20/12/2024 00:09:59 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:10:05 PIN ENTERED \n20/12/2024 00:10:05 CAMERA1 D:\\IMAGE\\20241220\\1_00100512_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:10:08 ***** Tran Request State ***** \n20/12/2024 00:10:08 TRANSACTION REQUEST AF \n20/12/2024 00:10:09 Transaction reply next 523 function 5157 \n20/12/2024 00:10:09 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:47:39 \nATM ID : 190015 NO.REF: 19580 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:10:09 ***** Tran Request State ***** \n20/12/2024 00:10:09 ***** Accept Cash State ***** \n20/12/2024 00:10:09 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:10:10 ----- Clear Cash-In Device ---- \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101005_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:10:10 ----- Insert Notes ---- \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101032_601301XXXXXX6089_Insert_Notes.JPG \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101062_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:10 CAMERA2 D:\\IMAGE\\20241220\\2_00101085_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:11 CAMERA2 D:\\IMAGE\\20241220\\2_00101114_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:11 CAMERA2 D:\\IMAGE\\20241220\\2_00101153_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:11 CAMERA2 D:\\IMAGE\\20241220\\2_00101176_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:12 CAMERA2 D:\\IMAGE\\20241220\\2_00101200_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:12 CAMERA2 D:\\IMAGE\\20241220\\2_00101228_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:12 CAMERA2 D:\\IMAGE\\20241220\\2_00101273_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:13 CAMERA2 D:\\IMAGE\\20241220\\2_00101314_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:13 CAMERA2 D:\\IMAGE\\20241220\\2_00101342_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:14 CAMERA2 D:\\IMAGE\\20241220\\2_00101388_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:14 CAMERA2 D:\\IMAGE\\20241220\\2_00101433_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:14 CAMERA2 D:\\IMAGE\\20241220\\2_00101474_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:15 CAMERA2 D:\\IMAGE\\20241220\\2_00101501_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:15 CAMERA2 D:\\IMAGE\\20241220\\2_00101543_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:15 CAMERA2 D:\\IMAGE\\20241220\\2_00101580_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:16 CAMERA2 D:\\IMAGE\\20241220\\2_00101617_601301XXXXXX6089_INTERVAL_CAPTURE.JPG \n20/12/2024 00:10:16 Notes INSERTED \n20/12/2024 00:10:16 CAMERA2 D:\\IMAGE\\20241220\\2_00101641_601301XXXXXX6089_Notes_INSERTED.JPG \n20/12/2024 00:10:16 ----- Identify Notes ---- \n20/12/2024 00:10:27 INVALID NOTES RECOGNIZED \n20/12/2024 00:10:29 Notes IDENTIFIED : (IDR,50000,1) \n20/12/2024 00:10:29 Notes IDENTIFIED : (IDR,100000,29) \n20/12/2024 00:10:30 Notes REFUSED : 4 \n20/12/2024 00:10:30 ----- Remove Notes ---- \n20/12/2024 00:10:37 NOTE(S) PRESENTING STARTED \n20/12/2024 00:11:10 Output Shutter JAMMED \n EMERGENCY RECEIPT \n SEDANG TERJADI GANGGUAN \n MESIN ATAU JARINGAN KOMUNIKASI \n SILAKAN CEK SALDO ANDA \n DAN HUBUNGI KANTOR BRI TERDEKAT\n RINCIAN TRANSAKSI ANDA: \n NO KARTU: 601301******6089 \n TGL/JAM: 12/20/2024 00:11 \n TID: 190015 \n IDR 50000 X 0 \n IDR 100000 X 0 \n TOTAL = IDR \n CONTACT BRI \n 1500017 \n20/12/2024 00:11:11 ***** Accept Cash State ***** \n20/12/2024 00:11:11 ***** Close Tran State ***** \n20/12/2024 00:11:11 ***** Close Tran State ***** \n20/12/2024 00:11:22 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:11:22 \u003c- Transaction end \n \n20/12/2024 00:11:22 CAMERA1 D:\\IMAGE\\20241220\\1_00112241_601301XXXXXX6089_END.JPG \n20/12/2024 00:11:22 Card State: (1001;00000;00;--------) \n20/12/2024 00:11:22 ----- Clear Cash-In Device ---- \n20/12/2024 00:11:22 CAMERA2 D:\\IMAGE\\20241220\\2_00112272__CASH_OTHERS.JPG \n20/12/2024 00:11:24 Device PROBLEM \n20/12/2024 00:11:27 Previous Identified Notes : (IDR,50000,1) \n20/12/2024 00:11:27 Previous Identified Notes : (IDR,100000,29) \n20/12/2024 00:11:39 SERIAL NUMBERS SUCCESSFULLY STORED FOR 30 GENUINE NOTES \n20/12/2024 00:11:39 IDR 50000 S/N: SEE371483 \n20/12/2024 00:11:39 IDR 100000 S/N: EDG082772,ANW700764,BME519965,CMJ223459,CMM235449,QOK669444,PHR654590,LRV623137,GPM502448,JKF662661,ZFG443777,MFK402963,JMA106121,GKK886445,FDE730240,RFZ767334,EDF783210,VHE736715,MQC639499,EBE596899,BGP644173,NAZ889183,HHO740886,KNK561936,BBJ206459,CPE301503,SOG402171,UPO334447,WFF868840 \n20/12/2024 00:11:39 Application LOCKED \n20/12/2024 00:11:39 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:11:39 CONFIG-ID : 2002 \n20/12/2024 00:11:39 SERIAL NUMBERS SUCCESSFULLY STORED FOR 30 GENUINE NOTES \n20/12/2024 00:11:39 IDR 50000 S/N: SEE371483 \n20/12/2024 00:11:39 IDR 100000 S/N: EDG082772,ANW700764,BME519965,CMJ223459,CMM235449,QOK669444,PHR654590,LRV623137,GPM502448,JKF662661,ZFG443777,MFK402963,JMA106121,GKK886445,FDE730240,RFZ767334,EDF783210,VHE736715,MQC639499,EBE596899,BGP644173,NAZ889183,HHO740886,KNK561936,BBJ206459,CPE301503,SOG402171,UPO334447,WFF868840\n20/12/2024 00:11:39 DEP ERROR: 00006446 00000023 00000009 LYNX CASHIN: Maximum cash in retracts reached \n20/12/2024 00:11:39 DEVICE CCCashInFW STATUS 4 SUPPLY 1 \n \n20/12/2024 00:11:43 -\u003e Transaction start \n20/12/2024 00:11:43 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:11:43 CAMERA1 D:\\IMAGE\\20241220\\1_00114321__START.JPG \n20/12/2024 00:11:43 CAMERA1 D:\\IMAGE\\20241220\\1_00114349_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:11:44 EMV CANDIDATES: 1 \n20/12/2024 00:11:46 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:11:51 PIN ENTERED \n20/12/2024 00:11:51 CAMERA1 D:\\IMAGE\\20241220\\1_00115153_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:11:58 ***** Close Tran State ***** \n20/12/2024 00:11:58 ***** Close Tran State ***** \n20/12/2024 00:11:59 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:12:04 \u003c- Transaction end \n \n20/12/2024 00:12:04 CAMERA1 D:\\IMAGE\\20241220\\1_00120444_601301XXXXXX6089_END.JPG \n20/12/2024 00:12:04 Card State: (1001;00000;00;--------) \n20/12/2024 00:12:04 ----- Clear Cash-In Device ---- \n20/12/2024 00:12:04 CAMERA2 D:\\IMAGE\\20241220\\2_00120476__CASH_OTHERS.JPG \n20/12/2024 00:12:04 Device PROBLEM \n20/12/2024 00:12:05 Cassette PROBLEM \n20/12/2024 00:12:05 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:12:05 CONFIG-ID : 2002 \n \n20/12/2024 00:12:08 -\u003e Transaction start \n20/12/2024 00:12:08 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:12:08 CAMERA1 D:\\IMAGE\\20241220\\1_00120832__START.JPG \n20/12/2024 00:12:08 CAMERA1 D:\\IMAGE\\20241220\\1_00120849_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:12:10 EMV CANDIDATES: 1 \n20/12/2024 00:12:11 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED\n20/12/2024 00:12:16 PIN ENTERED \n20/12/2024 00:12:16 CAMERA1 D:\\IMAGE\\20241220\\1_00121618_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:12:20 ***** Tran Request State ***** \n20/12/2024 00:12:21 TRANSACTION REQUEST A BA \n20/12/2024 00:12:21 Transaction reply next 264 function 5108 \n20/12/2024 00:12:21 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:49:51 \nATM ID : 190015 NO.REF: 19581 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 19.858.698 \nRESPON : 00 Sukses \n20/12/2024 00:12:21 ***** Tran Request State ***** \n20/12/2024 00:12:29 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:12:35 PIN ENTERED \n20/12/2024 00:12:35 CAMERA1 D:\\IMAGE\\20241220\\1_00123514_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:12:38 ***** Tran Request State ***** \n20/12/2024 00:12:38 TRANSACTION REQUEST AF \n20/12/2024 00:12:38 Transaction reply next 523 function 5157 \n20/12/2024 00:12:39 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:50:09 \nATM ID : 190015 NO.REF: 19582 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:12:39 ***** Tran Request State *****\n20/12/2024 00:12:39 ***** Accept Cash State ***** \n20/12/2024 00:12:39 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:12:39 ----- Clear Cash-In Device ---- \n20/12/2024 00:12:39 CAMERA2 D:\\IMAGE\\20241220\\2_00123978_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:12:39 Device PROBLEM \n20/12/2024 00:12:40 Cassette PROBLEM \n20/12/2024 00:12:40 ***** Accept Cash State ***** \n20/12/2024 00:12:40 ***** Close Tran State ***** \n20/12/2024 00:12:40 ***** Close Tran State ***** \n20/12/2024 00:12:42 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:12:46 \u003c- Transaction end \n \n20/12/2024 00:12:46 CAMERA1 D:\\IMAGE\\20241220\\1_00124654_601301XXXXXX6089_END.JPG \n20/12/2024 00:12:46 Card State: (1001;00000;00;--------) \n20/12/2024 00:12:46 ----- Clear Cash-In Device ---- \n20/12/2024 00:12:46 CAMERA2 D:\\IMAGE\\20241220\\2_00124685__CASH_OTHERS.JPG \n20/12/2024 00:12:46 Device PROBLEM \n20/12/2024 00:12:47 Cassette PROBLEM \n20/12/2024 00:12:47 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:12:47 CONFIG-ID : 2002 \n \n20/12/2024 00:13:20 -\u003e Transaction start \n20/12/2024 00:13:20 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:13:20 CAMERA1 D:\\IMAGE\\20241220\\1_00132042__START.JPG \n20/12/2024 00:13:20 CAMERA1 D:\\IMAGE\\20241220\\1_00132070_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:13:22 EMV CANDIDATES: 1 \n20/12/2024 00:13:23 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:13:29 PIN ENTERED \n20/12/2024 00:13:30 CAMERA1 D:\\IMAGE\\20241220\\1_00132993_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:13:34 ***** Tran Request State ***** \n20/12/2024 00:13:34 TRANSACTION REQUEST A BA \n20/12/2024 00:13:35 Transaction reply next 264 function 5108 \n20/12/2024 00:13:35 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:51:05 \nATM ID : 190015 NO.REF: 19583 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 19.858.698 \nRESPON : 00 Sukses \n20/12/2024 00:13:35 ***** Tran Request State ***** \n20/12/2024 00:13:42 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:13:48 PIN ENTERED \n20/12/2024 00:13:49 CAMERA1 D:\\IMAGE\\20241220\\1_00134886_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:13:52 ***** Tran Request State ***** \n20/12/2024 00:13:52 TRANSACTION REQUEST AF \n20/12/2024 00:13:53 Transaction reply next 523 function 5157 \n20/12/2024 00:13:53 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:51:23 \nATM ID : 190015 NO.REF: 19584 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:13:53 ***** Tran Request State ***** \n20/12/2024 00:13:53 ***** Accept Cash State ***** \n20/12/2024 00:13:54 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:13:54 ----- Clear Cash-In Device ---- \n20/12/2024 00:13:54 CAMERA2 D:\\IMAGE\\20241220\\2_00135415_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:13:54 Device PROBLEM \n20/12/2024 00:13:54 Cassette PROBLEM \n20/12/2024 00:13:54 ***** Accept Cash State ***** \n20/12/2024 00:13:54 ***** Close Tran State ***** \n20/12/2024 00:13:54 ***** Close Tran State ***** \n20/12/2024 00:13:56 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:14:00 \u003c- Transaction end \n \n20/12/2024 00:14:01 CAMERA1 D:\\IMAGE\\20241220\\1_00140095_601301XXXXXX6089_END.JPG \n20/12/2024 00:14:01 Card State: (1001;00000;00;--------) \n20/12/2024 00:14:01 ----- Clear Cash-In Device ---- \n20/12/2024 00:14:01 CAMERA2 D:\\IMAGE\\20241220\\2_00140127__CASH_OTHERS.JPG \n20/12/2024 00:14:01 Device PROBLEM \n20/12/2024 00:14:01 Cassette PROBLEM \n20/12/2024 00:14:01 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:14:01 CONFIG-ID : 2002 \n \n20/12/2024 00:16:34 -\u003e Transaction start \n20/12/2024 00:16:34 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:16:34 CAMERA1 D:\\IMAGE\\20241220\\1_00163434__START.JPG \n20/12/2024 00:16:34 CAMERA1 D:\\IMAGE\\20241220\\1_00163451_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:16:36 EMV CANDIDATES: 1 \n20/12/2024 00:16:37 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:16:43 PIN ENTERED \n20/12/2024 00:16:43 CAMERA1 D:\\IMAGE\\20241220\\1_00164354_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:16:46 ***** Tran Request State ***** \n20/12/2024 00:16:46 TRANSACTION REQUEST AF \n20/12/2024 00:16:46 Transaction reply next 523 function 5157 \n20/12/2024 00:16:47 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:54:16 \nATM ID : 190015 NO.REF: 19585\nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:16:47 ***** Tran Request State ***** \n20/12/2024 00:16:47 ***** Accept Cash State ***** \n20/12/2024 00:16:47 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:16:47 ----- Clear Cash-In Device ---- \n20/12/2024 00:16:47 CAMERA2 D:\\IMAGE\\20241220\\2_00164770_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:16:47 Device PROBLEM \n20/12/2024 00:16:47 Cassette PROBLEM \n20/12/2024 00:16:48 ***** Accept Cash State ***** \n20/12/2024 00:16:48 ***** Close Tran State ***** \n20/12/2024 00:16:48 ***** Close Tran State ***** \n20/12/2024 00:16:50 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:16:54 \u003c- Transaction end \n \n20/12/2024 00:16:54 CAMERA1 D:\\IMAGE\\20241220\\1_00165449_601301XXXXXX6089_END.JPG \n20/12/2024 00:16:54 Card State: (1001;00000;00;--------) \n20/12/2024 00:16:54 ----- Clear Cash-In Device ---- \n20/12/2024 00:16:54 Device PROBLEM \n20/12/2024 00:16:55 CAMERA2 D:\\IMAGE\\20241220\\2_00165481__CASH_OTHERS.JPG \n20/12/2024 00:16:55 Cassette PROBLEM \n20/12/2024 00:16:55 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:16:55 CONFIG-ID : 2002 \n \n20/12/2024 00:16:57 -\u003e Transaction start \n20/12/2024 00:16:57 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:16:57 CAMERA1 D:\\IMAGE\\20241220\\1_00165779__START.JPG \n20/12/2024 00:16:58 CAMERA1 D:\\IMAGE\\20241220\\1_00165798_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:16:59 EMV CANDIDATES: 1 \n20/12/2024 00:17:01 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:17:06 PIN ENTERED \n20/12/2024 00:17:06 CAMERA1 D:\\IMAGE\\20241220\\1_00170600_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:17:11 ***** Tran Request State ***** \n20/12/2024 00:17:11 TRANSACTION REQUEST AF \n20/12/2024 00:17:11 Transaction reply next 523 function 5157 \n20/12/2024 00:17:12 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:54:41 \nATM ID : 190015 NO.REF: 19586 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:17:12 ***** Tran Request State ***** \n20/12/2024 00:17:12 ***** Accept Cash State ***** \n20/12/2024 00:17:12 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:17:12 ----- Clear Cash-In Device ---- \n20/12/2024 00:17:12 CAMERA2 D:\\IMAGE\\20241220\\2_00171264_601301XXXXXX6089_CASH_OTHERS.JPG \n20/12/2024 00:17:12 Device PROBLEM \n20/12/2024 00:17:12 Cassette PROBLEM \n20/12/2024 00:17:13 ***** Accept Cash State ***** \n20/12/2024 00:17:13 ***** Close Tran State ***** \n20/12/2024 00:17:13 ***** Close Tran State ***** \n20/12/2024 00:17:15 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:17:19 \u003c- Transaction end \n \n20/12/2024 00:17:19 CAMERA1 D:\\IMAGE\\20241220\\1_00171944_601301XXXXXX6089_END.JPG \n20/12/2024 00:17:19 Card State: (1001;00000;00;--------) \n20/12/2024 00:17:19 ----- Clear Cash-In Device ---- \n20/12/2024 00:17:19 CAMERA2 D:\\IMAGE\\20241220\\2_00171976__CASH_OTHERS.JPG \n20/12/2024 00:17:19 Device PROBLEM \n20/12/2024 00:17:20 Cassette PROBLEM \n20/12/2024 00:17:20 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:17:20 CONFIG-ID : 2002 \n \n20/12/2024 00:17:34 -\u003e Transaction start \n20/12/2024 00:17:34 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:17:34 CAMERA1 D:\\IMAGE\\20241220\\1_00173473__START.JPG \n20/12/2024 00:17:35 CAMERA1 D:\\IMAGE\\20241220\\1_00173489_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:17:36 EMV CANDIDATES: 1 \n20/12/2024 00:17:37 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:17:47 PIN ENTERED \n20/12/2024 00:17:47 CAMERA1 D:\\IMAGE\\20241220\\1_00174742_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:17:57 ***** Close Tran State ***** \n20/12/2024 00:17:57 ***** Close Tran State ***** \n20/12/2024 00:18:00 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:18:03 \u003c- Transaction end \n \n20/12/2024 00:18:03 CAMERA1 D:\\IMAGE\\20241220\\1_00180332_601301XXXXXX6089_END.JPG \n20/12/2024 00:18:03 Card State: (1001;00000;00;--------) \n20/12/2024 00:18:03 ----- Clear Cash-In Device ---- \n20/12/2024 00:18:03 Device PROBLEM \n20/12/2024 00:18:03 CAMERA2 D:\\IMAGE\\20241220\\2_00180364__CASH_OTHERS.JPG \n20/12/2024 00:18:03 Cassette PROBLEM \n20/12/2024 00:18:03 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:18:04 CONFIG-ID : 2002 \n \n20/12/2024 00:18:07 -\u003e Transaction start\n20/12/2024 00:18:07 TRACK 2 DATA: 601301XXXXXX6089 \n20/12/2024 00:18:07 CAMERA1 D:\\IMAGE\\20241220\\1_00180711__START.JPG \n20/12/2024 00:18:07 CAMERA1 D:\\IMAGE\\20241220\\1_00180728_601301XXXXXX6089_CARD.JPG \n20/12/2024 00:18:08 EMV CANDIDATES: 1 \n20/12/2024 00:18:10 EMV AID A0000006021010 / 601301XXXXXX6089 STARTED \n20/12/2024 00:18:14 PIN ENTERED \n20/12/2024 00:18:14 CAMERA1 D:\\IMAGE\\20241220\\1_00181483_601301XXXXXX6089_PIN.JPG \n20/12/2024 00:18:35 ***** Tran Request State ***** \n20/12/2024 00:18:35 TRANSACTION REQUEST A BA \n20/12/2024 00:18:36 Transaction reply next 264 function 5108 \n20/12/2024 00:18:36 TVR: 8000040000, TSI: 7000 \nTANGGAL: 19/12/24 WAKTU : 23:56:06 \nATM ID : 190015 NO.REF: 19587 \nCARD : 601301XXXXXX6089 \nREK : 465501017325537 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 19.858.698 \nRESPON : 00 Sukses \n20/12/2024 00:18:36 ***** Tran Request State ***** \n20/12/2024 00:18:47 ***** Close Tran State ***** \n20/12/2024 00:18:47 ***** Close Tran State ***** \n20/12/2024 00:18:49 CARD(601301XXXXXX6089) TAKEN \n20/12/2024 00:18:53 \u003c- Transaction end \n \n20/12/2024 00:18:53 CAMERA1 D:\\IMAGE\\20241220\\1_00185339_601301XXXXXX6089_END.JPG \n20/12/2024 00:18:53 Card State: (1001;00000;00;--------) \n20/12/2024 00:18:54 ----- Clear Cash-In Device ---- \n20/12/2024 00:18:54 Device PROBLEM \n20/12/2024 00:18:54 Cassette PROBLEM \n20/12/2024 00:18:54 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 00:18:55 CONFIG-ID : 2002 \n20/12/2024 00:18:55 CAMERA2 D:\\IMAGE\\20241220\\2_00185460__CASH_OTHERS.JPG \n20/12/2024 00:23:53 CAMERA1 D:\\IMAGE\\20241220\\1_00235365__INTERVAL_CAPTURE.JPG \n20/12/2024 00:28:54 CAMERA1 D:\\IMAGE\\20241220\\1_00285387__INTERVAL_CAPTURE.JPG \n20/12/2024 00:33:54 CAMERA1 D:\\IMAGE\\20241220\\1_00335423__INTERVAL_CAPTURE.JPG \n20/12/2024 00:38:54 CAMERA1 D:\\IMAGE\\20241220\\1_00385463__INTERVAL_CAPTURE.JPG \n20/12/2024 00:43:54 CAMERA1 D:\\IMAGE\\20241220\\1_00435487__INTERVAL_CAPTURE.JPG \n20/12/2024 00:48:55 CAMERA1 D:\\IMAGE\\20241220\\1_00485508__INTERVAL_CAPTURE.JPG \n20/12/2024 00:53:55 CAMERA1 D:\\IMAGE\\20241220\\1_00535523__INTERVAL_CAPTURE.JPG \n \n20/12/2024 00:55:55 -\u003e Transaction start \n20/12/2024 00:55:55 TRACK 2 DATA: 601301XXXXXX0133 \n20/12/2024 00:55:55 CAMERA1 D:\\IMAGE\\20241220\\1_00555501__START.JPG \n20/12/2024 00:55:55 CAMERA1 D:\\IMAGE\\20241220\\1_00555521_601301XXXXXX0133_CARD.JPG \n20/12/2024 00:55:56 EMV CANDIDATES: 1 \n20/12/2024 00:55:58 EMV AID A0000006021010 / 601301XXXXXX0133 STARTED \n20/12/2024 00:56:04 PIN ENTERED \n20/12/2024 00:56:04 CAMERA1 D:\\IMAGE\\20241220\\1_00560476_601301XXXXXX0133_PIN.JPG \n20/12/2024 00:56:09 ***** Tran Request State ***** \n20/12/2024 00:56:09 TRANSACTION REQUEST AF \n20/12/2024 00:56:09 Transaction reply next 523 function 5157 \n20/12/2024 00:56:10 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 00:33:40 \nATM ID : 190015 NO.REF: 201 \nCARD : 601301XXXXXX0133 \nREK : 465501017443539 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:56:10 ***** Tran Request State ***** \n20/12/2024 00:56:10 ***** Accept Cash State ***** \n20/12/2024 00:56:10 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:56:10 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:10 Device PROBLEM \n20/12/2024 00:56:10 CAMERA2 D:\\IMAGE\\20241220\\2_00561061_601301XXXXXX0133_CASH_OTHERS.JPG \n20/12/2024 00:56:10 Cassette PROBLEM \n20/12/2024 00:56:11 ***** Accept Cash State ***** \n20/12/2024 00:56:11 ***** Close Tran State *****\n20/12/2024 00:56:11 ***** Close Tran State ***** \n20/12/2024 00:56:16 CARD(601301XXXXXX0133) TAKEN \n20/12/2024 00:56:17 \u003c- Transaction end \n \n20/12/2024 00:56:17 CAMERA1 D:\\IMAGE\\20241220\\1_00561738_601301XXXXXX0133_END.JPG \n20/12/2024 00:56:17 Card State: (1001;00000;00;--------) \n20/12/2024 00:56:17 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:17 Device PROBLEM \n20/12/2024 00:56:17 CAMERA2 D:\\IMAGE\\20241220\\2_00561770__CASH_OTHERS.JPG \n20/12/2024 00:56:17 Cassette PROBLEM \n20/12/2024 00:56:18 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:56:18 CONFIG-ID : 2002 \n \n20/12/2024 00:56:20 -\u003e Transaction start \n20/12/2024 00:56:20 TRACK 2 DATA: 601301XXXXXX0133 \n20/12/2024 00:56:20 CAMERA1 D:\\IMAGE\\20241220\\1_00562007__START.JPG \n20/12/2024 00:56:20 CAMERA1 D:\\IMAGE\\20241220\\1_00562032_601301XXXXXX0133_CARD.JPG \n20/12/2024 00:56:21 EMV CANDIDATES: 1 \n20/12/2024 00:56:23 EMV AID A0000006021010 / 601301XXXXXX0133 STARTED \n20/12/2024 00:56:36 PIN ENTERED \n20/12/2024 00:56:36 CAMERA1 D:\\IMAGE\\20241220\\1_00563650_601301XXXXXX0133_PIN.JPG \n20/12/2024 00:56:39 ***** Tran Request State ***** \n20/12/2024 00:56:40 TRANSACTION REQUEST AF \n20/12/2024 00:56:40 Transaction reply next 523 function 5157 \n20/12/2024 00:56:40 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 00:34:10 \nATM ID : 190015 NO.REF: 202 \nCARD : 601301XXXXXX0133 \nREK : 465501017443539 \nKODETX : 120 CRM \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : W0 INQUIRY KE 1 OK \n20/12/2024 00:56:40 ***** Tran Request State ***** \n20/12/2024 00:56:40 ***** Accept Cash State ***** \n20/12/2024 00:56:41 $MOD$ 220126_1014 BriCRMTa.DLL \n20/12/2024 00:56:41 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:41 Device PROBLEM \n20/12/2024 00:56:41 CAMERA2 D:\\IMAGE\\20241220\\2_00564118_601301XXXXXX0133_CASH_OTHERS.JPG \n20/12/2024 00:56:41 Cassette PROBLEM \n20/12/2024 00:56:41 ***** Accept Cash State ***** \n20/12/2024 00:56:41 ***** Close Tran State ***** \n20/12/2024 00:56:41 ***** Close Tran State ***** \n20/12/2024 00:56:46 CARD(601301XXXXXX0133) TAKEN \n20/12/2024 00:56:47 \u003c- Transaction end \n \n20/12/2024 00:56:47 CAMERA1 D:\\IMAGE\\20241220\\1_00564792_601301XXXXXX0133_END.JPG \n20/12/2024 00:56:48 Card State: (1001;00000;00;--------) \n20/12/2024 00:56:48 ----- Clear Cash-In Device ---- \n20/12/2024 00:56:48 Device PROBLEM \n20/12/2024 00:56:48 CAMERA2 D:\\IMAGE\\20241220\\2_00564826__CASH_OTHERS.JPG \n20/12/2024 00:56:48 Cassette PROBLEM\n20/12/2024 00:56:48 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 00:56:48 CONFIG-ID : 2002\n20/12/2024 01:01:48 CAMERA1 D:\\IMAGE\\20241220\\1_01014812__INTERVAL_CAPTURE.JPG \n20/12/2024 01:06:48 CAMERA1 D:\\IMAGE\\20241220\\1_01064835__INTERVAL_CAPTURE.JPG \n20/12/2024 01:11:48 CAMERA1 D:\\IMAGE\\20241220\\1_01114859__INTERVAL_CAPTURE.JPG \n20/12/2024 01:16:48 CAMERA1 D:\\IMAGE\\20241220\\1_01164881__INTERVAL_CAPTURE.JPG \n20/12/2024 01:21:49 CAMERA1 D:\\IMAGE\\20241220\\1_01214905__INTERVAL_CAPTURE.JPG \n20/12/2024 01:26:49 CAMERA1 D:\\IMAGE\\20241220\\1_01264917__INTERVAL_CAPTURE.JPG \n20/12/2024 01:31:49 CAMERA1 D:\\IMAGE\\20241220\\1_01314933__INTERVAL_CAPTURE.JPG \n20/12/2024 01:36:49 CAMERA1 D:\\IMAGE\\20241220\\1_01364944__INTERVAL_CAPTURE.JPG \n20/12/2024 01:41:49 CAMERA1 D:\\IMAGE\\20241220\\1_01414958__INTERVAL_CAPTURE.JPG \n20/12/2024 01:46:49 CAMERA1 D:\\IMAGE\\20241220\\1_01464975__INTERVAL_CAPTURE.JPG \n20/12/2024 01:51:50 CAMERA1 D:\\IMAGE\\20241220\\1_01514998__INTERVAL_CAPTURE.JPG \n20/12/2024 01:56:50 CAMERA1 D:\\IMAGE\\20241220\\1_01565017__INTERVAL_CAPTURE.JPG \n20/12/2024 02:01:50 CAMERA1 D:\\IMAGE\\20241220\\1_02015045__INTERVAL_CAPTURE.JPG \n20/12/2024 02:06:50 CAMERA1 D:\\IMAGE\\20241220\\1_02065066__INTERVAL_CAPTURE.JPG \n20/12/2024 02:11:50 CAMERA1 D:\\IMAGE\\20241220\\1_02115078__INTERVAL_CAPTURE.JPG \n20/12/2024 02:16:51 CAMERA1 D:\\IMAGE\\20241220\\1_02165091__INTERVAL_CAPTURE.JPG \n20/12/2024 02:21:51 CAMERA1 D:\\IMAGE\\20241220\\1_02215111__INTERVAL_CAPTURE.JPG \n \n20/12/2024 02:24:15 -\u003e Transaction start \n20/12/2024 02:24:15 CAMERA1 D:\\IMAGE\\20241220\\1_02241517__START.JPG \n20/12/2024 02:24:34 INFORMATION 100777 ENTERED\n20/12/2024 02:24:41 INFORMATION 081250261150 ENTERED \n20/12/2024 02:24:41 ***** Tran Request State ***** \n20/12/2024 02:24:41 EDM ERROR, CHECK KEYS \n20/12/2024 02:24:41 DEVICE CCEppFW/PIN30 EFC CODE: EV8 0 00 00 \n20/12/2024 02:24:41 TRANSACTION REQUEST A I \n20/12/2024 02:24:42 Transaction reply next 016 function 2024 \n20/12/2024 02:24:42 TRANSACTION 0003 FAILED \n20/12/2024 02:24:42 CDM ERROR: 00006434 0000004C 00000000 LYNX TRX: Shutter closed but cash tray not empty, dispense operation declined \n20/12/2024 02:24:42 DEVICE CCCdmFW STATUS 4 SUPPLY 1 \n20/12/2024 02:24:42 Transaction reply next 015 function 3105 \nTANGGAL: 20/12/24 WAKTU : 02:02:12 \nATM ID : 190015 NO.REF: 203 \nCARD : 6013500000000000 \nREK : 081250261150 \nKODETX : 141 Cardless Default Error Re \nAMOUNT : RP 1,000,000 \nSALDO : \nRESPON : %5 DISPENSE FAIL \nSWITCHING : BRIMO \n20/12/2024 02:24:43 ***** Tran Request State ***** \n20/12/2024 02:24:43 ***** Close Tran State ***** \n20/12/2024 02:24:43 ***** Close Tran State ***** \n20/12/2024 02:24:50 \u003c- Transaction end \n \n20/12/2024 02:24:50 CAMERA1 D:\\IMAGE\\20241220\\1_02245001__END.JPG \n20/12/2024 02:24:50 Card State: (4101;00000;00;--------) \n20/12/2024 02:24:50 ----- Clear Cash-In Device ---- \n20/12/2024 02:24:50 Device PROBLEM \n20/12/2024 02:24:50 CAMERA2 D:\\IMAGE\\20241220\\2_02245034__CASH_OTHERS.JPG \n20/12/2024 02:24:50 Cassette PROBLEM \n20/12/2024 02:24:50 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 02:24:50 CONFIG-ID : 2002 \n \n20/12/2024 02:25:08 -\u003e Transaction start \n20/12/2024 02:25:08 CAMERA1 D:\\IMAGE\\20241220\\1_02250838__START.JPG \n20/12/2024 02:25:12 GO OUT OF SERVICE COMMAND \n20/12/2024 02:25:28 INFORMATION 054218 ENTERED \n20/12/2024 02:25:35 INFORMATION 081250261150 ENTERED \n20/12/2024 02:25:35 ***** Tran Request State ***** \n20/12/2024 02:25:35 EDM ERROR, CHECK KEYS \n20/12/2024 02:25:35 DEVICE CCEppFW/PIN30 EFC CODE: EV8 0 00 00 \n20/12/2024 02:25:35 TRANSACTION REQUEST A I \n20/12/2024 02:25:35 Transaction reply next 015 function 3105 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 203| \nCARD : 6013500000000000 \nREK : \nKODETX : 909 CARDLESS \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 02:25:36 ***** Tran Request State ***** \n20/12/2024 02:25:36 ***** Close Tran State ***** \n20/12/2024 02:25:36 ***** Close Tran State *****\n20/12/2024 02:25:42 \u003c- Transaction end \n \n20/12/2024 02:25:42 CAMERA1 D:\\IMAGE\\20241220\\1_02254286__END.JPG \n20/12/2024 02:25:43 Card State: (4101;00000;00;--------) \n20/12/2024 02:25:43 ----- Clear Cash-In Device ---- \n20/12/2024 02:25:43 CAMERA2 D:\\IMAGE\\20241220\\2_02254339__CASH_OTHERS.JPG \n20/12/2024 02:25:43 Device PROBLEM \n20/12/2024 02:25:43 Cassette PROBLEM \n20/12/2024 02:25:43 GO IN SERVICE COMMAND \n20/12/2024 02:25:45 ----- Clear Cash-In Device ---- \n20/12/2024 02:25:45 CAMERA2 D:\\IMAGE\\20241220\\2_02254573__CASH_OTHERS.JPG \n20/12/2024 02:25:45 Device PROBLEM \n20/12/2024 02:25:45 Cassette PROBLEM \n20/12/2024 02:25:46 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 02:25:46 CONFIG-ID : 2002\n20/12/2024 02:30:43 CAMERA1 D:\\IMAGE\\20241220\\1_02304308__INTERVAL_CAPTURE.JPG \n20/12/2024 02:35:43 CAMERA1 D:\\IMAGE\\20241220\\1_02354343__INTERVAL_CAPTURE.JPG \n20/12/2024 02:40:43 CAMERA1 D:\\IMAGE\\20241220\\1_02404363__INTERVAL_CAPTURE.JPG \n20/12/2024 02:45:43 CAMERA1 D:\\IMAGE\\20241220\\1_02454378__INTERVAL_CAPTURE.JPG \n20/12/2024 02:50:44 CAMERA1 D:\\IMAGE\\20241220\\1_02504404__INTERVAL_CAPTURE.JPG \n20/12/2024 02:55:44 CAMERA1 D:\\IMAGE\\20241220\\1_02554429__INTERVAL_CAPTURE.JPG \n20/12/2024 03:00:44 CAMERA1 D:\\IMAGE\\20241220\\1_03004460__INTERVAL_CAPTURE.JPG \n20/12/2024 03:05:44 CAMERA1 D:\\IMAGE\\20241220\\1_03054480__INTERVAL_CAPTURE.JPG \n20/12/2024 03:10:45 CAMERA1 D:\\IMAGE\\20241220\\1_03104492__INTERVAL_CAPTURE.JPG \n20/12/2024 03:15:45 CAMERA1 D:\\IMAGE\\20241220\\1_03154513__INTERVAL_CAPTURE.JPG \n20/12/2024 03:20:45 CAMERA1 D:\\IMAGE\\20241220\\1_03204541__INTERVAL_CAPTURE.JPG \n20/12/2024 03:25:45 CAMERA1 D:\\IMAGE\\20241220\\1_03254552__INTERVAL_CAPTURE.JPG \n20/12/2024 03:30:45 CAMERA1 D:\\IMAGE\\20241220\\1_03304582__INTERVAL_CAPTURE.JPG \n20/12/2024 03:35:46 CAMERA1 D:\\IMAGE\\20241220\\1_03354598__INTERVAL_CAPTURE.JPG \n20/12/2024 03:40:46 CAMERA1 D:\\IMAGE\\20241220\\1_03404631__INTERVAL_CAPTURE.JPG \n20/12/2024 03:45:46 CAMERA1 D:\\IMAGE\\20241220\\1_03454660__INTERVAL_CAPTURE.JPG \n20/12/2024 03:50:46 CAMERA1 D:\\IMAGE\\20241220\\1_03504677__INTERVAL_CAPTURE.JPG \n20/12/2024 03:55:47 CAMERA1 D:\\IMAGE\\20241220\\1_03554707__INTERVAL_CAPTURE.JPG \n20/12/2024 04:00:47 CAMERA1 D:\\IMAGE\\20241220\\1_04004739__INTERVAL_CAPTURE.JPG \n20/12/2024 04:05:47 CAMERA1 D:\\IMAGE\\20241220\\1_04054773__INTERVAL_CAPTURE.JPG \n20/12/2024 04:10:48 CAMERA1 D:\\IMAGE\\20241220\\1_04104804__INTERVAL_CAPTURE.JPG \n20/12/2024 04:15:48 CAMERA1 D:\\IMAGE\\20241220\\1_04154835__INTERVAL_CAPTURE.JPG \n20/12/2024 04:20:48 CAMERA1 D:\\IMAGE\\20241220\\1_04204848__INTERVAL_CAPTURE.JPG \n20/12/2024 04:20:51 GO IN SERVICE COMMAND\n20/12/2024 04:25:48 CAMERA1 D:\\IMAGE\\20241220\\1_04254884__INTERVAL_CAPTURE.JPG \n20/12/2024 04:30:49 CAMERA1 D:\\IMAGE\\20241220\\1_04304914__INTERVAL_CAPTURE.JPG \n20/12/2024 04:35:49 CAMERA1 D:\\IMAGE\\20241220\\1_04354938__INTERVAL_CAPTURE.JPG \n20/12/2024 04:40:49 CAMERA1 D:\\IMAGE\\20241220\\1_04404967__INTERVAL_CAPTURE.JPG \n20/12/2024 04:45:50 CAMERA1 D:\\IMAGE\\20241220\\1_04455001__INTERVAL_CAPTURE.JPG \n \n20/12/2024 04:48:51 -\u003e Transaction start \n20/12/2024 04:48:51 TRACK 2 DATA: 601301XXXXXX4613 \n20/12/2024 04:48:52 CAMERA1 D:\\IMAGE\\20241220\\1_04485196__START.JPG \n20/12/2024 04:48:52 CAMERA1 D:\\IMAGE\\20241220\\1_04485224_601301XXXXXX4613_CARD.JPG \n20/12/2024 04:48:54 EMV CANDIDATES: 1 \n20/12/2024 04:48:57 EMV AID A0000006021010 / 601301XXXXXX4613 STARTED \n20/12/2024 04:49:13 PIN ENTERED \n20/12/2024 04:49:13 CAMERA1 D:\\IMAGE\\20241220\\1_04491305_601301XXXXXX4613_PIN.JPG \n20/12/2024 04:49:25 AMOUNT 5 ENTERED \n20/12/2024 04:49:27 AMOUNT ENTERED \n20/12/2024 04:49:31 AMOUNT ENTERED \n20/12/2024 04:49:39 AMOUNT 50000 ENTERED\n20/12/2024 04:49:46 ***** Tran Request State ***** \n20/12/2024 04:49:47 TRANSACTION REQUEST A BBC \n20/12/2024 04:49:47 Transaction reply next 009 function 5102 \n20/12/2024 04:49:47 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 04:49:48 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 203 \nCARD : 601301XXXXXX4613 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 04:49:48 ***** Tran Request State ***** \n20/12/2024 04:49:52 ***** Close Tran State ***** \n20/12/2024 04:49:52 ***** Close Tran State ***** \n20/12/2024 04:49:54 CARD(601301XXXXXX4613) TAKEN \n20/12/2024 04:49:58 \u003c- Transaction end \n \n20/12/2024 04:49:58 CAMERA1 D:\\IMAGE\\20241220\\1_04495878_601301XXXXXX4613_END.JPG \n20/12/2024 04:49:58 Card State: (1001;00000;00;--------) \n20/12/2024 04:49:59 ----- Clear Cash-In Device ---- \n20/12/2024 04:49:59 CAMERA2 D:\\IMAGE\\20241220\\2_04495911__CASH_OTHERS.JPG \n20/12/2024 04:49:59 Device PROBLEM \n20/12/2024 04:49:59 Cassette PROBLEM \n20/12/2024 04:49:59 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 04:49:59 CONFIG-ID : 2002 \n \n20/12/2024 04:50:15 -\u003e Transaction start \n20/12/2024 04:50:15 TRACK 2 DATA: 601301XXXXXX4613\n20/12/2024 04:50:15 CAMERA1 D:\\IMAGE\\20241220\\1_04501546__START.JPG \n20/12/2024 04:50:15 CAMERA1 D:\\IMAGE\\20241220\\1_04501577_601301XXXXXX4613_CARD.JPG \n20/12/2024 04:50:18 EMV CANDIDATES: 1 \n20/12/2024 04:50:20 EMV AID A0000006021010 / 601301XXXXXX4613 STARTED \n20/12/2024 04:50:26 PIN ENTERED \n20/12/2024 04:50:27 CAMERA1 D:\\IMAGE\\20241220\\1_04502695_601301XXXXXX4613_PIN.JPG \n20/12/2024 04:50:43 AMOUNT 50000 ENTERED \n20/12/2024 04:50:51 ***** Tran Request State ***** \n20/12/2024 04:50:51 TRANSACTION REQUEST A BBC \n20/12/2024 04:50:51 Transaction reply next 009 function 5102 \n20/12/2024 04:50:51 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 04:50:52 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 203 \nCARD : 601301XXXXXX4613 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 04:50:52 ***** Tran Request State ***** \n20/12/2024 04:50:59 ***** Close Tran State ***** \n20/12/2024 04:50:59 ***** Close Tran State ***** \n20/12/2024 04:51:03 CARD(601301XXXXXX4613) TAKEN \n20/12/2024 04:51:05 \u003c- Transaction end \n \n20/12/2024 04:51:05 CAMERA1 D:\\IMAGE\\20241220\\1_04510563_601301XXXXXX4613_END.JPG \n20/12/2024 04:51:05 Card State: (1001;00000;00;--------) \n20/12/2024 04:51:05 ----- Clear Cash-In Device ---- \n20/12/2024 04:51:06 Device PROBLEM \n20/12/2024 04:51:06 CAMERA2 D:\\IMAGE\\20241220\\2_04510596__CASH_OTHERS.JPG \n20/12/2024 04:51:06 Cassette PROBLEM \n20/12/2024 04:51:06 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 04:51:06 CONFIG-ID : 2002\n20/12/2024 04:56:05 CAMERA1 D:\\IMAGE\\20241220\\1_04560580__INTERVAL_CAPTURE.JPG \n20/12/2024 05:01:06 CAMERA1 D:\\IMAGE\\20241220\\1_05010597__INTERVAL_CAPTURE.JPG \n \n20/12/2024 05:04:20 -\u003e Transaction start \n20/12/2024 05:04:20 TRACK 2 DATA: 601301XXXXXX6016 \n20/12/2024 05:04:20 CAMERA1 D:\\IMAGE\\20241220\\1_05042025__START.JPG \n20/12/2024 05:04:20 CAMERA1 D:\\IMAGE\\20241220\\1_05042036_601301XXXXXX6016_CARD.JPG \n20/12/2024 05:04:23 EMV CANDIDATES: 1 \n20/12/2024 05:04:25 EMV AID A0000006021010 / 601301XXXXXX6016 STARTED \n20/12/2024 05:04:30 PIN ENTERED \n20/12/2024 05:04:30 CAMERA1 D:\\IMAGE\\20241220\\1_05043033_601301XXXXXX6016_PIN.JPG \n20/12/2024 05:04:34 ***** Tran Request State ***** \n20/12/2024 05:04:34 TRANSACTION REQUEST A BB \n20/12/2024 05:04:35 Transaction reply next 264 function 5108 \n20/12/2024 05:04:36 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 04:42:05 \nATM ID : 190015 NO.REF: 204 \nCARD : 601301XXXXXX6016 \nREK : 356701020330535 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 415,250 \nRESPON : 00 Sukses \n20/12/2024 05:04:36 ***** Tran Request State *****\n20/12/2024 05:04:43 EMV AID A0000006021010 / 601301XXXXXX6016 STARTED \n20/12/2024 05:04:47 PIN ENTERED \n20/12/2024 05:04:47 CAMERA1 D:\\IMAGE\\20241220\\1_05044705_601301XXXXXX6016_PIN.JPG \n20/12/2024 05:04:58 AMOUNT 350000 ENTERED \n20/12/2024 05:05:01 ***** Tran Request State ***** \n20/12/2024 05:05:02 TRANSACTION REQUEST A BBC \n20/12/2024 05:05:02 Transaction reply next 009 function 5102 \n20/12/2024 05:05:02 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:05:03 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 204 \nCARD : 601301XXXXXX6016 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:05:03 ***** Tran Request State ***** \n20/12/2024 05:05:09 EMV AID A0000006021010 / 601301XXXXXX6016 STARTED \n20/12/2024 05:05:13 PIN ENTERED \n20/12/2024 05:05:13 CAMERA1 D:\\IMAGE\\20241220\\1_05051365_601301XXXXXX6016_PIN.JPG \n20/12/2024 05:05:17 ***** Tran Request State ***** \n20/12/2024 05:05:18 TRANSACTION REQUEST A B \n20/12/2024 05:05:18 Transaction reply next 009 function 5102 \n20/12/2024 05:05:18 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:05:18 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 204 \nCARD : 601301XXXXXX6016 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:05:18 ***** Tran Request State ***** \n20/12/2024 05:05:24 ***** Close Tran State ***** \n20/12/2024 05:05:24 ***** Close Tran State ***** \n20/12/2024 05:05:25 CARD(601301XXXXXX6016) TAKEN \n20/12/2024 05:05:30 \u003c- Transaction end \n \n20/12/2024 05:05:30 Card State: (1001;00000;00;--------) \n20/12/2024 05:05:30 CAMERA1 D:\\IMAGE\\20241220\\1_05053042_601301XXXXXX6016_END.JPG \n20/12/2024 05:05:30 ----- Clear Cash-In Device ---- \n20/12/2024 05:05:30 CAMERA2 D:\\IMAGE\\20241220\\2_05053076__CASH_OTHERS.JPG \n20/12/2024 05:05:30 Device PROBLEM \n20/12/2024 05:05:30 Cassette PROBLEM \n20/12/2024 05:05:31 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:05:31 CONFIG-ID : 2002\n \n20/12/2024 05:07:05 -\u003e Transaction start \n20/12/2024 05:07:05 TRACK 2 DATA: 522184XXXXXX4426 \n20/12/2024 05:07:06 CAMERA1 D:\\IMAGE\\20241220\\1_05070594__START.JPG \n20/12/2024 05:07:06 CAMERA1 D:\\IMAGE\\20241220\\1_05070610_522184XXXXXX4426_CARD.JPG \n20/12/2024 05:07:07 EMV CANDIDATES: 2 \n20/12/2024 05:07:09 EMV AID A0000006021010 / 522184XXXXXX4426 STARTED \n20/12/2024 05:07:15 PIN ENTERED \n20/12/2024 05:07:15 CAMERA1 D:\\IMAGE\\20241220\\1_05071577_522184XXXXXX4426_PIN.JPG \n20/12/2024 05:07:26 AMOUNT 2500000 ENTERED \n20/12/2024 05:07:31 ***** Tran Request State ***** \n20/12/2024 05:07:32 TRANSACTION REQUEST A BCC \n20/12/2024 05:07:32 Transaction reply next 009 function 5102 \n20/12/2024 05:07:32 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:07:32 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 204 \nCARD : 522184XXXXXX4426 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:07:32 ***** Tran Request State *****\n20/12/2024 05:07:52 EMV AID A0000006021010 / 522184XXXXXX4426 STARTED \n20/12/2024 05:07:59 PIN ENTERED \n20/12/2024 05:07:59 CAMERA1 D:\\IMAGE\\20241220\\1_05075906_522184XXXXXX4426_PIN.JPG \n20/12/2024 05:08:08 ***** Tran Request State ***** \n20/12/2024 05:08:08 TRANSACTION REQUEST A BB \n20/12/2024 05:08:09 Transaction reply next 264 function 5108 \n20/12/2024 05:08:09 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 04:45:39 \nATM ID : 190015 NO.REF: 205 \nCARD : 522184XXXXXX4426 \nREK : 059001010592503 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 367,554,304 \nRESPON : 00 Sukses \n20/12/2024 05:08:09 ***** Tran Request State ***** \n20/12/2024 05:08:17 EMV AID A0000006021010 / 522184XXXXXX4426 STARTED \n20/12/2024 05:08:24 PIN ENTERED \n20/12/2024 05:08:25 CAMERA1 D:\\IMAGE\\20241220\\1_05082483_522184XXXXXX4426_PIN.JPG \n20/12/2024 05:08:34 AMOUNT 2500000 ENTERED\n20/12/2024 05:08:44 ***** Tran Request State ***** \n20/12/2024 05:08:44 TRANSACTION REQUEST A BCD \n20/12/2024 05:08:44 Transaction reply next 009 function 5102 \n20/12/2024 05:08:44 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:08:45 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : \nATM ID : 190015 NO.REF: 205 \nCARD : 522184XXXXXX4426 \nREK : \nKODETX : 0 Default Error Response \nAMOUNT : \nSALDO : \nRESPON : %3 CASH EMPTY \nSWITCHING : UNDEFINED \n20/12/2024 05:08:45 ***** Tran Request State ***** \n20/12/2024 05:08:52 ***** Close Tran State ***** \n20/12/2024 05:08:52 ***** Close Tran State ***** \n20/12/2024 05:08:54 CARD(522184XXXXXX4426) TAKEN \n20/12/2024 05:08:58 \u003c- Transaction end \n \n20/12/2024 05:08:58 Card State: (1001;00000;00;--------) \n20/12/2024 05:08:58 CAMERA1 D:\\IMAGE\\20241220\\1_05085832_522184XXXXXX4426_END.JPG \n20/12/2024 05:08:58 ----- Clear Cash-In Device ---- \n20/12/2024 05:08:58 Device PROBLEM \n20/12/2024 05:08:58 CAMERA2 D:\\IMAGE\\20241220\\2_05085865__CASH_OTHERS.JPG \n20/12/2024 05:08:58 Cassette PROBLEM \n20/12/2024 05:08:58 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:08:59 CONFIG-ID : 2002\n20/12/2024 05:13:58 CAMERA1 D:\\IMAGE\\20241220\\1_05135865__INTERVAL_CAPTURE.JPG \n20/12/2024 05:17:47 OPERATOR DOOR OPENED \n20/12/2024 05:17:48 SERVICEMODE ENTERED \n20/12/2024 05:17:48 CAMERA1 D:\\IMAGE\\20241220\\1_05174833__SOP.JPG \n20/12/2024 05:17:48 ----- Clear Cash-In Device ---- \n20/12/2024 05:17:48 CAMERA2 D:\\IMAGE\\20241220\\2_05174878__CASH_OTHERS.JPG \n20/12/2024 05:17:48 Device PROBLEM \n20/12/2024 05:17:49 Cassette PROBLEM \n20/12/2024 05:18:00 SAFE DOOR OPENED\n \n \nATM ID : 190015 \nDate/Time : 12/20/24 05:18 \n \n CUR DENO INIT DISP DEP CST RJ \n1RCY IDR 100K 2000 2079 0961 0671 0211 \n2RCY IDR 100K 2000 0000 0000 2000 0000 \n3RCY IDR 50K 2000 1243 0000 0698 0059 \n4RCY IDR 50K 0000 0000 0240 0240 0000 \n5DPC --- ---- ---- ---- 0001 ---- 0000 \n \nINIT AMOUNT: 500000000 IDR \nDISP AMOUNT: 270050000 IDR \nDEP AMOUNT: 108150000 IDR \nCST AMOUNT: 314000000 IDR \n \nNO DENOM REM+ ALLIN = TOTAL \n01 IDR 100000 2882 0000 2882 \n02 IDR 50000 0997 0001 0998 \n03 IDR 20000 0000 0000 0000 \n \nRETRACT COUNT : 0002 \nRETAIN UNKNOWN NOTES (RET) : 0003 \n \nBILL COUNT LAST CLEARED : \n12/18/24 16:30 \n \nCARDS CAPTURED : 00000 \nCARDS CAPTURED LAST CLEARED : \n09/24/21 14:35\n \n20/12/2024 05:18:59 CAMERA1 D:\\IMAGE\\20241220\\1_05185898__INTERVAL_CAPTURE.JPG \n CARDS CAPTURED 00000 \n LAST CLEARED: 12/20/24 05:22 \n \n ACTIVITY COUNT - 00006755\n20/12/2024 05:23:59 CAMERA1 D:\\IMAGE\\20241220\\1_05235920__INTERVAL_CAPTURE.JPG \n \n12/20/24 05:24:00 \nCUSTOMER MONEY CLEARED \nCURRENCY DENOM COUNT \nIDR 100000 3 \n20/12/2024 05:25:12 29 OF 30 ITEM INFOS DELIVERED INCOMPLETE, FILLED WITH DEFAULT SERIAL NUMBER \n20/12/2024 05:25:12 SERIAL NUMBERS SUCCESSFULLY STORED FOR 0 GENUINE NOTES \n20/12/2024 05:25:12 0 S/N: 9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999,9999999999 \n20/12/2024 05:25:12 IDR 100000 S/N: BGP644173 \n \nCUSTOMER MONEY MOVED TO RETRACT \nCURRENCY DENOM COUNT \nIDR 50000 1 \nIDR 100000 29 \n \n12/20/24 05:25:00 \nCUSTOMER MONEY CLEARED \nCURRENCY DENOM COUNT \nIDR 50000 1 \nIDR 100000 29 \n05:25:29 RETRACT CLEARED RETRACTS : 2, NOTES : 3\n20/12/2024 05:26:17 SAFE DOOR CLOSED \n20/12/2024 05:26:18 OPERATOR DOOR CLOSED \n20/12/2024 05:26:18 SERVICEMODE LEFT \n20/12/2024 05:26:18 GO OUT OF SERVICE COMMAND \n20/12/2024 05:26:18 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:19 Application LOCKED \n20/12/2024 05:26:19 DEVICE CCCdmFW STATUS 0 SUPPLY 1 \n20/12/2024 05:26:19 DEVICE CCCashInFW STATUS 0 SUPPLY 1 \n20/12/2024 05:26:19 GO IN SERVICE COMMAND \n20/12/2024 05:26:19 CAMERA1 D:\\IMAGE\\20241220\\1_05261932__PIN.JPG \n20/12/2024 05:26:20 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:21 Application LOCKED \n20/12/2024 05:26:21 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:26:21 CONFIG-ID : 2002 \n20/12/2024 05:26:26 SAFE DOOR OPENED \n20/12/2024 05:26:27 SERVICEMODE ENTERED \n20/12/2024 05:26:28 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:28 Device PROBLEM \n20/12/2024 05:26:28 Application LOCKED\n20/12/2024 05:26:47 SAFE DOOR CLOSED \n20/12/2024 05:26:47 SERVICEMODE LEFT \n20/12/2024 05:26:49 ----- Clear Cash-In Device ---- \n20/12/2024 05:26:49 Application LOCKED \n20/12/2024 05:26:49 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:26:49 CONFIG-ID : 2002 \n \n20/12/2024 05:26:52 -\u003e Transaction start \n20/12/2024 05:26:52 TRACK 2 DATA: 522184XXXXXX8610 \n20/12/2024 05:26:52 CAMERA1 D:\\IMAGE\\20241220\\1_05265222__END.JPG \n20/12/2024 05:26:52 CAMERA2 D:\\IMAGE\\20241220\\2_05265250_522184XXXXXX8610_CASH_OTHERS.JPG \n20/12/2024 05:26:54 EMV CANDIDATES: 2 \n20/12/2024 05:26:56 EMV AID A0000006021010 / 522184XXXXXX8610 STARTED \n20/12/2024 05:27:01 PIN ENTERED \n20/12/2024 05:27:09 AMOUNT 100000 ENTERED \n20/12/2024 05:27:12 ***** Tran Request State ***** \n20/12/2024 05:27:13 TRANSACTION REQUEST A BCC \n20/12/2024 05:27:13 Transaction reply next 084 function 2110 \n20/12/2024 05:27:14 TVR: 8000040000, TSI: 7000 \n20/12/2024 05:27:14 CAMERA1 D:\\IMAGE\\20241220\\1_05271438_522184XXXXXX8610_SOP.JPG \n20/12/2024 05:27:14 CAMERA2 D:\\IMAGE\\20241220\\2_05271461_522184XXXXXX8610_CASH_OTHERS.JPG \n20/12/2024 05:27:20 SERIAL NUMBERS SUCCESSFULLY STORED FOR 1 GENUINE NOTES \n20/12/2024 05:27:20 IDR 100000 S/N: JOB667752 \n20/12/2024 05:27:20 CASH REQUEST: 01000000 \n05:27:20 CASH 1:1,1; \n20/12/2024 05:27:26 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:04:43 \nATM ID : 190015 NO.REF: 206 \nCARD : 522184XXXXXX8610 \nREK : 001701101186502 \nKODETX : 14 Entry amount int\nAMOUNT : RP 100.000 \nSALDO : RP 1.785.097 \nRESPON : SS Sukses \nSWITCHING : BRI DEBIT\n20/12/2024 05:27:49 GO OUT OF SERVICE COMMAND \n20/12/2024 05:27:51 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:27:55 CASH TAKEN \n20/12/2024 05:27:55 ***** Tran Request State ***** \n20/12/2024 05:28:00 ***** Close Tran State ***** \n20/12/2024 05:28:00 ***** Close Tran State ***** \n20/12/2024 05:28:01 CARD(522184XXXXXX8610) TAKEN \n20/12/2024 05:28:06 \u003c- Transaction end \n \n20/12/2024 05:28:06 Card State: (1001;00000;00;--------) \n20/12/2024 05:28:07 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:07 Application LOCKED \n20/12/2024 05:28:07 GO IN SERVICE COMMAND \n20/12/2024 05:28:09 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:09 Application LOCKED \n20/12/2024 05:28:09 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:28:09 CONFIG-ID : 2002 \n20/12/2024 05:28:12 OPERATOR DOOR OPENED \n20/12/2024 05:28:13 SERVICEMODE ENTERED \n20/12/2024 05:28:14 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:14 Application LOCKED \n20/12/2024 05:28:17 OPERATOR DOOR CLOSED \n20/12/2024 05:28:18 SERVICEMODE LEFT \n20/12/2024 05:28:19 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:19 Application LOCKED \n20/12/2024 05:28:19 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:28:20 CONFIG-ID : 2002 \n20/12/2024 05:28:32 OPERATOR DOOR OPENED \n20/12/2024 05:28:34 SERVICEMODE ENTERED \n20/12/2024 05:28:34 ----- Clear Cash-In Device ---- \n20/12/2024 05:28:35 Application LOCKED\n20/12/2024 05:34:47 1 IDR, 1000 0 \n20/12/2024 05:34:47 2 IDR, 2000 0 \n20/12/2024 05:34:47 3 IDR, 5000 0 \n20/12/2024 05:34:47 4 IDR, 10000 0 \n20/12/2024 05:34:47 5 IDR, 20000 0 \n20/12/2024 05:34:47 6 IDR, 50000 1 \n20/12/2024 05:34:47 7 IDR, 100000 1 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 1 6 30063 0 0 0 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 2 9 35718 IDR 100000 0 670 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 7 IDR 100000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 3 9 00015 IDR 100000 0 2000 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 7 IDR 100000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 4 9 28635 IDR 50000 0 698 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 6 IDR 50000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 5 9 18334 IDR 50000 0 240 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 6 IDR 50000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 6 10 32999 0 0 1 \n20/12/2024 05:34:47 NOTE TYPE: \n20/12/2024 05:34:47 1 IDR 1000 \n20/12/2024 05:34:47 2 IDR 2000 \n20/12/2024 05:34:47 3 IDR 5000\n20/12/2024 05:34:47 4 IDR 10000 \n20/12/2024 05:34:47 5 IDR 20000 \n20/12/2024 05:34:47 6 IDR 50000 \n20/12/2024 05:34:47 7 IDR 100000 \n20/12/2024 05:34:47 CASSETTE INFORMATION: \n20/12/2024 05:34:47 7 10 32999 0 0 0 \n20/12/2024 05:34:48 STARTUP LTS: 0006 1 00001 00000 00000 00000 \n20/12/2024 05:34:55 ----- Clear Cash-In Device ---- \n20/12/2024 05:35:02 CAMERA1 OPERATIONAL \n20/12/2024 05:35:02 COMMUNICATION ONLINE \n20/12/2024 05:35:03 GO OUT OF SERVICE COMMAND \n20/12/2024 05:35:03 CAMERA2 OPERATIONAL \n20/12/2024 05:35:03 ----- Clear Cash-In Device ---- \n20/12/2024 05:35:04 DEVICE CCCardFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCCdmFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCCashInFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCRecPrtFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCJourPrtFW STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCCamFW STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE LOG_CASS_1 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE LOG_CASS_2 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE LOG_CASS_3 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE LOG_CASS_4 STATUS 0 SUPPLY 1 \n20/12/2024 05:35:04 DEVICE CCDocPrtFW STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE ENVELOPE_DISPENSER STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE VOICE STATUS 0 SUPPLY 0 \n20/12/2024 05:35:04 DEVICE CCChequeFW STATUS 0 SUPPLY 0 \n20/12/2024 05:35:05 GO IN SERVICE COMMAND \n20/12/2024 05:35:06 ----- Clear Cash-In Device ---- \n20/12/2024 05:35:06 CAMERA2 D:\\IMAGE\\20241220\\2_05350648__CASH_OTHERS.JPG \n20/12/2024 05:35:07 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 05:35:07 CONFIG-ID : 2002 \n20/12/2024 05:40:03 CAMERA1 D:\\IMAGE\\20241220\\1_05400299__INTERVAL_CAPTURE.JPG \n \n20/12/2024 05:42:05 -\u003e Transaction start \n20/12/2024 05:42:05 TRACK 2 DATA: 601301XXXXXX7150 \n20/12/2024 05:42:05 CAMERA1 D:\\IMAGE\\20241220\\1_05420557__START.JPG \n20/12/2024 05:42:05 CAMERA1 D:\\IMAGE\\20241220\\1_05420586_601301XXXXXX7150_CARD.JPG \n20/12/2024 05:42:07 EMV CANDIDATES: 1 \n20/12/2024 05:42:08 EMV AID A0000006021010 / 601301XXXXXX7150 STARTED \n20/12/2024 05:42:19 PIN ENTERED \n20/12/2024 05:42:19 CAMERA1 D:\\IMAGE\\20241220\\1_05421900_601301XXXXXX7150_PIN.JPG \n20/12/2024 05:42:28 ***** Tran Request State ***** \n20/12/2024 05:42:28 TRANSACTION REQUEST A A \n20/12/2024 05:42:28 Transaction reply next 016 function A024 \n20/12/2024 05:42:28 TVR: 8000040000, TSI: 7000\n20/12/2024 05:42:47 SERIAL NUMBERS SUCCESSFULLY STORED FOR 13 GENUINE NOTES \n20/12/2024 05:42:47 IDR 50000 S/N: LNT102178,CSR756558,DHN462153,FNF769300,DHD665026,SHU715878 \n20/12/2024 05:42:47 IDR 100000 S/N: SNL545042,RCE274359,QCA878313,BEG718840,AEW160478,BBN305032,VBP996047 \n20/12/2024 05:42:47 CASH REQUEST: 07000600 \n05:42:47 CASH 1:1,7;3:3,6; \n20/12/2024 05:42:47 CAMERA2 D:\\IMAGE\\20241220\\2_05424706_601301XXXXXX7150_CASH_REQUEST.JPG \n20/12/2024 05:42:49 CARD(601301XXXXXX7150) TAKEN \n20/12/2024 05:42:53 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:19:57 \nATM ID : 190015 NO.REF: 207 \nCARD : 601301XXXXXX7150 \nREK : 465501017181535 \nKODETX : 3 FAST CASH NO RECEIPT \nAMOUNT : RP 1,000,000 \nSALDO : RP 544,794 \nRESPON : 00 Fash Cash \nSWITCHING : BRI DEBIT \n20/12/2024 05:42:53 CAMERA1 D:\\IMAGE\\20241220\\1_05425375_601301XXXXXX7150_CASH_PRESENT.JPG \n20/12/2024 05:42:53 CAMERA2 D:\\IMAGE\\20241220\\2_05425390_601301XXXXXX7150_CASH_PRESENT.JPG \n20/12/2024 05:42:54 CAMERA2 D:\\IMAGE\\20241220\\2_05425417_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:54 CAMERA1 D:\\IMAGE\\20241220\\1_05425440_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:54 CAMERA2 D:\\IMAGE\\20241220\\2_05425458_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA2 D:\\IMAGE\\20241220\\2_05425486_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA1 D:\\IMAGE\\20241220\\1_05425508_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA2 D:\\IMAGE\\20241220\\2_05425531_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA1 D:\\IMAGE\\20241220\\1_05425576_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:55 CAMERA2 D:\\IMAGE\\20241220\\2_05425576_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:56 CAMERA2 D:\\IMAGE\\20241220\\2_05425617_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:56 CAMERA1 D:\\IMAGE\\20241220\\1_05425644_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:56 CAMERA2 D:\\IMAGE\\20241220\\2_05425645_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA2 D:\\IMAGE\\20241220\\2_05425690_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA1 D:\\IMAGE\\20241220\\1_05425713_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA2 D:\\IMAGE\\20241220\\2_05425735_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA2 D:\\IMAGE\\20241220\\2_05425776_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:57 CAMERA1 D:\\IMAGE\\20241220\\1_05425781_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA2 D:\\IMAGE\\20241220\\2_05425799_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA2 D:\\IMAGE\\20241220\\2_05425826_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA1 D:\\IMAGE\\20241220\\1_05425849_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:58 CAMERA2 D:\\IMAGE\\20241220\\2_05425867_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:59 CAMERA2 D:\\IMAGE\\20241220\\2_05425895_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:59 CAMERA1 D:\\IMAGE\\20241220\\1_05425916_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:42:59 CAMERA2 D:\\IMAGE\\20241220\\2_05425939_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA2 D:\\IMAGE\\20241220\\2_05425986_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA1 D:\\IMAGE\\20241220\\1_05425985_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA2 D:\\IMAGE\\20241220\\2_05430029_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA1 D:\\IMAGE\\20241220\\1_05430065_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:00 CAMERA2 D:\\IMAGE\\20241220\\2_05430076_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:01 CAMERA2 D:\\IMAGE\\20241220\\2_05430121_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:01 CAMERA1 D:\\IMAGE\\20241220\\1_05430145_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:01 CAMERA2 D:\\IMAGE\\20241220\\2_05430166_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA2 D:\\IMAGE\\20241220\\2_05430207_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA1 D:\\IMAGE\\20241220\\1_05430213_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA2 D:\\IMAGE\\20241220\\2_05430230_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA2 D:\\IMAGE\\20241220\\2_05430257_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:02 CAMERA1 D:\\IMAGE\\20241220\\1_05430281_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA2 D:\\IMAGE\\20241220\\2_05430303_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA2 D:\\IMAGE\\20241220\\2_05430344_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA1 D:\\IMAGE\\20241220\\1_05430350_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:03 CAMERA2 D:\\IMAGE\\20241220\\2_05430371_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA2 D:\\IMAGE\\20241220\\2_05430411_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA1 D:\\IMAGE\\20241220\\1_05430417_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA2 D:\\IMAGE\\20241220\\2_05430434_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA2 D:\\IMAGE\\20241220\\2_05430458_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:04 CAMERA1 D:\\IMAGE\\20241220\\1_05430486_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430485_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430526_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430549_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA1 D:\\IMAGE\\20241220\\1_05430552_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:05 CAMERA2 D:\\IMAGE\\20241220\\2_05430578_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA2 D:\\IMAGE\\20241220\\2_05430617_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA1 D:\\IMAGE\\20241220\\1_05430622_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA2 D:\\IMAGE\\20241220\\2_05430641_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA2 D:\\IMAGE\\20241220\\2_05430668_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:06 CAMERA1 D:\\IMAGE\\20241220\\1_05430689_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:07 CAMERA2 D:\\IMAGE\\20241220\\2_05430709_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:07 CAMERA2 D:\\IMAGE\\20241220\\2_05430737_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:07 CAMERA1 D:\\IMAGE\\20241220\\1_05430757_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA2 D:\\IMAGE\\20241220\\2_05430783_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA1 D:\\IMAGE\\20241220\\1_05430825_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA2 D:\\IMAGE\\20241220\\2_05430828_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:08 CAMERA2 D:\\IMAGE\\20241220\\2_05430867_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA1 D:\\IMAGE\\20241220\\1_05430899_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA2 D:\\IMAGE\\20241220\\2_05430895_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA2 D:\\IMAGE\\20241220\\2_05430936_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA2 D:\\IMAGE\\20241220\\2_05430958_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:09 CAMERA1 D:\\IMAGE\\20241220\\1_05430962_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA2 D:\\IMAGE\\20241220\\2_05430987_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA2 D:\\IMAGE\\20241220\\2_05431025_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA1 D:\\IMAGE\\20241220\\1_05431044_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:10 CAMERA2 D:\\IMAGE\\20241220\\2_05431054_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA2 D:\\IMAGE\\20241220\\2_05431101_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA1 D:\\IMAGE\\20241220\\1_05431121_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA2 D:\\IMAGE\\20241220\\2_05431141_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA2 D:\\IMAGE\\20241220\\2_05431168_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:11 CAMERA1 D:\\IMAGE\\20241220\\1_05431189_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA2 D:\\IMAGE\\20241220\\2_05431210_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA2 D:\\IMAGE\\20241220\\2_05431237_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA1 D:\\IMAGE\\20241220\\1_05431257_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:12 CAMERA2 D:\\IMAGE\\20241220\\2_05431275_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA2 D:\\IMAGE\\20241220\\2_05431306_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA1 D:\\IMAGE\\20241220\\1_05431325_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA2 D:\\IMAGE\\20241220\\2_05431351_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:13 CAMERA2 D:\\IMAGE\\20241220\\2_05431392_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA1 D:\\IMAGE\\20241220\\1_05431393_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA2 D:\\IMAGE\\20241220\\2_05431420_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA2 D:\\IMAGE\\20241220\\2_05431461_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:14 CAMERA1 D:\\IMAGE\\20241220\\1_05431461_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431488_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA1 D:\\IMAGE\\20241220\\1_05431529_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431534_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431574_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:15 CAMERA2 D:\\IMAGE\\20241220\\2_05431597_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA1 D:\\IMAGE\\20241220\\1_05431598_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA2 D:\\IMAGE\\20241220\\2_05431625_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA1 D:\\IMAGE\\20241220\\1_05431665_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:16 CAMERA2 D:\\IMAGE\\20241220\\2_05431670_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA2 D:\\IMAGE\\20241220\\2_05431711_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA2 D:\\IMAGE\\20241220\\2_05431733_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA1 D:\\IMAGE\\20241220\\1_05431734_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:17 CAMERA2 D:\\IMAGE\\20241220\\2_05431761_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA1 D:\\IMAGE\\20241220\\1_05431802_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA2 D:\\IMAGE\\20241220\\2_05431806_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA2 D:\\IMAGE\\20241220\\2_05431847_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CAMERA1 D:\\IMAGE\\20241220\\1_05431870_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:18 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:43:18 CAMERA2 D:\\IMAGE\\20241220\\2_05431875_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA2 D:\\IMAGE\\20241220\\2_05431914_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA1 D:\\IMAGE\\20241220\\1_05431939_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA2 D:\\IMAGE\\20241220\\2_05431941_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:19 CAMERA2 D:\\IMAGE\\20241220\\2_05431983_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA1 D:\\IMAGE\\20241220\\1_05432006_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA2 D:\\IMAGE\\20241220\\2_05432011_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA2 D:\\IMAGE\\20241220\\2_05432050_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA2 D:\\IMAGE\\20241220\\2_05432074_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:20 CAMERA1 D:\\IMAGE\\20241220\\1_05432075_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:21 CAMERA2 D:\\IMAGE\\20241220\\2_05432101_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:21 CAMERA2 D:\\IMAGE\\20241220\\2_05432148_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:21 CAMERA1 D:\\IMAGE\\20241220\\1_05432143_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA2 D:\\IMAGE\\20241220\\2_05432194_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA1 D:\\IMAGE\\20241220\\1_05432229_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA2 D:\\IMAGE\\20241220\\2_05432239_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CASH TAKEN \n20/12/2024 05:43:22 CAMERA2 D:\\IMAGE\\20241220\\2_05432280_601301XXXXXX7150_INTERVAL_CAPTURE.JPG \n20/12/2024 05:43:22 CAMERA1 D:\\IMAGE\\20241220\\1_05432283_601301XXXXXX7150_CASH_TAKEN.JPG \n20/12/2024 05:43:23 CAMERA2 D:\\IMAGE\\20241220\\2_05432299_601301XXXXXX7150_CASH_TAKEN.JPG \n20/12/2024 05:43:23 ***** Tran Request State ***** \n20/12/2024 05:43:24 ***** Close Tran State ***** \n20/12/2024 05:43:24 ***** Close Tran State ***** \n20/12/2024 05:43:30 \u003c- Transaction end \n \n20/12/2024 05:43:30 CAMERA1 D:\\IMAGE\\20241220\\1_05433033_601301XXXXXX7150_END.JPG \n20/12/2024 05:43:30 Card State: (4101;00000;00;--------) \n20/12/2024 05:43:30 ----- Clear Cash-In Device ---- \n20/12/2024 05:43:30 CAMERA2 D:\\IMAGE\\20241220\\2_05433065__CASH_OTHERS.JPG \n20/12/2024 05:43:31 APPLICATIONVERSION : BRI_DN200V_V1.6\n20/12/2024 05:43:32 CONFIG-ID : 2002 \n \n20/12/2024 05:43:33 -\u003e Transaction start \n20/12/2024 05:43:33 TRACK 2 DATA: 461699XXXXXX0978 \n20/12/2024 05:43:33 ***** Tran Request State ***** \n20/12/2024 05:43:33 CAMERA1 D:\\IMAGE\\20241220\\1_05433361__START.JPG \n20/12/2024 05:43:33 TRANSACTION REQUEST \n20/12/2024 05:43:33 Transaction reply next 807 function 5098 \nTANGGAL: 20/12/24 WAKTU : 05:21:02 \nATM ID : 190015 NO.REF: 208 \nCARD : 461699XXXXXX0978 \nREK : \nKODETX : 998 flipm \nAMOUNT : RP 0 \nSALDO : \nRESPON : F2 AJ \n20/12/2024 05:43:33 ***** Tran Request State ***** \n20/12/2024 05:43:33 CAMERA1 D:\\IMAGE\\20241220\\1_05433374_461699XXXXXX0978_CARD.JPG \n20/12/2024 05:43:35 EMV CANDIDATES: 2 \n20/12/2024 05:43:38 EMV AID A0000006021010 / 461699XXXXXX0978 STARTED \n20/12/2024 05:43:43 PIN ENTERED \n20/12/2024 05:43:43 CAMERA1 D:\\IMAGE\\20241220\\1_05434313_461699XXXXXX0978_PIN.JPG \n20/12/2024 05:43:54 ***** Tran Request State ***** \n20/12/2024 05:43:55 TRANSACTION REQUEST A BB \n20/12/2024 05:43:55 Transaction reply next 009 function 5102 \n20/12/2024 05:43:55 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:43:56 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : 05:21:24 \nATM ID : 190015 NO.REF: 209 \nCARD : 461699XXXXXX0978 \nREK : \nKODETX : 2 AJ \nAMOUNT : RP 0 \nSALDO : RP 0 \nRESPON : 51 Saldo Tidak Cukup \n20/12/2024 05:43:56 ***** Tran Request State ***** \n20/12/2024 05:44:02 ***** Close Tran State ***** \n20/12/2024 05:44:02 ***** Close Tran State ***** \n20/12/2024 05:44:04 CARD(461699XXXXXX0978) TAKEN \n20/12/2024 05:44:08 \u003c- Transaction end \n \n20/12/2024 05:44:08 CAMERA1 D:\\IMAGE\\20241220\\1_05440878_461699XXXXXX0978_END.JPG \n20/12/2024 05:44:08 Card State: (1001;00000;00;--------) \n20/12/2024 05:44:09 ----- Clear Cash-In Device ---- \n20/12/2024 05:44:09 CAMERA2 D:\\IMAGE\\20241220\\2_05440911__CASH_OTHERS.JPG \n20/12/2024 05:44:10 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:44:10 CONFIG-ID : 2002 \n \n20/12/2024 05:44:32 -\u003e Transaction start \n20/12/2024 05:44:32 TRACK 2 DATA: 601301XXXXXX6753 \n20/12/2024 05:44:32 CAMERA1 D:\\IMAGE\\20241220\\1_05443272__START.JPG \n20/12/2024 05:44:33 CAMERA1 D:\\IMAGE\\20241220\\1_05443298_601301XXXXXX6753_CARD.JPG \n20/12/2024 05:44:34 EMV CANDIDATES: 1 \n20/12/2024 05:44:36 EMV AID A0000006021010 / 601301XXXXXX6753 STARTED \n20/12/2024 05:44:43 PIN ENTERED \n20/12/2024 05:44:43 CAMERA1 D:\\IMAGE\\20241220\\1_05444305_601301XXXXXX6753_PIN.JPG \n20/12/2024 05:44:49 ***** Tran Request State ***** \n20/12/2024 05:44:49 TRANSACTION REQUEST A BB \n20/12/2024 05:44:50 Transaction reply next 264 function 5108 \n20/12/2024 05:44:50 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 05:22:18 \nATM ID : 190015 NO.REF: 2010 \nCARD : 601301XXXXXX6753 \nREK : 612001003550535 \nKODETX : 11 Info Saldo \nAMOUNT : RP 0 \nSALDO : RP 2,991,372 \nRESPON : 00 Sukses \n20/12/2024 05:44:50 ***** Tran Request State ***** \n20/12/2024 05:44:57 EMV AID A0000006021010 / 601301XXXXXX6753 STARTED \n20/12/2024 05:45:02 PIN ENTERED \n20/12/2024 05:45:02 CAMERA1 D:\\IMAGE\\20241220\\1_05450295_601301XXXXXX6753_PIN.JPG \n20/12/2024 05:45:30 INFORMATION 301341081239789180 ENTERED\n20/12/2024 05:45:45 AMOUNT 1000000 ENTERED \n20/12/2024 05:45:45 ***** Tran Request State ***** \n20/12/2024 05:45:46 TRANSACTION REQUEST A HCB \n20/12/2024 05:45:46 Transaction reply next 455 function 5157 \n20/12/2024 05:45:46 EXTERNAL AUTHENTICATE: NO ARPC \n20/12/2024 05:45:47 TVR: 8000040000, TSI: 6000 \nTANGGAL: 20/12/24 WAKTU : 05:23:15 \nATM ID : 190015 NO.REF: 2011 \nCARD : 601301XXXXXX6753 \nREK : \nKODETX : 20 Inq GOPAY \nAMOUNT : RP 1.000.000 \nSALDO : RP 0 \nRESPON : 00 Sukses \n20/12/2024 05:45:47 ***** Tran Request State ***** \n20/12/2024 05:45:54 EMV AID A0000006021010 / 601301XXXXXX6753 STARTED \n20/12/2024 05:45:54 ***** Tran Request State ***** \n20/12/2024 05:45:55 TRANSACTION REQUEST A HCB B \n20/12/2024 05:45:55 Transaction reply next 084 function 5110 \n20/12/2024 05:45:56 TVR: 8000040000, TSI: 7000 \nTANGGAL: 20/12/24 WAKTU : 05:23:23 \nATM ID : 190015 NO.REF: 2012 \nCARD : 601301XXXXXX6753 \nREK : 612001003550535 \nKODETX : 21 Pay GOPAY \nAMOUNT : RP 1.000.000 \nSALDO : RP 0 \nRESPON : 00 Sukses \n20/12/2024 05:45:56 ***** Tran Request State ***** \n20/12/2024 05:46:03 ***** Close Tran State ***** \n20/12/2024 05:46:04 ***** Close Tran State *****\n20/12/2024 05:46:06 CARD(601301XXXXXX6753) TAKEN \n20/12/2024 05:46:10 \u003c- Transaction end \n \n20/12/2024 05:46:10 CAMERA1 D:\\IMAGE\\20241220\\1_05461029_601301XXXXXX6753_END.JPG \n20/12/2024 05:46:10 Card State: (1001;00000;00;--------) \n20/12/2024 05:46:10 ----- Clear Cash-In Device ---- \n20/12/2024 05:46:10 CAMERA2 D:\\IMAGE\\20241220\\2_05461060__CASH_OTHERS.JPG \n20/12/2024 05:46:11 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:46:12 CONFIG-ID : 2002\n \n20/12/2024 05:47:13 -\u003e Transaction start \n20/12/2024 05:47:13 TRACK 2 DATA: 483795XXXXXX7577 \n20/12/2024 05:47:13 ***** Tran Request State ***** \n20/12/2024 05:47:13 CAMERA1 D:\\IMAGE\\20241220\\1_05471394__START.JPG \n20/12/2024 05:47:14 TRANSACTION REQUEST \n20/12/2024 05:47:14 Transaction reply next 800 function 5098 \nTANGGAL: 20/12/24 WAKTU : 05:24:42 \nATM ID : 190015 NO.REF: 2013 \nCARD : 483795XXXXXX7577 \nREK : \nKODETX : 998 flipm \nAMOUNT : RP 0 \nSALDO : \nRESPON : F1 PRIMA \n20/12/2024 05:47:14 ***** Tran Request State ***** \n20/12/2024 05:47:14 CAMERA1 D:\\IMAGE\\20241220\\1_05471409_483795XXXXXX7577_CARD.JPG \n20/12/2024 05:47:16 EMV CANDIDATES: 2 \n20/12/2024 05:47:17 EMV AID A0000006021010 / 483795XXXXXX7577 STARTED \n20/12/2024 05:47:22 PIN ENTERED \n20/12/2024 05:47:22 CAMERA1 D:\\IMAGE\\20241220\\1_05472248_483795XXXXXX7577_PIN.JPG \n20/12/2024 05:47:29 AMOUNT 500000 ENTERED\n20/12/2024 05:47:34 ***** Tran Request State ***** \n20/12/2024 05:47:34 TRANSACTION REQUEST A B C \n20/12/2024 05:47:34 Transaction reply next 820 function 2110 \n20/12/2024 05:47:35 TVR: 8000040000, TSI: 7000 \n20/12/2024 05:47:50 SERIAL NUMBERS SUCCESSFULLY STORED FOR 7 GENUINE NOTES \n20/12/2024 05:47:50 IDR 50000 S/N: RJU936244,CAM950665,SBR806794,FSS053358 \n20/12/2024 05:47:50 IDR 100000 S/N: LCK266920,POV587926,EPU668842 \n20/12/2024 05:47:50 CASH REQUEST: 03000400 \n05:47:50 CASH 1:1,3;3:3,4; \n20/12/2024 05:47:50 CAMERA2 D:\\IMAGE\\20241220\\2_05475034_483795XXXXXX7577_CASH_REQUEST.JPG \n20/12/2024 05:47:56 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:25:03 \nATM ID : 190015 NO.REF: 2014 \nCARD : 483795XXXXXX7577 \nREK : 9000016403520 \nKODETX : 9 PAKET TUNAI OTHER \nAMOUNT : RP 500,000 \nSALDO : RP 1,555,913 \nRESPON : 00 Sukses Prima \nSWITCHING : PRIMA \n20/12/2024 05:47:57 CAMERA1 D:\\IMAGE\\20241220\\1_05475687_483795XXXXXX7577_CASH_PRESENT.JPG \n20/12/2024 05:47:57 CAMERA2 D:\\IMAGE\\20241220\\2_05475715_483795XXXXXX7577_CASH_PRESENT.JPG \n20/12/2024 05:47:57 CAMERA2 D:\\IMAGE\\20241220\\2_05475751_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:57 CAMERA1 D:\\IMAGE\\20241220\\1_05475765_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:57 CAMERA2 D:\\IMAGE\\20241220\\2_05475791_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA2 D:\\IMAGE\\20241220\\2_05475818_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA1 D:\\IMAGE\\20241220\\1_05475834_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA2 D:\\IMAGE\\20241220\\2_05475860_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:58 CAMERA2 D:\\IMAGE\\20241220\\2_05475886_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA1 D:\\IMAGE\\20241220\\1_05475902_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA2 D:\\IMAGE\\20241220\\2_05475912_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA2 D:\\IMAGE\\20241220\\2_05475950_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA2 D:\\IMAGE\\20241220\\2_05475974_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:47:59 CAMERA1 D:\\IMAGE\\20241220\\1_05475969_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480001_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480042_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA1 D:\\IMAGE\\20241220\\1_05480039_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480066_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:00 CAMERA2 D:\\IMAGE\\20241220\\2_05480089_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA1 D:\\IMAGE\\20241220\\1_05480108_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA2 D:\\IMAGE\\20241220\\2_05480117_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA2 D:\\IMAGE\\20241220\\2_05480158_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:01 CAMERA1 D:\\IMAGE\\20241220\\1_05480178_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480185_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480225_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480249_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA1 D:\\IMAGE\\20241220\\1_05480246_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:02 CAMERA2 D:\\IMAGE\\20241220\\2_05480272_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA2 D:\\IMAGE\\20241220\\2_05480300_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA1 D:\\IMAGE\\20241220\\1_05480314_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA2 D:\\IMAGE\\20241220\\2_05480344_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA2 D:\\IMAGE\\20241220\\2_05480370_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:03 CAMERA1 D:\\IMAGE\\20241220\\1_05480382_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:04 CAMERA2 D:\\IMAGE\\20241220\\2_05480412_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:04 CAMERA2 D:\\IMAGE\\20241220\\2_05480457_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:04 CAMERA1 D:\\IMAGE\\20241220\\1_05480448_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480478_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480521_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA1 D:\\IMAGE\\20241220\\1_05480519_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480544_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA2 D:\\IMAGE\\20241220\\2_05480568_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:05 CAMERA1 D:\\IMAGE\\20241220\\1_05480587_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:06 CAMERA2 D:\\IMAGE\\20241220\\2_05480595_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:06 CAMERA2 D:\\IMAGE\\20241220\\2_05480640_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:06 CAMERA1 D:\\IMAGE\\20241220\\1_05480656_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480685_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480725_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA1 D:\\IMAGE\\20241220\\1_05480722_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480749_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA2 D:\\IMAGE\\20241220\\2_05480772_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:07 CAMERA1 D:\\IMAGE\\20241220\\1_05480791_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA2 D:\\IMAGE\\20241220\\2_05480799_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA2 D:\\IMAGE\\20241220\\2_05480839_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA1 D:\\IMAGE\\20241220\\1_05480859_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:08 CAMERA2 D:\\IMAGE\\20241220\\2_05480868_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA2 D:\\IMAGE\\20241220\\2_05480908_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA2 D:\\IMAGE\\20241220\\2_05480931_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA1 D:\\IMAGE\\20241220\\1_05480927_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:09 CAMERA2 D:\\IMAGE\\20241220\\2_05480959_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA1 D:\\IMAGE\\20241220\\1_05480996_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481004_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481045_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481069_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA1 D:\\IMAGE\\20241220\\1_05481065_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:10 CAMERA2 D:\\IMAGE\\20241220\\2_05481091_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA2 D:\\IMAGE\\20241220\\2_05481114_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA1 D:\\IMAGE\\20241220\\1_05481134_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA2 D:\\IMAGE\\20241220\\2_05481142_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:11 CAMERA2 D:\\IMAGE\\20241220\\2_05481183_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA1 D:\\IMAGE\\20241220\\1_05481202_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA2 D:\\IMAGE\\20241220\\2_05481210_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA2 D:\\IMAGE\\20241220\\2_05481251_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA1 D:\\IMAGE\\20241220\\1_05481271_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:12 CAMERA2 D:\\IMAGE\\20241220\\2_05481274_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481304_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481342_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA1 D:\\IMAGE\\20241220\\1_05481338_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481365_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:13 CAMERA2 D:\\IMAGE\\20241220\\2_05481388_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA2 D:\\IMAGE\\20241220\\2_05481411_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA1 D:\\IMAGE\\20241220\\1_05481408_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA2 D:\\IMAGE\\20241220\\2_05481439_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:14 CAMERA1 D:\\IMAGE\\20241220\\1_05481477_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA2 D:\\IMAGE\\20241220\\2_05481484_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA2 D:\\IMAGE\\20241220\\2_05481525_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA1 D:\\IMAGE\\20241220\\1_05481545_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:15 CAMERA2 D:\\IMAGE\\20241220\\2_05481553_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA2 D:\\IMAGE\\20241220\\2_05481594_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA1 D:\\IMAGE\\20241220\\1_05481614_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA2 D:\\IMAGE\\20241220\\2_05481625_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA1 D:\\IMAGE\\20241220\\1_05481681_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:16 CAMERA2 D:\\IMAGE\\20241220\\2_05481671_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA2 D:\\IMAGE\\20241220\\2_05481715_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA2 D:\\IMAGE\\20241220\\2_05481753_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA1 D:\\IMAGE\\20241220\\1_05481749_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:17 CAMERA2 D:\\IMAGE\\20241220\\2_05481780_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA2 D:\\IMAGE\\20241220\\2_05481807_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA1 D:\\IMAGE\\20241220\\1_05481816_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA2 D:\\IMAGE\\20241220\\2_05481847_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA2 D:\\IMAGE\\20241220\\2_05481869_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:18 CAMERA1 D:\\IMAGE\\20241220\\1_05481888_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA2 D:\\IMAGE\\20241220\\2_05481898_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA2 D:\\IMAGE\\20241220\\2_05481936_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA1 D:\\IMAGE\\20241220\\1_05481955_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:19 CAMERA2 D:\\IMAGE\\20241220\\2_05481966_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA2 D:\\IMAGE\\20241220\\2_05482005_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA1 D:\\IMAGE\\20241220\\1_05482023_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA2 D:\\IMAGE\\20241220\\2_05482035_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA2 D:\\IMAGE\\20241220\\2_05482075_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:20 CAMERA1 D:\\IMAGE\\20241220\\1_05482092_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA2 D:\\IMAGE\\20241220\\2_05482103_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA2 D:\\IMAGE\\20241220\\2_05482142_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA1 D:\\IMAGE\\20241220\\1_05482159_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CAMERA2 D:\\IMAGE\\20241220\\2_05482172_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:21 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:48:22 CAMERA2 D:\\IMAGE\\20241220\\2_05482213_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:22 CAMERA1 D:\\IMAGE\\20241220\\1_05482228_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:22 CAMERA2 D:\\IMAGE\\20241220\\2_05482240_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA1 D:\\IMAGE\\20241220\\1_05482296_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA2 D:\\IMAGE\\20241220\\2_05482285_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA2 D:\\IMAGE\\20241220\\2_05482327_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA1 D:\\IMAGE\\20241220\\1_05482364_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:23 CAMERA2 D:\\IMAGE\\20241220\\2_05482354_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA2 D:\\IMAGE\\20241220\\2_05482401_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA1 D:\\IMAGE\\20241220\\1_05482432_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA2 D:\\IMAGE\\20241220\\2_05482439_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:24 CAMERA2 D:\\IMAGE\\20241220\\2_05482464_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA1 D:\\IMAGE\\20241220\\1_05482500_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA2 D:\\IMAGE\\20241220\\2_05482492_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA2 D:\\IMAGE\\20241220\\2_05482533_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA1 D:\\IMAGE\\20241220\\1_05482569_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:25 CAMERA2 D:\\IMAGE\\20241220\\2_05482561_483795XXXXXX7577_INTERVAL_CAPTURE.JPG \n20/12/2024 05:48:26 CASH TAKEN \n20/12/2024 05:48:26 CAMERA1 D:\\IMAGE\\20241220\\1_05482601_483795XXXXXX7577_CASH_TAKEN.JPG \n20/12/2024 05:48:27 ***** Tran Request State *****\n20/12/2024 05:48:27 CAMERA2 D:\\IMAGE\\20241220\\2_05482617_483795XXXXXX7577_CASH_TAKEN.JPG \n20/12/2024 05:48:28 ***** Close Tran State ***** \n20/12/2024 05:48:28 ***** Close Tran State ***** \n20/12/2024 05:48:30 CARD(483795XXXXXX7577) TAKEN\n20/12/2024 05:48:34 \u003c- Transaction end \n \n20/12/2024 05:48:35 CAMERA1 D:\\IMAGE\\20241220\\1_05483495_483795XXXXXX7577_END.JPG \n20/12/2024 05:48:35 Card State: (1001;00000;00;--------) \n20/12/2024 05:48:35 ----- Clear Cash-In Device ---- \n20/12/2024 05:48:35 CAMERA2 D:\\IMAGE\\20241220\\2_05483527__CASH_OTHERS.JPG \n20/12/2024 05:48:36 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:48:36 CONFIG-ID : 2002\n \n20/12/2024 05:49:45 -\u003e Transaction start \n20/12/2024 05:49:45 TRACK 2 DATA: 461699XXXXXX4588 \n20/12/2024 05:49:45 ***** Tran Request State ***** \n20/12/2024 05:49:45 TRANSACTION REQUEST \n20/12/2024 05:49:45 Transaction reply next 807 function 5098 \nTANGGAL: 20/12/24 WAKTU : 05:27:14 \nATM ID : 190015 NO.REF: 2015 \nCARD : 461699XXXXXX4588 \nREK : \nKODETX : 998 flipm \nAMOUNT : RP 0 \nSALDO : \nRESPON : F2 AJ \n20/12/2024 05:49:46 ***** Tran Request State ***** \n20/12/2024 05:49:46 CAMERA1 D:\\IMAGE\\20241220\\1_05494579__START.JPG \n20/12/2024 05:49:46 CAMERA1 D:\\IMAGE\\20241220\\1_05494612_461699XXXXXX4588_CARD.JPG \n20/12/2024 05:49:48 EMV CANDIDATES: 2 \n20/12/2024 05:49:50 EMV AID A0000006021010 / 461699XXXXXX4588 STARTED \n20/12/2024 05:49:58 PIN ENTERED \n20/12/2024 05:49:58 CAMERA1 D:\\IMAGE\\20241220\\1_05495811_461699XXXXXX4588_PIN.JPG \n20/12/2024 05:50:03 ***** Tran Request State ***** \n20/12/2024 05:50:04 TRANSACTION REQUEST A B \n20/12/2024 05:50:04 Transaction reply next 016 function A024 \n20/12/2024 05:50:04 TVR: 8000040000, TSI: 7000 \n20/12/2024 05:50:12 SERIAL NUMBERS SUCCESSFULLY STORED FOR 7 GENUINE NOTES \n20/12/2024 05:50:12 IDR 50000 S/N: ZHH704593,GND974895,ELH831906,ARE469026 \n20/12/2024 05:50:12 IDR 100000 S/N: LGP083910,TOD360926,XAH287761 \n20/12/2024 05:50:12 CASH REQUEST: 03000400 \n05:50:12 CASH 1:1,3;3:3,4; \n20/12/2024 05:50:12 CAMERA2 D:\\IMAGE\\20241220\\2_05501261_461699XXXXXX4588_CASH_REQUEST.JPG \n20/12/2024 05:50:14 CARD(461699XXXXXX4588) TAKEN \n20/12/2024 05:50:18 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:27:32 \nATM ID : 190015 NO.REF: 2016 \nCARD : 461699XXXXXX4588 \nREK : 9901 \nKODETX : 15 FAST CASH OTHER \nAMOUNT : RP 500,000 \nSALDO : RP 680,281 \nRESPON : OO Fash Cash \nSWITCHING : AJ ATMBERSAMA \n20/12/2024 05:50:18 CAMERA1 D:\\IMAGE\\20241220\\1_05501873_461699XXXXXX4588_CASH_PRESENT.JPG \n20/12/2024 05:50:19 CAMERA2 D:\\IMAGE\\20241220\\2_05501898_461699XXXXXX4588_CASH_PRESENT.JPG \n20/12/2024 05:50:19 CAMERA2 D:\\IMAGE\\20241220\\2_05501927_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:19 CAMERA1 D:\\IMAGE\\20241220\\1_05501948_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:19 CAMERA2 D:\\IMAGE\\20241220\\2_05501954_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:20 CAMERA2 D:\\IMAGE\\20241220\\2_05502001_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:20 CAMERA2 D:\\IMAGE\\20241220\\2_05502050_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:20 CAMERA1 D:\\IMAGE\\20241220\\1_05502036_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA2 D:\\IMAGE\\20241220\\2_05502082_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA1 D:\\IMAGE\\20241220\\1_05502122_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA2 D:\\IMAGE\\20241220\\2_05502126_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:21 CAMERA2 D:\\IMAGE\\20241220\\2_05502175_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA1 D:\\IMAGE\\20241220\\1_05502193_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA2 D:\\IMAGE\\20241220\\2_05502221_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA1 D:\\IMAGE\\20241220\\1_05502263_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:22 CAMERA2 D:\\IMAGE\\20241220\\2_05502265_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA2 D:\\IMAGE\\20241220\\2_05502305_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA1 D:\\IMAGE\\20241220\\1_05502324_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA2 D:\\IMAGE\\20241220\\2_05502337_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:23 CAMERA2 D:\\IMAGE\\20241220\\2_05502380_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA1 D:\\IMAGE\\20241220\\1_05502400_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA2 D:\\IMAGE\\20241220\\2_05502407_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA2 D:\\IMAGE\\20241220\\2_05502452_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:24 CAMERA1 D:\\IMAGE\\20241220\\1_05502469_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502498_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502539_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA1 D:\\IMAGE\\20241220\\1_05502534_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502563_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:25 CAMERA2 D:\\IMAGE\\20241220\\2_05502586_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA1 D:\\IMAGE\\20241220\\1_05502606_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA2 D:\\IMAGE\\20241220\\2_05502615_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA2 D:\\IMAGE\\20241220\\2_05502657_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:26 CAMERA1 D:\\IMAGE\\20241220\\1_05502677_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA2 D:\\IMAGE\\20241220\\2_05502684_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA2 D:\\IMAGE\\20241220\\2_05502729_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA1 D:\\IMAGE\\20241220\\1_05502745_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:27 CAMERA2 D:\\IMAGE\\20241220\\2_05502775_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA1 D:\\IMAGE\\20241220\\1_05502814_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA2 D:\\IMAGE\\20241220\\2_05502820_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA2 D:\\IMAGE\\20241220\\2_05502862_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:28 CAMERA1 D:\\IMAGE\\20241220\\1_05502882_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:29 CAMERA2 D:\\IMAGE\\20241220\\2_05502911_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:29 CAMERA1 D:\\IMAGE\\20241220\\1_05502950_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:29 CAMERA2 D:\\IMAGE\\20241220\\2_05502956_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA2 D:\\IMAGE\\20241220\\2_05503001_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA1 D:\\IMAGE\\20241220\\1_05503019_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA2 D:\\IMAGE\\20241220\\2_05503047_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:30 CAMERA1 D:\\IMAGE\\20241220\\1_05503087_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503092_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503132_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503156_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA1 D:\\IMAGE\\20241220\\1_05503150_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:31 CAMERA2 D:\\IMAGE\\20241220\\2_05503180_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA2 D:\\IMAGE\\20241220\\2_05503207_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA1 D:\\IMAGE\\20241220\\1_05503224_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA2 D:\\IMAGE\\20241220\\2_05503247_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA2 D:\\IMAGE\\20241220\\2_05503271_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:32 CAMERA1 D:\\IMAGE\\20241220\\1_05503292_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:33 CAMERA2 D:\\IMAGE\\20241220\\2_05503298_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:33 CAMERA2 D:\\IMAGE\\20241220\\2_05503343_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:33 CAMERA1 D:\\IMAGE\\20241220\\1_05503359_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA2 D:\\IMAGE\\20241220\\2_05503388_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA2 D:\\IMAGE\\20241220\\2_05503430_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA1 D:\\IMAGE\\20241220\\1_05503428_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:34 CAMERA2 D:\\IMAGE\\20241220\\2_05503457_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503497_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA1 D:\\IMAGE\\20241220\\1_05503496_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503521_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503548_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA1 D:\\IMAGE\\20241220\\1_05503564_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:35 CAMERA2 D:\\IMAGE\\20241220\\2_05503589_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:36 CAMERA2 D:\\IMAGE\\20241220\\2_05503616_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:36 CAMERA1 D:\\IMAGE\\20241220\\1_05503632_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:36 CAMERA2 D:\\IMAGE\\20241220\\2_05503662_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA1 D:\\IMAGE\\20241220\\1_05503701_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA2 D:\\IMAGE\\20241220\\2_05503707_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA2 D:\\IMAGE\\20241220\\2_05503753_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA1 D:\\IMAGE\\20241220\\1_05503769_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:37 CAMERA2 D:\\IMAGE\\20241220\\2_05503793_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:38 CAMERA2 D:\\IMAGE\\20241220\\2_05503816_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:38 CAMERA1 D:\\IMAGE\\20241220\\1_05503837_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:38 CAMERA2 D:\\IMAGE\\20241220\\2_05503843_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503888_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA1 D:\\IMAGE\\20241220\\1_05503905_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503930_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503952_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA2 D:\\IMAGE\\20241220\\2_05503976_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:39 CAMERA1 D:\\IMAGE\\20241220\\1_05503972_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA2 D:\\IMAGE\\20241220\\2_05504003_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA2 D:\\IMAGE\\20241220\\2_05504044_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA1 D:\\IMAGE\\20241220\\1_05504041_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:40 CAMERA2 D:\\IMAGE\\20241220\\2_05504071_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA2 D:\\IMAGE\\20241220\\2_05504113_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA1 D:\\IMAGE\\20241220\\1_05504109_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA2 D:\\IMAGE\\20241220\\2_05504140_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:41 CAMERA1 D:\\IMAGE\\20241220\\1_05504177_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504185_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504231_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA1 D:\\IMAGE\\20241220\\1_05504246_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504271_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:42 CAMERA2 D:\\IMAGE\\20241220\\2_05504294_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CAMERA1 D:\\IMAGE\\20241220\\1_05504314_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CAMERA2 D:\\IMAGE\\20241220\\2_05504321_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CASH PRESENT TIMER EXPIRED \n20/12/2024 05:50:43 CAMERA2 D:\\IMAGE\\20241220\\2_05504367_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:43 CAMERA1 D:\\IMAGE\\20241220\\1_05504382_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:44 CAMERA2 D:\\IMAGE\\20241220\\2_05504408_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:44 CAMERA2 D:\\IMAGE\\20241220\\2_05504435_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:44 CAMERA1 D:\\IMAGE\\20241220\\1_05504450_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA2 D:\\IMAGE\\20241220\\2_05504481_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA1 D:\\IMAGE\\20241220\\1_05504523_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA2 D:\\IMAGE\\20241220\\2_05504527_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA2 D:\\IMAGE\\20241220\\2_05504567_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:45 CAMERA1 D:\\IMAGE\\20241220\\1_05504588_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:46 CAMERA2 D:\\IMAGE\\20241220\\2_05504595_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:46 CAMERA2 D:\\IMAGE\\20241220\\2_05504640_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:46 CAMERA1 D:\\IMAGE\\20241220\\1_05504656_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA2 D:\\IMAGE\\20241220\\2_05504686_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA1 D:\\IMAGE\\20241220\\1_05504724_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA2 D:\\IMAGE\\20241220\\2_05504732_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:47 CAMERA2 D:\\IMAGE\\20241220\\2_05504778_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:48 CAMERA1 D:\\IMAGE\\20241220\\1_05504792_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:48 CASH TAKEN \n20/12/2024 05:50:48 CAMERA2 D:\\IMAGE\\20241220\\2_05504823_461699XXXXXX4588_INTERVAL_CAPTURE.JPG \n20/12/2024 05:50:48 CAMERA1 D:\\IMAGE\\20241220\\1_05504839_461699XXXXXX4588_CASH_TAKEN.JPG \n20/12/2024 05:50:48 CAMERA2 D:\\IMAGE\\20241220\\2_05504856_461699XXXXXX4588_CASH_TAKEN.JPG \n20/12/2024 05:50:49 ***** Tran Request State ***** \n20/12/2024 05:50:49 ***** Close Tran State ***** \n20/12/2024 05:50:49 ***** Close Tran State ***** \n20/12/2024 05:50:55 \u003c- Transaction end \n \n20/12/2024 05:50:56 CAMERA1 D:\\IMAGE\\20241220\\1_05505589_461699XXXXXX4588_END.JPG \n20/12/2024 05:50:56 Card State: (4101;00000;00;--------) \n20/12/2024 05:50:56 ----- Clear Cash-In Device ---- \n20/12/2024 05:50:56 CAMERA2 D:\\IMAGE\\20241220\\2_05505622__CASH_OTHERS.JPG \n20/12/2024 05:50:57 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 05:50:57 CONFIG-ID : 2002\n20/12/2024 05:55:56 CAMERA1 D:\\IMAGE\\20241220\\1_05555613__INTERVAL_CAPTURE.JPG \n \n20/12/2024 05:59:50 -\u003e Transaction start \n20/12/2024 05:59:50 TRACK 2 DATA: 532659XXXXXX6470 \n20/12/2024 05:59:50 CAMERA1 D:\\IMAGE\\20241220\\1_05595056__START.JPG \n20/12/2024 05:59:50 CAMERA1 D:\\IMAGE\\20241220\\1_05595075_532659XXXXXX6470_CARD.JPG \n20/12/2024 05:59:52 EMV CANDIDATES: 2 \n20/12/2024 05:59:54 EMV AID A0000006021010 / 532659XXXXXX6470 STARTED \n20/12/2024 06:00:01 PIN ENTERED \n20/12/2024 06:00:01 CAMERA1 D:\\IMAGE\\20241220\\1_06000161_532659XXXXXX6470_PIN.JPG \n20/12/2024 06:00:03 ***** Tran Request State ***** \n20/12/2024 06:00:04 TRANSACTION REQUEST A B \n20/12/2024 06:00:04 Transaction reply next 016 function A024 \n20/12/2024 06:00:05 TVR: 8000040000, TSI: 7000 \n20/12/2024 06:00:14 SERIAL NUMBERS SUCCESSFULLY STORED FOR 20 GENUINE NOTES \n20/12/2024 06:00:14 IDR 50000 S/N: ZNN654909,VPK239205,VNT638805,RRV401446,JMB255294,LNC544756,RLK133508,OES031962,BQT902509,MCG596000 \n20/12/2024 06:00:14 IDR 100000 S/N: CRJ352020,QNU658606,ENB236559,MQE578753,CNP898272,KNC626696,MQQ085321,JAM052180,PQP378728,KCK853042 \n20/12/2024 06:00:14 CASH REQUEST: 10001000 \n06:00:14 CASH 1:1,10;3:3,10; \n20/12/2024 06:00:14 CAMERA2 D:\\IMAGE\\20241220\\2_06001480_532659XXXXXX6470_CASH_REQUEST.JPG \n20/12/2024 06:00:16 CARD(532659XXXXXX6470) TAKEN \n20/12/2024 06:00:20 CASH PRESENTED \n20/12/2024 06:00:20 CAMERA1 D:\\IMAGE\\20241220\\1_06002024_532659XXXXXX6470_CASH_PRESENT.JPG \nTANGGAL: 20/12/24 WAKTU : 05:37:33 \nATM ID : 190015 NO.REF: 2017 \nCARD : 532659XXXXXX6470 \nREK : 011001003011560 \nKODETX : 3 FAST CASH NO RECEIPT \nAMOUNT : RP 1,500,000 \nSALDO : RP 32,846,515 \nRESPON : 00 Fash Cash\nSWITCHING : BRI DEBIT \n20/12/2024 06:00:20 CAMERA2 D:\\IMAGE\\20241220\\2_06002036_532659XXXXXX6470_CASH_PRESENT.JPG \n20/12/2024 06:00:20 CAMERA2 D:\\IMAGE\\20241220\\2_06002064_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:20 CAMERA1 D:\\IMAGE\\20241220\\1_06002086_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA2 D:\\IMAGE\\20241220\\2_06002109_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA2 D:\\IMAGE\\20241220\\2_06002150_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA1 D:\\IMAGE\\20241220\\1_06002155_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:21 CAMERA2 D:\\IMAGE\\20241220\\2_06002178_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:22 CAMERA2 D:\\IMAGE\\20241220\\2_06002219_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:22 CAMERA1 D:\\IMAGE\\20241220\\1_06002222_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:22 CAMERA2 D:\\IMAGE\\20241220\\2_06002246_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA2 D:\\IMAGE\\20241220\\2_06002290_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA1 D:\\IMAGE\\20241220\\1_06002305_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA2 D:\\IMAGE\\20241220\\2_06002338_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:23 CAMERA1 D:\\IMAGE\\20241220\\1_06002381_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA2 D:\\IMAGE\\20241220\\2_06002383_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA2 D:\\IMAGE\\20241220\\2_06002429_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA1 D:\\IMAGE\\20241220\\1_06002449_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:24 CAMERA2 D:\\IMAGE\\20241220\\2_06002476_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002514_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA1 D:\\IMAGE\\20241220\\1_06002517_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002536_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002560_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA2 D:\\IMAGE\\20241220\\2_06002583_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:25 CAMERA1 D:\\IMAGE\\20241220\\1_06002585_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA2 D:\\IMAGE\\20241220\\2_06002607_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA2 D:\\IMAGE\\20241220\\2_06002634_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA1 D:\\IMAGE\\20241220\\1_06002653_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:26 CAMERA2 D:\\IMAGE\\20241220\\2_06002679_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA1 D:\\IMAGE\\20241220\\1_06002721_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA2 D:\\IMAGE\\20241220\\2_06002724_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA2 D:\\IMAGE\\20241220\\2_06002765_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA2 D:\\IMAGE\\20241220\\2_06002788_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:27 CAMERA1 D:\\IMAGE\\20241220\\1_06002790_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:28 CAMERA2 D:\\IMAGE\\20241220\\2_06002815_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:28 CAMERA1 D:\\IMAGE\\20241220\\1_06002858_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:28 CAMERA2 D:\\IMAGE\\20241220\\2_06002860_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA2 D:\\IMAGE\\20241220\\2_06002906_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA1 D:\\IMAGE\\20241220\\1_06002926_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA2 D:\\IMAGE\\20241220\\2_06002947_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:29 CAMERA2 D:\\IMAGE\\20241220\\2_06002974_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA1 D:\\IMAGE\\20241220\\1_06002994_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA2 D:\\IMAGE\\20241220\\2_06003020_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA2 D:\\IMAGE\\20241220\\2_06003060_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA1 D:\\IMAGE\\20241220\\1_06003062_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:30 CAMERA2 D:\\IMAGE\\20241220\\2_06003083_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA2 D:\\IMAGE\\20241220\\2_06003110_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA1 D:\\IMAGE\\20241220\\1_06003131_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA2 D:\\IMAGE\\20241220\\2_06003156_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:31 CAMERA2 D:\\IMAGE\\20241220\\2_06003197_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA1 D:\\IMAGE\\20241220\\1_06003199_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA2 D:\\IMAGE\\20241220\\2_06003224_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA2 D:\\IMAGE\\20241220\\2_06003264_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:32 CAMERA1 D:\\IMAGE\\20241220\\1_06003266_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003292_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003333_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA1 D:\\IMAGE\\20241220\\1_06003335_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003355_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:33 CAMERA2 D:\\IMAGE\\20241220\\2_06003378_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA1 D:\\IMAGE\\20241220\\1_06003403_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA2 D:\\IMAGE\\20241220\\2_06003406_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA2 D:\\IMAGE\\20241220\\2_06003447_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA1 D:\\IMAGE\\20241220\\1_06003471_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:34 CAMERA2 D:\\IMAGE\\20241220\\2_06003474_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:35 CAMERA2 D:\\IMAGE\\20241220\\2_06003520_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:35 CAMERA1 D:\\IMAGE\\20241220\\1_06003554_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:35 CAMERA2 D:\\IMAGE\\20241220\\2_06003565_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA2 D:\\IMAGE\\20241220\\2_06003611_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA1 D:\\IMAGE\\20241220\\1_06003630_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA2 D:\\IMAGE\\20241220\\2_06003650_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:36 CAMERA2 D:\\IMAGE\\20241220\\2_06003678_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA1 D:\\IMAGE\\20241220\\1_06003698_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA2 D:\\IMAGE\\20241220\\2_06003718_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA2 D:\\IMAGE\\20241220\\2_06003741_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA2 D:\\IMAGE\\20241220\\2_06003764_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:37 CAMERA1 D:\\IMAGE\\20241220\\1_06003765_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:38 CAMERA2 D:\\IMAGE\\20241220\\2_06003792_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:38 CAMERA1 D:\\IMAGE\\20241220\\1_06003834_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:38 CAMERA2 D:\\IMAGE\\20241220\\2_06003837_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA2 D:\\IMAGE\\20241220\\2_06003884_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA1 D:\\IMAGE\\20241220\\1_06003902_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA2 D:\\IMAGE\\20241220\\2_06003929_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA1 D:\\IMAGE\\20241220\\1_06003970_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:39 CAMERA2 D:\\IMAGE\\20241220\\2_06003974_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA2 D:\\IMAGE\\20241220\\2_06004016_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA2 D:\\IMAGE\\20241220\\2_06004039_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA1 D:\\IMAGE\\20241220\\1_06004038_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:40 CAMERA2 D:\\IMAGE\\20241220\\2_06004067_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA1 D:\\IMAGE\\20241220\\1_06004106_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA2 D:\\IMAGE\\20241220\\2_06004112_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA2 D:\\IMAGE\\20241220\\2_06004156_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:41 CAMERA1 D:\\IMAGE\\20241220\\1_06004170_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004198_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004222_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004244_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA1 D:\\IMAGE\\20241220\\1_06004243_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:42 CAMERA2 D:\\IMAGE\\20241220\\2_06004268_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:43 CAMERA2 D:\\IMAGE\\20241220\\2_06004295_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:43 CAMERA1 D:\\IMAGE\\20241220\\1_06004330_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:43 CAMERA2 D:\\IMAGE\\20241220\\2_06004340_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA2 D:\\IMAGE\\20241220\\2_06004385_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA1 D:\\IMAGE\\20241220\\1_06004401_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA2 D:\\IMAGE\\20241220\\2_06004431_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA2 D:\\IMAGE\\20241220\\2_06004472_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:44 CAMERA1 D:\\IMAGE\\20241220\\1_06004470_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CAMERA2 D:\\IMAGE\\20241220\\2_06004500_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CASH PRESENT TIMER EXPIRED \n20/12/2024 06:00:45 CAMERA1 D:\\IMAGE\\20241220\\1_06004538_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CAMERA2 D:\\IMAGE\\20241220\\2_06004545_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:45 CAMERA2 D:\\IMAGE\\20241220\\2_06004572_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA1 D:\\IMAGE\\20241220\\1_06004607_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA2 D:\\IMAGE\\20241220\\2_06004614_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA2 D:\\IMAGE\\20241220\\2_06004659_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:46 CAMERA1 D:\\IMAGE\\20241220\\1_06004675_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA2 D:\\IMAGE\\20241220\\2_06004705_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA2 D:\\IMAGE\\20241220\\2_06004745_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA1 D:\\IMAGE\\20241220\\1_06004744_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:47 CAMERA2 D:\\IMAGE\\20241220\\2_06004772_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA1 D:\\IMAGE\\20241220\\1_06004813_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA2 D:\\IMAGE\\20241220\\2_06004818_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA2 D:\\IMAGE\\20241220\\2_06004860_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:48 CAMERA1 D:\\IMAGE\\20241220\\1_06004881_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:49 CAMERA2 D:\\IMAGE\\20241220\\2_06004887_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:49 CASH TAKEN \n20/12/2024 06:00:49 CAMERA2 D:\\IMAGE\\20241220\\2_06004933_532659XXXXXX6470_INTERVAL_CAPTURE.JPG \n20/12/2024 06:00:49 CAMERA1 D:\\IMAGE\\20241220\\1_06004936_532659XXXXXX6470_CASH_TAKEN.JPG \n20/12/2024 06:00:49 CAMERA2 D:\\IMAGE\\20241220\\2_06004964_532659XXXXXX6470_CASH_TAKEN.JPG \n20/12/2024 06:00:50 ***** Tran Request State ***** \n20/12/2024 06:00:50 ***** Close Tran State ***** \n20/12/2024 06:00:50 ***** Close Tran State ***** \n20/12/2024 06:00:56 \u003c- Transaction end \n \n20/12/2024 06:00:57 Card State: (4101;00000;00;--------) \n20/12/2024 06:00:57 CAMERA1 D:\\IMAGE\\20241220\\1_06005681_532659XXXXXX6470_END.JPG \n20/12/2024 06:00:57 ----- Clear Cash-In Device ---- \n20/12/2024 06:00:57 CAMERA2 D:\\IMAGE\\20241220\\2_06005720__CASH_OTHERS.JPG \n20/12/2024 06:00:58 APPLICATIONVERSION : BRI_DN200V_V1.6 \n20/12/2024 06:00:58 CONFIG-ID : 2002\n20/12/2024 06:05:57 CAMERA1 D:\\IMAGE\\20241220\\1_06055722__INTERVAL_CAPTURE.JPG \n \n20/12/2024 06:08:07 -\u003e Transaction start \n20/12/2024 06:08:07 TRACK 2 DATA: 522184XXXXXX4614 \n20/12/2024 06:08:08 CAMERA1 D:\\IMAGE\\20241220\\1_06080786__START.JPG \n20/12/2024 06:08:08 CAMERA1 D:\\IMAGE\\20241220\\1_06080814_522184XXXXXX4614_CARD.JPG \n20/12/2024 06:08:09 EMV CANDIDATES: 2 \n20/12/2024 06:08:11 EMV AID A0000006021010 / 522184XXXXXX4614 STARTED \n20/12/2024 06:08:16 PIN ENTERED \n20/12/2024 06:08:16 CAMERA1 D:\\IMAGE\\20241220\\1_06081678_522184XXXXXX4614_PIN.JPG \n20/12/2024 06:08:21 ***** Tran Request State ***** \n20/12/2024 06:08:21 TRANSACTION REQUEST A B \n20/12/2024 06:08:21 Transaction reply next 016 function A024 \n20/12/2024 06:08:22 TVR: 8000040000, TSI: 7000\n20/12/2024 06:08:40 SERIAL NUMBERS SUCCESSFULLY STORED FOR 3 GENUINE NOTES \n20/12/2024 06:08:40 IDR 50000 S/N: AAU861988,BAL777900 \n20/12/2024 06:08:40 IDR 100000 S/N: CMQ162638 \n20/12/2024 06:08:40 CASH REQUEST: 01000200 \n06:08:40 CASH 1:1,1;3:3,2; \n20/12/2024 06:08:40 CAMERA2 D:\\IMAGE\\20241220\\2_06084049_522184XXXXXX4614_CASH_REQUEST.JPG \n20/12/2024 06:08:42 CARD(522184XXXXXX4614) TAKEN \n20/12/2024 06:08:47 CASH PRESENTED \nTANGGAL: 20/12/24 WAKTU : 05:45:50 \nATM ID : 190015 NO.REF: 2018 \nCARD : 522184XXXXXX4614 \nREK : 465501000131507 \nKODETX : 3 FAST CASH NO RECEIPT \nAMOUNT : RP 200,000 \nSALDO : RP 166,842 \nRESPON : 00 Fash Cash \nSWITCHING : BRI DEBIT \n20/12/2024 06:08:47 CAMERA1 D:\\IMAGE\\20241220\\1_06084746_522184XXXXXX4614_CASH_PRESENT.JPG \n20/12/2024 06:08:47 CAMERA2 D:\\IMAGE\\20241220\\2_06084771_522184XXXXXX4614_CASH_PRESENT.JPG \n20/12/2024 06:08:48 CAMERA2 D:\\IMAGE\\20241220\\2_06084814_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA1 D:\\IMAGE\\20241220\\1_06084822_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA2 D:\\IMAGE\\20241220\\2_06084842_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA2 D:\\IMAGE\\20241220\\2_06084882_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:48 CAMERA1 D:\\IMAGE\\20241220\\1_06084891_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA2 D:\\IMAGE\\20241220\\2_06084905_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA2 D:\\IMAGE\\20241220\\2_06084932_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA1 D:\\IMAGE\\20241220\\1_06084958_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:49 CAMERA2 D:\\IMAGE\\20241220\\2_06084977_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA2 D:\\IMAGE\\20241220\\2_06085019_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA1 D:\\IMAGE\\20241220\\1_06085027_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA2 D:\\IMAGE\\20241220\\2_06085042_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:50 CAMERA2 D:\\IMAGE\\20241220\\2_06085070_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA1 D:\\IMAGE\\20241220\\1_06085094_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA2 D:\\IMAGE\\20241220\\2_06085110_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA2 D:\\IMAGE\\20241220\\2_06085138_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:51 CAMERA1 D:\\IMAGE\\20241220\\1_06085163_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085184_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA1 D:\\IMAGE\\20241220\\1_06085231_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085227_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085271_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:52 CAMERA2 D:\\IMAGE\\20241220\\2_06085292_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA2 D:\\IMAGE\\20241220\\2_06085316_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA1 D:\\IMAGE\\20241220\\1_06085311_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA2 D:\\IMAGE\\20241220\\2_06085339_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA2 D:\\IMAGE\\20241220\\2_06085361_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:53 CAMERA1 D:\\IMAGE\\20241220\\1_06085390_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085389_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085430_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085453_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA1 D:\\IMAGE\\20241220\\1_06085458_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:54 CAMERA2 D:\\IMAGE\\20241220\\2_06085477_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA2 D:\\IMAGE\\20241220\\2_06085504_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA1 D:\\IMAGE\\20241220\\1_06085527_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA2 D:\\IMAGE\\20241220\\2_06085549_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:55 CAMERA2 D:\\IMAGE\\20241220\\2_06085590_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA1 D:\\IMAGE\\20241220\\1_06085595_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA2 D:\\IMAGE\\20241220\\2_06085613_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA2 D:\\IMAGE\\20241220\\2_06085640_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:56 CAMERA1 D:\\IMAGE\\20241220\\1_06085663_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085686_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085727_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA1 D:\\IMAGE\\20241220\\1_06085731_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085754_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:57 CAMERA2 D:\\IMAGE\\20241220\\2_06085794_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA1 D:\\IMAGE\\20241220\\1_06085799_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA2 D:\\IMAGE\\20241220\\2_06085821_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA2 D:\\IMAGE\\20241220\\2_06085867_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:58 CAMERA1 D:\\IMAGE\\20241220\\1_06085868_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:59 CAMERA2 D:\\IMAGE\\20241220\\2_06085912_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:59 CAMERA1 D:\\IMAGE\\20241220\\1_06085948_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:08:59 CAMERA2 D:\\IMAGE\\20241220\\2_06085959_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA2 D:\\IMAGE\\20241220\\2_06085998_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA1 D:\\IMAGE\\20241220\\1_06090026_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA2 D:\\IMAGE\\20241220\\2_06090028_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:00 CAMERA2 D:\\IMAGE\\20241220\\2_06090072_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA1 D:\\IMAGE\\20241220\\1_06090094_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA2 D:\\IMAGE\\20241220\\2_06090117_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA2 D:\\IMAGE\\20241220\\2_06090162_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:01 CAMERA1 D:\\IMAGE\\20241220\\1_06090162_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA2 D:\\IMAGE\\20241220\\2_06090201_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA1 D:\\IMAGE\\20241220\\1_06090242_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA2 D:\\IMAGE\\20241220\\2_06090231_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:02 CAMERA2 D:\\IMAGE\\20241220\\2_06090278_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA1 D:\\IMAGE\\20241220\\1_06090313_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA2 D:\\IMAGE\\20241220\\2_06090323_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA2 D:\\IMAGE\\20241220\\2_06090368_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:03 CAMERA1 D:\\IMAGE\\20241220\\1_06090390_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:04 CAMERA2 D:\\IMAGE\\20241220\\2_06090413_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:04 CAMERA1 D:\\IMAGE\\20241220\\1_06090459_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:04 CAMERA2 D:\\IMAGE\\20241220\\2_06090459_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:05 CAMERA2 D:\\IMAGE\\20241220\\2_06090505_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:05 CAMERA1 D:\\IMAGE\\20241220\\1_06090544_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:05 CAMERA2 D:\\IMAGE\\20241220\\2_06090548_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:06 CAMERA2 D:\\IMAGE\\20241220\\2_06090595_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:06 CAMERA1 D:\\IMAGE\\20241220\\1_06090617_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:06 CAMERA2 D:\\IMAGE\\20241220\\2_06090640_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA2 D:\\IMAGE\\20241220\\2_06090684_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA1 D:\\IMAGE\\20241220\\1_06090698_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA2 D:\\IMAGE\\20241220\\2_06090727_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA2 D:\\IMAGE\\20241220\\2_06090754_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:07 CAMERA1 D:\\IMAGE\\20241220\\1_06090777_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA2 D:\\IMAGE\\20241220\\2_06090799_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA2 D:\\IMAGE\\20241220\\2_06090840_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA1 D:\\IMAGE\\20241220\\1_06090845_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:08 CAMERA2 D:\\IMAGE\\20241220\\2_06090863_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA2 D:\\IMAGE\\20241220\\2_06090890_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA1 D:\\IMAGE\\20241220\\1_06090913_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA2 D:\\IMAGE\\20241220\\2_06090935_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA2 D:\\IMAGE\\20241220\\2_06090976_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:09 CAMERA1 D:\\IMAGE\\20241220\\1_06090981_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA2 D:\\IMAGE\\20241220\\2_06090999_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA2 D:\\IMAGE\\20241220\\2_06091026_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA1 D:\\IMAGE\\20241220\\1_06091049_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:10 CAMERA2 D:\\IMAGE\\20241220\\2_06091067_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA2 D:\\IMAGE\\20241220\\2_06091095_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA1 D:\\IMAGE\\20241220\\1_06091117_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA2 D:\\IMAGE\\20241220\\2_06091135_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA2 D:\\IMAGE\\20241220\\2_06091162_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:11 CAMERA1 D:\\IMAGE\\20241220\\1_06091186_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:12 CAMERA2 D:\\IMAGE\\20241220\\2_06091209_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:12 CAMERA2 D:\\IMAGE\\20241220\\2_06091249_522184XXXXXX4614_INTERVAL_CAPTURE.JPG \n20/12/2024 06:09:12 CASH PRESENT TIMER EXPIRED \n20/12/2024 06';
        dt.filename ='ej_10_102_13_96';
        dt.ip_address = '10.102.13.96';
        SCC_CaseResolution_EJOLWrapper.EJLogResponse res = new SCC_CaseResolution_EJOLWrapper.EJLogResponse();
        res.code = 200;
        res.message = 'OK';
        res.data = dt;
        return res;
    }

    public static SCC_CaseResolution_EJOLWrapper.EJLogResponseError ejLogResponseError(){
        SCC_CaseResolution_EJOLWrapper.EJLogData dt = new SCC_CaseResolution_EJOLWrapper.EJLogData();
        dt.field = 'date_request';
        dt.message = 'Date must less than 100 days';
        List<SCC_CaseResolution_EJOLWrapper.EJLogData> ldt = new List<SCC_CaseResolution_EJOLWrapper.EJLogData>();
        ldt.add(dt);
        SCC_CaseResolution_EJOLWrapper.EJLogResponseError res = new SCC_CaseResolution_EJOLWrapper.EJLogResponseError();
        res.code = 400;
        res.message = 'OK';
        res.data = ldt;
        return res;
    }

    public static SCC_CaseResolution_EJOLWrapper.EJLogRequest ejLogRequest(){
        SCC_CaseResolution_EJOLWrapper.EJLogRequest req = new SCC_CaseResolution_EJOLWrapper.EJLogRequest();
        req.dateRequest = '2022-02-02';
        req.ipAddress  = '10.102.13.96';
        req.tid = '00060012';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse cardApplicationResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CardApplicationData cad = new SCC_CaseResoultion_DataHub_Wrapper.CardApplicationData();
        cad.namaNasabahLengkap ='LILIS DAMAYANTI';
        cad.nik ='3275034101950023';
        cad.tanggalLahir ='1995-12-30T00:00:00';
        cad.nomorAplikasiPengajuan ='CX3565100100000305';
        cad.tanggalPengajuan ='CUSTPERSONAL';
        cad.channelPengajuan ='CUSTPERSONAL';
        cad.nomorKartuKredit ='CUSTPERSONAL';
        cad.progressPengajuan ='CUSTPERSONAL';
        List<SCC_CaseResoultion_DataHub_Wrapper.CardApplicationData> lcad = new List<SCC_CaseResoultion_DataHub_Wrapper.CardApplicationData>();
        lcad.add(cad);
        SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardApplicationResponse();
        res.CUSTPERSONAL = lcad;
        res.code = 'bad-request';
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardApplicationRequest cardApplicationRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.CardApplicationRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardApplicationRequest();
        req.idNumber = '3275034101950023';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse briMolaResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaTrxData trxData = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaTrxData();
        trxData.agenName = 'Agent 1';
        trxData.biayaAdmin = '10000';
        trxData.hargaTabung = '20000';
        trxData.jenisPembayaran = 'Cash';
        trxData.jumlahTabung = '2';
        trxData.noBriva = '1234567890';
        trxData.orderId = 'ORD001';
        trxData.pangkalanName = 'Pangkalan A';
        trxData.statusBayar = 'Paid';
        trxData.tanggalOrder = '2024-09-20';
        trxData.totalHarga = '40000';

        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaTrx trx = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaTrx();
        trx.data = new List<SCC_CaseResoultion_DataHub_Wrapper.BRIMolaTrxData>{ trxData };

        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaData molaData = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaData();
        molaData.agenAlamat = '123 Street';
        molaData.agenId = 'A001';
        molaData.agenName = 'Agent 1';
        molaData.agenNorek = '9876543210';
        molaData.corpBriva = 'Corp A';
        molaData.corpClientBriva = 'Client A';
        molaData.pangkalanName = 'Pangkalan A';
        molaData.pangkalanId = 'P001';
        molaData.BrilinkTrxByIdKeagenan = trx;

        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaIdPangkalan idPangkalan = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaIdPangkalan();
        idPangkalan.data = molaData; //new List<SCC_CaseResoultion_DataHub_Wrapper.BRIMolaData>{ molaData };
        idPangkalan.rc = '00';
        idPangkalan.descr = 'Success';

        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaInquiry inquiry = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaInquiry();
        inquiry.inquiryBrimolaPangkalan = idPangkalan;

        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse response = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaResponse();
        response.chmGraphql = inquiry;
        response.error = 'Unexpected variable phoneNumberr';
        response.path = '$';
        response.code = '200';
        return response;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest briMolaRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest req = new SCC_CaseResoultion_DataHub_Wrapper.BRIMolaRequest();
        req.endDate = '2024-12-31';
        req.startDate = '2024-01-01';
        req.idPangkalan = '923749273982743';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse trxMerchantResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantData trxData = new SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantData();
        trxData.trxDate = '2024-09-21';
        trxData.trxTime = '12:00:00';
        trxData.midOrMpan = '1234567890';
        trxData.tidOrStoreId = 'TID123';
        trxData.appCodeReffNum = 'APP123';
        trxData.jenisTrx = 'Purchase';
        trxData.trxAmount = 100.50;
        trxData.mti = '0200';
        trxData.merchantName = 'Test Merchant';
        trxData.noKartuCpan = '4111111111111111';
        trxData.batchNo = 'Batch001';
        trxData.mdr = '0.50';
        trxData.channelID = 'Channel1';
        trxData.proccode = '00';
        trxData.namaFitur = 'Feature1';
        trxData.localCrossBorder = 'Local';
        trxData.onUsNotOnUs = 'OnUs';
        trxData.cardType = 'Credit';
        trxData.rc = '00';
        trxData.status = 'Completed';
        trxData.trxStatus = 'Success';
        trxData.trxType = 'Sale';
        trxData.traceNum = 'Trace001';
        trxData.location = 'Location1';
        trxData.address = '123 Test St';
        trxData.acqBank = 'Acquirer Bank';
        trxData.posEntryMode = 'Mode1';
        trxData.settleAmount = '100.50';
        trxData.settleDate = '2024-09-22';
        trxData.paymentDate = '2024-09-21';
        trxData.noRekMerchant = 'Account123';
        trxData.paymentRemark = 'Payment for services';
        trxData.switchs = 'Switch1';

        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse trxResponse = new SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantResponse();
        trxResponse.statusCode = 200;
        trxResponse.errorCode = null;
        trxResponse.responseCode = '00';
        trxResponse.responseMessage = 'Success';
        trxResponse.errors = null;
        trxResponse.data = new List<SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantData>{trxData};
        return trxResponse;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest trxMerchantRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest trxRequest = new SCC_CaseResoultion_DataHub_Wrapper.TrxMerchantRequest();
        trxRequest.midOrMpan = '1234567890';
        trxRequest.tidOrStoreId = 'TID123';
        trxRequest.trxDate = '2024-09-21';
        trxRequest.trxTime = '12:00:00';
        trxRequest.appCodeOrReffNum = 'APP123';
        return trxRequest;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardResponse cardResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.CardHistoryData historyData = new SCC_CaseResoultion_DataHub_Wrapper.CardHistoryData();
        historyData.accNo = 'ACC123';
        historyData.activeDate = '2024-01-01';
        historyData.blockDate = '2024-06-01';
        historyData.branchCode = 'BR001';
        historyData.cardNo = 'CARD123';
        historyData.cardStatus = 'Active';
        historyData.expDate = '2025-01-01';
        historyData.issueDate = '2023-01-01';
        historyData.lastMaint = '2024-09-01';
        historyData.mbNo = 'MB001';
        historyData.mbStatus = 'Active';
        historyData.renewalDate = '2024-12-31';
        historyData.typeCode = 'Type1';
        historyData.userBlock = 'User1';

        SCC_CaseResoultion_DataHub_Wrapper.CardHistoryResponseData responseData = new SCC_CaseResoultion_DataHub_Wrapper.CardHistoryResponseData();
        responseData.data = new List<SCC_CaseResoultion_DataHub_Wrapper.CardHistoryData>{historyData};

        SCC_CaseResoultion_DataHub_Wrapper.CardHistoryAccount historyAccount = new SCC_CaseResoultion_DataHub_Wrapper.CardHistoryAccount();
        historyAccount.responseData = responseData;

        SCC_CaseResoultion_DataHub_Wrapper.CardData cardData = new SCC_CaseResoultion_DataHub_Wrapper.CardData();
        cardData.accNo = 'ACC123';
        cardData.cardNo = 'CARD123';
        cardData.type = 'Visa';
        cardData.name = 'Test User';
        cardData.activeDate = '2024-01-01';
        cardData.expDate = '2025-01-01';
        cardData.issueDate = '2023-01-01';
        cardData.cardStatus = 'Active';
        cardData.lastMaint = '2024-09-01';
        cardData.userMaint = 'User1';
        cardData.statusDesc = 'Active';
        cardData.blockDate = '2024-06-01';
        cardData.userBlock = 'User2';
        cardData.historyAccount = historyAccount;

        SCC_CaseResoultion_DataHub_Wrapper.CardInquiryData inquiryData = new SCC_CaseResoultion_DataHub_Wrapper.CardInquiryData();
        inquiryData.responseCode = '00';
        inquiryData.responseDesc = 'Success';
        inquiryData.status = 'Completed';
        inquiryData.data = cardData;

        SCC_CaseResoultion_DataHub_Wrapper.CardInquiry inquiry = new SCC_CaseResoultion_DataHub_Wrapper.CardInquiry();
        inquiry.inquiryCardData = inquiryData;

        SCC_CaseResoultion_DataHub_Wrapper.CardResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CardResponse();
        res.chmGraphql = inquiry;
        res.error = 'Unexpected variable phoneNumberr';
        res.path = '$';
        res.code = '200';
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.CardRequest cardRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.CardRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CardRequest();
        req.cardNo = '34343432432432423';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse holdStatusResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusData holdData = new SCC_CaseResoultion_DataHub_Wrapper.HoldStatusData();
        holdData.acctNo = '123456';
        holdData.acctType = 'Checking';
        holdData.expdate = '12/25';
        holdData.holdAmt = '1000';
        holdData.holdBranch = 'Main Branch';
        holdData.holdDate = '09/22/2024';
        holdData.holdRemark = 'Initial Hold';
        holdData.holdSeq = '1';
        holdData.holdType = 'Temporary';
        holdData.recordId = '001234567890';

        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponseData responseData = new SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponseData();
        responseData.data =  new List<SCC_CaseResoultion_DataHub_Wrapper.HoldStatusData>{holdData};
        responseData.errorCode = 'AS-000';
        responseData.responseCode = '00';
        responseData.responseMessage = 'Transaction Successfully';

        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse holdStatusResponse = new SCC_CaseResoultion_DataHub_Wrapper.HoldStatusResponse();
        holdStatusResponse.inquiryHoldStatus = responseData;
        holdStatusResponse.error ='Unexpected variable xx';
        holdStatusResponse.path = '$';
        holdStatusResponse.code = 'bad-request';
        return holdStatusResponse;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest holdStatusRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest request = new SCC_CaseResoultion_DataHub_Wrapper.HoldStatusRequest();
        request.acctNo = '123456';
        request.externalId = 'ext-001';
        request.channelId = 'web';
        request.serviceId = 'service-001';
        request.tellerId = 'teller-123';
        return request;
    }

    // herbing

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestErrorModel(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = '';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKPBlankModel(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = 'OPEN';
        rgmsd.area = 'KP';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKPBlank2Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = 'CLOSED';
        rgmsd.area = 'KP';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKPBlank3Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = 'CANCEL';
        rgmsd.area = 'KP';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKPBlank4Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = '';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKPFalseModel(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'DC';
        rgmsd.costCenter = 'P90RT';
        rgmsd.region = 'G';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKPModel(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'KP';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestKP1Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'KP';
        rgmsd.costCenter = 'PS98502';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestROModel(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestROModel1(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = 'OPEN';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestROModel2(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = 'CLOSED';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestROModel3(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = 'CANCEL';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestRO1Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = 'B';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestRO2Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = 'B';
        rgmsd.mainBranch = '113';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetRequest_Model bristarRequestRO3Model(){
        BristarSummary_API_Wrapper.GetRequest_Model rgmsd = new BristarSummary_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.statusTicket = '';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = 'B';
        rgmsd.mainBranch = '113';
        rgmsd.branch = '00113';
        rgmsd.page = '1';
        rgmsd.lmt = '1';
        return rgmsd;
    }

    public static BristarSummary_API_Wrapper.GetResponseKP_Model bristarResponseKPModel(){
        BristarSummary_API_Wrapper.GetDetailKP_Model rgmsdd = new BristarSummary_API_Wrapper.GetDetailKP_Model();
        rgmsdd.costCenter='PS98502';
        rgmsdd.costCenterDesc ='DIVISI SERVICE & CONTACT CENTER';
        rgmsdd.openTicket ='4';
        rgmsdd.closedTicket ='0';
        rgmsdd.overSla='3';
        rgmsdd.onSla ='1';
        List<BristarSummary_API_Wrapper.GetDetailKP_Model> listrgmsdd = new List<BristarSummary_API_Wrapper.GetDetailKP_Model>();
        listrgmsdd.add(rgmsdd);

        BristarSummary_API_Wrapper.GetResponseKP_Model rgmsr = new BristarSummary_API_Wrapper.GetResponseKP_Model();
        rgmsr.divisionSummary = listrgmsdd;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'KP';
        return rgmsr;
    }

    public static BristarSummary_API_Wrapper.GetResponseKP1_Model bristarResponseKP1Model(){
        BristarSummary_API_Wrapper.GetDetailKP1_Model rgmsdd = new BristarSummary_API_Wrapper.GetDetailKP1_Model();
        rgmsdd.caseNumber='TICKET001840138';
        rgmsdd.createdTime ='2024-07-02 22:12:02';
        rgmsdd.closedTime ='';
        rgmsdd.status ='Returned';
        rgmsdd.caseType='8713';
        rgmsdd.caseDescription ='Nasabah Komplain Gagal Top Up/Transaksi Brizzi & Saldo Berkurang';
        rgmsdd.slaSaatIni ='90';
        rgmsdd.targetSla ='5';
        rgmsdd.gapTerhadapSla ='-85';
        List<BristarSummary_API_Wrapper.GetDetailKP1_Model> listrgmsdd = new List<BristarSummary_API_Wrapper.GetDetailKP1_Model>();
        listrgmsdd.add(rgmsdd);

        BristarSummary_API_Wrapper.GetResponseKP1_Model rgmsr = new BristarSummary_API_Wrapper.GetResponseKP1_Model();
        rgmsr.ticketSummary = listrgmsdd;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'KP';
        rgmsr.costCenter = 'PS98502';
        rgmsr.costCenterDesc = 'DIVISI SERVICE & CONTACT CENTER';
        rgmsr.openTicket = '44';
        rgmsr.closedTicket = '11';
        rgmsr.overSla = 'KP';
        rgmsr.onSLa = '12';
        return rgmsr;
    }

    public static BristarSummary_API_Wrapper.GetResponseRO_Model bristarResponseROModel(){
        BristarSummary_API_Wrapper.GetDetailRO_Model rgmsdd = new BristarSummary_API_Wrapper.GetDetailRO_Model();
        rgmsdd.region='G';
        rgmsdd.regionDesc ='G -- Semarang';
        rgmsdd.openTicket ='541';
        rgmsdd.closedTicket ='0';
        rgmsdd.overSla='10';
        rgmsdd.onSla ='531';
        List<BristarSummary_API_Wrapper.GetDetailRO_Model> listrgmsdd = new List<BristarSummary_API_Wrapper.GetDetailRO_Model>();
        listrgmsdd.add(rgmsdd);

        BristarSummary_API_Wrapper.GetResponseRO_Model rgmsr = new BristarSummary_API_Wrapper.GetResponseRO_Model();
        rgmsr.regionSummary = listrgmsdd;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        return rgmsr;
    }

    public static BristarSummary_API_Wrapper.GetResponseRO1_Model bristarResponseRO1Model(){
        BristarSummary_API_Wrapper.GetDetailRO1_Model rgmsdd = new BristarSummary_API_Wrapper.GetDetailRO1_Model();
        rgmsdd.mainBranch='101';
        rgmsdd.mainBranchDesc ='KC Tegal';
        rgmsdd.openTicket ='45';
        rgmsdd.closedTicket ='0';
        rgmsdd.overSla='10';
        rgmsdd.onSla ='35';
        List<BristarSummary_API_Wrapper.GetDetailRO1_Model> listrgmsdd = new List<BristarSummary_API_Wrapper.GetDetailRO1_Model>();
        listrgmsdd.add(rgmsdd);

        BristarSummary_API_Wrapper.GetResponseRO1_Model rgmsr = new BristarSummary_API_Wrapper.GetResponseRO1_Model();
        rgmsr.mainBranchSummary = listrgmsdd;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        rgmsr.region = 'G';
        rgmsr.regionDesc = 'G -- Semarang';
        return rgmsr;
    }

    public static BristarSummary_API_Wrapper.GetResponseRO2_Model bristarResponseRO2Model(){
        BristarSummary_API_Wrapper.GetDetailRO2_Model rgmsdd = new BristarSummary_API_Wrapper.GetDetailRO2_Model();
        rgmsdd.branch='00101';
        rgmsdd.branchDesc ='101 - KC Tegal';
        rgmsdd.openTicket ='13';
        rgmsdd.closedTicket ='0';
        rgmsdd.overSla='10';
        rgmsdd.onSla ='3';
        List<BristarSummary_API_Wrapper.GetDetailRO2_Model> listrgmsdd = new List<BristarSummary_API_Wrapper.GetDetailRO2_Model>();
        listrgmsdd.add(rgmsdd);

        BristarSummary_API_Wrapper.GetResponseRO2_Model rgmsr = new BristarSummary_API_Wrapper.GetResponseRO2_Model();
        rgmsr.branchSummary = listrgmsdd;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        rgmsr.region = 'G';
        rgmsr.regionDesc = 'G -- Semarang';
        rgmsr.mainBranch = '101';
        rgmsr.mainBranchDesc = 'KC Tegal';
        return rgmsr;
    }

    public static BristarSummary_API_Wrapper.GetResponseRO3_Model bristarResponseRO3Model(){
        BristarSummary_API_Wrapper.GetDetailRO3_Model rgmsdd = new BristarSummary_API_Wrapper.GetDetailRO3_Model();
        rgmsdd.targetSla='5';
        rgmsdd.status ='New';
        rgmsdd.slaSaatIni ='2';
        rgmsdd.gapTerhadapSla ='3';
        rgmsdd.createdTime='2024-10-07 15:02:10';
        rgmsdd.closedTime ='';
        rgmsdd.caseType ='1003';
        rgmsdd.caseNumber ='TICKET001868934';
        rgmsdd.caseDescription ='xxx';
        List<BristarSummary_API_Wrapper.GetDetailRO3_Model> listrgmsdd = new List<BristarSummary_API_Wrapper.GetDetailRO3_Model>();
        listrgmsdd.add(rgmsdd);

        BristarSummary_API_Wrapper.GetResponseRO3_Model rgmsr = new BristarSummary_API_Wrapper.GetResponseRO3_Model();
        rgmsr.ticketSummary = listrgmsdd;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        rgmsr.overSla = '10';
        rgmsr.openTicket = '13';
        rgmsr.onSLa = '3';
        rgmsr.region = 'G -- Semarang';
        rgmsr.regionDesc = 'G';
        rgmsr.mainBranch = '101';
        rgmsr.mainBranchDesc = '101 - KC Tegal';
        rgmsr.branch = '00101';
        rgmsr.branchDesc = 'KC Tegal';
        rgmsr.closedTicket = '0';
        return rgmsr;
    }

    public static String getTestCaseKP() {
        String Query = 'SELECT Id, Area__c, Date__c, IsClosed__c, Cost_Center__c, SLA_saat_ini__c, Total_SLA_2__c, Gap_Terhadap_SLA__c, ClosedDate, Description, Status, CreatedDate, Case_Number__c, Region__c, Region_Name__c, Main_Branch__c, Main_Branch_Description__c, Branch_Code__c, Within_Target_SLA__c, Branch_Unit_Name__c, Cost_Center_Description__c, SCC_Call_Type__r.Name, SCC_Call_Type__r.SSC_Case_Description__c FROM Case WHERE Date__c >= 2024-01-01 AND Date__c <= 2024-12-31AND Status != \'Cancelled\' AND Status != \'Disconnected\' AND Area__c = \'KP00\' AND Cost_Center__c != null ORDER BY Date__c';
        return Query;
    }

    public static SSC_Call_Type__c setCaseType(String ctid){
        SSC_Call_Type__c ct = new SSC_Call_Type__c();
        ct.Active__c = true;
        ct.SSC_Case_Description__c = 'Cek';
        ct.name = ctid;
        ct.SCC_Level1_OLA__c = 6;
        ct.SCC_Level2_OLA__c = 6;
        ct.SCC_Level3_OLA__c = 6;
        ct.SCC_Level4_OLA__c = 6;
        ct.External_Id__c = ctid;
        ct.SCC_Customer_Segment__c = 'UMKM';
        ct.SSC_Product_L1__c = 'Servicing';
        ct.SSC_Product_L2__c = 'Cash Management';
        ct.SSC_Case_Category__c = 'Request';
        ct.SCC_Additional_Details__c = 'Description Case';
        return ct;
    }

    public static Case setCaseBristar(String status, String ctid){
        Case cs = new Case();
        cs.subject = 'test';
        cs.SCC_Call_Type__c = ctid;
        cs.Description = 'Test';
        cs.Cost_Center__c = 'CC001';
        cs.Status = status;
        // Set dates to force specific SLA calculations
        if(cs.status.equalsIgnoreCase('Closed') || 
           cs.status.equalsIgnoreCase('Cancelled') || 
           cs.status.equalsIgnoreCase('Disconnected')) {
            // For closed cases, set dates to ensure over/under SLA
            cs.CreatedDate = System.today().addDays(-7);  // A week ago
            cs.ClosedDate = System.today();
        } else {
            // For open cases
            cs.CreatedDate = System.today().addDays(-2);  // 2 days ago
        }
        cs.Origin  = 'MMS';
        cs.SCC_Terminal_ID__c = '123456';
        cs.SCC_Waktu_Transaksi__c = system.now();
        cs.SCC_Transaction_Date__c = system.today();
        cs.SCC_Status_Transaksi__c = 'Berhasil';
        return cs ;
    }

    public static BristarSummary_API_Wrapper.GetDetailKP_Model createTestDetailKP() {
        BristarSummary_API_Wrapper.GetDetailKP_Model summary = new BristarSummary_API_Wrapper.GetDetailKP_Model();
        summary.costCenter = 'CC001';
        summary.costCenterDesc = 'Test Cost Center';
        summary.openTicket = '0';
        summary.closedTicket = '0';
        summary.overSla = '0';
        summary.onSla = '0';
        return summary;
    }

    public static BristarSummary_API_Wrapper.GetDetailRO_Model createTestDetailRO() {
        BristarSummary_API_Wrapper.GetDetailRO_Model summary = new BristarSummary_API_Wrapper.GetDetailRO_Model();
        summary.region = 'G';
        summary.regionDesc = 'G Makasar';
        summary.openTicket = '0';
        summary.closedTicket = '0';
        summary.overSla = '0';
        summary.onSla = '0';
        return summary;
    }

    public static BristarSummary_API_Wrapper.GetDetailRO1_Model createTestDetailRO1() {
        BristarSummary_API_Wrapper.GetDetailRO1_Model summary = new BristarSummary_API_Wrapper.GetDetailRO1_Model();
        summary.mainBranch = '104';
        summary.mainBranchDesc = '104 Makasar';
        summary.openTicket = '0';
        summary.closedTicket = '0';
        summary.overSla = '0';
        summary.onSla = '0';
        return summary;
    }

    public static BristarSummary_API_Wrapper.GetDetailRO2_Model createTestDetailRO2() {
        BristarSummary_API_Wrapper.GetDetailRO2_Model summary = new BristarSummary_API_Wrapper.GetDetailRO2_Model();
        summary.branch = '104002';
        summary.branchDesc = '104 Makasar';
        summary.openTicket = '0';
        summary.closedTicket = '0';
        summary.overSla = '0';
        summary.onSla = '0';
        return summary;
    }

    public static Orgeh__c setOrgeh(){
        Orgeh__c og = new Orgeh__c();
        og.Cost_Center__c = 'CC001';
        og.Cost_Center_Description__c = 'Test Cost Center 1';
        return og;
    }
    
    public static Branch_Unit__c setBranchUnit(String bc, String ut, String kc, String rg){
        Branch_Unit__c bu = new Branch_Unit__c();
        bu.Branch_Code__c = bc;
        bu.Name = '113 - KC Pematang Siantar';
        bu.Kode_Cabang__c = kc;
        bu.Nama_Cabang__c = 'KC Pematang Siantar';
        bu.Region__c = rg;
        bu.Region_Name__c = 'B -- Medan';
        bu.Tipe_Uker__c = ut;
        return bu;
    }

    public static User setUser(String area, String costCenter, String branch, String userName, String email){
        User us = new User();
        us.SCC_Area__c = area;
        us.SCC_Cost_Center__c = costCenter;
        us.SCC_Branch__c = branch;
        us.SCC_Division__c = 'Test Division 1';
        us.LastName = 'TestUser';
        us.Alias = 'tuser';
        us.Username = userName;
        us.Email = email;
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.LanguageLocaleKey = 'en_US';
        us.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        return us;
    }

    public static Monitoring_Summary__c setMonitoringSum(String anomaly, String user){
        Monitoring_Summary__c ms = new Monitoring_Summary__c();
        ms.Date__c = Date.today();
        ms.Frequency_Access__c = 10;
        ms.Anomali_Category__c = anomaly;
        ms.Total__c = 10;
        ms.Total_Access_Not_Create_Case__c = 5;
        ms.Total_Access_Outside_Business_Hours__c = 5;
        ms.OwnerId = user;
        ms.User__c = user;
        return ms;
    }

    public static Anomali_Category__c setAnomaly(String user){
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Anomali_Category__c' AND DeveloperName = 'Extremely_Frequency' LIMIT 1];
        Anomali_Category__c ac = new Anomali_Category__c();
        ac.Frequency__c = 40;
        ac.Name = 'Extremely Frequency Access Datahub Branch';
        ac.RecordTypeId = rt.Id;
        ac.Profile__c = 'Branch Users';
        ac.OwnerId = user;
        return ac;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestKPModel(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = 'KP';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestKPDateBlankModel(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '';
        rgmsd.area = 'KP';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestBlankAreaModel(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = '';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestKP1Model(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = 'KP';
        rgmsd.costCenter = 'PS85000';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '1';
        rgmsd.lmt = '1';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestROModel(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = '';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestRO1Model(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = 'B';
        rgmsd.mainBranch = '';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestRO2Model(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = 'B';
        rgmsd.mainBranch = '113';
        rgmsd.branch = '';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetRequest_Model evMonRequestRO3Model(){
        EventMonitoring_API_Wrapper.GetRequest_Model rgmsd = new EventMonitoring_API_Wrapper.GetRequest_Model();
        rgmsd.startDate = '2024-01-01';
        rgmsd.endDate = '2024-12-31';
        rgmsd.area = 'RO';
        rgmsd.costCenter = '';
        rgmsd.region = 'B';
        rgmsd.mainBranch = '113';
        rgmsd.branch = '00113';
        rgmsd.page = '';
        rgmsd.lmt = '';
        return rgmsd;
    }

    public static EventMonitoring_API_Wrapper.GetResponseKP_Model evMontResponseKPModel(){
        EventMonitoring_API_Wrapper.GetDetailKP_Model rgmsdd = new EventMonitoring_API_Wrapper.GetDetailKP_Model();
        rgmsdd.cosCenter='PS98502';
        rgmsdd.cosCenterDesc ='DIVISI SERVICE & CONTACT CENTER';
        rgmsdd.totalActivities ='40';
        List<EventMonitoring_API_Wrapper.GetDetailKP_Model> activities = new List<EventMonitoring_API_Wrapper.GetDetailKP_Model>();
        activities.add(rgmsdd);

        EventMonitoring_API_Wrapper.GetResponseKP_Model rgmsr = new EventMonitoring_API_Wrapper.GetResponseKP_Model();
        rgmsr.divisionSummary = activities;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'KP';
        return rgmsr;
    }

    public static EventMonitoring_API_Wrapper.GetResponseKP1_Model evMontResponseKP1Model(){
        EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model rgmsdd = new EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model();
        rgmsdd.user_Name='PS98502';
        rgmsdd.total ='DIVISI SERVICE & CONTACT CENTER';
        rgmsdd.tanggal ='40';
        rgmsdd.monitoringSummary_Name ='test monitoring';
        rgmsdd.anomalyCategory_RecordType ='anomaly test';
        List<EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model> activities = new List<EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model>();
        activities.add(rgmsdd);

        EventMonitoring_API_Wrapper.GetResponseKP1_Model rgmsr = new EventMonitoring_API_Wrapper.GetResponseKP1_Model();
        rgmsr.dataActivities = activities;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'KP';
        rgmsr.costCenter = 'PS98502';
        rgmsr.costCenterDesc = 'PS98502';
        rgmsr.totalActivities = '40';
        return rgmsr;
    }

    public static EventMonitoring_API_Wrapper.GetResponseRO_Model evMontResponseROModel(){
        EventMonitoring_API_Wrapper.GetActivitiesRO_Model rgmsdd = new EventMonitoring_API_Wrapper.GetActivitiesRO_Model();
        rgmsdd.anomalyType='PS98502';
        rgmsdd.total ='40';
        List<EventMonitoring_API_Wrapper.GetActivitiesRO_Model> activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO_Model>();
        activities.add(rgmsdd);

        EventMonitoring_API_Wrapper.GetDetailRO_Model rgmsrRO = new EventMonitoring_API_Wrapper.GetDetailRO_Model();
        rgmsrRO.activities = activities;
        rgmsrRO.region = 'B';
        rgmsrRO.regionDesc = 'B -- bandung';
        rgmsrRO.totalActivities = '40';
        List<EventMonitoring_API_Wrapper.GetDetailRO_Model> regionList = new List<EventMonitoring_API_Wrapper.GetDetailRO_Model>();
        regionList.add(rgmsrRO);

        EventMonitoring_API_Wrapper.GetResponseRO_Model rgmsr = new EventMonitoring_API_Wrapper.GetResponseRO_Model();
        rgmsr.regionalOfficeSummary = regionList;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'KP';
        return rgmsr;
    }

    public static EventMonitoring_API_Wrapper.GetResponseRO1_Model evMontResponseRO1Model(){
        EventMonitoring_API_Wrapper.GetActivitiesRO1_Model rgmsdd = new EventMonitoring_API_Wrapper.GetActivitiesRO1_Model();
        rgmsdd.anomalyType='PS98502';
        rgmsdd.total ='40';
        List<EventMonitoring_API_Wrapper.GetActivitiesRO1_Model> activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO1_Model>();
        activities.add(rgmsdd);

        EventMonitoring_API_Wrapper.GetDetailRO1_Model rgmsrRO = new EventMonitoring_API_Wrapper.GetDetailRO1_Model();
        rgmsrRO.activities = activities;
        rgmsrRO.mainBranch = '113';
        rgmsrRO.mainBranchDesc = '113 -- bandung';
        rgmsrRO.totalActivities = '40';
        List<EventMonitoring_API_Wrapper.GetDetailRO1_Model> regionList = new List<EventMonitoring_API_Wrapper.GetDetailRO1_Model>();
        regionList.add(rgmsrRO);

        EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model detailRO = new EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model();
        detailRO.user_Name = 'User 123';
        detailRO.mainBranch = '113';
        detailRO.mainBranchDesc = '113 -- bandung';
        detailRO.branchCode = '00113';
        detailRO.branchDesc = '00113 -- test Branch';
        detailRO.total = '40';
        detailRO.tanggal = '2024-10-30';
        detailRO.monitoringSummary_Name = 'Test Monitoring';
        detailRO.anomalyCategory_RecordType = 'test Anomaly';
        List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model> detailRoList = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model>();
        detailRoList.add(detailRO);

        EventMonitoring_API_Wrapper.GetResponseRO1_Model rgmsr = new EventMonitoring_API_Wrapper.GetResponseRO1_Model();
        rgmsr.branchOfficeSummary = regionList;
        rgmsr.DataActivities = detailRoList;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        rgmsr.region = 'B';
        rgmsr.regionDesc = 'B -- bandung';
        rgmsr.totalActivities = '40';
        return rgmsr;
    }

    public static EventMonitoring_API_Wrapper.GetResponseRO2_Model evMontResponseRO2Model(){
        EventMonitoring_API_Wrapper.GetActivitiesRO2_Model rgmsdd = new EventMonitoring_API_Wrapper.GetActivitiesRO2_Model();
        rgmsdd.anomalyType='PS98502';
        rgmsdd.total ='40';
        List<EventMonitoring_API_Wrapper.GetActivitiesRO2_Model> activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO2_Model>();
        activities.add(rgmsdd);

        EventMonitoring_API_Wrapper.GetDetailRO2_Model rgmsrRO = new EventMonitoring_API_Wrapper.GetDetailRO2_Model();
        rgmsrRO.activities = activities;
        rgmsrRO.branchCode = '00113';
        rgmsrRO.branchDesc = '00113 -- bandung';
        rgmsrRO.totalActivities = '40';
        List<EventMonitoring_API_Wrapper.GetDetailRO2_Model> regionList = new List<EventMonitoring_API_Wrapper.GetDetailRO2_Model>();
        regionList.add(rgmsrRO);

        EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model detailRO = new EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model();
        detailRO.user_Name = 'User 123';
        detailRO.branchCode = '00113';
        detailRO.branchDesc = '00113 -- test Branch';
        detailRO.total = '40';
        detailRO.tanggal = '2024-10-30';
        detailRO.monitoringSummary_Name = 'Test Monitoring';
        detailRO.anomalyCategory_RecordType = 'test Anomaly';
        List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model> detailRoList = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model>();
        detailRoList.add(detailRO);

        EventMonitoring_API_Wrapper.GetResponseRO2_Model rgmsr = new EventMonitoring_API_Wrapper.GetResponseRO2_Model();
        rgmsr.BranchSummary = regionList;
        rgmsr.DataActivities = detailRoList;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        rgmsr.region = 'B';
        rgmsr.regionDesc = 'B -- bandung';
        rgmsr.totalActivities = '40';
        return rgmsr;
    }

    public static EventMonitoring_API_Wrapper.GetResponseRO3_Model evMontResponseRO3Model(){
        EventMonitoring_API_Wrapper.GetDetailRO3_Model rgmsdd = new EventMonitoring_API_Wrapper.GetDetailRO3_Model();
        rgmsdd.user_Name='user123';
        rgmsdd.total ='40';
        rgmsdd.tanggal ='2024-10-30';
        rgmsdd.monitoringSummary_Name ='Test Monitoring';
        rgmsdd.anomalyCategory_RecordType ='Anomaly Test';
        List<EventMonitoring_API_Wrapper.GetDetailRO3_Model> activities = new List<EventMonitoring_API_Wrapper.GetDetailRO3_Model>();
        activities.add(rgmsdd);

        EventMonitoring_API_Wrapper.GetResponseRO3_Model rgmsr = new EventMonitoring_API_Wrapper.GetResponseRO3_Model();
        rgmsr.DataActivities = activities;
        rgmsr.responseMessage = 'Success';
        rgmsr.responseCode = '00';
        rgmsr.area = 'RO';
        rgmsr.region = 'B';
        rgmsr.regionDesc = 'B -- bandung';
        rgmsr.mainBranch = '113';
        rgmsr.mainBranchDesc = '113 -- bandung';
        rgmsr.branchCode = '00113';
        rgmsr.branchDesc = '00113 -- bandung';
        rgmsr.totalActivities = '40';
        return rgmsr;
    }
}