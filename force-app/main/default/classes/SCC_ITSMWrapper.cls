public with sharing class SCC_ITSMWrapper {
    public class WrapperAPI {
        public HttpRequest req { get; set; }
        public HttpResponse res { get; set; }
        public String url_current { get; set; }

        public WrapperAPI(HttpRequest req, HttpResponse res, String url_current) {
            this.req = req;
            this.res = res;
            this.url_current = url_current;
        }
    }

    public class WrapperError {
        public String url_current { get; set; }
        public String cls_name { get; set; }

        public WrapperError(String url_current, String cls_name) {
            this.url_current = url_current;
            this.cls_name = cls_name;
        }
    }

    public class ResponseError{
        public String code {get;set;}
        public String description {get;set;}
        public List<String> message {get;set;}
        public String help {get;set;}
    }

    public class Message {
        public String message {get;set;}
    }

    public class RequestCreateTicket{
        public String BRI_DetectedTime {get;set;}
        public String ProfileLink {get;set;}
        public String Subject {get;set;}
        public String Symptom {get;set;}
        public String Source {get;set;}
        public String BRI_SourceKey {get;set;}
        public String BRI_LayananTerdampak {get;set;}
        public String BRI_TipeIncident {get;set;}
        public String BRI_CategorySystem {get;set;}
        public String Urgency {get;set;}
        public String Impact {get;set;}
        public String BRI_CIDITEMUKAN {get;set;}
        public String BRI_SApp_Detail {get;set;}
        public String BRI_SApp_TicketNumber {get;set;}
        public String BRI_SApp_OLA {get;set;}
    }

    public class ResponseCreateTicket{
        public String data_context {get;set;}
        public String ActualCategory_Valid {get;set;} 
        public String ActualCategory {get;set;} 
        public String Category_Valid {get;set;} 
        public String Category {get;set;} 
        public String CauseCode_Valid {get;set;} 
        public String CauseCode {get;set;} 
        public String ClosedBy {get;set;} 
        public String ClosedDateTime {get;set;} 
        public String ClosedDuration {get;set;} 
        public String CreatedBy {get;set;} 
        public String CreatedDateTime {get;set;} 
        public String Email {get;set;} 
        public String FirstCallResolution {get;set;} 
        public String Impact_Valid {get;set;} 
        public String Impact {get;set;} 
        public Integer IncidentNumber {get;set;} 
        public String IsNotification {get;set;} 
        public String IsVIP {get;set;} 
        public String IsWorkAround {get;set;} 
        public String LastModBy {get;set;} 
        public String LastModDateTime {get;set;} 
        public String Phone {get;set;} 
        public String Priority_Valid {get;set;} 
        public String Priority {get;set;} 
        public String ProfileFullName {get;set;} 
        public String ProfileLink_Category {get;set;} 
        public String ProfileLink_RecID {get;set;} 
        public String ProfileLink {get;set;} 
        public String RecId {get;set;} 
        public String Resolution {get;set;} 
        public String Service_Valid {get;set;} 
        public String Service {get;set;} 
        public String SLA {get;set;} 
        public String SLALink_Category {get;set;} 
        public String SLALink_RecID {get;set;} 
        public String SLALink {get;set;} 
        public String Source_Valid {get;set;} 
        public String Source {get;set;} 
        public String Status_Valid {get;set;} 
        public String Status {get;set;} 
        public String Subject {get;set;} 
        public String Symptom {get;set;} 
        public String Urgency_Valid {get;set;} 
        public String Urgency {get;set;} 
        public String LoginId {get;set;} 
        public String Owner_Valid {get;set;} 
        public String Owner {get;set;} 
        public String OwnerTeam_Valid {get;set;} 
        public String OwnerTeam {get;set;} 
        public String OwnerType {get;set;} 
        public String IsNewRecord {get;set;} 
        public String AlternateContactLink_Category {get;set;} 
        public String AlternateContactLink_RecID {get;set;} 
        public String AlternateContactLink {get;set;} 
        public String ResolvedDateTime {get;set;} 
        public String ResolvedBy {get;set;} 
        public String HoursOfOperation_Valid {get;set;} 
        public String HoursOfOperation {get;set;} 
        public String OwnerEmail {get;set;} 
        public String OwnerTeamEmail {get;set;} 
        public String OwnershipAssignmentEmail {get;set;} 
        public String CustomerLocation_Valid {get;set;} 
        public String CustomerLocation {get;set;} 
        public String IsReportedByAlternateContact {get;set;} 
        public String ResolutionEscLink_Category {get;set;} 
        public String ResolutionEscLink_RecID {get;set;} 
        public String ResolutionEscLink {get;set;} 
        public String ResponseEscLink_Category {get;set;} 
        public String ResponseEscLink_RecID {get;set;} 
        public String ResponseEscLink {get;set;} 
        public String WaitingEscLink_Category {get;set;} 
        public String WaitingEscLink_RecID {get;set;} 
        public String WaitingEscLink {get;set;} 
        public String ClosingEscLink_Category {get;set;} 
        public String ClosingEscLink_RecID {get;set;} 
        public String ClosingEscLink {get;set;} 
        public String AlternateContactEmail {get;set;} 
        public String OrganizationUnitID {get;set;} 
        public String ReportingOrgUnitID_Valid {get;set;} 
        public String ReportingOrgUnitID {get;set;} 
        public String TypeOfIncident {get;set;} 
        public String AlternateContactPhone {get;set;} 
        public String TeamManagerEmail {get;set;} 
        public String ProblemLink_Category {get;set;} 
        public String ProblemLink_RecID {get;set;} 
        public String ProblemLink {get;set;} 
        public String CustomerDepartment_Valid {get;set;} 
        public String CustomerDepartment {get;set;} 
        public String ActualService_Valid {get;set;} 
        public String ActualService {get;set;} 
        public String CostPerMinute_Currency {get;set;} 
        public String CostPerMinute_CurrencyValid {get;set;} 
        public String CostPerMinute {get;set;} 
        public String IsInFinalState {get;set;} 
        public String IsReclassifiedForResolution {get;set;} 
        public String KnowledgeLink_Category {get;set;} 
        public String KnowledgeLink_RecID {get;set;} 
        public String KnowledgeLink {get;set;} 
        public String PreviousState {get;set;} 
        public String ResolvedByIncidentNumber {get;set;} 
        public String TotalTimeSpent {get;set;} 
        public String RespondedBy {get;set;} 
        public String RespondedDateTime {get;set;} 
        public String OrgUnitLink_Category {get;set;} 
        public String OrgUnitLink_RecID {get;set;} 
        public String OrgUnitLink {get;set;} 
        public String OwningOrgUnitId_Valid {get;set;} 
        public String OwningOrgUnitId {get;set;} 
        public String ProgressBarPosition {get;set;} 
        public String ResolvedByType {get;set;} 
        public String ReportedBy {get;set;} 
        public String NewNotes {get;set;} 
        public String CreatedByType {get;set;} 
        public String SLADisplayText {get;set;} 
        public String ServiceReqLink_Category {get;set;} 
        public String ServiceReqLink_RecID {get;set;} 
        public String ServiceReqLink {get;set;} 
        public String ReadOnly {get;set;} 
        public String Cost_Currency {get;set;} 
        public String Cost_CurrencyValid {get;set;} 
        public String Cost {get;set;} 
        public String IncidentDetailWorkflowTag {get;set;} 
        public String IncidentDetailSummary {get;set;} 
        public String IsApprovalNeeded {get;set;} 
        public String Approver_Valid {get;set;} 
        public String Approver {get;set;} 
        public String IsDSMTaskExisted {get;set;} 
        public String ApprovalStatus {get;set;} 
        public String SocialTextHeader {get;set;} 
        public String Subcategory_Valid {get;set;} 
        public String Subcategory {get;set;} 
        public String helpdesk_Priority_Valid {get;set;} 
        public String helpdesk_Priority {get;set;} 
        public String ViewType {get;set;} 
        public String IncidentNetworkUserName {get;set;} 
        public String SendSurveyNotification {get;set;} 
        public String EntityLink_Category {get;set;} 
        public String EntityLink_RecID {get;set;} 
        public String EntityLink {get;set;} 
        public String EventCIRecId {get;set;} 
        public String IsMasterIncident {get;set;} 
        public String IsResolvedByMaster {get;set;} 
        public String MasterIncidentLink_Category {get;set;} 
        public String MasterIncidentLink_RecID {get;set;} 
        public String MasterIncidentLink {get;set;} 
        public String ServiceOwnerEmail {get;set;} 
        public String IsRelatedIncidentUpdate {get;set;} 
        public String IsRelatedIncidentResolutionUpdate {get;set;} 
        public String IsUnRead {get;set;} 
        public String ivnt_RequestforInformationorData {get;set;} 
        public String ivnt_UpdateRFI {get;set;} 
        public String AddChatconversationtoActivityHistory {get;set;} 
        public String ivnt_TeamsUserDetailsLink_Category {get;set;} 
        public String ivnt_TeamsUserDetailsLink_RecID {get;set;} 
        public String ivnt_TeamsUserDetailsLink {get;set;} 
        public String VirimaAssetID {get;set;} 
        public String RecommendedCategory {get;set;} 
        public String RecommendedService {get;set;} 
        public String RecommendedSubCategory {get;set;} 
        public String Accuracy {get;set;} 
        public String IsRecommended {get;set;} 
        public String RecomService {get;set;} 
        public String RecomCategory {get;set;} 
        public String RecomSubCategory {get;set;} 
        public String HRCaseLink_Category {get;set;} 
        public String HRCaseLink_RecID {get;set;} 
        public String HRCaseLink {get;set;} 
        public String IsRunTicketClassification {get;set;} 
        public String BRI_IncidentAge {get;set;} 
        public String TestNotes {get;set;} 
        public String BRI_LayananCITerdampak_Valid {get;set;} 
        public String BRI_LayananCITerdampak {get;set;} 
        public String BRI_DescriptionLayanan {get;set;} 
        public String BRI_TanggalInsiden {get;set;} 
        public String BRI_WaktuInsiden {get;set;} 
        public String BRI_CalcualtedWeight_Valid {get;set;} 
        public String BRI_CalcualtedWeight {get;set;} 
        public String BRI_Application {get;set;} 
        public String BRI_Criticaly {get;set;} 
        public String BRI_TotalDuration {get;set;} 
        public String BRI_RootCause {get;set;} 
        public String BRI_LessonLearned {get;set;} 
        public String BRI_ProposedEhancment {get;set;} 
        public String BRI_Divisi_Valid {get;set;} 
        public String BRI_Divisi {get;set;} 
        public String BRI_Reopen_Reason {get;set;} 
        public String BRI_Reopen_tag_Valid {get;set;} 
        public String BRI_Reopen_tag {get;set;} 
        public String BRI_tampungsatu {get;set;} 
        public String BRI_ReasonHold {get;set;} 
        public String BRI_ActionItems {get;set;} 
        public String BRI_CSIRT_Valid {get;set;} 
        public String BRI_CSIRT {get;set;} 
        public String BRI_DRP_Valid {get;set;} 
        public String BRI_DRP {get;set;} 
        public String BRI_TypeSolution_Valid {get;set;} 
        public String BRI_TypeSolution {get;set;} 
        public String BRI_Tampung1 {get;set;} 
        public String BRI_Tampung2 {get;set;} 
        public String BRI_Tampung3 {get;set;} 
        public String BRI_FormatTiketIncident {get;set;} 
        public String BRI_WAResult_Create {get;set;} 
        public String BRI_WAResult_Resolved {get;set;} 
        public String BRI_PindahPriority {get;set;} 
        public String BRI_PindahPriority_tag {get;set;} 
        public String BRI_WANotifResult {get;set;} 
        public String temp_CIRecId {get;set;} 
        public String BRI_CategorySystem_Valid {get;set;} 
        public String BRI_CategorySystem {get;set;} 
        public String BRI_WASendNotif {get;set;} 
        public String BRI_DetectedTime {get;set;} 
        public String BRI_ISKPI {get;set;} 
        public String BRI_TipeIncident_Valid {get;set;} 
        public String BRI_TipeIncident {get;set;} 
        public String BRI_ManagerMajorIncident {get;set;} 
        public String BRI_IncidentMajorManager_Category {get;set;} 
        public String BRI_IncidentMajorManager_RecID {get;set;} 
        public String BRI_IncidentMajorManager {get;set;} 
        public String BRI_ActualAge {get;set;} 
        public String BRI_TechnicalProblem {get;set;} 
        public String BRI_techresolution {get;set;} 
        public String BRI_psblrc {get;set;} 
        public String BRI_RCCategory {get;set;} 
        public String BRI_Sysapp_Impact {get;set;} 
        public String BRI_BusinessImpact {get;set;} 
        public String BRI_ServiceImpact {get;set;} 
        public String BRI_HInvolved {get;set;} 
        public String BRI_CIDITEMUKAN_Valid {get;set;} 
        public String BRI_CIDITEMUKAN {get;set;} 
        public String BRI_LayananTerdampak_Valid {get;set;} 
        public String BRI_LayananTerdampak {get;set;} 
        public String BRI_OwnerDisplayName {get;set;} 
        public String BRI_SubjectTemplate {get;set;} 
        public String BRI_Kritikalitas_Aplikasi_Valid {get;set;} 
        public String BRI_Kritikalitas_Aplikasi {get;set;} 
        public String BRI_Kritikalitas_Aplikasi_Pengelola {get;set;} 
        public String BRI_Kritikalitas_Aplikasi_Value {get;set;} 
        public String BRI_Priority_Value {get;set;} 
        public String BRI_Notif_Count {get;set;} 
        public String BRI_Notif_Count_Master {get;set;} 
        public String BRI_Notif_PhoneNumber {get;set;} 
        public String BRI_Notif_PhoneNumberAll {get;set;} 
        public String BRI_APP_OWNER {get;set;} 
        public String BRI_APP_KRITIKALITAS {get;set;} 
        public String Shield_Start_Time {get;set;} 
        public String Shield_detect_intervals {get;set;} 
        public String Shield_resolved_intervals {get;set;} 
        public String Shield_str_detect_intervals {get;set;} 
        public String Shield_str_resolved_intervals {get;set;} 
        public String Shield_impact {get;set;} 
        public String Shield_urgency {get;set;} 
        public String Shield_is_kpi {get;set;} 
        public String Shield_third_party_name {get;set;} 
        public String Shield_responsible_engineer {get;set;} 
        public String Shield_prefix_department {get;set;} 
        public String Shield_is_problem {get;set;} 
        public String Shield_proposed_enhancement {get;set;} 
        public String bri_dwntm_hours {get;set;} 
        public String bri_dwntm_minutes {get;set;} 
        public String bri_dwntm_seconds {get;set;} 
        public String bri_totaldowntime {get;set;} 
        public String BRI_ISDOWNTIME {get;set;} 
        public String BRI_DetectedDuration {get;set;} 
        public String BRI_NotifWARaw {get;set;} 
        public String BRI_CustomerTeam_Valid {get;set;} 
        public String BRI_CustomerTeam {get;set;} 
        public String BRI_CustomerDivisi_Valid {get;set;} 
        public String BRI_CustomerDivisi {get;set;} 
        public String BRI_isWFRun {get;set;} 
        public String BRI_TempSymptom {get;set;} 
        public String BRI_isUpdateSymptom {get;set;} 
        public String BRI_NotifWALen {get;set;} 
        public String BRI_NotifWAChar {get;set;} 
        public String BRI_WANotif_Token {get;set;} 
        public String BRI_NotifWAGroup {get;set;} 
        public String BRI_FlagNewIncident {get;set;} 
        public String BRI_GlobalObject_Valid {get;set;} 
        public String BRI_GlobalObject {get;set;} 
        public String BRI_NotifWAGroupError {get;set;} 
        public String BRI_TampungOpenDateTime {get;set;} 
        public String BRI_TampungInProgressDateTime {get;set;} 
        public String BRI_TempText {get;set;} 
        public String BRI_IsDeploymentImpact {get;set;} 
        public String BRI_DetectedDurationInt {get;set;} 
        public String BRI_RecoverDurationInt {get;set;} 
        public String BRI_isReopenFromIntegration {get;set;} 
        public String BRI_isIncProb {get;set;} 
        public String BRI_IncProb_Status_Valid {get;set;} 
        public String BRI_IncProb_Status {get;set;} 
        public String BRI_IncProb_Justification {get;set;} 
        public String BRI_SymptomForProblem {get;set;} 
        public String BRI_NotifCreate_Count {get;set;} 
        public String BRI_isNotifSend {get;set;} 
        public String BRI_NotifResolve_Count {get;set;} 
        public String BRI_isWFDetailRun {get;set;} 
        public String BRI_NotifDetail_Count {get;set;} 
        public String BRI_SourceKey {get;set;} 
        public String BRI_KodeUKO_Valid {get;set;} 
        public String BRI_KodeUKO {get;set;} 
        public String BRI_UKO {get;set;} 
        public String BRI_RegionalOffice {get;set;} 
        public String BRI_KantorCabangInduk {get;set;} 
        public String BRI_JenisFitur_Valid {get;set;} 
        public String BRI_JenisFitur {get;set;} 
        public String BRI_JenisFiturActual {get;set;} 
        public String BRI_NeedProblem_Valid {get;set;} 
        public String BRI_NeedProblem {get;set;} 
        public String BRI_SApp_Detail {get;set;} 
        public String BRI_Profider_Valid {get;set;} 
        public String BRI_Profider {get;set;} 
        public String BRI_JenisPerangkat_Valid {get;set;} 
        public String BRI_JenisPerangkat {get;set;} 
        public String BRI_JenisGangguan_Valid {get;set;} 
        public String BRI_JenisGangguan {get;set;} 
        public String BRI_InfraCatResolution_Valid {get;set;} 
        public String BRI_InfraCatResolution {get;set;} 
        public String BRI_AggregatorVendor {get;set;} 
        public String BRI_FlagAutoExTask {get;set;} 
        public String BRI_LinkToUKOMaster_Category {get;set;} 
        public String BRI_LinkToUKOMaster_RecID {get;set;} 
        public String BRI_LinkToUKOMaster {get;set;} 
        public String BRI_KodeUKO_INF {get;set;} 
        public String BRI_SApp_TicketNumber {get;set;} 
        public String BRI_SApp_Reopen_Justification {get;set;}
        public String BRI_isUnHoldFromIntegration {get;set;}
        public String BRI_SApp_UnHold_Justification {get;set;}
        public String BRI_SApp_UnHold_Status_Valid {get;set;}
        public String BRI_SApp_UnHold_Status {get;set;}
        public String BRI_SApp_UnHold_RejectJustification {get;set;}
        public String BRI_SApp_OLA {get;set;}
        public String BRI_ResolvedDuration {get;set;}
        
    }

    public class RequestAttachment{
        public String URL {get;set;}
        public String ATTACHNAME {get;set;}
        public String ParentLink_RecID {get;set;}
        public String Uploaded {get;set;}
        public String SaveType {get;set;}
        public String ParentLink_Category {get;set;}
        public String ATTACHDESC {get;set;}
    }

    public class ResponseAttachment{
        public String data_context {get;set;} 
        public String AttachmentHost {get;set;} 
        public String AttachmentPath {get;set;} 
        public String CreatedBy {get;set;} 
        public String CreatedDateTime {get;set;} 
        public String ATTACHDESC {get;set;} 
        public String LastModBy {get;set;} 
        public String LastModDateTime {get;set;} 
        public String ATTACHNAME {get;set;} 
        public String ParentLink_Category {get;set;} 
        public String ParentLink_RecID {get;set;} 
        public String ParentLink {get;set;} 
        public String RecId {get;set;} 
        public String AttachmentSize {get;set;} 
        public String Uploaded {get;set;} 
        public String ReadOnly {get;set;} 
        public String URL {get;set;} 
        public String SaveType {get;set;} 
        public String DataRecId {get;set;} 
        public String ParentLink2_Category {get;set;} 
        public String ParentLink2_RecID {get;set;} 
        public String ParentLink2 {get;set;} 
    }

    public class RequestReopenTicket{
        public String BRI_isReopenFromIntegration {get;set;}
        public String BRI_SApp_Reopen_Justification {get;set;}
    }

    public class ResponseReopenTicket{
        public String data_context {get;set;} 
        public String ActualCategory_Valid {get;set;} 
        public String ActualCategory {get;set;} 
        public String Category_Valid {get;set;} 
        public String Category {get;set;} 
        public String CauseCode_Valid {get;set;} 
        public String CauseCode {get;set;} 
        public String ClosedBy {get;set;} 
        public String ClosedDateTime {get;set;} 
        public String ClosedDuration {get;set;} 
        public String CreatedBy {get;set;} 
        public String CreatedDateTime {get;set;} 
        public String Email {get;set;} 
        public String FirstCallResolution {get;set;} 
        public String Impact_Valid {get;set;} 
        public String Impact {get;set;} 
        public String IncidentNumber {get;set;} 
        public String IsNotification {get;set;} 
        public String IsVIP {get;set;} 
        public String IsWorkAround {get;set;} 
        public String LastModBy {get;set;} 
        public String LastModDateTime {get;set;} 
        public String Phone {get;set;} 
        public String Priority_Valid {get;set;} 
        public String Priority {get;set;} 
        public String ProfileFullName {get;set;} 
        public String ProfileLink_Category {get;set;} 
        public String ProfileLink_RecID {get;set;} 
        public String ProfileLink {get;set;} 
        public String RecId {get;set;} 
        public String Resolution {get;set;} 
        public String Service_Valid {get;set;} 
        public String Service {get;set;} 
        public String SLA {get;set;} 
        public String SLALink_Category {get;set;} 
        public String SLALink_RecID {get;set;} 
        public String SLALink {get;set;} 
        public String Source_Valid {get;set;} 
        public String Source {get;set;} 
        public String Status_Valid {get;set;} 
        public String Status {get;set;} 
        public String Subject {get;set;} 
        public String Symptom {get;set;} 
        public String Urgency_Valid {get;set;} 
        public String Urgency {get;set;} 
        public String LoginId {get;set;} 
        public String Owner_Valid {get;set;} 
        public String Owner {get;set;} 
        public String OwnerTeam_Valid {get;set;} 
        public String OwnerTeam {get;set;} 
        public String OwnerType {get;set;} 
        public String IsNewRecord {get;set;} 
        public String AlternateContactLink_Category {get;set;} 
        public String AlternateContactLink_RecID {get;set;} 
        public String AlternateContactLink {get;set;} 
        public String ResolvedDateTime {get;set;} 
        public String ResolvedBy {get;set;} 
        public String HoursOfOperation_Valid {get;set;} 
        public String HoursOfOperation {get;set;} 
        public String OwnerEmail {get;set;} 
        public String OwnerTeamEmail {get;set;} 
        public String OwnershipAssignmentEmail {get;set;} 
        public String CustomerLocation_Valid {get;set;} 
        public String CustomerLocation {get;set;} 
        public String IsReportedByAlternateContact {get;set;} 
        public String ResolutionEscLink_Category {get;set;} 
        public String ResolutionEscLink_RecID {get;set;} 
        public String ResolutionEscLink {get;set;} 
        public String ResponseEscLink_Category {get;set;} 
        public String ResponseEscLink_RecID {get;set;} 
        public String ResponseEscLink {get;set;} 
        public String WaitingEscLink_Category {get;set;} 
        public String WaitingEscLink_RecID {get;set;} 
        public String WaitingEscLink {get;set;} 
        public String ClosingEscLink_Category {get;set;} 
        public String ClosingEscLink_RecID {get;set;} 
        public String ClosingEscLink {get;set;} 
        public String AlternateContactEmail {get;set;} 
        public String OrganizationUnitID {get;set;} 
        public String ReportingOrgUnitID_Valid {get;set;} 
        public String ReportingOrgUnitID {get;set;} 
        public String TypeOfIncident {get;set;} 
        public String AlternateContactPhone {get;set;} 
        public String TeamManagerEmail {get;set;} 
        public String ProblemLink_Category {get;set;} 
        public String ProblemLink_RecID {get;set;} 
        public String ProblemLink {get;set;} 
        public String CustomerDepartment_Valid {get;set;} 
        public String CustomerDepartment {get;set;} 
        public String ActualService_Valid {get;set;} 
        public String ActualService {get;set;} 
        public String CostPerMinute_Currency {get;set;} 
        public String CostPerMinute_CurrencyValid {get;set;} 
        public String CostPerMinute {get;set;} 
        public String IsInFinalState {get;set;} 
        public String IsReclassifiedForResolution {get;set;} 
        public String KnowledgeLink_Category {get;set;} 
        public String KnowledgeLink_RecID {get;set;} 
        public String KnowledgeLink {get;set;} 
        public String PreviousState {get;set;} 
        public String ResolvedByIncidentNumber {get;set;} 
        public String TotalTimeSpent {get;set;} 
        public String RespondedBy {get;set;} 
        public String RespondedDateTime {get;set;} 
        public String OrgUnitLink_Category {get;set;} 
        public String OrgUnitLink_RecID {get;set;} 
        public String OrgUnitLink {get;set;} 
        public String OwningOrgUnitId_Valid {get;set;} 
        public String OwningOrgUnitId {get;set;} 
        public String ProgressBarPosition {get;set;} 
        public String ResolvedByType {get;set;} 
        public String ReportedBy {get;set;} 
        public String NewNotes {get;set;} 
        public String CreatedByType {get;set;} 
        public String SLADisplayText {get;set;} 
        public String ServiceReqLink_Category {get;set;} 
        public String ServiceReqLink_RecID {get;set;} 
        public String ServiceReqLink {get;set;} 
        public String ReadOnly {get;set;} 
        public String Cost_Currency {get;set;} 
        public String Cost_CurrencyValid {get;set;} 
        public String Cost {get;set;} 
        public String IncidentDetailWorkflowTag {get;set;} 
        public String IncidentDetailSummary {get;set;} 
        public String IsApprovalNeeded {get;set;} 
        public String Approver_Valid {get;set;} 
        public String Approver {get;set;} 
        public String IsDSMTaskExisted {get;set;} 
        public String ApprovalStatus {get;set;} 
        public String SocialTextHeader {get;set;} 
        public String Subcategory_Valid {get;set;} 
        public String Subcategory {get;set;} 
        public String helpdesk_Priority_Valid {get;set;} 
        public String helpdesk_Priority {get;set;} 
        public String ViewType {get;set;} 
        public String IncidentNetworkUserName {get;set;} 
        public String SendSurveyNotification {get;set;} 
        public String EntityLink_Category {get;set;} 
        public String EntityLink_RecID {get;set;} 
        public String EntityLink {get;set;} 
        public String EventCIRecId {get;set;} 
        public String IsMasterIncident {get;set;} 
        public String IsResolvedByMaster {get;set;} 
        public String MasterIncidentLink_Category {get;set;} 
        public String MasterIncidentLink_RecID {get;set;} 
        public String MasterIncidentLink {get;set;} 
        public String ServiceOwnerEmail {get;set;} 
        public String IsRelatedIncidentUpdate {get;set;} 
        public String IsRelatedIncidentResolutionUpdate {get;set;} 
        public String IsUnRead {get;set;} 
        public String ivnt_RequestforInformationorData {get;set;} 
        public String ivnt_UpdateRFI {get;set;} 
        public String AddChatconversationtoActivityHistory {get;set;} 
        public String ivnt_TeamsUserDetailsLink_Category {get;set;} 
        public String ivnt_TeamsUserDetailsLink_RecID {get;set;} 
        public String ivnt_TeamsUserDetailsLink {get;set;} 
        public String VirimaAssetID {get;set;} 
        public String RecommendedCategory {get;set;} 
        public String RecommendedService {get;set;} 
        public String RecommendedSubCategory {get;set;} 
        public String Accuracy {get;set;} 
        public String IsRecommended {get;set;} 
        public String RecomService {get;set;} 
        public String RecomCategory {get;set;} 
        public String RecomSubCategory {get;set;} 
        public String HRCaseLink_Category {get;set;} 
        public String HRCaseLink_RecID {get;set;} 
        public String HRCaseLink {get;set;} 
        public String IsRunTicketClassification {get;set;} 
        public String BRI_IncidentAge {get;set;} 
        public String TestNotes {get;set;} 
        public String BRI_LayananCITerdampak_Valid {get;set;} 
        public String BRI_LayananCITerdampak {get;set;} 
        public String BRI_DescriptionLayanan {get;set;} 
        public String BRI_TanggalInsiden {get;set;} 
        public String BRI_WaktuInsiden {get;set;} 
        public String BRI_CalcualtedWeight_Valid {get;set;} 
        public String BRI_CalcualtedWeight {get;set;} 
        public String BRI_Application {get;set;} 
        public String BRI_Criticaly {get;set;} 
        public String BRI_TotalDuration {get;set;} 
        public String BRI_RootCause {get;set;} 
        public String BRI_LessonLearned {get;set;} 
        public String BRI_ProposedEhancment {get;set;} 
        public String BRI_Divisi_Valid {get;set;} 
        public String BRI_Divisi {get;set;} 
        public String BRI_Reopen_Reason {get;set;} 
        public String BRI_Reopen_tag_Valid {get;set;} 
        public String BRI_Reopen_tag {get;set;} 
        public String BRI_tampungsatu {get;set;} 
        public String BRI_ReasonHold {get;set;} 
        public String BRI_ActionItems {get;set;} 
        public String BRI_CSIRT_Valid {get;set;} 
        public String BRI_CSIRT {get;set;} 
        public String BRI_DRP_Valid {get;set;} 
        public String BRI_DRP {get;set;} 
        public String BRI_TypeSolution_Valid {get;set;} 
        public String BRI_TypeSolution {get;set;} 
        public String BRI_Tampung1 {get;set;} 
        public String BRI_Tampung2 {get;set;} 
        public String BRI_Tampung3 {get;set;} 
        public String BRI_FormatTiketIncident {get;set;} 
        public String BRI_WAResult_Create {get;set;} 
        public String BRI_WAResult_Resolved {get;set;} 
        public String BRI_PindahPriority {get;set;} 
        public String BRI_PindahPriority_tag {get;set;} 
        public String BRI_WANotifResult {get;set;} 
        public String temp_CIRecId {get;set;} 
        public String BRI_CategorySystem_Valid {get;set;} 
        public String BRI_CategorySystem {get;set;} 
        public String BRI_WASendNotif {get;set;} 
        public String BRI_DetectedTime {get;set;} 
        public String BRI_ISKPI {get;set;} 
        public String BRI_TipeIncident_Valid {get;set;} 
        public String BRI_TipeIncident {get;set;} 
        public String BRI_ManagerMajorIncident {get;set;} 
        public String BRI_IncidentMajorManager_Category {get;set;} 
        public String BRI_IncidentMajorManager_RecID {get;set;} 
        public String BRI_IncidentMajorManager {get;set;} 
        public String BRI_ActualAge {get;set;} 
        public String BRI_TechnicalProblem {get;set;} 
        public String BRI_techresolution {get;set;} 
        public String BRI_psblrc {get;set;} 
        public String BRI_RCCategory {get;set;} 
        public String BRI_Sysapp_Impact {get;set;} 
        public String BRI_BusinessImpact {get;set;} 
        public String BRI_ServiceImpact {get;set;} 
        public String BRI_HInvolved {get;set;} 
        public String BRI_CIDITEMUKAN_Valid {get;set;} 
        public String BRI_CIDITEMUKAN {get;set;} 
        public String BRI_LayananTerdampak_Valid {get;set;} 
        public String BRI_LayananTerdampak {get;set;} 
        public String BRI_OwnerDisplayName {get;set;} 
        public String BRI_SubjectTemplate {get;set;} 
        public String BRI_Kritikalitas_Aplikasi_Valid {get;set;} 
        public String BRI_Kritikalitas_Aplikasi {get;set;} 
        public String BRI_Kritikalitas_Aplikasi_Pengelola {get;set;} 
        public String BRI_Kritikalitas_Aplikasi_Value {get;set;} 
        public String BRI_Priority_Value {get;set;} 
        public String BRI_Notif_Count {get;set;} 
        public String BRI_Notif_Count_Master {get;set;} 
        public String BRI_Notif_PhoneNumber {get;set;} 
        public String BRI_Notif_PhoneNumberAll {get;set;} 
        public String BRI_APP_OWNER {get;set;} 
        public String BRI_APP_KRITIKALITAS {get;set;} 
        public String Shield_Start_Time {get;set;} 
        public String Shield_detect_intervals {get;set;} 
        public String Shield_resolved_intervals {get;set;} 
        public String Shield_str_detect_intervals {get;set;} 
        public String Shield_str_resolved_intervals {get;set;} 
        public String Shield_impact {get;set;} 
        public String Shield_urgency {get;set;} 
        public String Shield_is_kpi {get;set;} 
        public String Shield_third_party_name {get;set;} 
        public String Shield_responsible_engineer {get;set;} 
        public String Shield_prefix_department {get;set;} 
        public String Shield_is_problem {get;set;} 
        public String Shield_proposed_enhancement {get;set;} 
        public String bri_dwntm_hours {get;set;} 
        public String bri_dwntm_minutes {get;set;} 
        public String bri_dwntm_seconds {get;set;} 
        public String bri_totaldowntime {get;set;} 
        public String BRI_ISDOWNTIME {get;set;} 
        public String BRI_DetectedDuration {get;set;} 
        public String BRI_NotifWARaw {get;set;} 
        public String BRI_CustomerTeam_Valid {get;set;} 
        public String BRI_CustomerTeam {get;set;} 
        public String BRI_CustomerDivisi_Valid {get;set;} 
        public String BRI_CustomerDivisi {get;set;} 
        public String BRI_isWFRun {get;set;} 
        public String BRI_TempSymptom {get;set;} 
        public String BRI_isUpdateSymptom {get;set;} 
        public String BRI_NotifWALen {get;set;} 
        public String BRI_NotifWAChar {get;set;} 
        public String BRI_WANotif_Token {get;set;} 
        public String BRI_NotifWAGroup {get;set;} 
        public String BRI_FlagNewIncident {get;set;} 
        public String BRI_GlobalString_Valid {get;set;} 
        public String BRI_GlobalString {get;set;} 
        public String BRI_NotifWAGroupError {get;set;} 
        public String BRI_TampungOpenDateTime {get;set;} 
        public String BRI_TampungInProgressDateTime {get;set;} 
        public String BRI_TempText {get;set;} 
        public String BRI_IsDeploymentImpact {get;set;} 
        public String BRI_DetectedDurationInt {get;set;} 
        public String BRI_RecoverDurationInt {get;set;} 
        public Boolean BRI_isReopenFromIntegration {get;set;} 
        public String BRI_isIncProb {get;set;} 
        public String BRI_IncProb_Status_Valid {get;set;} 
        public String BRI_IncProb_Status {get;set;} 
        public String BRI_IncProb_Justification {get;set;} 
        public String BRI_SymptomForProblem {get;set;} 
        public String BRI_NotifCreate_Count {get;set;} 
        public String BRI_isNotifSend {get;set;} 
        public String BRI_NotifResolve_Count {get;set;} 
        public String BRI_isWFDetailRun {get;set;} 
        public String BRI_NotifDetail_Count {get;set;} 
        public String BRI_SourceKey {get;set;} 
        public String BRI_KodeUKO_Valid {get;set;} 
        public String BRI_KodeUKO {get;set;} 
        public String BRI_UKO {get;set;} 
        public String BRI_RegionalOffice {get;set;} 
        public String BRI_KantorCabangInduk {get;set;} 
        public String BRI_JenisFitur_Valid {get;set;} 
        public String BRI_JenisFitur {get;set;} 
        public String BRI_JenisFiturActual {get;set;} 
        public String BRI_NeedProblem_Valid {get;set;} 
        public String BRI_NeedProblem {get;set;} 
        public String BRI_SApp_Detail {get;set;} 
        public String BRI_Profider_Valid {get;set;} 
        public String BRI_Profider {get;set;} 
        public String BRI_JenisPerangkat_Valid {get;set;} 
        public String BRI_JenisPerangkat {get;set;} 
        public String BRI_JenisGangguan_Valid {get;set;} 
        public String BRI_JenisGangguan {get;set;} 
        public String BRI_InfraCatResolution_Valid {get;set;} 
        public String BRI_InfraCatResolution {get;set;} 
        public String BRI_AggregatorVendor {get;set;} 
        public String BRI_FlagAutoExTask {get;set;} 
        public String BRI_LinkToUKOMaster_Category {get;set;} 
        public String BRI_LinkToUKOMaster_RecID {get;set;} 
        public String BRI_LinkToUKOMaster {get;set;} 
        public String BRI_KodeUKO_INF {get;set;} 
        public String BRI_SApp_TicketNumber {get;set;} 
        public String BRI_SApp_Reopen_Justification {get;set;} 
        //unhold
        public String BRI_isUnHoldFromIntegration {get;set;}
        public String BRI_SApp_UnHold_Justification {get;set;}
        public String BRI_SApp_UnHold_Status_Valid {get;set;}
        public String BRI_SApp_UnHold_Status {get;set;}
        public String BRI_SApp_UnHold_RejectJustification {get;set;}
        public String BRI_SApp_OLA {get;set;}
        public String BRI_ResolvedDuration {get;set;}

    }

    public class RequestUnhold {
        public String BRI_isUnHoldFromIntegration {get; set;}
        public String BRI_SApp_UnHold_Justification {get;set;}
    }

    public class ResponseUnhold {
        public String dataContext { get; set; }
        public String actualCategory_Valid { get; set; }
        public String actualCategory { get; set; }
        public String category_Valid { get; set; }
        public String category { get; set; }
        public String causeCode_Valid { get; set; }
        public String causeCode { get; set; }
        public String closedBy { get; set; }
        public DateTime closedDateTime { get; set; }
        public Integer closedDuration { get; set; }
        public String createdBy { get; set; }
        public DateTime createdDateTime { get; set; }
        public String email { get; set; }
        public Boolean firstCallResolution { get; set; }
        public String impact_Valid { get; set; }
        public String impact { get; set; }
        public Integer incidentNumber { get; set; }
        public Boolean isNotification { get; set; }
        public Boolean isVIP { get; set; }
        public Boolean isWorkAround { get; set; }
        public String lastModBy { get; set; }
        public DateTime lastModDateTime { get; set; }
        public String phone { get; set; }
        public String priority_Valid { get; set; }
        public String priority { get; set; }
        public String profileFullName { get; set; }
        public String profileLink_Category { get; set; }
        public String profileLink_RecID { get; set; }
        public String profileLink { get; set; }
        public String recId { get; set; }
        public String resolution { get; set; }
        public String service_Valid { get; set; }
        public String service { get; set; }
        public String sla { get; set; }
        public String slaLink_Category { get; set; }
        public String slaLink_RecID { get; set; }
        public String slaLink { get; set; }
        public String source_Valid { get; set; }
        public String source { get; set; }
        public String status_Valid { get; set; }
        public String status { get; set; }
        public String subject { get; set; }
        public String symptom { get; set; }
        public String urgency_Valid { get; set; }
        public String urgency { get; set; }
        public String loginId { get; set; }
        public String owner_Valid { get; set; }
        public String owner { get; set; }
        public String ownerTeam_Valid { get; set; }
        public String ownerTeam { get; set; }
        public String ownerType { get; set; }
        public Boolean isNewRecord { get; set; }
        public String briFormatTiketIncident { get; set; }
        public String briCategorySystem { get; set; }
        public DateTime briDetectedTime { get; set; }
        public Boolean briISKPI { get; set; }
        public String briTipeIncident { get; set; }
        public String briLayananTerdampak { get; set; }
        public String briKritikalitasAplikasi { get; set; }
        public Integer briNotifCount { get; set; }
        public String briNotifPhoneNumber { get; set; }
        public Boolean briISDOWNTIME { get; set; }
        public String briDetectedDuration { get; set; }
        public Boolean briFlagNewIncident { get; set; }
        public Integer briDetectedDurationInt { get; set; }
        public Integer briRecoverDurationInt { get; set; }
        public Boolean briIsReopenFromIntegration { get; set; }
        public String briSAppTicketNumber { get; set; }
        public String briSAppReopenJustification { get; set; }
        public String briSAppReopenStatus { get; set; }
    }


}