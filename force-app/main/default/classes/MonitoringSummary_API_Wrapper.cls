// Apex Class Name    : MonitoringSummary_API_Wrapper
// Created Date       : 21 September 2024
// @author            : Suherbing Septian
// Modification Log :
// Ver   Date         Author                            Modification
// 1.0   21/09/2024   Suherbing Septian                 Initial Version

public with sharing class MonitoringSummary_API_Wrapper {

// get monitoring summary group by Date

    // get Request
    public class GetByDateRequestModel{
        public String StartDate {get;set;}
        public String EndDate {get;set;}
    }

    // get detail data response
    public class GetByDateDetailModel{
        public String Tanggal {get;set;}
        public String AnomalyCategory_RecordType {get;set;}
        public String Area {get;set;}
        public String Branch_Unit {get;set;}
        public String Divisi {get;set;}
        public String AnomalyCategory_Name {get;set;}
        public String MonitoringSummary_Name {get;set;}
        public String User_Name {get;set;}
        public String Total {get;set;}
    }

    // get Response
    public class GetByDateResponseModel{
        public List<GetByDateDetailModel> MonitoringSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }

// get monitoring summary group by Divisi - Kantor Pusat and Branch - Cabang

    // get Request
    public class GetByAreaRequestModel{
        public String Area {get;set;}
        public String GroupBy {get;set;}
    }
    
    // get detail data response
    public class GetByAreaDivisiDetailModel{
        public String Tanggal {get;set;}
        public String AnomalyCategory_RecordType {get;set;}
        public String Divisi {get;set;}
        public String Area {get;set;}
        public String AnomalyCategory_Name {get;set;}
        public String MonitoringSummary_Name {get;set;}
        public String User_Name {get;set;}
        public String Total {get;set;}
    }

    // get response
    public class GetByAreaDivisiResponseModel{
        public List<GetByAreaDivisiDetailModel> MonitoringSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }

    // get detail data response
    public class GetByAreaBranchDetailModel{
        public String Tanggal {get;set;}
        public String AnomalyCategory_RecordType {get;set;}
        public String Branch_Unit {get;set;}
        public String Area {get;set;}
        public String Sub_Area {get;set;}
        public String AnomalyCategory_Name {get;set;}
        public String MonitoringSummary_Name {get;set;}
        public String User_Name {get;set;}
        public String Total {get;set;}
    }

    // get response
    public class GetByAreaBranchResponseModel{
        public List<GetByAreaBranchDetailModel> MonitoringSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
    }

    // general response
    public class ErrorResponseModel {
        public String responseCode {get;set;}
        public String responseMessage {get;set;}
    }
}