public with sharing class SCC_ITSM_API_Wrapper {
    public class RequestITSMModel{
        public String resolutionType {get;set;}
        public String rootCause {get;set;}
        public String status {get;set;}
        public String incidentId {get;set;}
        public String actionItem {get;set;}
        public String reopenStatus {get;set;}
        public String reopenJustification {get;set;}
        public String holdJustification {get;set;}
        public String unholdStatus {get;set;}
        public String unholdJustification {get;set;}
        public String totalSLA_IT {get; set;}
    }

    public class ResponseITSMModel{
        public String ResponseCode{get; set;}
        public String ResponseMessage {get; set;}
        public IncidentUpdate updatedData{get;set;}
    }

    public class IncidentUpdate{
        public String IncidentCHMId {get;set;}
        public String incidentId {get;set;}
        public String resolutionType {get;set;}
        public String rootCause {get;set;}
        public String status {get;set;}
        public String actionItem {get;set;}
        public String updatedDate {get;set;}
        public String reopenStatus {get;set;}
        public String reopenJustification {get;set;}
        public String holdJustification {get; set;}
        public String unholdStatus {get; set;}
        public String unholdJustification{get; set;}
        public String totalSLA_IT {get;set;}
    }
}