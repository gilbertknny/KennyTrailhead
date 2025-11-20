public with sharing class SCC_AVAYA_Wrapper {
    public class RequestToken{
        @AuraEnabled public String username {get;set;}
        @AuraEnabled public String password {get;set;}
    }

    public class ResponseToken{
        @AuraEnabled public String token {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public Decimal status {get;set;}
        @AuraEnabled public String traceId {get;set;}
    }

    public class ResponseReportHistorical{
        @AuraEnabled public String headerHistorical {get;set;}
        @AuraEnabled public Decimal valueHistorical {get;set;}
    }

    public class ResponseReportAgent{
        @AuraEnabled public String dates {get;set;}
        @AuraEnabled public String agentGroup {get;set;}
        @AuraEnabled public ReportAgent totals {get;set;}
        @AuraEnabled public List<ReportAgent> agents {get;set;}
        
    }

    public class ReportAgent{
        @AuraEnabled public Decimal loginID {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String availTime {get;set;}
        @AuraEnabled public String staffedTime {get;set;}
        @AuraEnabled public Decimal aht {get;set;}
        @AuraEnabled public String auxIsiForm {get;set;}
        @AuraEnabled public String auxRestRoom {get;set;}
        @AuraEnabled public String auxSholat {get;set;}
    }

    public class ResponseReportSkills{
        @AuraEnabled public String seksiSkill {get;set;}
        @AuraEnabled public Decimal callOffered {get;set;}
        @AuraEnabled public Decimal acceptable {get;set;}
        @AuraEnabled public Decimal acdCalls {get;set;}
        @AuraEnabled public Decimal abanCalls {get;set;}
        @AuraEnabled public Decimal agentsAvail {get;set;}
        @AuraEnabled public Decimal agentsStaffed {get;set;}
        @AuraEnabled public Decimal serviceLevel {get;set;}
    }
}