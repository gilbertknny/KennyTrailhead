public with sharing class Object_Test_MMS {
    
    public static SCC_MMSWrapper.RequestCreateMMS requestCreateMMS() {
        SCC_MMSWrapper.RequestCreateMMS req = new SCC_MMSWrapper.RequestCreateMMS();
        req.ticket_type = 'settlement';
        req.merchant_type = 'EDC';
        req.id_ticket_bricare = 'TTB000001683863';
        req.mid = '000012596382';
        req.tid = '18551749';
        req.kode_uker = '00000';
        req.call_type = '8630';
        req.nama_pic = 'alvin vigo';
        req.telp_pic = '08123456789';
        req.attachment = 'TEMP/0_PJf88gv_small_pdf.pdf_mEDZA8lS8.pdf';
        req.remark = 'Test remark';

        SCC_MMSWrapper.cmSettlement settlement = new SCC_MMSWrapper.cmSettlement();
        settlement.reff_number = '1999569819219271';
        settlement.jumlah_transaksi = 1;
        settlement.nominal_transaksi = 500000;
        settlement.tanggal_transaksi = '2024-03-04';

        req.cm_settlement = settlement;
        return req;
    }
}