/**
 * @description       : test object wrapper
 * @author            : Femy
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@istest
public with sharing class Object_Test2 {
    public static SCC_CASA_Wrapper.RequestHoldAmount setRequestHoldAmount(){
        SCC_CASA_Wrapper.DetailRequestHoldAmount reqdt = new SCC_CASA_Wrapper.DetailRequestHoldAmount();
        reqdt.accountNumber = '020601076526501';
        reqdt.holdAmount = '30000000';
        reqdt.remarkHold = 'TEST HOLD 2';
        reqdt.expirationDate = '101024';
        reqdt.datePlaced = '150125';
        reqdt.externalId = '280320240017';
        reqdt.serviceId = '0002S';
        reqdt.channelId = 'CHM';
        reqdt.tellerId = '0019051';
        reqdt.holdType = 'HG';
        reqdt.tellerHold = '0206051';
        SCC_CASA_Wrapper.RequestHoldAmount req = new SCC_CASA_Wrapper.RequestHoldAmount();
        req.request = reqdt;
        return req;
    }

    public static SCC_CASA_Wrapper.ResponseHoldAmount setResponseHoldAmount(){
        SCC_CASA_Wrapper.DetailResponseHoldAmount reqdt = new SCC_CASA_Wrapper.DetailResponseHoldAmount();
        reqdt.errorCode = 'AS-000';
        reqdt.responseCode = '00';
        reqdt.responseMessage = 'Transaction Successfully';
        reqdt.accountNumber = '0000020601076526501';
        reqdt.holdSequence = '00000000020';
        reqdt.holdType = 'HG';
        reqdt.holdAmt = '0000030000000.00';
        reqdt.holdRemark = 'TEST HOLD 2';
        reqdt.expiredDate = '0101024';
        reqdt.userId = '0019051';
        reqdt.holdTime = '0184634';
        reqdt.holdDate = '0150125';
        SCC_CASA_Wrapper.ResponseHoldAmount req = new SCC_CASA_Wrapper.ResponseHoldAmount();
        req.response = reqdt;
        return req;
    }

    public static SCC_CASA_Wrapper.RequestUnholdAmount setRequestUnholdAmount(){
        SCC_CASA_Wrapper.DetailRequestUnholdAmount reqdt = new SCC_CASA_Wrapper.DetailRequestUnholdAmount();
        reqdt.accountNumber = '020601076526501';
        reqdt.holdSeq = '2';
        reqdt.externalId = 'YSFF009';
        reqdt.channelId = 'CHM';
        reqdt.serviceId = '0002M';
        reqdt.tellerId = '0206891';
        SCC_CASA_Wrapper.RequestUnholdAmount req = new SCC_CASA_Wrapper.RequestUnholdAmount();
        req.request = reqdt;
        return req;
    }

    public static SCC_CASA_Wrapper.ResponseUnholdAmount setResponseUnholdAmount(){
        SCC_CASA_Wrapper.DetailResponseUnholdAmount reqdt = new SCC_CASA_Wrapper.DetailResponseUnholdAmount();
        reqdt.errorCode = 'AS-000';
        reqdt.responseCode = '00';
        reqdt.responseMessage = 'Transaction Successfully';
        reqdt.accountNumber = '0000020601076526501';
        reqdt.holdSeq = '00000000020';
        SCC_CASA_Wrapper.ResponseUnholdAmount req = new SCC_CASA_Wrapper.ResponseUnholdAmount();
        req.response = reqdt;
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest setbriLinkProfileRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = Object_Test.briLinkProfileRequest();
        req.outletCode = '12345678';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse setbriLinkProfileResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileResponse res = Object_Test.briLinkProfileResponse();
        for(SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfile bp:res.BRILINK_PROFILE){
            bp.outlet_code = '0987655555';
        }
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCRequest setPengajuanCCRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCRequest req = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCRequest();
        req.idNumber = '8748124789127389712';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCResponse setPengajuanCCResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDeskripsi pccd = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDeskripsi();
        pccd.deskripsiPengajuan = 'Document Checking';
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCAppFlag pcca = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCAppFlag();
        pcca.Deskripsi = pccd;
        pcca.progresPengajuan = '1.1';
        List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCAppFlag> lpcca = new List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCAppFlag>();
        lpcca.add(pcca);
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCCustPro pcccp = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCCustPro();
        pcccp.nomorKartuKredit = '3565100100000206';
        List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCCustPro> lpcccp = new List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCCustPro>();
        lpcccp.add(pcccp);
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataPengajuan pccdp = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataPengajuan();
        pccdp.APPFLAG = lpcca;
        pccdp.CUSTPRO = lpcccp;
        pccdp.channelPengajuan = 'BR';
        pccdp.kodeAplikasiPengajuan = 'kodeAplikasiPengajuan';
        pccdp.tanggalPengajuan = 'tanggalPengajuan';
        List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataPengajuan> lpccdp = new List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataPengajuan>();
        lpccdp.add(pccdp);
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataNasabah pccdn = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataNasabah();
        pccdn.dataPengajuan = lpccdp;
        pccdn.namaNasabahLengkap = 'NIKMATUL AKBAR';
        pccdn.nik = '1871050901890003';
        pccdn.tanggalLahir = '1989-01-09T00:00:00';
        List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataNasabah> lpccdn = new List<SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCDataNasabah>();
        lpccdn.add(pccdn);
        SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCResponse res = new SCC_CaseResoultion_DataHub_Wrapper.PengajuanCCResponse();
        res.dataNasabah = lpccdn;
        return res;
    }
    
    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponse setInquiryBCCMResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponseData resdt = new SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponseData();
        resdt.userName = 'hendrabri888';
        resdt.securityQuestion = 'Jambi';
        resdt.nomorKartuCC = '5520020238158206';
        resdt.nomorHandphone = '085266789888';
        resdt.tanggalRegistrasi = '2022-03-18 10:13:04';
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponseData> lresdt = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponseData>();
        lresdt.add(resdt);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponse res = new SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMResponse();
        res.USER_ACCESS = lresdt;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMRequest setInquiryBCCMRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMRequest req = new SCC_CaseResoultion_DataHub_Wrapper.InquiryBCCMRequest();
        req.cardNumber = '5475820107144301';
        req.phoneNumber = '085266789888';
        req.userName = 'hendrapur01';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCResponse setInquiryPelacakanCCResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCDeliveryData ipccdd = new SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCDeliveryData();
        ipccdd.alamatPengirimanCC1 = 'KOMP DPR II NO 22';
        ipccdd.alamatPengirimanCC2 = 'RT 004, RW 013';
        ipccdd.alamatPengirimanCC3 = 'KEBON JERUK, KEBON JERUK';
        ipccdd.namaVendorPengirim = 'SAP';
        ipccdd.tanggalPengirimanKartu = '2024-09-04 03:56:14';
        ipccdd.namaPenerima = '';
        ipccdd.statusPengirimanKartu = 'CB1';
        ipccdd.tanggalPenerimaKartu = '2024-09-12 17:00:00';
        ipccdd.trackingPengirimanBarang = 'OD';
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCDeliveryData> lipccdd = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCDeliveryData>();
        lipccdd.add(ipccdd);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCEmbossData ipcced = new SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCEmbossData();        
        ipcced.nomorHandphone = '087885542426';
        ipcced.namaNasabahLengkap= 'CHANDRA DIAS';
        ipcced.nomorKartu = '4359650300281608';
        ipcced.DELIVERY_DATA = lipccdd;
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCEmbossData> lipcced = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCEmbossData>();
        lipcced.add(ipcced);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCResponse res = new SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCResponse();
        res.EMBOSS_DATA = lipcced;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCRequest setInquiryPelacakanCCRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCRequest req = new SCC_CaseResoultion_DataHub_Wrapper.InquiryPelacakanCCRequest();
        req.cardNumber = '5475820107144301';
        req.phoneNumber = '085266789888';
        req.namaLengkap = 'CHANDRA DIA';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaResponse setInquiryCeriaResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaTransactionData ictd = new SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaTransactionData();
        ictd.reffNum= 'TKP2047460234';
        ictd.tanggalTrx= '2022-12-07 17=00=00';
        ictd.nominalTransaksi= '10667548.0000';
        ictd.namaMerchant= 'TOKOPEDIA-CERIA';
        ictd.jenisTransaksi= 'purchase';
        ictd.tenorCicilan= '1';
        ictd.sisaBulanCicilan= null;
        ictd.rincianPembayaran= null;
        ictd.statusTransaksi= 'success';
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaTransactionData> lictd = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaTransactionData>();
        lictd.add(ictd);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaData icd = new SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaData();
        icd.ceriaId= '1895121000253510';
        icd.noHP= '0816531936';
        icd.nama= 'NANANG DWI SETIYONO';
        icd.nik= '3522120404830002';
        icd.tanggalPembukaanRekening= '2022-11-28 17=00=00';
        icd.sisaOutstanding= '0.0000';
        icd.sisaLimit= '20000000.0000';
        icd.tanggalPenerbitanBilling= '2024-06-08 17=00=00';
        icd.tanggalJatuhTempo= '2024-06-25';
        icd.nominalPembayaranTerakhir= '10805559.0000';
        icd.tanggalPembayaranTerakhir= '2022-12-26 17=00=00';
        icd.nominalTagihan= '0.0000';
        icd.statusKolektibilitas= '1.0';
        icd.blockCodeKolektibilitas= '';
        icd.blockCodeSystem= '';
        icd.metodeBayar= null;
        icd.nomorRekeningPendebetan= '617701019694532';
        icd.status= 'AKTIF';
        icd.remarks= null;
        icd.referenceNumberPembayaranTerakhir= null;
        icd.statusPembayaranTagihan= null;
        icd.transactionData = lictd;
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaData> licd = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaData>();
        licd.add(icd);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaResponse res = new SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaResponse();
        res.CERIA_MASTER_DATA = licd;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaRequest setInquiryCeriaRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaRequest req = new SCC_CaseResoultion_DataHub_Wrapper.InquiryCeriaRequest();
        req.acctNo = '5475820107144301';
        req.idNumber = '085266789888';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponse setInquiryIbbizResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRekeningData iird = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRekeningData();
        iird.productType= 'S6';
        iird.status= 1;
        iird.accountName= 'LAM SUN ON (haz3l)';
        iird.accountNumber= '020601005578533';
        iird.accountType= 'S';
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRekeningData> liird = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRekeningData>();
        liird.add(iird);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizListRekeningData iilrd = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizListRekeningData();
        iilrd.listData = liird;
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizUserData iiud = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizUserData();
        iiud.userType= 1;
        iiud.id= 10002343;
        iiud.name= 'Bil Nasution';
        iiud.email= 'sitikhairaninasution31@gmail.com';
        iiud.handphone= '0895613333786';
        iiud.lastLogin= '0001-01-01T00=00=00Z';
        iiud.lastLogout= '1970-01-01T08=00=00+07=00';
        List<SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizUserData> liiud = new List<SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizUserData>();
        liiud.add(iiud);
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizListUserData iilud = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizListUserData();
        iilud.listData = liiud;
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizClientData iicd = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizClientData();
        iicd.accNumber= '022501000538564';
        iicd.handle= 'IBBIZUIUX';
        iicd.name= 'SIGNER';
        iicd.id= 10001361;
        iicd.createdAt= '2024-10-23T04=03=21+07=00';
        iicd.branchCode= '';
        iicd.cardNumber= '5221847700392232';
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizData iid = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizData();
        iid.responseCode= '00';
        iid.responseDesc= 'success';
        iid.responseMessage= 'OK';
        iid.clientId= 10001361;
        iid.clientData = iicd;
        iid.userData = iilud;
        iid.listRekening = iilrd;
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponseData resdt = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponseData();
        resdt.data = iid;
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizErrorData erd = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizErrorData();
        erd.responseCode= '00';
        erd.responseDesc= 'success';
        erd.responseMessage= 'OK';
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponse res = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizResponse();
        res.response = resdt;
        res.extensions = erd;
        res.message = 'OK';
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRequest setInquiryIbbizRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRequest req = new SCC_CaseResoultion_DataHub_Wrapper.InquiryIbbizRequest();
        req.acctNo = '5475820107144301';
        req.corporateId = '085266789888';
        return req;
    }

    public static SCC_Brimo_Wrapper.ResponseInquiryUserBrimo setResponseInquiryUserBrimo(){
        SCC_Brimo_Wrapper.ActivityHistory ah = new SCC_Brimo_Wrapper.ActivityHistory();
        ah.id = '323477257205';
        ah.reference_num = '323477257205';
        ah.activity_status = 'Sukses';
        ah.activity_type = 'DPLK';
        ah.activity_icon = 'icon_dplk.png';
        ah.activity_date = '15 Jul 2024';
        ah.activity_time = '15:14';
        ah.activity_dest = 'Klaim - 12271229';
        ah.trx_type = 'PaymentUpdateStatusClaimDPLK';
        ah.total_amount = 'Rp2.145.678,99';        
        List<SCC_Brimo_Wrapper.ActivityHistory> lah = new List<SCC_Brimo_Wrapper.ActivityHistory>();
        lah.add(ah);
        SCC_Brimo_Wrapper.AccountList al = new SCC_Brimo_Wrapper.AccountList();
        al.account = '0206********552';
        al.account_name = 'Revamp asuransi';
        al.card_number = '5221********1940';
        al.finansial_status = '1';
        al.product_type = 'Simpedes';
        al.status = '1';
        al.type_account = 'SA';
        List<SCC_Brimo_Wrapper.AccountList> lal = new List<SCC_Brimo_Wrapper.AccountList>();
        lal.add(al);
        SCC_Brimo_Wrapper.LastLoginAttempt lla = new SCC_Brimo_Wrapper.LastLoginAttempt();
        lla.last_login = '';
        lla.login_status = '';
        SCC_Brimo_Wrapper.ResponseDataInquiryUserBrimo rdiub = new SCC_Brimo_Wrapper.ResponseDataInquiryUserBrimo();
        rdiub.account_list = lal;
        rdiub.activity_history = lah;
        rdiub.cellphone_number = '08128709****';
        rdiub.email_address = 'farr****************@gmail.com';
        rdiub.financial_status = '1';
        rdiub.last_login_attempt = lla;
        rdiub.registered_date = '2010-10-10 10:10:10';
        rdiub.status = '3';
        rdiub.user_alias = 'usergans005';
        rdiub.username = 'usersbn005';
        SCC_Brimo_Wrapper.ResponseInquiryUserBrimo res = new SCC_Brimo_Wrapper.ResponseInquiryUserBrimo();
        res.message = '';
        res.response_code = '00';
        res.response_data = rdiub;
        res.response_description = 'Success';
        res.response_id = 'b42a4c4b18054dd5816454d64da07190';
        res.response_refnum = '123456789192';
        return res;
    }

    public static SCC_Brimo_Wrapper.ResponseDeleteUserBrimo setResponseDeleteUserBrimo(){
        SCC_Brimo_Wrapper.ResponseDeleteUserBrimo res = new SCC_Brimo_Wrapper.ResponseDeleteUserBrimo();
        res.message = '';
        res.response_code = '00';
        res.response_desc = 'Success';
        res.response_id = 'b42a4c4b18054dd5816454d64da07190';
        res.response_refnum = '123456789192';
        res.response_description = 'Success';
        return res;
    }

    public static SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo setResponseInquiryOnboardingBrimo(){
        SCC_Brimo_Wrapper.ResponseDataInquiryOnboardingBrimo rdiob = new SCC_Brimo_Wrapper.ResponseDataInquiryOnboardingBrimo();
        rdiob.account = '039001020937501';
        rdiob.name = 'Fatin Nurhalisa Rozsidhy';
        rdiob.nik = '3507185806030001';
        rdiob.status = 14;
        rdiob.status_description = 'Generate Brimo Success';
        SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo res = new SCC_Brimo_Wrapper.ResponseInquiryOnboardingBrimo();
        res.message = '';
        res.response_data = rdiob;
        res.response_code = '00';
        res.response_description = 'Success';
        res.response_id = 'b42a4c4b18054dd5816454d64da07190';
        res.response_refnum = '123456789192';
        return res;
    }

    public static SCC_Brimo_Wrapper.RequestBrimo setRequestBrimo(){
        SCC_Brimo_Wrapper.RequestBrimo req = new SCC_Brimo_Wrapper.RequestBrimo();
        req.client =  'BRIMON';
        req.request_refnum =  '123456789192';
        req.account_number =  '020601000194538';
        req.cellphone_number =  '081287095923';
        req.channel_id =  'NBMB';
        req.cif =  'L096945';
        req.user_id = '234234';
        req.username = 'bejo34';
        req.card_number = '12345678910';
        req.cellphone_number = '082754393180';
        return req;
    }
    
    public static SCC_CaseResoultion_DataHub_Wrapper.LastTransactionResponse setLastTransactionResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.LastTransactionData ltd = new SCC_CaseResoultion_DataHub_Wrapper.LastTransactionData();
        ltd.Tracct = '95301032767500';
        ltd.Trdate = '31/12/2024';
        ltd.Trdate2 = '2024366';
        ltd.Timent = '184938';
        ltd.Dorc = 'D';
        ltd.Amt = 200000;
        ltd.Trremk = 'GOP01 +6285607551555NBMB5221845063847750';
        ltd.RemarkCustom = 'Top Up Gopay+62856xxxx555 via BRImo';
        List<String> listerr = new List<String>{'channel tidak boleh kosong'};
        List<SCC_CaseResoultion_DataHub_Wrapper.LastTransactionData> listltd = new List<SCC_CaseResoultion_DataHub_Wrapper.LastTransactionData>{ltd};
        SCC_CaseResoultion_DataHub_Wrapper.LastTransactionResponse res = new SCC_CaseResoultion_DataHub_Wrapper.LastTransactionResponse();
        res.statusCode = 200;
        res.errorCode = '000';
        res.responseCode = '00';
        res.responseMessage = 'Success';
        res.errors = listerr;
        res.data = listltd;
        return res;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.LastTransactionRequest setLastTransactionRequest(){
        SCC_CaseResoultion_DataHub_Wrapper.LastTransactionRequest req = new SCC_CaseResoultion_DataHub_Wrapper.LastTransactionRequest();
        req.norekVarchar = '095301032767500';
        req.channel = 'CHMS';
        req.jenisTransaksi = '';
        return req;
    }

    public static SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAResponse setReportTransactionBRIVAResponse(){
        SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAData dt = new SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAData();
        dt.brivaNo = '77778';
        dt.uniqueCode = ' ';
        dt.custCode = '85157999142';
        dt.nama = ' ISAKU NIXXXXX ';
        dt.keterangan = ' ';
        dt.amount = 4000000;
        dt.paymentDate = ' 2024-04-29 00:04:28';
        dt.tellerid = '8888581';
        dt.norek = '41501000978301';
        dt.seq = '120038';
        dt.pageShow = ' 1 / 246';
        dt.trremk = ' BRIVA77778085157999142NBMBISAKU NIXXXXX';
        dt.seqOther = ' ';
        dt.jaringan = ' NBMB';
        dt.trstat = ' SUKSES';
        dt.auxtrc = '6669';
        dt.julianDate = '24120';
        dt.trxID = '2412088885810120000';
        dt.totalRow = 4919;
        dt.pageShow = '1 / 246';
        List<String> listerr = new List<String>{'channel tidak boleh kosong'};
        List<SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAData> listdt = new List<SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAData>{dt};
        SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAResponse res = new SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVAResponse();
        res.statusCode = 200;
        res.errorCode = '000';
        res.responseCode = '00';
        res.responseMessage = 'Success';
        res.errors = listerr;
        res.data = listdt;
        return res;
    }
    
    public static SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVARequest setReportTransactionBRIVARequest(){
        SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVARequest req = new SCC_CaseResoultion_DataHub_Wrapper.ReportTransactionBRIVARequest();
        req.corpCode = '77778';
        req.custCode = '';
        req.tanggalAwal = '2024-04-30 00:00:00';
        req.tanggalAkhir = '2024-04-30 00:00:00';
        req.transactionID = '';
        req.reversal = 'Y';
        req.uniqcode = 'ALL';
        req.pageNumber = 1;
        req.rowsPerPage = 20;
        return req;
    }
}