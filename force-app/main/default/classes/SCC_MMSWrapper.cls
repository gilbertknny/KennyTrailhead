public with sharing class SCC_MMSWrapper {
    
    public class RequestCreateMMS {
        public String ticket_type {get;set;}
        public String merchant_type {get;set;}
        public String id_ticket_bricare {get; set;}
        public String mid {get; set;}
        public String tid {get; set;}
        public String kode_uker {get;set;}
        public String call_type {get;set;}
        public String nama_pic {get;set;}
        public String telp_pic {get;set;}
        public String attachment {get;set;}
        public String remark {get;set;}
        public cmSettlement cm_settlement {get; set;}
    }

    public class cmSettlement {
        public String reff_number {get;set;}
        public Integer jumlah_transaksi {get;set;}
        public Integer nominal_transaksi {get;set;}
        public String tanggal_transaksi {get;set;}
    }

    public class ResponseCreateMMS {
        public String rc {get;set;}
        public String descs {get;set;}
        public String msg {get;set;}
        public DataResponseMMS data {get;set;}
    }

    public class DataResponseMMS {
        public Integer id_tiket {get;set;}
        public String id_tiket_bricare {get;set;}
    }

}