public with sharing class SCC_DroneAPIWrapper {
    public class UpdateCaseRequestModel{
        public String case_number {get;set;}
        public String process {get;set;}
        public Boolean closed_drone {get;set;}
        public String closed_by {get;set;}
        public String remark {get;set;}
        public Integer fitur_id {get;set;}
        public String update_call_type {get;set;}
        public String closure_comments {get;set;}
    }

    public class UpdateCaseResponseModel{
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }

    public class CheckManualReconRequestModel{
        public Date transaction_date {get;set;}
        public String call_type {get;set;} 
        public Integer amount {get;set;} 
        public String nomor_rekening {get;set;} 
        public String terminal_id {get;set;} 
        public String nomor_kartu {get;set;} 
    }
    public class DataManualRecon {
        public String caseId {get;set;}
        public String caseNumber {get;set;}
        public String status {get;set;}
        public Boolean manualRekonFlag {get;set;}
        public Boolean pembukuanSukses {get;set;}
    }

    public class CheckManualReconResponseModel{
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public Integer totalSize {get;set;} 
        public List <DataManualRecon> data {get;set;} 
    }

    public class RequestCreateTicketDrone {
        public String ticket_no_chm {get;set;}
        public String cust_name {get;set;}
        public String card_no {get;set;}
        public String acct_no {get;set;}
        public String call_type {get;set;}
        public String branch {get;set;}
        public String trx_date {get;set;}
        public String amount {get;set;}
        public String remark {get;set;}
        public String notelp {get;set;}
        public String email {get;set;}
        public String description {get;set;}
    }

    public class ResponseCreateTicket {
        public String status {get;set;}
        public String code {get;set;}
        public String message {get;set;}
        public Data data {get;set;}
    }
    public class Data {
        public String ticket_no {get;set;}
        public String ticket_no_chm {get;set;}
    }

    public class RequestUpdateTicketDrone {
        public String ticket_no_chm {get;set;}
        public String remark {get;set;}
    }

}