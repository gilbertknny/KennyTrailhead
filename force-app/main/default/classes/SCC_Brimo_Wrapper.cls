public with sharing class SCC_Brimo_Wrapper {
    public class ActivityHistory{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String reference_num {get;set;}
        @AuraEnabled public String activity_status {get;set;}
        @AuraEnabled public String activity_type {get;set;}
        @AuraEnabled public String activity_group {get;set;}
        @AuraEnabled public String activity_icon {get;set;}
        @AuraEnabled public String activity_date {get;set;}
        @AuraEnabled public String activity_time {get;set;}
        @AuraEnabled public String activity_dest {get;set;}
        @AuraEnabled public String trx_type {get;set;}
        @AuraEnabled public String total_amount {get;set;}
    }

    public class AccountList{
        @AuraEnabled public String account {get;set;}
        @AuraEnabled public String type_account {get;set;}
        @AuraEnabled public String product_type {get;set;}
        @AuraEnabled public String account_name {get;set;}
        @AuraEnabled public String card_number {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String finansial_status {get;set;}
    }

    public class LastLoginAttempt{
        @AuraEnabled public String last_login {get;set;}
        @AuraEnabled public String login_status {get;set;}
    }

    public class ResponseDataInquiryUserBrimo{
        @AuraEnabled public List<AccountList> account_list {get;set;}
        @AuraEnabled public List<ActivityHistory> activity_history {get;set;}
        @AuraEnabled public String cellphone_number {get;set;}
        @AuraEnabled public String email_address {get;set;}
        @AuraEnabled public String financial_status {get;set;}
        @AuraEnabled public LastLoginAttempt last_login_attempt {get;set;}
        @AuraEnabled public String registered_date {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String user_alias {get;set;}
        @AuraEnabled public String username {get;set;}
    }

    public class ResponseInquiryUserBrimo{
        @AuraEnabled public String response_code {get;set;}
        @AuraEnabled public String response_refnum {get;set;}
        @AuraEnabled public String response_id {get;set;}
        @AuraEnabled public String response_description {get;set;}
        @AuraEnabled public ResponseDataInquiryUserBrimo response_data {get;set;}
        @AuraEnabled public String message {get;set;}
    }
    
    public class ResponseDataInquiryOnboardingBrimo{
        @AuraEnabled public String account {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String nik {get;set;}
        @AuraEnabled public Integer status {get;set;}
        @AuraEnabled public String status_description {get;set;}
    }

    public class ResponseInquiryOnboardingBrimo{
        @AuraEnabled public String response_code {get;set;}
        @AuraEnabled public String response_refnum {get;set;}
        @AuraEnabled public String response_id {get;set;}
        @AuraEnabled public String response_description {get;set;}
        @AuraEnabled public ResponseDataInquiryOnboardingBrimo response_data {get;set;}
        @AuraEnabled public String message {get;set;}
    }

    public class ResponseDeleteUserBrimo{
        @AuraEnabled public String response_code {get;set;}
        @AuraEnabled public String response_refnum {get;set;}
        @AuraEnabled public String response_id {get;set;}
        @AuraEnabled public String response_desc {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String response_description {get;set;}
    }

    public class RequestBrimo{
        @AuraEnabled public String client {get;set;}
        @AuraEnabled public String channel_id {get;set;}
        @AuraEnabled public String request_refnum {get;set;}
        //Inquiry User Brimo
        @AuraEnabled public String account_number {get;set;}
        @AuraEnabled public String cellphone_number {get;set;}
        @AuraEnabled public String cif {get;set;}
        //Inquiry Onboarding Brimo
        @AuraEnabled public String nik {get;set;}
        //Delet user Brimo
        @AuraEnabled public String card_number {get;set;}
        @AuraEnabled public String user_id {get;set;}
        @AuraEnabled public String username {get;set;}
    }
}