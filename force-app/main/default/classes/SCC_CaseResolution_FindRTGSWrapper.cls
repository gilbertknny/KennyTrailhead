/**
    * @description       : Find RTGS Wrapper
    * @last modified on  : 16/01/2025
    * @last modified by  : Suherbing Septian
    **/

    public with sharing class SCC_CaseResolution_FindRTGSWrapper {
        public class DataResponse{
            @AuraEnabled public String originalTransaction {get;set;}
            @AuraEnabled public String referenceTransaction {get;set;}
            @AuraEnabled public String mt {get;set;}
            @AuraEnabled public String ttc {get;set;}
            @JsonProperty('date')
            @AuraEnabled public String dateTransaction {get;set;}
            @AuraEnabled public String amountDebit {get;set;}
            @AuraEnabled public String debitCurrency {get;set;}
            @AuraEnabled public String amountCredit {get;set;}
            @AuraEnabled public String creditCurrency {get;set;}
            @AuraEnabled public String feeAmount {get;set;}
            @AuraEnabled public String feeCurrency {get;set;}
            @AuraEnabled public String ppn {get;set;}
            @AuraEnabled public String toMemberBIC {get;set;}
            @AuraEnabled public String orderingCustomerAccount {get;set;}
            @AuraEnabled public String orderingCustomerName {get;set;}
            @AuraEnabled public String beneficiaryCustomerAccount {get;set;}
            @AuraEnabled public String beneficiaryCustomerName {get;set;}
            @AuraEnabled public String remittanceInformation {get;set;}
            @AuraEnabled public String noSakti {get;set;}
            @AuraEnabled public String isNotPool {get;set;}
            @AuraEnabled public String isWic {get;set;}
            @AuraEnabled public String bankOwnReference {get;set;}
            @AuraEnabled public String saranaTransaksi {get;set;}
            @AuraEnabled public String channel {get;set;}
            @AuraEnabled public String insertDate {get;set;}
            @AuraEnabled public String returnDate {get;set;}
            @AuraEnabled public String userMaker {get;set;}
            @AuraEnabled public String makerDate {get;set;}
            @AuraEnabled public String userApprove {get;set;}
            @AuraEnabled public String approveDate {get;set;}
            @AuraEnabled public String status {get;set;}
            @AuraEnabled public String statusDesc {get;set;}
        }

        public class FindRTGSDataResponse{
            @AuraEnabled public String responseCode {get;set;}
            @AuraEnabled public String errorCode {get;set;}
            @AuraEnabled public String responseMessage {get;set;}
            @AuraEnabled public DataResponse data {get;set;}
        }

        public class FindRTGSResponse{
            @AuraEnabled public FindRTGSDataResponse response {get;set;}
        }

        public class ErrorResponse{
            @AuraEnabled public String errorCode {get;set;}
            @AuraEnabled public String responseMessage {get;set;}
            @AuraEnabled public String responseCode {get;set;}
        }

        public class FindRTGSResponseError{
            @AuraEnabled public ErrorResponse response {get;set;}
        }

        public class PaymentDataRequest{
            @AuraEnabled public String idTransaction {get;set;}
        }

        public class DataRequest{
            @AuraEnabled public String kodePembayaran {get;set;}
            @AuraEnabled public String channelId {get;set;}
            @AuraEnabled public String serviceId {get;set;}
            @AuraEnabled public String externalId {get;set;}
            @AuraEnabled public String userName {get;set;}
            @AuraEnabled public String tellerId {get;set;}
            @AuraEnabled public String supervisorId {get;set;}
            @AuraEnabled public PaymentDataRequest paymentData {get;set;}
        }

        public class FindRTGSRequest{
            @AuraEnabled public DataRequest request {get;set;}
        }
    }