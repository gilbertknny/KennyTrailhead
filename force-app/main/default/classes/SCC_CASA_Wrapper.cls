/**
 * @description       : CASA Wrapper Class
 * @author            : Femy
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
public with sharing class SCC_CASA_Wrapper {
    /*
    public class OauthCasaResponse{
        @AuraEnabled public String access_token {get;set;}
        @AuraEnabled public String token_type {get;set;}
        @AuraEnabled public Integer expires_in {get;set;}
    }

    public class OauthCasaRequest{
        @AuraEnabled public String client_id {get;set;}
        @AuraEnabled public String client_secret {get;set;}
        @AuraEnabled public String grant_type {get;set;}
        @AuraEnabled public String scope {get;set;}
        
    }
    */
    public class DetailRequestHoldAmount{
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public String holdAmount {get;set;}
        @AuraEnabled public String remarkHold {get;set;}
        @AuraEnabled public String expirationDate {get;set;}
        @AuraEnabled public String datePlaced {get;set;}
        @AuraEnabled public String externalId {get;set;}
        @AuraEnabled public String serviceId {get;set;}
        @AuraEnabled public String channelId {get;set;}
        @AuraEnabled public String tellerId {get;set;}
        @AuraEnabled public String holdType {get;set;}
        @AuraEnabled public String tellerHold {get;set;}
    }

    public class RequestHoldAmount{
        @AuraEnabled public DetailRequestHoldAmount request {get;set;}
    }

    public class DetailResponseHoldAmount{
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public String holdSequence {get;set;}
        @AuraEnabled public String holdType {get;set;}
        @AuraEnabled public String holdAmt {get;set;}
        @AuraEnabled public String holdRemark {get;set;}
        @AuraEnabled public String expiredDate {get;set;}
        @AuraEnabled public String userId {get;set;}
        @AuraEnabled public String holdTime {get;set;}
        @AuraEnabled public String holdDate {get;set;}
    }

    public class ResponseHoldAmount{
        @AuraEnabled public DetailResponseHoldAmount response {get;set;}
    }

    public class DetailRequestUnholdAmount{
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public String holdSeq {get;set;}
        @AuraEnabled public String externalId {get;set;}
        @AuraEnabled public String channelId {get;set;}
        @AuraEnabled public String serviceId {get;set;}
        @AuraEnabled public String tellerId {get;set;}
    }

    public class RequestUnholdAmount{
        @AuraEnabled public DetailRequestUnholdAmount request {get;set;}
    }

    public class DetailResponseUnholdAmount{
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public String holdSeq {get;set;}
    }

    public class ResponseUnholdAmount{
        @AuraEnabled public DetailResponseUnholdAmount response {get;set;}
    }
}