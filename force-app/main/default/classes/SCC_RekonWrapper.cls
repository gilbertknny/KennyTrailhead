public with sharing class SCC_RekonWrapper {
    public class RequestRekon {
        @AuraEnabled
        public String TerminalID {get; set;}
        @AuraEnabled
        public String TransactionDate {get; set;}
        @AuraEnabled
        public String AccountNumber {get; set;}
        @AuraEnabled
        public String Amount {get; set;}
        @AuraEnabled
        public Integer Page {get; set;}
    }

    public class ResponseRekon {
        @AuraEnabled
        public String ERROR_CODE {get; set;}
        @AuraEnabled
        public String RESPONSE_CODE {get; set;}
        @AuraEnabled
        public String RESPONSE_MESSAGE {get; set;}
        @AuraEnabled
        public ResponseRekonData RESPONSE_DATA {get; set;}
    }

    public class ResponseRekonData {
        @AuraEnabled
        public List<ResponseRekonResult> result {get; set;}
    }

    public class ResponseRekonResult {
        @AuraEnabled
        public String uuid {get; set;}
        @AuraEnabled
        public String trx_date {get; set;}
        @AuraEnabled
        public String terminal_id {get; set;}
        @AuraEnabled
        public String account_no {get; set;}
        @AuraEnabled
        public String card_no {get; set;}
        @AuraEnabled
        public Integer amount {get; set;}
        @AuraEnabled
        public Integer seq_no {get; set;}
        @AuraEnabled
        public String StatusRekon {get; set;}
        @AuraEnabled
        public String DebetAccount {get; set;}
        @AuraEnabled
        public String CreditAccount {get; set;}
        @AuraEnabled
        public String CreditAccountType {get; set;}
        @AuraEnabled
        public String StatusPenyelesaian {get; set;}
        @AuraEnabled
        public String PenyelesaianRekon {get; set;}
        @AuraEnabled
        public String TableRekon {get; set;}
    }

    public class RequestBeritaAcaraOpname {
        @AuraEnabled
        public String TerminalID {get; set;}
        @AuraEnabled
        public String TanggalTransaksi {get; set;}
        @AuraEnabled
        public Integer Page {get; set;}
    }

    public class ResponseBeritaAcaraOpname {
        @AuraEnabled
        public String ERROR_CODE {get; set;}
        @AuraEnabled
        public String RESPONSE_CODE {get; set;}
        @AuraEnabled
        public String RESPONSE_MESSAGE {get; set;}
        @AuraEnabled
        public ResponseBeritaAcaraOpnameData RESPONSE_DATA {get; set;}
    }

    public class ResponseBeritaAcaraOpnameData {
        @AuraEnabled
        public List<ResponseBeritaAcaraOpnameResult> result {get; set;}
    }

    public class ResponseBeritaAcaraOpnameResult {
        @AuraEnabled
        public String id_terminal {get; set;}
        @AuraEnabled
        public Integer branch {get; set;}
        @AuraEnabled
        public String WaktuOpname {get; set;}
        @AuraEnabled
        public String JenisTerminal {get; set;}
        @AuraEnabled
        public Decimal LebihKas {get; set;}
        @AuraEnabled
        public Decimal KurangKas {get; set;}
        @AuraEnabled
        public Decimal LebihFisik {get; set;}
        @AuraEnabled
        public Decimal KurangFisik {get; set;}
        @AuraEnabled
        public String StatusId {get; set;}
        @AuraEnabled
        public String StatusName {get; set;}
    }

    public class RequestFlagDataRekon {
        @AuraEnabled
        public String Status {get; set;}
        @AuraEnabled
        public String TransactionDate {get; set;}
        @AuraEnabled
        public String NoTicket {get; set;}
        @AuraEnabled
        public List<String> UUID {get; set;}
    }

    public class ResponseFlagDataRekon {
        @AuraEnabled
        public String ERROR_CODE {get; set;}
        @AuraEnabled
        public String RESPONSE_CODE {get; set;}
        @AuraEnabled
        public String RESPONSE_MESSAGE {get; set;}
        @AuraEnabled
        public DataFlagDataRekon RESPONSE_DATA {get; set;}
    }

    public class DataFlagDataRekon {
        @AuraEnabled
        public String message {get; set;}
    }
}