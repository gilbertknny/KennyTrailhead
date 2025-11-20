// public with sharing class BristarSummary_API_Wrapper {
//     public BristarSummary_API_Wrapper() {

//     }
// }

// Apex Class Name    : EventMonitoring_API
// Created Date       : 25 September 2024
// Created Time       : 03.00 AM
// @author            : Suherbing Septian
// Modification Log :
// Ver   Date         Author                            Modification
// 1.0   25/09/2024   Suherbing Septian                 Initial Version

public with sharing class BristarSummary_API_Wrapper {

// get request all

    // get request (All)
    public class GetRequest_Model{
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String statusTicket {get;set;}
        public String area {get;set;}
        public String costCenter {get;set;}
        public String region {get;set;}
        public String mainBranch {get;set;}
        public String branch {get;set;} 
        public String page {get;set;}
        public String lmt {get;set;}
    }

// get Kantor Pusat (KP)
    // get detail KP (KP)
    public class GetDetailKP_Model{
        public String costCenter {get;set;}
        public String costCenterDesc {get;set;}
        public String openTicket {get;set;}
        public String closedTicket {get;set;}
        public String overSla {get;set;}
        public String onSla {get;set;}
    }
    // get Response (KP)
    public class GetResponseKP_Model{
        public List<GetDetailKP_Model> divisionSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String area {get;set;} 
    }

// get KP + divisi
    // get detail dataActivities (KP + CC)
    public class GetDetailKP1_Model{
        public String caseNumber {get;set;}
        public String createdTime {get;set;}
        public String closedTime {get;set;}
        public String status {get;set;} 
        public String caseType {get;set;}
        public String caseDescription {get;set;}
        public String slaSaatIni {get;set;}
        public String targetSla {get;set;}
        public String gapTerhadapSla {get;set;}
    }
    // get response (KP + CC)
    public class GetResponseKP1_Model{
        public List<GetDetailKP1_Model> ticketSummary {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
        public String costCenter {get;set;} 
        public String costCenterDesc {get;set;} 
        public String openTicket {get;set;}
        public String closedTicket {get;set;}
        public String overSla {get;set;}
        public String onSLa {get;set;}
    }

// get Kantor Wilayah (RO)
    // get detail RO
    public class GetDetailRO_Model{
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String openTicket {get;set;}
        public String closedTicket {get;set;}
        public String overSla {get;set;}
        public String onSla {get;set;}
    }
    // get Response RO
    public class GetResponseRO_Model{
        public List<GetDetailRO_Model> regionSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String area {get;set;} 
    }

// get Kantor Wilayah (RO) + Region (R)
    // get detail RO1
    public class GetDetailRO1_Model{
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
        public String openTicket {get;set;}
        public String closedTicket {get;set;}
        public String overSla {get;set;}
        public String onSla {get;set;}
    }
    // get Response RO1
    public class GetResponseRO1_Model{
        public List<GetDetailRO1_Model> mainBranchSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String area {get;set;} 
        public String region {get;set;}
        public String regionDesc {get;set;}
    }

// get Kantor Wilayah (RO) + Region + MainBr
    // get detail RO2
    public class GetDetailRO2_Model{
        public String branch {get;set;}
        public String branchDesc {get;set;}
        public String openTicket {get;set;}
        public String closedTicket {get;set;}
        public String overSla {get;set;}
        public String onSla {get;set;}
    }
    // get Response RO2
    public class GetResponseRO2_Model{
        public List<GetDetailRO2_Model> branchSummary {get;set;}
        public String responseCode {get;set;}
        public String responseMessage {get;set;} 
        public String area {get;set;} 
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
    }

// get Kantor Wilayah (RO) + Region + MainBr + Branch
    public class GetDetailRO3_Model{
        public String caseNumber {get;set;}
        public String createdTime {get;set;}
        public String closedTime {get;set;}
        public String status {get;set;} 
        public String caseType {get;set;}
        public String caseDescription {get;set;}
        public String slaSaatIni {get;set;}
        public String targetSla {get;set;}
        public String gapTerhadapSla {get;set;}
    }
    // get response (KP + CC)
    public class GetResponseRO3_Model{
        public List<GetDetailRO3_Model> ticketSummary {get;set;}
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
        public String area {get;set;}
        public String region {get;set;}
        public String regionDesc {get;set;}
        public String mainBranch {get;set;}
        public String mainBranchDesc {get;set;}
        public String branch {get;set;}
        public String branchDesc {get;set;}
        public String openTicket {get;set;}
        public String closedTicket {get;set;}
        public String overSla {get;set;}
        public String onSLa {get;set;}
    }

    // get response getResponse
    public class GetResponseModel{
        public String responseMessage {get;set;}
        public String responseCode {get;set;}
    }
}