/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@istest
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
        SCC_RekonWrapper.ResponseRekonResult dat4 = responseRekonResult(400000,'Match','Transaction Successful','2022-07-09T20:00:00.000Z');
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
        dt.ejlog = 'DATA DUMMY 20240905\n05/14/2023 00:16:40 ==> Transaction Start\r\n05/14/2023 00:16:40 Terminal ID    [670046]\r\n05/14/2023 00:16:40 Cardless Menu\r\n05/14/2023 00:17:20 INFORMATION_ENTER\r\n05/14/2023 00:17:26 INFORMATION_ENTER\r\n05/14/2023 00:17:27 PING Success!\r\n05/14/2023 00:17:27 Transaction Req. Send: Succeeded\r\n05/14/2023 00:17:27 [OP Code]: [A   I   ]\r\n05/14/2023 00:17:27 [Amount Entry Field]: [00000000]\r\n05/14/2023 00:17:27 [Last TSN]: [0007]\r\n05/14/2023 00:17:28 Transaction Res. Received\r\n05/14/2023 00:17:28 [Replied TSN]: [0008]\r\n05/14/2023 00:17:28 [Next State]: [016]\r\n05/14/2023 00:17:28 [Function Identifier]: [2]\r\n05/14/2023 00:17:39 Notes Dispensed:\r\nIDR100000*1\nTotal Amount IDR 100000\r\nA1093:B2093:C0000:D0250:E0140:F0000:R0000\r\nDispensed Note\r\nEDO216820\r\n*********\r\n05/14/2023 00:17:39 TRANSACTION DATA (COMPLETED)\r\n[Transaction record]\r\nOPCode              [A   I   ]\r\nFunction ID         [2]\r\nCard Number         [601350******0000]\r\nAmount              [0000000100000]\r\nDenomination        [A,A,B,B]\r\nRequest Count       [01,00,00,00]\r\nDispense Count      [1,0,0,0]\r\nRemain Count        [1093,2093,0,250]\r\nPickup Count        [1,0,0,0]\nReject Count        [0,0,0,0]\r\nTrans SEQ Number [0008]\r\nError Code   [0000000]\r\n[Jpr contents]\r\n+++++++++++++++++++++++++++++++++++++++++++++\r\n\r\n05/14/2023 00:17:39 TANGGAL: 14/05/23   WAKTU : 00:17:29\r\nATM ID : 670046     NO.REF: 148\r\nCARD   : 6013500000000000    \r\nREK    : 089666567575\r\nKODETX : 901  TBANK\r\nAMOUNT : RP 100.000\r\nSALDO  : RP 0\r\nRESPON : 00   Sukses\r\nSWITCHING  : BRIMO\r\n\n+++++++++++++++++++++++++++++++++++++++++++++\r\n05/14/2023 00:17:40 Cash Presented\r\n05/14/2023 00:17:46 Printed Receipt Printer\r\n05/14/2023 00:17:46 Solicited Status  Send: Succeeded\r\n05/14/2023 00:17:48 Cash Taken\r\n05/14/2023 00:17:55 <== Transaction End\r\n05/14/2023 08:04:47 ==> Transaction Start\r\n05/14/2023 08:04:47 Terminal ID    [670046]\r\n05/14/2023 08:04:47 Card Inserted\r\n05/14/2023 08:04:50 PING Success!\r\n05/14/2023 08:04:50 Transaction Req. Send: Succeeded\r\n05/14/2023 08:04:50 [OP Code]: [        ]\r\n05/14/2023 08:04:50 [Amount Entry Field]: [00000000]\n05/14/2023 08:04:50 [Last TSN]: [0161]\r\n05/14/2023 08:04:50 Transaction Res. Received\r\n05/14/2023 08:04:50 [Replied TSN]: [0161]\r\n05/14/2023 08:04:50 [Next State]: [800]\r\n05/14/2023 08:04:50 [Function Identifier]: [5]\r\n05/14/2023 08:04:50 TRANSACTION DATA (COMPLETED)\r\n[Transaction record]\r\nOPCode              [        ]\r\nFunction ID         [5]\r\nCard Number         [603605******1821]\r\nAmount              [0000000000000]\r\nTrans SEQ Number [0161]\r\nError Code   [0000000]\r\n[Jpr contents]\r\n+++++++++++++++++++++++++++++++++++++++++++++\r\n\n05/14/2023 08:04:50 TANGGAL: 14/05/23   WAKTU : 08:04:52\r\nATM ID : 670046     NO.REF: 14161\r\nCARD   : 6036050060101821    \r\nREK    :     \r\nKODETX : 998  flipm\r\nAMOUNT : RP 0\r\nSALDO  :    \r\nRESPON : F1   PRIMA\r\n\r\n+++++++++++++++++++++++++++++++++++++++++++++\r\n05/14/2023 08:04:51 Solicited Status  Send: Succeeded\r\n05/14/2023 08:04:58 Card Number: 603605******1821\r\n05/14/2023 08:05:03 PIN Entered: 603605******1821\r\n05/14/2023 08:05:10 PING Success!\r\n05/14/2023 08:05:11 Transaction Req. Send: Succeeded\r\n05/14/2023 08:05:11 [OP Code]: [A B     ]\n05/14/2023 08:05:11 [Amount Entry Field]: [00500000]\r\n05/14/2023 08:05:11 [Last TSN]: [0161]\r\n05/14/2023 08:05:12 Transaction Res. Received\r\n05/14/2023 08:05:12 [Replied TSN]: [0162]\r\n05/14/2023 08:05:12 [Next State]: [016]\r\n05/14/2023 08:05:12 [Function Identifier]: [A]\r\n05/14/2023 08:05:25 Card Ejected\r\n05/14/2023 08:05:27 Card Removed\r\n05/14/2023 08:05:27 Solicited Status  Send: Succeeded\r\n05/14/2023 08:05:27 Notes Dispensed:\r\nIDR100000*3\r\nIDR50000*4\r\nTotal Amount IDR 500000\r\nA1087:B2093:C0000:D0377:E0144:F0000:R0000\r\nDispensed Note\r\nFHG504717,TQB930605,L?????132,MJM944226,EBL624093,\nVAZ509406,JSO531010\r\n*********\r\n05/14/2023 08:05:27 TRANSACTION DATA (COMPLETED)\r\n[Transaction record]\r\nOPCode              [A B     ]\r\nFunction ID         [A]\r\nCard Number         [603605******1821]\r\nAmount              [0000000500000]\r\nDenomination        [A,A,B,B]\r\nRequest Count       [03,00,00,04]\r\nDispense Count      [3,0,0,4]\r\nRemain Count        [1087,2093,0,377]\r\nPickup Count        [3,0,0,4]\r\nReject Count        [0,0,0,0]\r\nTrans SEQ Number [0162]\r\nError Code   [000000]\n';
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