public class SCC_BrizziWrapper {
    public class CardInquiryRequestData {
        @AuraEnabled public String cardNumber {get;set;}
        @AuraEnabled public String userMaker {get;set;}
    }

    public class CardInquiryRequest {
        @AuraEnabled public List<CardInquiryRequestData> data {get;set;}
    }

    public class CardInquiryResponseData {
        @AuraEnabled public String cardnum {get;set;}
        @AuraEnabled public String uid {get;set;}
        @AuraEnabled public String saldo {get;set;}
        @AuraEnabled public String status_kartu {get;set;}
        @AuraEnabled public String issue_date {get;set;}
        @AuraEnabled public String saldo_topup {get;set;}
        @AuraEnabled public String cbg_issue {get;set;}
        @AuraEnabled public String tipe_kartu_bisnis {get;set;}
        @AuraEnabled public String model_kartu {get;set;}
        @AuraEnabled public String nama_pemilik {get;set;}
        @AuraEnabled public String tempat_lahir {get;set;}
        @AuraEnabled public String tanggal_lahir {get;set;}
        @AuraEnabled public String id_num {get;set;}
        @AuraEnabled public String no_telp {get;set;}
        @AuraEnabled public String gender {get;set;}
        @AuraEnabled public String last_trx_date {get;set;}
        @AuraEnabled public String last_trx_amount {get;set;}
        @AuraEnabled public String last_trx_merchant {get;set;}
        @AuraEnabled public String last_trx_terminal {get;set;}
        @AuraEnabled public String exp_date {get;set;}
        @AuraEnabled public String akum_debet {get;set;}
        @AuraEnabled public String akum_kredit {get;set;}
        @AuraEnabled public String alamat_pemilik {get;set;}
        @AuraEnabled public String nama_gadis_ibu {get;set;}
        @AuraEnabled public String reserved {get;set;}
        @AuraEnabled public String reserved2 {get;set;}
        @AuraEnabled public String id_hash {get;set;}
        @AuraEnabled public String encrypted {get;set;}
        @AuraEnabled public String kota_alamat {get;set;}
        @AuraEnabled public String profesi {get;set;}
        @AuraEnabled public String topup {get;set;}
    }

    public class CardInquiryResponse {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
        @AuraEnabled public List<CardInquiryResponseData> data {get;set;}
    }

    public class CardInquiryResponseError {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    public class CardHistoryPartnerRequest {
        @AuraEnabled 
        public List<CardHistoryPartnerRequestData> data {get;set;}
    }

    public class CardHistoryPartnerRequestData {
        @AuraEnabled
        public String cardNumber {get;set;}
        @AuraEnabled
        public String userMaker {get;set;}
        @JsonProperty('limit')
        @AuraEnabled
        public Integer limits {get;set;}
        @AuraEnabled
        public Integer offset {get;set;}
    }

    public class CardHistoryPartnerData{
        @AuraEnabled
        public String mercID { get; set;}
        @AuraEnabled
        public String terminID { get; set;}
        @AuraEnabled
        public String tgl_set { get; set; }
        @AuraEnabled
        public String jam_set { get; set; }
        @AuraEnabled
        public String tgl_trx { get; set; }
        @AuraEnabled
        public String jam_trx { get; set; }
        @AuraEnabled
        public String proc_code { get; set; }
        @AuraEnabled
        public Decimal amount_trx { get; set; }
        @AuraEnabled
        public String cardnum { get; set; }
        @AuraEnabled
        public String ref_number { get; set; }
        @AuraEnabled
        public String batch_num { get; set; }
        @AuraEnabled
        public String MAC { get; set; }
        @AuraEnabled
        public String statusset { get; set; }
        @AuraEnabled
        public String ISOcode { get; set; }
        @AuraEnabled
        public String statustrx { get; set; }
        @AuraEnabled
        public String status_adj { get; set; }
        @AuraEnabled
        public Integer cl_id { get; set; }
        @AuraEnabled
        public String user_id { get; set; }
        @AuraEnabled
        public String keterangan { get; set; }
        @AuraEnabled
        public String namafile { get; set; }
        @AuraEnabled
        public String additional { get; set; }
    }

    public class CardHistoryPartnerResponse{
        @AuraEnabled
        public String responseCode {get; set;}
        @AuraEnabled
        public String responseDesc {get;set;}
        @AuraEnabled
        public List<CardHistoryPartnerData> data {get; set;}
    }

    public class CardHistoryPartnerResponseError {
        @AuraEnabled
        public String responseCode {get;set;}
        @AuraEnabled
        public String responseDesc {get;set;}
    }

    // Card Change
    public class CardChangeRequestData {
        @AuraEnabled public String oldCardNumber {get;set;}
        @AuraEnabled public String newCardNumber {get;set;}
        @AuraEnabled public Integer oldCardBalance {get;set;}
        @AuraEnabled public String userMaker {get;set;}
        @AuraEnabled public String userSigner {get;set;}
    }

    public class CardChangeRequest {
        @AuraEnabled public List<CardChangeRequestData> data {get;set;}
    }

    public class CardChangeResponse {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
        @AuraEnabled public String refNumber {get;set;}
    }

    public class CardChangeResponseError {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    // Adjust Deposit
    public class AdjustDepositDataRequest {
        @AuraEnabled public String cardNumber {get;set;}
        @AuraEnabled public Decimal amount {get;set;}
        @AuraEnabled public String userMaker {get;set;}
        @AuraEnabled public String userSigner {get;set;}
        @AuraEnabled public Boolean hostBalanceCorrection {get;set;}
    }

    public class AdjustDepositRequest {
        @AuraEnabled public List<AdjustDepositDataRequest> data {get;set;}
    }

    public class AdjustDepositResponse {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
        @AuraEnabled public String refNumber {get;set;}
    }

    public class AdjustDepositResponseError {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    // Trx History
    public class TrxHistoryRequestData {
        @AuraEnabled public String cardNumber {get;set;}
        @AuraEnabled public String userMaker {get;set;}
        @JsonProperty('limit')
        @AuraEnabled public Integer limits {get;set;}
        @AuraEnabled public Integer offset {get;set;}
    }

    public class TrxHistoryRequest {
        @AuraEnabled public List<TrxHistoryRequestData> data {get;set;}
    }

    public class TrxHistoryResponseData {
        @AuraEnabled public String mercID { get; set; }
        @AuraEnabled public String terminID { get; set; }
        @AuraEnabled public String tgl_set { get; set; }
        @AuraEnabled public String jam_set { get; set; }
        @AuraEnabled public String tgl_trx { get; set; }
        @AuraEnabled public String jam_trx { get; set; }
        @AuraEnabled public String proc_code { get; set; }
        @AuraEnabled public Decimal amount_trx { get; set; }
        @AuraEnabled public String cardnum { get; set; }
        @AuraEnabled public String ref_number { get; set; }
        @AuraEnabled public String batch_num { get; set; }
        @AuraEnabled public String MAC { get; set; }
        @AuraEnabled public String statusset { get; set; }
        @AuraEnabled public String ISOcode { get; set; }
        @AuraEnabled public String statustrx { get; set; }
        @AuraEnabled public String status_adj { get; set; }
        @AuraEnabled public Integer cl_id { get; set; }
        @AuraEnabled public String user_id { get; set; }
        @AuraEnabled public String keterangan { get; set; }
        @AuraEnabled public String status_clr { get; set; }
        @AuraEnabled public String remark { get; set; }
        @AuraEnabled public String clr_time { get; set; }
    }

    public class TrxHistoryResponse {
        @AuraEnabled public String responseCode { get; set; }
        @AuraEnabled public String responseDesc { get; set; }
        @AuraEnabled public List<TrxHistoryResponseData> data { get; set; }
    }

    public class TrxHistoryResponseError {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    public class BrizziPembukuanRequest {
        @AuraEnabled public String nott {get;set;}
        @AuraEnabled public String callType {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String trxDate {get;set;}
        @AuraEnabled public String amountTopup {get;set;}
        @AuraEnabled public String accountCredit {get;set;}
    }

    public class BrizziPembukuanResponseData {
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String nott {get;set;}
        @AuraEnabled public String journalSequence {get;set;}
        @AuraEnabled public String remarkTransaction {get;set;}
        @AuraEnabled public String externalId {get;set;}
    }

    public class BrizziPembukuanResponse {
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public BrizziPembukuanResponseData data {get;set;}
    }

    public class BrizziPembukuanResponseError {
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String data {get;set;}
    }

    public class BrzziPembukuanTimeout{
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }
}