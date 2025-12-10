/**
 * @description Controller class for Renewal Notice Visualforce page & Email Template
 * Handles the display of Insurance Policy and related Asset (Risk) information
 * @updated 2025-12-09 - Added support for Visualforce Component/Email Template
 */
public with sharing class renewalNoticeController {

    private static final String ERROR_NULL_RECORD_ID = 'Record ID is null';
    private static final String ERROR_LOADING_POLICY = 'Error loading policy data: ';
    
    // Properties
    @TestVisible private InsurancePolicy policy { get; private set; }
    @TestVisible private Integer numberOfRisks { get; private set; }
    @TestVisible private Asset singleRisk { get; private set; }
    @TestVisible private List<Asset> risksList { get; private set; }
    @TestVisible private Decimal totalSumInsured { get; private set; }

    // --- BAGIAN BARU: LOGIKA UNTUK EMAIL TEMPLATE / COMPONENT ---
    
    /**
     * Variable ini menerima ID dari Visualforce Component
     * Ketika ID di-set (assignTo), otomatis men-trigger load data
     */
    public Id componentPolicyId {
        get;
        set {
            componentPolicyId = value;
            if (value != null) {
                // Trigger logic load data saat ID diterima dari Component
                loadAllData(value);
            }
        }
    }

    /**
     * Constructor Kosong (Wajib ada untuk Visualforce Component)
     */
    public renewalNoticeController() {
        initializeEmptyData();
    }

    // --- AKHIR BAGIAN BARU ---

    /**
     * Constructor untuk Standard Visualforce Page (jika masih dipakai di Page biasa)
     */
    public renewalNoticeController(ApexPages.StandardController stdController) {
        Id recordId = stdController.getId();
        if (recordId == null) {
            handleNullRecordId();
            return;
        }
        loadAllData(recordId);
    }
    
    /**
     * Helper method to load all data based on ID
     */
    private void loadAllData(Id recordId) {
        try {
            loadPolicyData(recordId);
            loadRisksData(recordId);
            calculateTotalSumInsured();
            logDebugInformation(recordId);
        } catch (QueryException qe) {
            handleQueryException(qe);
        } catch (Exception e) {
            handleGeneralException(e);
        }
    }

    private void loadPolicyData(Id recordId) {
        this.policy = [
            SELECT Id, NameInsured__c, Aswata_Policy_Number__c, Address__c,
                   Phone__c, ExpirationDate, Notice_ID__c,
                   SourceOpportunityId, SourceOpportunity.Amount
            FROM InsurancePolicy
            WHERE Id = :recordId
            LIMIT 1
        ];
    }
    
    private void loadRisksData(Id recordId) {
        this.risksList = [
            SELECT Id, Name, Occupation_Description__c, Occupation_Code__c,
                   Occupation_Code__r.Name, Type_Description__c, Amount_IDR__c
            FROM Asset
            WHERE Insurance_Policy__c = :recordId
            ORDER BY CreatedDate ASC
        ];
        
        this.numberOfRisks = this.risksList != null ? this.risksList.size() : 0;
        
        if (this.numberOfRisks == 1) {
            this.singleRisk = this.risksList[0];
        }
    }
    
    private void calculateTotalSumInsured() {
        this.totalSumInsured = 0;
        if (this.risksList != null && !this.risksList.isEmpty()) {
            for (Asset risk : this.risksList) {
                if (risk.Amount_IDR__c != null) {
                    this.totalSumInsured += risk.Amount_IDR__c;
                }
            }
        }
    }
    
    private void logDebugInformation(Id recordId) {
        System.debug('Policy ID: ' + recordId);
        System.debug('Total Sum Insured: ' + this.totalSumInsured);
    }
    
    private void handleNullRecordId() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_NULL_RECORD_ID));
        initializeEmptyData();
    }
    
    private void handleQueryException(QueryException qe) {
        System.debug('Query Exception: ' + qe.getMessage());
        initializeEmptyData();
    }
    
    private void handleGeneralException(Exception e) {
        System.debug('Exception: ' + e.getMessage());
        initializeEmptyData();
    }
    
    private void initializeEmptyData() {
        this.policy = new InsurancePolicy();
        this.numberOfRisks = 0;
        this.risksList = new List<Asset>();
        this.totalSumInsured = 0;
        this.singleRisk = null;
    }
    
    // Getters for VF Page/Component
    public InsurancePolicy getPolicy() { return this.policy; }
    public Integer getNumberOfRisks() { return this.numberOfRisks; }
    public Asset getSingleRisk() { return this.singleRisk; }
    public List<Asset> getRisksList() { return this.risksList; }
    public Decimal getTotalSumInsured() { return this.totalSumInsured; }
}