public with sharing class SCC_CaseResolution_CHMSupport_Wrapper {
    public class InquiryRoleUserCHMRequest{
        @AuraEnabled public string	is_request_all	{get;set;}
    }

    public class InquiryRoleUserCHMResponse{
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public List<String> data {get;set;}
    }

    public class TerminalIDRequest{
        @AuraEnabled public string	terminal_id	{get;set;}
        @AuraEnabled public string	dates	{get;set;} //date
    }

    public class TerminalIDResponse{
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public TerminalIDData data {get;set;}
    }

    public class TerminalIDData{
        @AuraEnabled public String acct_no {get;set;}
        @AuraEnabled public String terminal_id {get;set;}
        @AuraEnabled public String teller_id {get;set;}
        @AuraEnabled public String branch_code {get;set;}
        @AuraEnabled public String add_time {get;set;}
    }

    public class TerminalIDListRequest{
        @AuraEnabled public string	input_text	{get;set;}
        @AuraEnabled public string	dates	{get;set;} //date
    }

    public class TerminalIDListResponse{
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public List<String> data {get;set;}
    }

    public class PaymentResolutionServiceRequest{
        @AuraEnabled
        public string	no_tt	{get;set;}
        @AuraEnabled
        public string	calltype	{get;set;}
        @AuraEnabled
        public string	fitur_id	{get;set;}
        @AuraEnabled
        public string	trx_date	{get;set;}
        @AuraEnabled
        public string	branchcode	{get;set;}
        @AuraEnabled
        public string curency {get;set;} //currency
        @AuraEnabled
        public String terminal_id {get;set;}
        @AuraEnabled
        public String acct_debet1 {get;set;}
        @AuraEnabled
        public String amt_debet1 {get;set;}
        @AuraEnabled
        public String acct_debet2 {get;set;}
        @AuraEnabled
        public String amt_debet2 {get;set;}
        @AuraEnabled
        public String acct_debet3 {get;set;}
        @AuraEnabled
        public String amt_debet3 {get;set;}
        @AuraEnabled
        public String acct_debet4 {get;set;}
        @AuraEnabled
        public String amt_debet4 {get;set;}
        @AuraEnabled
        public String acct_debet5 {get;set;}
        @AuraEnabled
        public String amt_debet5 {get;set;}
        @AuraEnabled
        public String acct_kredit1 {get;set;}
        @AuraEnabled
        public String amt_kredit1 {get;set;}
        @AuraEnabled
        public String acct_kredit2 {get;set;}
        @AuraEnabled
        public String amt_kredit2 {get;set;}
        @AuraEnabled
        public String acct_kredit3 {get;set;}
        @AuraEnabled
        public String amt_kredit3 {get;set;}
        @AuraEnabled
        public String acct_kredit4 {get;set;}
        @AuraEnabled
        public String amt_kredit4 {get;set;}
        @AuraEnabled
        public String acct_kredit5 {get;set;}
        @AuraEnabled
        public String amt_kredit5 {get;set;}
    }

    public class PaymentResolutionServiceResponse{
        @AuraEnabled
        public Boolean status {get;set;}
        @AuraEnabled
        public Integer code {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public PaymentResolutionServiceData data {get;set;}
    }

    public class PaymentResolutionServiceData{
        @AuraEnabled
        public String errorCode {get;set;}
        @AuraEnabled
        public String responseCode {get;set;}
        @AuraEnabled
        public String responseMessage {get;set;}
        @AuraEnabled
        public String trancode {get;set;}
        @AuraEnabled
        public String journalSequence {get;set;}
        @AuraEnabled
        public String needApproval {get;set;}
        @AuraEnabled
        public String currencyCode {get;set;}
        @AuraEnabled
        public String accountNumber {get;set;}
        @AuraEnabled
        public String shortNumber {get;set;}
        @AuraEnabled
        public String shortName {get;set;}
        @AuraEnabled
        public String accountCurrency {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String fullName {get;set;}
        @AuraEnabled
        public String branchCode {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public String corporateName {get;set;}
        @AuraEnabled
        public String accType {get;set;}
        @AuraEnabled
        public String namaGiroPenarikan {get;set;}
        @AuraEnabled
        public String nomorGiroPenarikan {get;set;}
        @AuraEnabled
        public String namaGiroSetoran {get;set;}
        @AuraEnabled
        public String nomorGiroSetoran {get;set;}
    }

    public class GenerateTokenCHMSRequest{
        @AuraEnabled
        public String client_id {get;set;}
        @AuraEnabled
        public String client_secret {get;set;}
    }
    public class GenerateTokenCHMSResponse{
        @AuraEnabled
        public Boolean status {get;set;}
        @AuraEnabled
        public Integer code {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public GenerateTokenCHMSData data {get;set;}
    }
    
    public class GenerateTokenCHMSData{
        @AuraEnabled
        public String token {get;set;}
        @AuraEnabled
        public String token_type {get;set;}
        @AuraEnabled
        public Integer expires_in {get;set;}
        @AuraEnabled
        public String client_id {get;set;}
    }
}