public with sharing class SCC_LegacyCaseAPIWrapper {
    public class CreateCaseRequestModel{
        public String NamaPIC {get;set;}
        public String CallTypeID {get;set;}
        public String NoTelpPIC {get;set;}
        public String User {get;set;}
        public String Gateway {get;set;}
        public String TID {get;set;}
        public String Assignee {get;set;}
        public String TipeIntegrasi {get;set;}
        public String Notes {get;set;}
        public String UniqueID {get;set;}
        public String NomorKartu {get;set;}
        public String NoRekening {get;set;}
        public String Nominal {get;set;}
        public String TglTransaksi {get;set;}
        public String Email {get;set;}
        public String JenisTiket {get;set;}
        public String NamaMerchant {get;set;}
        public String PICMerchant {get;set;}
        public String TelfonPICMerchant {get;set;}
        public String MID {get;set;}
    }

    public class CreateCaseResponseModel{
        public String Response {get;set;}
        public String CreateDate {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String TroubleTicketID {get;set;}
    }

    public class GetCaseRequestModel{
        public String Qualification {get;set;}
        public String maxLimit {get;set;}
        public String startRecord {get;set;}
    }
    
    public class GetCaseTicketDetailModel{
        public String TicketId {get;set;}
        public String Create_Date {get;set;}
        public String Status_Ticket {get;set;}
        public String Status_SLA {get;set;}
        public String Calltype {get;set;}
        public String CalltypeID {get;set;}
        public String TglTransaksi {get;set;}
        public String Nominal {get;set;}
        public String NoTelpNasabah {get;set;}
        public String Details {get;set;}
        public String
         Close_Date {get;set;}
    }

    public class GetCaseResponseModel{
        public List<GetCaseTicketDetailModel> TicketList {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }
}