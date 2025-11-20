// @istest
public with sharing class Object_Test_MPN {
    public static SCC_BillingMPN_Wrapper.BillingMPN_Request billingMPNRequest(){
        SCC_BillingMPN_Wrapper.BillingMPN_Request req = new SCC_BillingMPN_Wrapper.BillingMPN_Request();
        req.transactionCurrencyCode = 'IDR';
        req.idSetoran = '127306958506102';
        return req;
    }

    public static SCC_BillingMPN_Wrapper.BillingMPN_Response billingMPNResponse(){
        SCC_BillingMPN_Wrapper.BillingMPN_DataResponse drs = new SCC_BillingMPN_Wrapper.BillingMPN_DataResponse();
        drs.idSetoran = '127306958506102';
        drs.transactionCurrencyCode = 'IDR';
        drs.transactionAmount = '350000.00';
        drs.systemTraceAuditNumber = '';
        drs.merchantTypes = '7015';
        drs.retrievalReferenceNumber = '230224655997';
        drs.namaWP = 'WP BADAN';
        drs.alamatWP = 'JL. INI ALAMATNYA - KAB. TANGERANG';
        drs.npwp = '0024191678418000';
        drs.jumlahDetail = '';
        drs.jenisDokumen = '';
        drs.nomorDokumen = '';
        drs.tanggalDokumen = '';
        drs.kodeKpbc = '';
        drs.idPeserta = '';
        drs.kodeNTB = '';
        drs.kodeKL = '';
        drs.unitEselon1 = '';
        drs.satker = '';
        drs.kodeNTPN = '';
        drs.rcMPN = '98';
        drs.responseMessageMPN = 'Panjang message tidak sesuai (Reversal)';
        drs.tglBuku = '25022023';
        drs.tanggalSettlement = '25022023';
        drs.tanggalTransaksi = '';
        drs.jamTransaksi = '';
        drs.transCabang = '';
        drs.journalSeq1 = '';
        drs.journalSeq2 = '';
        drs.applicationName = '';

        SCC_BillingMPN_Wrapper.BillingMPN_Response res = new SCC_BillingMPN_Wrapper.BillingMPN_Response();
        res.data = drs;
        return res;
    }

    public static SCC_BillingMPN_Wrapper.BillingMPN_Response_Response billingMPNResponseError(){
        SCC_BillingMPN_Wrapper.BillingMPN_Response_Response res = new SCC_BillingMPN_Wrapper.BillingMPN_Response_Response();
        res.responseCode = '01';
        res.responseMessage = 'ID Setoran Tidak Boleh Kosong';
        return res;
    }
}