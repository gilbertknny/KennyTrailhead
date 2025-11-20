public with sharing class SCC_CaseResolution_EJOLWrapper {
    public class EJLogData{
        @AuraEnabled public String ejlog {get;set;}
        @AuraEnabled public String last_ejlog {get;set;}
        @AuraEnabled public String filename {get;set;}
        @AuraEnabled public String ip_address {get;set;}
        @AuraEnabled public String field {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String num {get;set;}
        @AuraEnabled public String index {get;set;}
    }

    public class EJLogResponse{
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public EJLogData data {get;set;}
    }

    public class EJLogResponseError{
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public Integer code {get;set;}
        @AuraEnabled public List<EJLogData> data {get;set;}
    }

    public class EJLogRequest{
        @AuraEnabled public String ipAddress {get;set;}
        @AuraEnabled public String dateRequest {get;set;}
        @AuraEnabled public String tid {get;set;}
    }
}