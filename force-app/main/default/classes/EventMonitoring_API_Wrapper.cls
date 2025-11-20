// Apex Class Name    : EventMonitoring_API
// Created Date       : 25 September 2024
// Created Time       : 03.00 AM
// @author            : Suherbing Septian
// Modification Log :
// Ver   Date         Author                            Modification
// 1.0   25/09/2024   Suherbing Septian                 Initial Version

public with sharing class EventMonitoring_API_Wrapper {

// get request all

    // get request (All)
    public class GetRequest_Model{
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String area {get;set;}
        public String costCenter {get;set;}
        public String region {get;set;}
        public String mainBranch {get;set;}
        public String branch {get;set;} 
        public String page {get;set;}
        public String lmt {get;set;}
    }

// get Kantor Pusat (KP)
    // get detail activities (KP)
    public class GetActivitiesKP_Model{
        public String anomalyType {get;set;}
        // public String anomalyTypeDesc {get;set;}
        public String total {get;set;} 
    }
    // get detail KP (KP)
    public class GetDetailKP_Model{
        public List<GetActivitiesKP_Model> activities {get;set;}
        public String cosCenter {get;set;}
        public String cosCenterDesc {get;set;}
        public String totalActivities {get;set;}
    }
    // get Response (KP)
    public class GetResponseKP_Model{
        public List<GetDetailKP_Model> divisionSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String area {get;set;} 
    }

// get KP + costCenter
    // get detail dataActivities (KP + CC)
    public class GetDataActivitiesKP1_Model{
        public String user_Name {get;set;}
        public String total {get;set;}
        public String tanggal {get;set;}
        public String monitoringSummary_Name {get;set;} 
        public String anomalyCategory_RecordType {get;set;}
        // public String anomalyCategory_Name {get;set;}
    }
    // get response (KP + CC)
    public class GetResponseKP1_Model{
        public List<GetDataActivitiesKP1_Model> dataActivities {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
        public String costCenter {get;set;} 
        public String costCenterDesc {get;set;}
        public String totalActivities {get;set;}
    }

// get Kantor Wilayah (RO)
    // get detail Activities (RO)
    public class GetActivitiesRO_Model{
        public String anomalyType {get;set;}
        // public String anomalyTypeDesc {get;set;}
        public String total {get;set;}
    }
    // get detail (RO)
    public class GetDetailRO_Model{
        public List<GetActivitiesRO_Model> activities {get;set;}
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String totalActivities {get;set;}
    }
    // get response (RO)
    public class GetResponseRO_Model{
        public List<GetDetailRO_Model> regionalOfficeSummary {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
    }

// get Kantor Wilayah (RO) + Region (R)
    // get detail dataActivities (RO + R)
    public class GetActivitiesRO1_Model{
        public String anomalyType {get;set;}
        // public String anomalyTypeDesc {get;set;}
        public String total {get;set;}
    }
    // get detail (RO + R)
    public class GetDetailRO1_Model{
        public List<GetActivitiesRO1_Model> activities {get;set;}
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
        public String totalActivities {get;set;}
    }
    // get data activities RO1
    public class GetDetailActivitiesRO1_Model{
        public String user_Name {get;set;}
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
        public String branchCode {get;set;}
        public String branchDesc {get;set;}
        public String total {get;set;}
        public String tanggal {get;set;}
        public String monitoringSummary_Name {get;set;}
        public String anomalyCategory_RecordType {get;set;}
        // public String anomalyCategory_Name {get;set;}
    }
    // get response (RO + R)
    public class GetResponseRO1_Model{
        public List<GetDetailRO1_Model> branchOfficeSummary {get;set;}
        public List<GetDetailActivitiesRO1_Model> DataActivities {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String totalActivities {get;set;}
    }

// get Kantor Wilayah (RO) + Region + MainBr
    // get detail dataActivities (RO + R + MB)
    public class GetActivitiesRO2_Model{
        public String anomalyType {get;set;}
        // public String anomalyTypeDesc {get;set;}
        public String total {get;set;}
    }
    // get detail (RO + R + MB)
    public class GetDetailRO2_Model{
        public List<GetActivitiesRO2_Model> activities {get;set;}
        public String branchCode {get;set;}
        public String branchDesc {get;set;}
        public String totalActivities {get;set;}
    }
    // get data activities RO2
    public class GetDetailActivitiesRO2_Model{
        public String user_Name {get;set;}
        public String branchCode {get;set;}
        public String branchDesc {get;set;}
        public String total {get;set;}
        public String tanggal {get;set;}
        public String monitoringSummary_Name {get;set;}
        public String anomalyCategory_RecordType {get;set;}
        // public String anomalyCategory_Name {get;set;}
    }
    // get response (RO + R + MB)
    public class GetResponseRO2_Model{
        public List<GetDetailRO2_Model> BranchSummary {get;set;}
        public List<GetDetailActivitiesRO2_Model> DataActivities {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
        public String totalActivities {get;set;}
    }

// get Kantor Wilayah (RO) + Region + MainBr + Branch
    // get detail (RO + R + MB)
    public class GetDetailRO3_Model{
        public String user_Name {get;set;}
        public String total {get;set;}
        public String tanggal {get;set;}
        public String monitoringSummary_Name {get;set;}
        public String anomalyCategory_RecordType {get;set;}
        // public String anomalyCategory_Name {get;set;}
    }
    // get response (RO + R + MB)
    public class GetResponseRO3_Model{
        public List<GetDetailRO3_Model> DataActivities {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
        public String branchCode {get;set;}
        public String branchDesc {get;set;}
        public String totalActivities {get;set;}
    }

    // get response getResponse
    public class GetResponseModel{
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
    }
}