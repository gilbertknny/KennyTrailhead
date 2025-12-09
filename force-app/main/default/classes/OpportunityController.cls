/**
 * @author [Marco Lie]
 * @date [2025-11-26]
 * @description Controller class for Opportunity operations including co-insurer management,
 * QQ transaction data, insurance period handling, and facultative opportunity creation
 */
public with sharing class OpportunityController {
    
    /**
     * @description Retrieves opportunity details by ID
     * @param opportunityId The ID of the opportunity to retrieve
     * @return Opportunity record with specified fields
     */
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunity(Id opportunityId) {
        // Check CRUD permission for Opportunity object
        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Opportunity object');
        }
        
        // Check FLS permission for specific fields
        String[] opportunityFields = new String[]{
            'Closing_Class__c', 'Policy_Closing_Type__c', 'Type_Of_Business__c', 'Handling_Fee__c',
            'Leader_Policy_Number__c', 'Profit_Sharing__c', 'The_Insured_Name__c', 'The_Insured_Status__c',
            'The_Insured_Address__c', 'Payment_Term__c', 'Billing_To__c', 'Payment_Method__c',
            'Incoming_Request_Approval__c', 'Policy_Settlement_Delivery__c', 'Delivery_To__c', 'StageName'
        };
        
        for (String fieldName : opportunityFields) {
            if (!Schema.sObjectType.Opportunity.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Opportunity field: ' + fieldName);
            }
        }
        
        return [
            SELECT
                Closing_Class__c,
                Policy_Closing_Type__c,
                Type_Of_Business__c,
                Handling_Fee__c,
                Leader_Policy_Number__c,
                Profit_Sharing__c,
                The_Insured_Name__r.Name,
                The_Insured_Status__c,
                The_Insured_Address__c,
                Payment_Term__c,
                Billing_To__r.Name,
                Payment_Method__c,
                Incoming_Request_Approval__c,
                Policy_Settlement_Delivery__c,
                Delivery_To__r.Name,
                StageName
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
    }

    /**
     * @description Searches for co-insurer accounts by name
     * @param searchKey Search term for account name
     * @return List of matching Account records
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> searchCoInsurerAccounts(String searchKey) {
        // Check CRUD permission for Account object
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Account object');
        }
        
        // Check FLS permission for specific fields
        String[] accountFields = new String[]{'Id', 'Name', 'Industry', 'Phone', 'Type'};
        for (String fieldName : accountFields) {
            if (!Schema.sObjectType.Account.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Account field: ' + fieldName);
            }
        }
        
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
        return [
            SELECT Id, Name, Industry, Phone
            FROM Account
            WHERE Type = 'Insurance'
                AND Name LIKE :key
            ORDER BY Name
            LIMIT 10
        ];
    }
    
    /**
     * @description Retrieves co-insurer transaction data for an opportunity
     * @param opportunityId The ID of the opportunity
     * @return List of Transaction_Data__c records for co-insurers
     */
    @AuraEnabled(cacheable=true)
    public static List<Transaction_Data__c> getCoInsurerData(Id opportunityId) {
        // Check CRUD permissions
        if (!Schema.sObjectType.Transaction_Data__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Transaction Data object');
        }
        
        // Check FLS permissions for Transaction_Data__c fields
        String[] transactionFields = new String[]{
            'Co_Insurance_Company__c', 'Leader_Member__c', 'Member_Share__c', 
            'Currency__c', 'Amount__c', 'RecordTypeId', 'Opportunity__c'
        };
        for (String fieldName : transactionFields) {
            if (!Schema.sObjectType.Transaction_Data__c.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Transaction Data field: ' + fieldName);
            }
        }
        
        // Check Account field permissions for related objects
        if (!Schema.sObjectType.Account.fields.Name.isAccessible() ||
            !Schema.sObjectType.Account.fields.Type.isAccessible() ||
            !Schema.sObjectType.Account.fields.Account_Segment__c.isAccessible()) {
            throw new AuraHandledException('Insufficient field-level access to Account fields');
        }
        
        Id rtId = Schema.SObjectType.Transaction_Data__c
                    .getRecordTypeInfosByDeveloperName()
                    .get('CoInsurer')
                    .getRecordTypeId();
    
        return [
            SELECT
                Co_Insurance_Company__c,
                Co_Insurance_Company__r.Name,
                toLabel(Co_Insurance_Company__r.Type),
                toLabel(Co_Insurance_Company__r.Account_Segment__c),
                Leader_Member__c,
                Member_Share__c,
                Currency__c,
                Amount__c 
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
                AND RecordTypeId = :rtId
        ];
    }
    
    /**
     * @description Saves co-insurer data for an opportunity
     * @param opportunityId The opportunity ID
     * @param accountIds List of account IDs to associate as co-insurers
     */
    @AuraEnabled
    public static void saveCoInsurerData(Id opportunityId, List<Id> accountIds) {
        // Check CRUD permissions for Transaction_Data__c
        if (!Schema.sObjectType.Transaction_Data__c.isCreateable() || 
            !Schema.sObjectType.Transaction_Data__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Transaction Data object');
        }
        
        // Check FLS permissions for fields being created
        String[] transactionFields = new String[]{
            'Opportunity__c', 'Co_Insurance_Company__c', 'RecordTypeId'
        };
        for (String fieldName : transactionFields) {
            if (!Schema.sObjectType.Transaction_Data__c.fields.getMap().get(fieldName).getDescribe().isCreateable()) {
                throw new AuraHandledException('Insufficient field-level access to create Transaction Data field: ' + fieldName);
            }
        }
        
        Id rtId = Schema.SObjectType.Transaction_Data__c
                    .getRecordTypeInfosByDeveloperName()
                    .get('CoInsurer')
                    .getRecordTypeId();

        // Fetch existing Co_Insurance_Company__c values for this Opportunity
        Set<Id> existingAccIds = new Set<Id>();
        for (Transaction_Data__c td : [
            SELECT Id, Co_Insurance_Company__c
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
                AND RecordTypeId = :rtId
        ]) {
            existingAccIds.add(td.Co_Insurance_Company__c);
        }

        // Prepare new records
        List<Transaction_Data__c> toInsert = new List<Transaction_Data__c>();
        for (Id accId : accountIds) {
            if (!existingAccIds.contains(accId)) {
                toInsert.add(new Transaction_Data__c(
                    Opportunity__c = opportunityId,
                    Co_Insurance_Company__c = accId,
                    RecordTypeId = rtId
                ));
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    /**
     * @description Retrieves QQ transaction data for an opportunity
     * @param opportunityId The ID of the opportunity
     * @return List of Transaction_Data__c records for QQ members
     */
    @AuraEnabled(cacheable=true)
    public static List<Transaction_Data__c> getQQTransactionData(Id opportunityId) {
        // Check CRUD permissions
        if (!Schema.sObjectType.Transaction_Data__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Transaction Data object');
        }
        
        // Check FLS permissions
        String[] transactionFields = new String[]{
            'Id', 'Name', 'QQ_Address__c', 'Contract_Number__c', 'Loan_Acc_Number__c',
            'RecordTypeId', 'Opportunity__c'
        };
        for (String fieldName : transactionFields) {
            if (!Schema.sObjectType.Transaction_Data__c.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Transaction Data field: ' + fieldName);
            }
        }
        
        Id rtId = Schema.SObjectType.Transaction_Data__c
                    .getRecordTypeInfosByDeveloperName()
                    .get('Member_of_QQ')
                    .getRecordTypeId();

        return [
            SELECT 
                Id, Name, QQ_Address__c, Contract_Number__c, Loan_Acc_Number__c
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
                AND RecordTypeId = :rtId
        ];
    }
    
    /**
     * @description Searches for QQ accounts by name
     * @param searchKey Search term for account name
     * @return List of matching Account records
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> searchQQAccounts(String searchKey) {
        // Check CRUD permission for Account object
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Account object');
        }
        
        // Check FLS permission for specific fields
        String[] accountFields = new String[]{'Id', 'Name', 'Address__c'};
        for (String fieldName : accountFields) {
            if (!Schema.sObjectType.Account.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Account field: ' + fieldName);
            }
        }
        
        return [
            SELECT Id, Name, Address__c
            FROM Account
            WHERE Name LIKE :(searchKey + '%')
            ORDER BY Id ASC
            LIMIT 10
        ];
    }
    
    /**
     * @description Saves the insured transaction data for an opportunity
     * @param opportunityId The opportunity ID
     * @param accountData List of account data maps containing account information
     */
    @AuraEnabled
    public static void saveTheInsuredTransactionData(Id opportunityId, List<Map<String, Object>> accountData) {
        // Check CRUD permissions for Transaction_Data__c
        if (!Schema.sObjectType.Transaction_Data__c.isCreateable() || 
            !Schema.sObjectType.Transaction_Data__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Transaction Data object');
        }
        
        // Check FLS permissions for fields being created
        String[] transactionFields = new String[]{
            'Opportunity__c', 'QQ_Name__c', 'RecordTypeId', 'Name', 'QQ_Address__c'
        };
        for (String fieldName : transactionFields) {
            if (!Schema.sObjectType.Transaction_Data__c.fields.getMap().get(fieldName).getDescribe().isCreateable()) {
                throw new AuraHandledException('Insufficient field-level access to create Transaction Data field: ' + fieldName);
            }
        }
        
        Id rtId = Schema.SObjectType.Transaction_Data__c
                    .getRecordTypeInfosByDeveloperName()
                    .get('Member_of_QQ')
                    .getRecordTypeId();
    
        // Fetch existing QQ_Name__c values for this Opportunity
        Set<Id> existingAccIds = new Set<Id>();
        for (Transaction_Data__c td : [
            SELECT QQ_Name__c
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
                AND RecordTypeId = :rtId
        ]) {
            existingAccIds.add(td.QQ_Name__c);
        }
    
        // Prepare new records with Account data
        List<Transaction_Data__c> toInsert = new List<Transaction_Data__c>();
        for (Map<String, Object> accData : accountData) {
            Id accId = (Id)accData.get('accountId');
            String accName = (String)accData.get('accountName');
            String accAddress = (String)accData.get('accountAddress');
            
            if (!existingAccIds.contains(accId)) {
                toInsert.add(new Transaction_Data__c(
                    Opportunity__c = opportunityId,
                    QQ_Name__c = accId,
                    RecordTypeId = rtId,
                    Name = accName,
                    QQ_Address__c = accAddress
                ));
            }
        }
    
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    /**
     * @description Deletes co-insurer data for an opportunity and account
     * @param opportunityId The opportunity ID
     * @param accountId The account ID to remove
     */
    @AuraEnabled
    public static void deleteCoInsurerData(Id opportunityId, Id accountId) {
        // Check CRUD permissions for Transaction_Data__c
        if (!Schema.sObjectType.Transaction_Data__c.isDeletable() || 
            !Schema.sObjectType.Transaction_Data__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to delete Transaction Data');
        }
        
        List<Transaction_Data__c> toDelete = [
            SELECT Id
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
                AND Co_Insurance_Company__c = :accountId
        ];
        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
    }
    
    /**
     * @description Deletes transaction data by record ID
     * @param recordId The record ID to delete
     */
    @AuraEnabled
    public static void deleteTransactionData(Id recordId) {
        // Check CRUD permissions for Transaction_Data__c
        if (!Schema.sObjectType.Transaction_Data__c.isDeletable()) {
            throw new AuraHandledException('Insufficient access to delete Transaction Data');
        }
        
        if (recordId == null) {
            throw new AuraHandledException('No recordId provided for deletion.');
        }
        try {
            delete new Transaction_Data__c(Id = recordId);
        } catch (DmlException e) {
            throw new AuraHandledException('Error deleting Transaction Data: ' + e.getMessage());
        }
    }
    
    //------------------------------//
    //   for insurancePeriode LWC   //
    //------------------------------//
    
    /**
     * @description Retrieves opportunity insurance period details
     * @param recordId The opportunity ID
     * @return Opportunity record with insurance period fields
     */
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityInsurancePeriod(Id recordId) {
        // Check CRUD permission for Opportunity object
        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Opportunity object');
        }
        
        // Check FLS permission for insurance period fields
        String[] insuranceFields = new String[]{
            'Insurance_Period_Type__c', 'Start_Date_Periode__c', 'End_Date_Periode__c',
            'Period_Rate__c', 'Percentage__c', 'Short_Period_Basis__c', 'Number_of_Years__c',
            'StageName', 'COB__c', 'premium_calculation__c'
        };
        for (String fieldName : insuranceFields) {
            if (!Schema.sObjectType.Opportunity.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Opportunity field: ' + fieldName);
            }
        }
        
        return [
            SELECT
                Id,
                Insurance_Period_Type__c,
                Start_Date_Periode__c,
                End_Date_Periode__c,
                Period_Rate__c,
                Percentage__c,
                Short_Period_Basis__c,
                Number_of_Years__c,
                StageName,
                COB__c,
                premium_calculation__c
            FROM Opportunity
            WHERE Id = :recordId
            LIMIT 1
        ];
    }

    /**
     * @description Retrieves transaction data for insurance period
     * @param opportunityId The opportunity ID
     * @return List of Transaction_Data__c records for insurance period
     */
    @AuraEnabled(cacheable=true)
    public static List<Transaction_Data__c> getTransactionDataInsurancePeriod(Id opportunityId) {
        // Check CRUD permissions
        if (!Schema.sObjectType.Transaction_Data__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Transaction Data object');
        }
        
        // Check FLS permissions
        String[] transactionFields = new String[]{
            'Insurance_Period_Type__c', 'Schema_Type__c', 'Year__c', 
            'Short_Period_Type__c', 'Value__c', 'RecordTypeId', 'Opportunity__c'
        };
        for (String fieldName : transactionFields) {
            if (!Schema.sObjectType.Transaction_Data__c.fields.getMap().get(fieldName).getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient field-level access to Transaction Data field: ' + fieldName);
            }
        }
        
        return [
            SELECT
                Id,
                Insurance_Period_Type__c,
                Schema_Type__c,
                Year__c,
                Short_Period_Type__c,
                Value__c,
                RecordTypeId
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
            AND RecordType.DeveloperName = 'Insurance_Period'
            ORDER BY Year__c ASC
        ];
    }
    
    /**
     * @description Wrapper class for insurance period data
     */
    public class InsurancePeriodWrapper {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public String periodType { get; set; }
        @AuraEnabled public Date startDate { get; set; }
        @AuraEnabled public Date endDate { get; set; }
        @AuraEnabled public String shortBasis { get; set; }
        @AuraEnabled public String premiumCalculation { get; set; }
        @AuraEnabled public Decimal percentage { get; set; }
        @AuraEnabled public String schemaType { get; set; }
        @AuraEnabled public Decimal periodRate { get; set; }
        @AuraEnabled public Integer numberOfYear { get; set; }
        @AuraEnabled public Integer totalYears { get; set; }
        @AuraEnabled public Integer totalMonth { get; set; }
        @AuraEnabled public List<TransactionRow> transactionRows { get; set; }
    }

    /**
     * @description Wrapper class for transaction row data
     */
    public class TransactionRow {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public Integer year { get; set; }
        @AuraEnabled public Decimal percentage { get; set; }
        @AuraEnabled public String type { get; set; }
    }

    /**
     * @description Saves insurance period details
     * @param wrapper InsurancePeriodWrapper containing all insurance period data
     */
    @AuraEnabled
    @SuppressWarnings('PMD.NcssMethodCount, PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity')
    public static void saveInsuranceDetails(InsurancePeriodWrapper wrapper) {
        // Check CRUD permission for Opportunity object - update access
        if (!Schema.sObjectType.Opportunity.isUpdateable()) {
            throw new AuraHandledException('Insufficient access to update Opportunity records');
        }
        
        // Check FLS permission for insurance period fields
        String[] insuranceFields = new String[]{
            'Insurance_Period_Type__c', 'Start_Date_Periode__c', 'End_Date_Periode__c',
            'Short_Period_Basis__c', 'premium_calculation__c', 'Percentage__c', 'Period_Rate__c', 'Number_of_Years__c'
        };
        for (String fieldName : insuranceFields) {
            if (!Schema.sObjectType.Opportunity.fields.getMap().get(fieldName).getDescribe().isUpdateable()) {
                throw new AuraHandledException('Insufficient field-level access to update Opportunity field: ' + fieldName);
            }
        }
        
        Decimal periodRateFinal = wrapper.periodRate;
        Integer numberOfYear = wrapper.numberOfYear;
        if (wrapper.periodType == '3') { // 3 = long term
            if (wrapper.totalMonth > 0 && wrapper.periodRate > 0) { // long term & have extra month (pro rata rate)
                periodRateFinal = periodRateFinal + wrapper.totalYears;
            } else { // long term with annual years / no extra month
                periodRateFinal = wrapper.totalYears;
                numberOfYear = wrapper.totalYears;
            }
        }
        
        // Step 1: Update the parent Opportunity record
        Opportunity oppToUpdate = new Opportunity(
            Id = wrapper.opportunityId,
            Insurance_Period_Type__c = wrapper.periodType,
            Start_Date_Periode__c = wrapper.startDate,
            End_Date_Periode__c = wrapper.endDate,
            Short_Period_Basis__c = wrapper.shortBasis,
            Percentage__c = wrapper.percentage,
            Period_Rate__c = periodRateFinal,
            Number_of_Years__c = numberOfYear,
            premium_calculation__c = wrapper.premiumCalculation
        );
        update oppToUpdate;
    }
    
    /*-----------------------------------------
     * ---------- FACULTATIVE ----------------- */
    
    /**
     * @description Request wrapper for facultative opportunity creation
     */
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity, PMD.NcssMethodCount')
    public class OpportunityRequest {
        @AuraEnabled public String rate { get; set; }
        @AuraEnabled public String commission { get; set; }
        @AuraEnabled public String shareOffered { get; set; }
        @AuraEnabled public String shareAcceptedApproved { get; set; }
        @AuraEnabled public String shareBinding { get; set; }
        @AuraEnabled public String termCondition { get; set; }
        @AuraEnabled public String clausesWarranty { get; set; }
        @AuraEnabled public String coverageWarranty { get; set; }
        @AuraEnabled public String inputMode { get; set; }
        @AuraEnabled public String offeringStatus { get; set; }
        @AuraEnabled public String folderId { get; set; }
        @AuraEnabled public Decimal totalAmountInsured { get; set; }
        @AuraEnabled public List<Id> riskId { get; set; }
        @AuraEnabled public List<Id> accountIds { get; set; }

        /**
         * @description Helper method to create from JSON input
         * @param jsonInput JSON string input
         * @return OpportunityRequest instance
         */
        @SuppressWarnings('PMD.IfStmtsMustUseBraces, PMD.IfElseStmtsMustUseBraces')
        public OpportunityRequest fromJson(String jsonInput) {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('JSON input is empty or null.');
            }

            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);

            OpportunityRequest req = new OpportunityRequest();

            req.rate = (String) data.get('Rate__c');
            req.commission = (String) data.get('Commission__c');
            req.shareOffered = (String) data.get('Share_Offered__c');
            req.shareAcceptedApproved = (String) data.get('Share_Accepted_Approved__c');
            req.shareBinding = (String) data.get('Share_Binding__c');
            req.termCondition = (String) data.get('termCondition');
            req.clausesWarranty = (String) data.get('clausesWarranty');
            req.coverageWarranty = (String) data.get('coverageWarranty');
            req.inputMode = (String) data.get('inputMode');
            req.offeringStatus = (String) data.get('offeringStatus');
            req.folderId = (String) data.get('folderId');
            
            Object totalAmtObj = data.get('totalAmountInsured');
            if (totalAmtObj != null && String.isNotBlank(String.valueOf(totalAmtObj))) {
                 req.totalAmountInsured = Decimal.valueOf(String.valueOf(totalAmtObj));
            } else {
                 req.totalAmountInsured = null;
            }

            // Handle List<Object> → List<Id> conversion for riskId
            List<Object> riskList = (List<Object>) data.get('riskId');
            if (riskList != null && !riskList.isEmpty()) {
                req.riskId = new List<Id>();
                for (Object o : riskList) {
                    if (o != null) {
                        req.riskId.add((Id) String.valueOf(o));
                    }
                }
            }

            // Handle List<Object> → List<Id> conversion for accountIds
            List<Object> accountList = (List<Object>) data.get('accountIds');
            if (accountList != null && !accountList.isEmpty()) {
                req.accountIds = new List<Id>();
                for (Object o : accountList) {
                    if (o != null) {
                        req.accountIds.add((Id) String.valueOf(o));
                    }
                }
            }

            return req;
        }
    }

    /**
     * @description Result wrapper returned to LWC
     */
    public class ProcessingResult {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public List<OpportunityDetail> opportunityDetails { get; set; }
        @AuraEnabled public List<FacultativeShareDetail> facultativeShareDetails { get; set; }

        /**
         * @description Constructor for ProcessingResult
         */
        public ProcessingResult() {
            this.isSuccess = false;
            this.message = '';
            this.opportunityDetails = new List<OpportunityDetail>();
            this.facultativeShareDetails = new List<FacultativeShareDetail>();
        }
    }

    /**
     * @description Detail for each created Opportunity
     */
    public class OpportunityDetail {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
    }
    
    /**
     * @description Detail for each created Facultative Share
     */
    public class FacultativeShareDetail {
        @AuraEnabled public Id facultativeShareId { get; set; }
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Id originRiskId { get; set; }
        @AuraEnabled public String facultativeShareName { get; set; }
    }
    
    /**
     * @description Creates opportunities and facultative shares from JSON input
     * @param jsonInput JSON string containing opportunity creation parameters
     * @return ProcessingResult with creation details
     */
    @AuraEnabled (cacheable=false)
    @SuppressWarnings('PMD.NcssMethodCount, PMD.CyclomaticComplexity, PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity, PMD.AvoidDebugStatements, PMD.DebugsShouldUseLoggingLevel')
    public static ProcessingResult createOpportunitiesAndCloneAssets(String jsonInput) {
        ProcessingResult result = new ProcessingResult();
        
        try {
            // Validate input
            if (String.isBlank(jsonInput)) {
                result.isSuccess = false;
                result.message = 'JSON input is required';
                return result;
            }
    
            // Step 0: Deserialize JSON input
            OpportunityController.OpportunityRequest helper = new OpportunityController.OpportunityRequest();
            OpportunityController.OpportunityRequest req = helper.fromJson(jsonInput);
            
            // Enhanced validation
            if (req == null) {
                result.isSuccess = false;
                result.message = 'Invalid JSON structure';
                return result;
            }
            
            if (req.riskId == null || req.riskId.isEmpty()) {
                result.isSuccess = false;
                result.message = 'At least one riskId is required';
                return result;
            }

            if (req.accountIds == null || req.accountIds.isEmpty()) {
                result.isSuccess = false;
                result.message = 'At least one accountId is required';
                return result;
            }
    
            if (req.riskId.size() > 100) {
                result.isSuccess = false;
                result.message = 'Maximum 100 riskIds allowed per transaction';
                return result;
            }

            // Validate Accounts exist
            List<Account> accounts = [
                SELECT Id, Name 
                FROM Account 
                WHERE Id IN :req.accountIds
            ];
            
            if (accounts.isEmpty()) {
                result.isSuccess = false;
                result.message = 'No valid accounts found with the provided IDs';
                return result;
            }

            Map<Id, Account> accountMap = new Map<Id, Account>();
            for (Account acc : accounts) {
                accountMap.put(acc.Id, acc);
            }
    
            // Step 1: Query original Assets (Risks)
            List<Asset> originalAssets = [
                SELECT Id, Address, Address__c, Address_of_Obligee__c, Age__c, Authorized_Person_Name__c,
                Beneficiary__c, Brand__c, Builder_Yard_Name__c, Chasis_No__c, City__c, City_From__c,
                City_To__c, Class__c, Classification_1__c, Classification_2__c, Collateral__c, Collateral_Value__c,
                Color__c, Contact_Person__c, Contractor_Name__c, Coordinate__c, Date_of_Birth__c, Description,
                Destination__c, Detail_Description__c, Document_Type__c, Engine_No__c, Entry_Party_Name__c,
                Entry_Party_Type__c, Eq_Zone__c, Event_Location__c, Exposure__c, Fax__c, Flag__c,
                Flood_Zone__c, From_Address__c, From_Place_of_Dispatch__c, Gender__c, Group_Package__c, Hole__c,
                Incoming_Request_Fire_No__c, Indemnity_Agreement__c, Indemnity_Agreement_No__c, Industry__c, Industry_Conveyance_Type__c, Jurisdiction__c,
                Kegiatan_Kepabean__c, License_Plate_Number__c, Load_Capacity_Tonnage__c, Model__c, Model_Sepeda__c, N_K_R__c,
                Nama_Pemilik__c, Name, Name_of_Obligee__c, Nationality__c, NIK_Passport_No__c,
                NIPER__c, No_Serial_Rangka_Sepeda__c, NPWP__c, Number_of_Player__c, Number_of_Seats__c, Occupation_Code__c,
                Other_Document__c, Pabean__c, Par__c, Phone__c, PIB_PIBT_SPKPBM_Date__c, PIB_PIBT_SPKPBM_No__c,
                Place_of_Birth__c, Place_of_Built__c, Place_Port_of_Destination__c, Place_Port_of_Loading__c, Place_Port_of_Transhipment__c, Place_Port_of_Transit__c,
                Player_Classification__c, Policy_Fire_No__c, Premises__c, Project_Detail__c, Project_Type__c, Province__c,
                Province_From__c, Province_To__c, Purchasing_Document__c, Register_No__c, Relation__c, Risk_Code__c,
                Risk_Description__c, Risk_ID__c, Route_From_Voyage_Cover_Only__c, Route_To_Voyage_Cover_Only__c, Shipping_Document__c, SKEP_Date__c,
                SKEP_No__c, Tahun_Pembelian_Sepeda__c, Tanggal_Lahir__c, Tempat_Lahir__c, Territorial_Limit__c, Territorial_Limit_PA__c,
                Territory__c, Title__c, To_Address__c, To_Final_Place_of_Destination__c, Transmission__c,
                Trip_Package__c, Tsunami_Zone__c, Type__c, Type_Description__c, Vehicle_Market_Value__c,
                Vehicle_Market_Value_IDR__c, Vessel_Code__c, Vessel_Name__c, Vessel_Principal__c, Vessel_Type_Construction__c, Volcanic_Zone__c,
                Voyage_Number__c, Year_of_Built__c, Year_of_Manufacture__c, Zip_Code__c, Zip_Code_From__c, Zip_Code_To__c
                FROM Asset
                WHERE Id IN :req.riskId
                AND RecordType.DeveloperName = 'Risk'
            ];
            
            if (originalAssets.isEmpty()) {
                result.isSuccess = false;
                result.message = 'No Risk records found for the provided riskId(s)';
                return result;
            }

            // Step 2: Create Opportunities for each Account
            List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
            Map<Id, List<Opportunity>> accountToOpportunitiesMap = new Map<Id, List<Opportunity>>();

            for (Id accountId : req.accountIds) {
                Account acc = accountMap.get(accountId);
                if (acc != null) {
                    Opportunity opp = createOpportunity(acc, req, originalAssets[0]);
                    opportunitiesToInsert.add(opp);
                    
                    if (!accountToOpportunitiesMap.containsKey(accountId)) {
                        accountToOpportunitiesMap.put(accountId, new List<Opportunity>());
                    }
                    accountToOpportunitiesMap.get(accountId).add(opp);
                }
            }

            if (opportunitiesToInsert.isEmpty()) {
                result.isSuccess = false;
                result.message = 'No opportunities could be created';
                return result;
            }

            // Step 3: Insert Opportunities
            insert opportunitiesToInsert;

            // Step 4: Create Facultative Share records for each Opportunity and each Risk
            List<Facultative_Share__c> facultativeSharesToInsert = new List<Facultative_Share__c>();
            Map<Id, List<FacultativeShareDetail>> opportunityToFacultativeSharesMap = new Map<Id, List<FacultativeShareDetail>>();

            for (Opportunity opp : opportunitiesToInsert) {
                opportunityToFacultativeSharesMap.put(opp.Id, new List<FacultativeShareDetail>());
                
                // Create one Facultative Share record for each original riskId
                for (Id riskId : req.riskId) {
                    Facultative_Share__c facultativeShare = createFacultativeShare(riskId, opp.Id, req);
                    facultativeSharesToInsert.add(facultativeShare);
                }
            }

            // Step 5: Insert Facultative Share records
            if (!facultativeSharesToInsert.isEmpty()) {
                insert facultativeSharesToInsert;
                
                // Build the relationship map after insertion
                for (Facultative_Share__c fs : facultativeSharesToInsert) {
                    FacultativeShareDetail detail = new FacultativeShareDetail();
                    detail.facultativeShareId = fs.Id;
                    detail.opportunityId = fs.Facultative_Opportunity__c;
                    detail.originRiskId = fs.Origin_Risk__c;
                    detail.facultativeShareName = fs.Name;
                    
                    if (opportunityToFacultativeSharesMap.containsKey(fs.Facultative_Opportunity__c)) {
                        opportunityToFacultativeSharesMap.get(fs.Facultative_Opportunity__c).add(detail);
                    }
                    
                    // Add to result details
                    result.facultativeShareDetails.add(detail);
                }
            }

            // Step 6: Prepare result details
            for (Opportunity opp : opportunitiesToInsert) {
                OpportunityDetail detail = new OpportunityDetail();
                detail.opportunityId = opp.Id;
                detail.accountId = opp.AccountId;
                detail.opportunityName = opp.Name;
                result.opportunityDetails.add(detail);
            }

            result.isSuccess = true;
            result.message = 'Successfully created ' + opportunitiesToInsert.size() + 
                           ' opportunities with ' + originalAssets.size() + ' risks each' +
                           ' and ' + facultativeSharesToInsert.size() + ' facultative shares';

        } catch (Exception e) {
            result.isSuccess = false;
            result.message = 'Error: ' + e.getMessage();
        }
        
        return result;
    }

    /**
     * @description Creates an Opportunity for an Account
     * @param acc The account to associate with the opportunity
     * @param req The opportunity request data
     * @param sampleAsset Sample asset for naming convention
     * @return Opportunity record
     */
    private static Opportunity createOpportunity(Account acc, OpportunityRequest req, Asset sampleAsset) {
        // Get the Facultative RecordTypeId for Opportunity
        Id facultativeRecordTypeId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('Facultative')
            .getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        
        opp.Name = 'Facultative - ' + acc.Name;
        opp.AccountId = acc.Id;
        opp.StageName = 'Opportunity';
        opp.Offering_status__c = 'Offering';
        opp.Opportunity_Type__c = 'Facultative Outward';
        opp.CloseDate = System.today().addMonths(1);
        opp.Facultative_Folder__c = req.folderId;
        opp.Total_Sum_Insured__c = req.totalAmountInsured;
        
        opp.RecordTypeId = facultativeRecordTypeId;
        
        // Convert string values to decimal with null safety
        opp.Rate__c = String.isNotBlank(req.rate) ? Decimal.valueOf(req.rate) : null;
        opp.Commision__c = String.isNotBlank(req.commission) ? Decimal.valueOf(req.commission) : null;
        opp.Offering_status__c = req.offeringStatus;
        opp.Share_Binding__c = String.isNotBlank(req.shareBinding) ? Decimal.valueOf(req.shareBinding) : null;
        opp.Share_Accepted_Approved__c = String.isNotBlank(req.shareAcceptedApproved) ? Decimal.valueOf(req.shareAcceptedApproved) : null;
        opp.Share_Offered__c = String.isNotBlank(req.shareOffered) ? Decimal.valueOf(req.shareOffered) : null;
        
        String clauses = String.isNotBlank(req.clausesWarranty) ? req.clausesWarranty : '';
        opp.Profesional_Term_Facultative_Clauses_W__c = clauses;
        
        return opp;
    }

    /**
     * @description Creates Facultative Share record
     * @param riskId The risk ID
     * @param opportunityId The opportunity ID
     * @param req The opportunity request data
     * @return Facultative_Share__c record
     */
    private static Facultative_Share__c createFacultativeShare(Id riskId, Id opportunityId, OpportunityRequest req) {
        Facultative_Share__c fs = new Facultative_Share__c();
        
        // Set required fields
        fs.Facultative_Opportunity__c = opportunityId;
        fs.Origin_Risk__c = riskId;
        
        // Set share and percentage fields with null safety
        fs.Commission__c = String.isNotBlank(req.commission) ? Decimal.valueOf(req.commission) : null;
        fs.Rate__c = String.isNotBlank(req.rate) ? Decimal.valueOf(req.rate) : null;
        fs.Share_Offered__c = String.isNotBlank(req.shareOffered) ? Decimal.valueOf(req.shareOffered) : null;
        fs.Share_Accepted_Approved__c = String.isNotBlank(req.shareAcceptedApproved) ? Decimal.valueOf(req.shareAcceptedApproved) : null;
        fs.Share_Binding__c = String.isNotBlank(req.shareBinding) ? Decimal.valueOf(req.shareBinding) : null;
        
        String clauses = String.isNotBlank(req.clausesWarranty) ? req.clausesWarranty : '';
        fs.Subjectivity_Clauses__c = clauses;
        
        return fs;
    }
}