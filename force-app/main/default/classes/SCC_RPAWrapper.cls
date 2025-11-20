public without sharing class SCC_RPAWrapper {
    public class InsertUpdateCaseResponseModel{
        public String response {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String ttNumber {get;set;}
        public String ticketId {get;set;}
    }

    public class GetCaseRequestModelBulk{
        public String caseTypeNumber {get;set;} 
    }

    public class GetCaseResponseModelBulk{
        public List<Case> ticketList {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }

    public class GetCaseRequestModelDetail{
        public String ticketId {get;set;}
    }

    public class GetCaseResponseModelDetail{
        public Case ticketDetail {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }

    public class InsertFileRequestModel{
        public String linkedEntityId {get;set;}
        public String versionData {get;set;}
        public String title {get;set;}
        public String pathOnClient {get;set;}
    }

    public class InsertFileResponseModel{
        public String responseCode {get;set;}
        public String responseMessage {get;set;}
        public String url {get;set;}
    }
}