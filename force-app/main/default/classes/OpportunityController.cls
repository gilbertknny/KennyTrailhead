public with sharing class OpportunityController {
  @AuraEnabled(cacheable=true)
  public static Opportunity getOpportunity(Id opportunityId) {
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
        //Billing_To_Address__c,
        Payment_Method__c,
        Incoming_Request_Approval__c,
        Policy_Settlement_Delivery__c,
        Delivery_To__r.Name,
        //Delivery_To_Address__c,
        StageName
      FROM Opportunity
      WHERE Id = :opportunityId
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Account> searchCoInsurerAccounts(String searchKey) {
    String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
    return [
      SELECT Id, Name, Industry, Phone
      FROM Account
      //WHERE Type = 'Co-Insurer'
      WHERE Type = 'Insurance'
        AND Name LIKE :key
      ORDER BY Name
      LIMIT 10
    ];
  }
    
    @AuraEnabled(cacheable=true)
    public static List<Transaction_Data__c> getCoInsurerData(Id opportunityId) {
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
          AND RecordTypeId   = :rtId
      ];
    }
    
    //saveCoInsurerData
    @AuraEnabled
    public static void saveCoInsurerData(
        Id opportunityId,
        List<Id> accountIds
    ) {
        Id rtId = Schema.SObjectType.Transaction_Data__c
                    .getRecordTypeInfosByDeveloperName()
                    .get('CoInsurer')
                    .getRecordTypeId();

        // Fetch existing QQ_Name__c values for this Opportunity
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
                    RecordTypeId   = rtId
                ));
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Transaction_Data__c> getQQTransactionData(Id opportunityId) {
        // Lookup RecordTypeId for 'Member_of_QQ'
        Id rtId = Schema.SObjectType.Transaction_Data__c
                    .getRecordTypeInfosByDeveloperName()
                    .get('Member_of_QQ')
                    .getRecordTypeId();

        return [
            SELECT 
                Id, Name, QQ_Address__c, Contract_Number__c, Loan_Acc_Number__c
                //QQ_Name__c,
                //QQ_Name__r.Name,
                //QQ_Name__r.Address__c,
                //toLabel(QQ_Name__r.Type)
            FROM Transaction_Data__c
            WHERE Opportunity__c = :opportunityId
              AND RecordTypeId = :rtId
        ];
    }
	/*
    @AuraEnabled(cacheable=true)
    public static List<Account> searchQQAccounts(String searchKey) {
        return [
            SELECT Id, Name, Industry, Phone, Additional__c,Address__c,toLabel(Type) Type
            FROM Account
            WHERE Name LIKE :(searchKey + '%')
            ORDER BY Id ASC
            LIMIT 10
        ];
    }
	
    @AuraEnabled
    public static void saveTheInsuredTransactionData(
        Id opportunityId,
        List<Id> accountIds
    ) {
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

        // Prepare new records
        List<Transaction_Data__c> toInsert = new List<Transaction_Data__c>();
        for (Id accId : accountIds) {
            if (!existingAccIds.contains(accId)) {
                toInsert.add(new Transaction_Data__c(
                    Opportunity__c = opportunityId,
                    QQ_Name__c     = accId,
                    RecordTypeId   = rtId
                ));
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    } */ 
    
    @AuraEnabled(cacheable=true)
    public static List<Account> searchQQAccounts(String searchKey) {
        return [
            SELECT Id, Name, Address__c
            FROM Account
            WHERE Name LIKE :(searchKey + '%')
            ORDER BY Id ASC
            LIMIT 10
        ];
    }
    
    @AuraEnabled
    public static void saveTheInsuredTransactionData(
        Id opportunityId,
        List<Map<String, Object>> accountData  // Changed from List<Id> to List<Map>
    ) {
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
                    Name = accName,           // Set Transaction_Data__c.Name to Account Name
                    QQ_Address__c = accAddress // Set QQ_Address__c to Account Address
                ));
            }
        }
    
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    @AuraEnabled
    public static void deleteCoInsurerData(Id opportunityId, Id accountId) {
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
    
    @AuraEnabled
    public static void deleteTransactionData(Id recordId) {
        if (recordId == null) {
            throw new AuraHandledException('No recordId provided for deletion.');
        }
        try {
            // Perform the delete
            delete new Transaction_Data__c(Id = recordId);
        } catch (DmlException e) {
            // Wrap and rethrow so LWC can catch it
            throw new AuraHandledException('Error deleting Transaction Data: ' + e.getMessage());
        }
    }
    
    //------------------------------//
    //   for insurancePeriode LWC   //
    //------------------------------//
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityInsurancePeriod(Id recordId) {
        return [
            SELECT
                Id,
                Insurance_Period_Type__c,
                Start_Date_Periode__c,
                End_Date_Periode__c,
                //Period_Annual__c,
                Period_Rate__c,
                Percentage__c,
                Short_Period_Basis__c,
                Number_of_Years__c,
                StageName
            FROM Opportunity
            WHERE Id = :recordId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Transaction_Data__c> getTransactionDataInsurancePeriod(Id opportunityId) {
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
    
    public class InsurancePeriodWrapper {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public String periodType { get; set; }
        @AuraEnabled public Date startDate { get; set; }
        @AuraEnabled public Date endDate { get; set; }
        @AuraEnabled public String shortBasis { get; set; }
        @AuraEnabled public Decimal percentage { get; set; }
        @AuraEnabled public String schemaType { get; set; }
        @AuraEnabled public Decimal periodRate { get; set; }
        @AuraEnabled public Integer numberOfYear { get; set; }
        @AuraEnabled public Integer totalYears { get; set; }
        @AuraEnabled public Integer totalMonth { get; set; }
        @AuraEnabled public List<TransactionRow> transactionRows { get; set; }
    }

    public class TransactionRow {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public Integer year { get; set; }
        @AuraEnabled public Decimal percentage { get; set; }
        @AuraEnabled public String type { get; set; }
    }

    @AuraEnabled
    public static void saveInsuranceDetails(InsurancePeriodWrapper wrapper) {
        Decimal periodRateFinal = wrapper.periodRate;
        if(wrapper.periodType == '3'){ // 3 = long term
            if(wrapper.totalMonth > 0 && wrapper.periodRate > 0){
                periodRateFinal = periodRateFinal+ wrapper.totalYears;
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
            Number_of_Years__c = wrapper.numberOfYear
        );
        update oppToUpdate;
        
        /* ---- Commented because not used for while ----

        // Step 2: Prepare the list of Transaction_Data__c for upsert
        Id insurancePeriodRecordTypeId = Schema.SObjectType.Transaction_Data__c.getRecordTypeInfosByDeveloperName()
            .get('Insurance_Period').getRecordTypeId();
        
        List<Transaction_Data__c> transactionsToUpsert = new List<Transaction_Data__c>();
        system.debug('tR='+wrapper.transactionRows);
        if (wrapper.transactionRows != null) {
            // Switched to an indexed loop to identify the last row.
            for (Integer i = 0; i < wrapper.transactionRows.size(); i++) {
                // If schemaType is null, skip all iterations until we reach the very last one.
                if (wrapper.schemaType == null && i < wrapper.transactionRows.size() - 1) {
                    continue;
                }
                
                TransactionRow row = wrapper.transactionRows.get(i);
                String transactionPeriodType;

                // New logic to set the correct period type on each transaction
                if ('3'.equals(wrapper.periodType)) {
                    // If the parent is Long Term, the last row is 'Short', others are 'Annual'
                    if (i == wrapper.transactionRows.size() - 1) {
                        transactionPeriodType = '2';
                    } else {
                        transactionPeriodType = '1';
                    }
                } else {
                    // Otherwise, the transaction type is the same as the parent's
                    transactionPeriodType = wrapper.periodType;
                }

                transactionsToUpsert.add(new Transaction_Data__c(
                    Id = row.recordId,
                    Opportunity__c = wrapper.opportunityId,
                    RecordTypeId = insurancePeriodRecordTypeId,
                    Schema_Type__c = wrapper.schemaType,
                    Year__c = row.year,
                    Value__c = row.percentage, // period_rate -> annual 100
                    Short_Period_Type__c = row.type,
                    Insurance_Period_Type__c = transactionPeriodType // <-- ADDED: Set the period type
                ));
            }
        }
/*        else{
            Transaction_Data__c tr;
            List<Transaction_Data__c> ltr = [SELECT Id, Opportunity__c, Schema_Type__c, Year__c, Short_Period_Type__c, Insurance_Period_Type__c, Value__c
                                     FROM Transaction_Data__c WHERE
                                     Opportunity__c =: wrapper.opportunityId AND
                                     RecordTypeId =: insurancePeriodRecordTypeId];
                if(!ltr.isEmpty()){
                    tr = ltr[0];
                    tr.Schema_Type__c = '';
                    tr.Insurance_Period_Type__c = '';
                    tr.Short_Period_Type__c = '';
                    tr.Value__c = 0;
                    //tr.
                }
        } 

*/
/*        
        // Step 3: Perform the upsert operation
        if (!transactionsToUpsert.isEmpty()) {
            upsert transactionsToUpsert;
        } 
*/
    }
    
    /*-----------------------------------------
     * ---------- FACULTATIVE ----------------- */
    
    public class OpportunityRequest {
        public String rate;
        public String commission;
        public String shareOffered;
        public String shareAcceptedApproved;
        public String shareBinding;
        public String termCondition;
        public String clausesWarranty;
        public String coverageWarranty;
        public String inputMode;
        public String offeringStatus;
        public String folderId;
        //public String totalAmountInsured;
        public Decimal totalAmountInsured;
        public List<Id> riskId;
        public List<Id> accountIds;

        // ✅ Helper method to create from JSON input
        public OpportunityRequest fromJson(String jsonInput) {
            if (String.isBlank(jsonInput)) {
                throw new AuraHandledException('JSON input is empty or null.');
            }

            System.debug('📥 Raw JSON: ' + jsonInput);

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

            // ✅ Safely handle List<Object> → List<Id> conversion for riskId
            List<Object> riskList = (List<Object>) data.get('riskId');
            if (riskList != null && !riskList.isEmpty()) {
                req.riskId = new List<Id>();
                for (Object o : riskList) {
                    if (o != null) req.riskId.add((Id) String.valueOf(o));
                }
            }

            // ✅ Safely handle List<Object> → List<Id> conversion for accountIds
            List<Object> accountList = (List<Object>) data.get('accountIds');
            if (accountList != null && !accountList.isEmpty()) {
                req.accountIds = new List<Id>();
                for (Object o : accountList) {
                    if (o != null) req.accountIds.add((Id) String.valueOf(o));
                }
            }

            System.debug('✅ Deserialized OpportunityRequest: ' + JSON.serialize(req));
            return req;
        }
    }

    // 🔹 Result wrapper returned to LWC
   // 🔹 Wrapper returned to LWC
    public class ProcessingResult {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }

        public ProcessingResult() {
            this.isSuccess = false;
            this.message = '';
        }
    }

    // 🔹 Detail for each created Opportunity
    public class OpportunityDetail {
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public List<String> clonedRiskIds { get; set; }

        public OpportunityDetail() {
            this.clonedRiskIds = new List<String>();
        }
    }
    
    @AuraEnabled (cacheable=false)
    public static ProcessingResult createOpportunitiesAndCloneAssets(String jsonInput) {
        ProcessingResult result = new ProcessingResult();
        
        try {
            // Validate input
            if (String.isBlank(jsonInput)) {
                result.isSuccess = false;
                result.message = 'JSON input is required';
                return result;
            }

            System.debug('Received JSON input: ' + jsonInput);
    
            // Step 0: Deserialize JSON input
            OpportunityController.OpportunityRequest helper = new OpportunityController.OpportunityRequest();
            OpportunityController.OpportunityRequest req = helper.fromJson(jsonInput);
            
            System.debug('Deserialized OpportunityRequest: ' + JSON.serialize(req));
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
    
            // Step 1: Query original Assets (Risks) - Only the fields you specified
            List<Asset> originalAssets = [
                /*SELECT Id, Address__c, Address_Description__c, COB__c, Collateral__c,
                       Eq_Zone__c, is_builtup__c, is_certificate_endorse__c, is_endorsement__c,
                       is_life_insurance__c, IsCompetitorProduct, IsInternal, Name,
                       RecordTypeId, Risk_ID__c, Tsunami_Zone__c, Volcanic_Zone__c, AccountId*/
                SELECT Id, Address, Address__c, Address_of_Obligee__c, Age__c, Authorized_Person_Name__c,
                Beneficiary__c, Brand__c, Builder_Yard_Name__c, Chasis_No__c, City__c, City_From__c,
                City_To__c, Class__c, Classification_1__c, Classification_2__c, Collateral__c, Collateral_Value__c,
                Color__c, Contact_Person__c, Contractor_Name__c, Coordinate__c, Date_of_Birth__c, Description,
                Destination__c, Detail_Description__c, Document_Type__c, Engine_Capacity_CC__c, Engine_No__c, Entry_Party_Name__c,
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
                Trip_Package__c, Tsunami_Zone__c, Type__c, Type_Description__c, Vehicle_Brand__c, Vehicle_Market_Value__c,
                Vehicle_Market_Value_IDR__c, Vessel_Code__c, Vessel_Name__c, Vessel_Principal__c, Vessel_Type_Construction__c, Volcanic_Zone__c,
                Voyage_Number__c, Year_of_Built__c, Year_of_Manufacture__c, Zip_Code__c, Zip_Code_From__c, Zip_Code_To__c
                FROM Asset
                WHERE Id IN :req.riskId
                AND RecordType.DeveloperName = 'Risk' // Ensure we're getting Risk records
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
                    // Create one opportunity per account
                    // Using the first asset for naming convention as in your original code
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

            // Step 4: Clone Assets (Risks) for each Opportunity
            List<Asset> assetsToInsert = new List<Asset>();
            Map<Id, List<Id>> opportunityToClonedRiskMap = new Map<Id, List<Id>>();

            for (Opportunity opp : opportunitiesToInsert) {
                opportunityToClonedRiskMap.put(opp.Id, new List<Id>());
                
                // Clone each original asset for this opportunity
                for (Asset originalAsset : originalAssets) {
                    Asset clonedAsset = cloneAsset(originalAsset, req, opp);
                    assetsToInsert.add(clonedAsset);
                }
            }

            // Step 5: Insert cloned Assets
            if (!assetsToInsert.isEmpty()) {
                insert assetsToInsert;
                
                // Build the relationship map after insertion
                for (Asset clonedAsset : assetsToInsert) {
                    Id oppId = clonedAsset.Opportunity__c;
                    if (opportunityToClonedRiskMap.containsKey(oppId)) {
                        opportunityToClonedRiskMap.get(oppId).add((String)clonedAsset.Id);
                    }
                }
            }

            // Additional Create Quote for each Oppotunity (Fikri)
            // 2️⃣ Collect their IDs (and any other info needed)
            Map<Id, Opportunity> insertedOppMap = new Map<Id, Opportunity>(opportunitiesToInsert);
            /*
            // 3️⃣ Prepare a list to store Quotes
            List<Quote> quotesToInsert = new List<Quote>();

            // 4️⃣ Loop through inserted Opportunities
            for (Opportunity opp : insertedOppMap.values()) {
                Quote q = new Quote();
                q.Name = opp.Name;                // Quote name = Opportunity name
                q.OpportunityId = opp.Id;         // Link to the Opportunity
                //q.AccountId = opp.AccountId;      // Link to same Account
                q.The_Insured_Name__c = opp.AccountId; // Custom field (lookup to Account)

                quotesToInsert.add(q);
            }

            // 5️⃣ Bulk insert all Quotes at once
            if (!quotesToInsert.isEmpty()) {
                insert quotesToInsert;
            }
            */
            // Step 6: Prepare result details
            for (Opportunity opp : opportunitiesToInsert) {
                OpportunityDetail detail = new OpportunityDetail();
                detail.opportunityId = opp.Id;
                detail.accountId = opp.AccountId;
                detail.opportunityName = opp.Name;
                detail.clonedRiskIds = opportunityToClonedRiskMap.get(opp.Id);
                //result.opportunityDetails.add(detail);
            }

            result.isSuccess = true;
            result.message = 'Successfully created ' + opportunitiesToInsert.size() + 
                           ' opportunities with ' + originalAssets.size() + ' cloned risks each';

        } catch (Exception e) {
            System.debug('Unexpected Error: ' + e.getMessage() + ' StackTrace: ' + e.getStackTraceString());
            result.isSuccess = false;
            result.message = 'Error: ' + e.getMessage();
        }
        
        System.debug('Returning result to LWC: ' + JSON.serialize(result));
        return result;
    }

    /**
     * Create an Opportunity for an Account - Using your exact field mappings
     */
    private static Opportunity createOpportunity(Account acc, OpportunityRequest req, Asset sampleAsset) {
        
        // Get the Facultative RecordTypeId for Opportunity
        Id facultativeRecordTypeId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get('Facultative')
            .getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        
        System.debug('OpportunityRequest: '+JSON.serialize(req));
        // Using your exact naming convention and field mappings
        //opp.Name = 'Facultative '+ acc.Name + ' - ' + sampleAsset.Name;
        opp.Name = 'Facultative - ' + acc.Name;
        opp.AccountId = acc.Id; // Using the account from the loop, not from panelSetting
        opp.StageName = 'Opportunity';
        opp.Offering_status__c = 'Offering';
        opp.Opportunity_Type__c = 'Facultative Outward';
        opp.CloseDate = System.today().addMonths(1);
        opp.Facultative_Folder__c = req.folderId;
        opp.Total_Sum_Insured__c = req.totalAmountInsured; // total sum insured
        
        opp.RecordTypeId = facultativeRecordTypeId; // Add the RecordTypeId
        
        // Convert string values to decimal with null safety - using your exact field mappings
        opp.Rate__c = String.isNotBlank(req.rate) ? Decimal.valueOf(req.rate) : null;
        opp.Commision__c = String.isNotBlank(req.commission) ? Decimal.valueOf(req.commission) : null;
        opp.Offering_status__c = req.offeringStatus;
        opp.Share_Binding__c = String.isNotBlank(req.shareBinding) ? Decimal.valueOf(req.shareBinding) : null;
        opp.Share_Accepted_Approved__c = String.isNotBlank(req.shareAcceptedApproved) ? Decimal.valueOf(req.shareAcceptedApproved) : null;
        opp.Share_Offered__c = String.isNotBlank(req.shareOffered) ? Decimal.valueOf(req.shareOffered) : null;
        
        String clauses = String.isNotBlank(req.clausesWarranty) ? req.clausesWarranty : '';
        opp.Profesional_Term_Facultative_Clauses_W__c = clauses;
        
        // Handle concatenation with null checks - using your exact logic
        /*
        String clauses = String.isNotBlank(req.clausesWarranty) ? req.clausesWarranty : '';
        String coverage = String.isNotBlank(req.coverageWarranty) ? req.coverageWarranty : '';
        if (String.isNotBlank(clauses) && String.isNotBlank(coverage)) {
            opp.Profesional_Term_Facultative_Coverage__c = clauses + ' - ' + coverage;
        } else if (String.isNotBlank(clauses)) {
            opp.Profesional_Term_Facultative_Coverage__c = clauses;
        } else if (String.isNotBlank(coverage)) {
            opp.Profesional_Term_Facultative_Coverage__c = coverage;
        } */
        
        return opp;
    }

    /**
     * Clone an Asset (Risk) and link to Opportunity
     * Only cloning the basic Risk fields, not applying JSON parameters to Risk
     */
    private static Asset cloneAsset(Asset originalAsset, OpportunityRequest req, Opportunity opp) {
        Asset clonedAsset = originalAsset.clone(false, false, false, false);
        
        // Only clone the basic Risk fields as per your query
        // Link to opportunity and account
        //clonedAsset.Opportunity_Facultative__c = opp.Id;
        clonedAsset.AccountId = opp.AccountId;
        clonedAsset.Opportunity__c = opp.Id;
        
        // Put the Origin Risk ID
        clonedAsset.Origin_Risk__c = originalAsset.Id;
        
        // Set clone name - maintain your naming convention
        clonedAsset.Name = originalAsset.Name;
        
        return clonedAsset;
    }
}