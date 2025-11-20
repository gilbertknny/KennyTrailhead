/**
* @description       : Billing MPN Wrapper
* @last modified on  : 21/01/2025
* @last modified by  : Suherbing Septian
**/

public with sharing class SCC_BillingMPN_Wrapper {
    public class BillingMPN_Request {
        @AuraEnabled public String transactionCurrencyCode {get;set;}
        @AuraEnabled public String idSetoran {get;set;}
    }
    public class BillingMPN_DataResponse {
        @AuraEnabled public String idSetoran {get;set;}
        @AuraEnabled public String transactionCurrencyCode {get;set;}
        @AuraEnabled public String transactionAmount {get;set;}
        @AuraEnabled public String systemTraceAuditNumber {get;set;}
        @AuraEnabled public String merchantTypes {get;set;}
        @AuraEnabled public String retrievalReferenceNumber {get;set;}
        @AuraEnabled public String namaWP {get;set;}
        @AuraEnabled public String alamatWP {get;set;}
        @AuraEnabled public String npwp {get;set;}
        @AuraEnabled public String jumlahDetail {get;set;}
        @AuraEnabled public String jenisDokumen {get;set;}
        @AuraEnabled public String nomorDokumen {get;set;}
        @AuraEnabled public String tanggalDokumen {get;set;}
        @AuraEnabled public String kodeKpbc {get;set;}
        @AuraEnabled public String idPeserta {get;set;}
        @AuraEnabled public String kodeNTB {get;set;}
        @AuraEnabled public String kodeKL {get;set;}
        @AuraEnabled public String unitEselon1 {get;set;}
        @AuraEnabled public String satker {get;set;}
        @AuraEnabled public String kodeNTPN {get;set;}
        @AuraEnabled public String rcMPN {get;set;}
        @AuraEnabled public String responseMessageMPN {get;set;}
        @AuraEnabled public String tglBuku {get;set;}
        @AuraEnabled public String tanggalSettlement {get;set;}
        @AuraEnabled public String tanggalTransaksi {get;set;}
        @AuraEnabled public String jamTransaksi {get;set;}
        @AuraEnabled public String transCabang {get;set;}
        @AuraEnabled public String journalSeq1 {get;set;}
        @AuraEnabled public String journalSeq2 {get;set;}
        @AuraEnabled public String applicationName {get;set;}
    }
    public class BillingMPN_Response {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public BillingMPN_DataResponse Data {get;set;}
    }

    public class BillingMPN_Response_Response {
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
    }
}