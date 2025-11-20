public with sharing class SCC_BrivaWrapper {
    
    public class requestBrivaWrapper{
        @AuraEnabled
        public bodyBriva request {get; set;}
    }

    public class bodyBriva{
        @AuraEnabled
        public String brivaNo {get; set;}
        @AuraEnabled
        public String channelId {get; set;}
        @AuraEnabled
        public String serviceId {get; set;}
        @AuraEnabled
        public String externalId {get; set;}
    }

    public class responseBrivaWrapper{
        @AuraEnabled
        public responseBriva response {get; set;}
    }

    public class responseBriva{
        @AuraEnabled
        public String corpAccountNo {get; set;}
        @AuraEnabled
        public String errorCode {get; set;}
        @AuraEnabled
        public String responseMessage {get; set;}
        @AuraEnabled
        public String responseCode {get; set;}
        @AuraEnabled
        public dataBriva data {get; set;}
    }
    
    public class responseBrivaCustom {
        @AuraEnabled
        public String corpAccountNo {get; set;}
        @AuraEnabled
        public String errorCode {get; set;}
        @AuraEnabled
        public String responseMessage {get; set;}
        @AuraEnabled
        public String responseCode {get; set;}
        @AuraEnabled
        public String corpName {get;set;}
        @AuraEnabled
        public List<Brivaco> brivaco {get; set;}
        @AuraEnabled
        public String specialSegment {get; set;}
    }

    public class dataBriva{
        public String corpId  {get; set;}
        public String corpName {get; set;}
        public String corpCode {get; set;}
        public String corpAccountNo {get; set;}
        public String currencys {get; set;}
        public String isActive {get; set;}
        public String corpFee {get; set;}
        public String custFee {get; set;}
        public String corpFeeAtm {get; set;}
        public String custFeeAtm {get; set;}
        public String corpFeeBrilink {get; set;}
        public String custFeeBrilink {get; set;}
        public String isSplitFee {get; set;}
        public String amountFeeSplitBri {get; set;}
        public String amountFeeSplit {get; set;}
        public String amountFeeSplit2 {get; set;}
        public String isSplitFeeEchannel {get; set;}
        public String amountFeeSplitEchannelBri {get; set;}
        public String amountFeeSplitEchannel {get; set;}
        public String amountFeeSplitEchannel2 {get; set;}
        public String isSplitFeeBrilink {get; set;}
        public String amountFeeSplitBrilinkBri {get; set;}
        public String amountFeeSplitBrilink {get; set;}
        public String amountFeeSplitBrilink2 {get; set;}
        public String accountNoFeeSplit {get; set;}
        public String accountNFeeSplit2 {get; set;}
        public String limitMinTrx {get; set;}
        public String limitMaxTrx {get; set;}
        public String openPayment {get; set;}
        public String billingPayment {get; set;}
        public String specialFlag {get; set;}
        public String cif {get; set;}
        public String brivaService {get; set;}
        public String specialSegment {get; set;}
        public String startIndexSegment {get; set;}
        public String lengthIndexSegment {get; set;}
        public String isKeteranganTambahan {get; set;}
        public String itPartnerName {get; set;}
        public String itPartnerPhoneNo {get; set;}
        public String itPartnerEmail {get; set;}
        public String businessPartnerName {get; set;}
        public String businessPartnerPhoneNo {get; set;}
        public String businessPartnerEmail {get; set;}
        public String picRm {get; set;}
        public String rmPhoneNo {get; set;}
        public String rmEmail {get; set;}
        public String profilingType {get; set;}
        public String paymentChannel {get; set;}
        public List<Brivaco> brivaco {get; set;}        
    }

    public class Brivaco{
        @AuraEnabled
        public String uniqueCode {get; set;}
        @AuraEnabled
        public String accountNo {get; set;}
        @AuraEnabled
        public String accountName {get; set;}
        @AuraEnabled
        public String description {get; set;}

    }

    public class ReportBrivaRequest{
        @AuraEnabled
        public String corpCode {get;set;}
        @AuraEnabled
        public String custCode {get;set;}
        @AuraEnabled
        public String tanggalAwal {get;set;}
        @AuraEnabled
        public String tanggalAkhir {get;set;}
        @AuraEnabled
        public String uniqcode {get;set;}
        @AuraEnabled
        public Integer pageNumber {get; set;}
        @AuraEnabled
        public Integer rowsPerPage {get;set;}
    }


    public class ReportBrivaResponse{
        @AuraEnabled
        public Integer statusCode {get;set;}
        @AuraEnabled
        public String errorCode {get;set;}
        @AuraEnabled
        public String responseCode {get;set;}
        @AuraEnabled
        public String responseMessage {get; set;}
        @AuraEnabled
        public String errors {get; set;}
        @AuraEnabled
        public List<DataReportBriva> data {get; set;}

    }

    public class DataReportBriva {
        @AuraEnabled
        public String brivaNo {get; set;}
        @AuraEnabled
        public String uniqueCode {get; set;}
        @AuraEnabled
        public String custCode {get; set;}
        @AuraEnabled
        public String nama {get; set;}
        @AuraEnabled
        public String keterangan {get; set;}
        @AuraEnabled
        public Integer amount {get; set;}
        @AuraEnabled
        public String paymentDate {get; set;} 
        @AuraEnabled
        public String tellerid {get; set;}
        @AuraEnabled
        public String norek {get; set;}
        @AuraEnabled
        public Integer seq {get; set;}
        @AuraEnabled
        public String trremk {get; set;}
        @AuraEnabled
        public String seqOther {get; set;}
        @AuraEnabled
        public String jaringan {get; set;}
        @AuraEnabled
        public String trstat {get; set;}
        @AuraEnabled
        public String auxtrc {get; set;}
        @AuraEnabled
        public String julianDate {get; set;}
        @AuraEnabled
        public String trxID {get; set;}
        @AuraEnabled
        public Integer totalRow {get; set;}
        @AuraEnabled
        public String pageShow {get; set;}
    }
}