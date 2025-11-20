@istest
public with sharing class Object_Test_Brizzi {
    public static SCC_BrizziWrapper.CardInquiryRequest cardInquiryRequest(){
        SCC_BrizziWrapper.CardInquiryRequestData dt = new SCC_BrizziWrapper.CardInquiryRequestData();
        dt.cardNumber = '6013500300000355';
        dt.userMaker = 'dio';
        List<SCC_BrizziWrapper.CardInquiryRequestData> ldt = new List<SCC_BrizziWrapper.CardInquiryRequestData>();
        ldt.add(dt);

        SCC_BrizziWrapper.CardInquiryRequest req = new SCC_BrizziWrapper.CardInquiryRequest();
        req.data = ldt;
        return req;
    }

    public static SCC_BrizziWrapper.CardInquiryResponse cardInquiryResponse(){
        SCC_BrizziWrapper.CardInquiryResponseData dt = new SCC_BrizziWrapper.CardInquiryResponseData();
        dt.cardnum = '6013500300000355';
        dt.uid = '';
        dt.saldo = '0.00';
        dt.status_kartu = 'rd';
        dt.issue_date = '';
        dt.saldo_topup = '0.00';
        dt.cbg_issue = '0206';
        dt.tipe_kartu_bisnis = '03';
        dt.model_kartu = 'Brizzi_co-branding_Bank_Jambi';
        dt.nama_pemilik = '';
        dt.tempat_lahir = '';
        dt.tanggal_lahir = '';
        dt.id_num = '';
        dt.no_telp = '';
        dt.gender = '';
        dt.last_trx_date = '';
        dt.last_trx_amount = '0';
        dt.last_trx_merchant = '';
        dt.last_trx_terminal = '';
        dt.exp_date = '2099-12-31';
        dt.akum_debet = '0';
        dt.akum_kredit = '0';
        dt.alamat_pemilik = '';
        dt.nama_gadis_ibu = '';
        dt.reserved = '16/12/24';
        dt.reserved2 = '';
        dt.id_hash = '0';
        dt.encrypted = '';
        dt.kota_alamat = '';
        dt.profesi = '';
        dt.topup = '0';

        List<SCC_BrizziWrapper.CardInquiryResponseData> ldt = new List<SCC_BrizziWrapper.CardInquiryResponseData>();
        ldt.add(dt);

        SCC_BrizziWrapper.CardInquiryResponse res = new SCC_BrizziWrapper.CardInquiryResponse();
        res.data = ldt;
        return res;
    }

    public static SCC_BrizziWrapper.CardInquiryResponseError cardInquiryResponseError(){
        SCC_BrizziWrapper.cardInquiryResponseError res = new SCC_BrizziWrapper.cardInquiryResponseError();
        res.responseCode = 'NV';
        res.responseDesc = 'Invalid Payload Data';
        return res;
    }

    public static SCC_BrizziWrapper.CardChangeRequest cardChangeRequest(){
        SCC_BrizziWrapper.CardChangeRequestData dt = new SCC_BrizziWrapper.CardChangeRequestData();
        dt.oldCardNumber = '6013509900000961';
        dt.newCardNumber = '6013501000501402';
        dt.oldCardBalance = 0;
        dt.userMaker = 'dio';
        dt.userSigner = 'rey';
        List<SCC_BrizziWrapper.CardChangeRequestData> ldt = new List<SCC_BrizziWrapper.CardChangeRequestData>();
        ldt.add(dt);

        SCC_BrizziWrapper.CardChangeRequest req = new SCC_BrizziWrapper.CardChangeRequest();
        req.data = ldt;
        return req;
    }

    public static SCC_BrizziWrapper.CardChangeResponse cardChangeResponse(){
        SCC_BrizziWrapper.CardChangeResponse res = new SCC_BrizziWrapper.CardChangeResponse();
        res.responseCode = '00';
        res.responseDesc = 'success';
        res.refNumber = '283856';
        return res;
    }

    public static SCC_BrizziWrapper.CardChangeResponseError cardChangeResponseError(){
        SCC_BrizziWrapper.CardChangeResponseError res = new SCC_BrizziWrapper.CardChangeResponseError();
        res.responseCode = 'NV';
        res.responseDesc = 'Invalid Payload Data';
        return res;
    }

    public static Brizzi_Card__c setChangeCard(String csid){
        Brizzi_Card__c rk = new Brizzi_Card__c();
        rk.Case__c = csid;
        return rk ;
    }
    
    public static SCC_BrizziWrapper.AdjustDepositRequest adjustDepositRequest(){
        SCC_BrizziWrapper.AdjustDepositDataRequest dt = new SCC_BrizziWrapper.AdjustDepositDataRequest();
        dt.cardNumber = '6013509900000961';
        dt.amount = 50000.00;
        dt.userMaker = 'dio';
        dt.userSigner = 'wisnu';
        dt.hostBalanceCorrection = false;
        List<SCC_BrizziWrapper.AdjustDepositDataRequest> ldt = new List<SCC_BrizziWrapper.AdjustDepositDataRequest>();
        ldt.add(dt);

        SCC_BrizziWrapper.AdjustDepositRequest req = new SCC_BrizziWrapper.AdjustDepositRequest();
        req.data = ldt;
        return req;
    }

    public static SCC_BrizziWrapper.AdjustDepositResponse adjustDepositResponse(){
        SCC_BrizziWrapper.AdjustDepositResponse res = new SCC_BrizziWrapper.AdjustDepositResponse();
        res.responseCode = '00';
        res.responseDesc = 'success';
        res.refNumber = '3895467';
        return res;
    }

    public static SCC_BrizziWrapper.AdjustDepositResponseError adjustDepositResponseError(){
        SCC_BrizziWrapper.AdjustDepositResponseError res = new SCC_BrizziWrapper.AdjustDepositResponseError();
        res.responseCode = 'OV';
        res.responseDesc = 'Overlimit Card Balance';
        return res;
    }

    public static Adjust_Deposit__c setAdjustDeposit(String csid){
        Adjust_Deposit__c rk = new Adjust_Deposit__c();
        rk.Case__c = csid;
        return rk ;
    }

    // Object Test Trx History
    public static SCC_BrizziWrapper.TrxHistoryRequest trxHistoryRequest(){
        SCC_BrizziWrapper.TrxHistoryRequestData dt = new SCC_BrizziWrapper.TrxHistoryRequestData();
        dt.cardNumber = '6013501000501402';
        dt.userMaker = 'dio';
        dt.limits = 10;
        dt.offset = 0;
        List<SCC_BrizziWrapper.TrxHistoryRequestData> ldt = new List<SCC_BrizziWrapper.TrxHistoryRequestData>();
        ldt.add(dt);

        SCC_BrizziWrapper.TrxHistoryRequest req = new SCC_BrizziWrapper.TrxHistoryRequest();
        req.data = ldt;
        return req;
    }

    public static SCC_BrizziWrapper.TrxHistoryResponse trxHistoryResponse(){
        SCC_BrizziWrapper.TrxHistoryResponseData dt = new SCC_BrizziWrapper.TrxHistoryResponseData();
        dt.mercID = 'CHM';
        dt.terminID = 'CHM';
        dt.tgl_set = '2024-12-30';
        dt.jam_set = '10:52:30';
        dt.tgl_trx = '2024-12-30';
        dt.jam_trx = '10:52:30';
        dt.proc_code = 'ADJDPS';
        dt.amount_trx = 20000.00;
        dt.cardnum = '6013501000501402';
        dt.ref_number = '1806000';
        dt.batch_num = '';
        dt.MAC = '';
        dt.statusset = '';
        dt.ISOcode = '630';
        dt.statustrx = 'AD';
        dt.status_adj = 'AP';
        dt.cl_id = 0;
        dt.user_id = 'dio|wisnu';
        dt.keterangan = 'Y-adjdps2-189142-adjdpsappr-522370';
        dt.status_clr = '';
        dt.remark = '';
        dt.clr_time = '';

        // Create second record
        SCC_BrizziWrapper.TrxHistoryResponseData dt2 = new SCC_BrizziWrapper.TrxHistoryResponseData();
        dt2.mercID = 'CHM';
        dt2.terminID = 'CHM';
        dt2.tgl_set = '2024-12-31';
        dt2.jam_set = '10:58:14';
        dt2.tgl_trx = '2024-12-31';
        dt2.jam_trx = '10:58:14';
        dt2.proc_code = 'ADJDPS';
        dt2.amount_trx = 1000000.00;
        dt2.cardnum = '6013501000501402';
        dt2.ref_number = '2633693';
        dt2.batch_num = '';
        dt2.MAC = '';
        dt2.statusset = '';
        dt2.ISOcode = '630';
        dt2.statustrx = 'AD';
        dt2.status_adj = 'AP';
        dt2.cl_id = 0;
        dt2.user_id = 'dio|wisnu';
        dt2.keterangan = 'N-adjdps2-189142-adjdpsappr-637027';
        dt2.status_clr = '';
        dt2.remark = '';
        dt2.clr_time = '';

        List<SCC_BrizziWrapper.TrxHistoryResponseData> ldt = new List<SCC_BrizziWrapper.TrxHistoryResponseData>();
        ldt.add(dt);
        ldt.add(dt2);

        SCC_BrizziWrapper.TrxHistoryResponse res = new SCC_BrizziWrapper.TrxHistoryResponse();
        res.responseCode = '00';
        res.responseDesc = 'success';
        res.data = ldt;
        return res;
    }

    public static SCC_BrizziWrapper.TrxHistoryResponseError trxHistoryResponseError(){
        SCC_BrizziWrapper.TrxHistoryResponseError res = new SCC_BrizziWrapper.TrxHistoryResponseError();
        res.responseCode = 'NV';
        res.responseDesc = 'Invalid Payload Data';
        return res;
    }

     // Object Test Partner Trx History
     public static SCC_BrizziWrapper.CardHistoryPartnerRequest ptrTrxHistoryRequest(){
        SCC_BrizziWrapper.CardHistoryPartnerRequestData dt = new SCC_BrizziWrapper.CardHistoryPartnerRequestData();
        dt.cardNumber = '6013501000501402';
        dt.userMaker = 'dio';
        dt.limits = 10;
        dt.offset = 0;
        List<SCC_BrizziWrapper.CardHistoryPartnerRequestData> ldt = new List<SCC_BrizziWrapper.CardHistoryPartnerRequestData>();
        ldt.add(dt);

        SCC_BrizziWrapper.CardHistoryPartnerRequest req = new SCC_BrizziWrapper.CardHistoryPartnerRequest();
        req.data = ldt;
        return req;
    }

    public static SCC_BrizziWrapper.CardHistoryPartnerResponse ptrTrxHistoryResponse(){
        SCC_BrizziWrapper.CardHistoryPartnerData dt = new SCC_BrizziWrapper.CardHistoryPartnerData();
        dt.mercID = '000000000000017';
        dt.terminID = '10292313';
        dt.tgl_set = '2024-11-12';
        dt.jam_set = '11:15:22';
        dt.tgl_trx = '2024-10-28';
        dt.jam_trx = '123122';
        dt.proc_code = '808239';
        dt.amount_trx = 10.00;
        dt.cardnum = '6013501000503523';
        dt.ref_number = '000001';
        dt.batch_num = '01';
        dt.MAC = 'EA087261';
        dt.statusset = 'OK';
        dt.ISOcode = '';
        dt.statustrx = 'OK';
        dt.status_adj = '';
        dt.cl_id = 2835;
        dt.user_id = '';
        dt.keterangan = '';
        dt.namafile = '808239_000000000000017_20241028114239_01.bri';
        dt.additional = '';

        // Create second record
        SCC_BrizziWrapper.CardHistoryPartnerData dt2 = new SCC_BrizziWrapper.CardHistoryPartnerData();
        dt2.mercID = '000000000000017';
        dt2.terminID = '10292313';
        dt2.tgl_set = '2024-11-12';
        dt2.jam_set = '11:15:22';
        dt2.tgl_trx = '2024-10-28';
        dt2.jam_trx = '123122';
        dt2.proc_code = '808239';
        dt2.amount_trx = 10.00;
        dt2.cardnum = '6013501000503523';
        dt2.ref_number = '000001';
        dt2.batch_num = '01';
        dt2.MAC = 'EA087261';
        dt2.statusset = 'OK';
        dt2.ISOcode = '';
        dt2.statustrx = 'OK';
        dt2.status_adj = '';
        dt2.cl_id = 2835;
        dt2.user_id = '';
        dt2.keterangan = '';
        dt2.namafile = '808239_000000000000017_20241028114239_01.bri';
        dt2.additional = '';

        List<SCC_BrizziWrapper.CardHistoryPartnerData> ldt = new List<SCC_BrizziWrapper.CardHistoryPartnerData>();
        ldt.add(dt);
        ldt.add(dt2);

        SCC_BrizziWrapper.CardHistoryPartnerResponse res = new SCC_BrizziWrapper.CardHistoryPartnerResponse();
        res.responseCode = '00';
        res.responseDesc = 'success';
        res.data = ldt;
        return res;
    }

    public static SCC_BrizziWrapper.CardHistoryPartnerResponseError ptrTrxHistoryResponseError(){
        SCC_BrizziWrapper.CardHistoryPartnerResponseError res = new SCC_BrizziWrapper.CardHistoryPartnerResponseError();
        res.responseCode = 'NV';
        res.responseDesc = 'Invalid Payload Data';
        return res;
    }

    // Object Test Partner Trx History
    public static SCC_BrizziWrapper.BrizziPembukuanRequest brizziPembukuanRequest(){
        SCC_BrizziWrapper.BrizziPembukuanRequest dt = new SCC_BrizziWrapper.BrizziPembukuanRequest();
        dt.nott = 'TTB0aq021w021as1asaasd';
        dt.callType = '8713';
        dt.type = '2';
        dt.trxDate = '2024-06-06';
        dt.amountTopup = '100000.00';
        dt.accountCredit = '020601003837305';
        return dt;
    }

    public static SCC_BrizziWrapper.BrizziPembukuanResponse brizziPembukuanResponse(){
        SCC_BrizziWrapper.BrizziPembukuanResponseData dt = new SCC_BrizziWrapper.BrizziPembukuanResponseData();
        dt.errorCode = 'AS-000';
        dt.responseCode = '00';
        dt.responseMessage = 'Transaction Successfully';
        dt.nott = 'TTB0aq021w021qwasaasd';
        dt.journalSequence = '6716888';
        dt.remarkTransaction = 'KOMTOP 020601003837305 030525 1qwasaasd';
        dt.externalId = '738572165928874155';

        SCC_BrizziWrapper.BrizziPembukuanResponse res = new SCC_BrizziWrapper.BrizziPembukuanResponse();
        res.status = true;
        res.code = 200;
        res.message = 'Transaction Successfully';
        res.data = dt;
        return res;
    }

    public static SCC_BrizziWrapper.BrizziPembukuanResponseError brizziPembukuanResponseError(){
        SCC_BrizziWrapper.BrizziPembukuanResponseError res = new SCC_BrizziWrapper.BrizziPembukuanResponseError();
        res.status = false;
        res.code = 400;
        res.message = 'Transaction is Processing';
        res.data = null;
        return res;
    }
}