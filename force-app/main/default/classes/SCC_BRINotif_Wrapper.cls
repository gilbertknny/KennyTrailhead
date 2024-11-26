public with sharing class SCC_BRINotif_Wrapper {
    public class WANotifRequest {
        public String rekening {get;set;}
        public String produk {get;set;}
        public String phoneNumber {get;set;}
        public String pesan {get;set;}
        public List<WANotifPesan> pesanWa {get;set;}
        public String sendTime {get;set;}
    }

    public class WANotifPesan {
        public String type {get;set;}
        public List<WANotifParameter> parameters {get;set;}
    }

    public class WANotifParameter {
        public String type {get;set;}
        public String text {get;set;}
        public String image {get;set;}
    }

    public class WANotifResponse{
        public String errorCode {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;}
        public String reffNumber {get;set;}
    }
}