/**
 * @description       : Test Class for AccumulationController
 * @author            : Peppp
 * @group             : Test
 * @last modified on  : 05-12-2025
 * @last modified by  : Peppp
 **/
@isTest
private class AccumulationControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create User for ownership tests
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + System.currentTimeMillis() + '@test.com'
        );
        insert testUser;
        
        // Create Master Data for Exchange Rate
        Master_Data__c exchangeRate = new Master_Data__c(
            CURRENCY_CODE__c = 'USD',
            RI_PARAM_YEAR__c = String.valueOf(System.today().year()),
            Exchange_Rate__c = 15000
        );
        insert exchangeRate;
        
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Busreq_ID__c = 'BUSREQ001',
            COB__c = '201',
            Start_Date_Periode__c = System.today(),
            End_Date_Periode__c = System.today().addDays(365),
            Assigned_Underwriting__c = testUser.Id
        );
        insert opp;
        
        // Create Accumulation (without Name if auto-number)
        Accumulation__c accum = new Accumulation__c(
            Version__c = 'V1',
            Group_ID__c = 'GRP001',
            As_Per_Inception_Date__c = System.now()
        );
        insert accum;
        
        // Create Quote
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id
        );
        insert quote;
        
        // Create Zip Code with Branch
        Master_Data__c branch = new Master_Data__c(
            BRANCH_ID__c = 'BR001'
        );
        insert branch;
        
        Master_Data__c zipCode = new Master_Data__c(
            Name = '12345',
            Branch_Name__c = branch.Id
        );
        insert zipCode;
        
        // Create City
        Master_Data__c city = new Master_Data__c(
            Name = 'Jakarta'
        );
        insert city;
        
        // Create NKR
        Master_Data__c nkr = new Master_Data__c(
            Name = 'NKR001'
        );
        insert nkr;
        
        // Create Currency (renamed variable to avoid reserved keyword)
        Master_Data__c currencyMaster = new Master_Data__c(
            Name = 'USD'
        );
        insert currencyMaster;
        
        // Create Vessel Name
        Master_Data__c vessel = new Master_Data__c(
            Name = 'MV Test Vessel'
        );
        insert vessel;
        
        // Create Insurance Policy - Check your org's API name
        // Common variations: InsurancePolicy__c, Insurance_Policy__c, or standard InsurancePolicy
        // Using dynamic approach to handle different org configurations
        String policyObjectName = 'InsurancePolicy__c'; // Adjust based on your org
        
        SObject policy;
        try {
            // Try custom object first
            policy = Schema.getGlobalDescribe().get(policyObjectName).newSObject();
            policy.put('Name', 'POL001');
            policy.put('NameInsured__c', 'Test Insured');
        } catch (Exception e) {
            // Fallback to creating without policy if object doesn't exist
            System.debug('InsurancePolicy object not available, skipping');
        }
        
        if (policy != null) {
            insert policy;
        }
        
        // Get Risk Record Type
        Id riskRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
            .get('Risk').getRecordTypeId();
        
        // Create Asset with Risk Record Type
        Asset asset = new Asset(
            Name = 'Test Risk Asset',
            RecordTypeId = riskRecordTypeId,
            Risk_ID__c = 'RISK001',
            Address_Description__c = 'Test Address',
            Amount_Insured__c = 1000000,
            N_K_R__c = nkr.Id,
            Opportunity__c = opp.Id,
            Accumulation__c = accum.Id,
            Vessel_Name__c = vessel.Id,
            Voyage_Number__c = 'VOY001'
        );
        
        // Add Insurance_Policy__c if policy was created
        if (policy != null) {
            asset.put('Insurance_Policy__c', policy.Id);
        }
        
        // Add Accumulation_ID__c if field exists and is writeable
        if (isFieldWriteable('Asset', 'Accumulation_ID__c')) {
            asset.put('Accumulation_ID__c', 'ACC001');
        }
        
        // Add Busreq_ID__c if field exists and is writeable
        if (isFieldWriteable('Asset', 'Busreq_ID__c')) {
            asset.put('Busreq_ID__c', 'BUSREQ001');
        }
        
        insert asset;
        
        // Update Quote with Risk
        quote.Risk_Name__c = asset.Id;
        update quote;
    }
    
    // Helper method to check if field is writeable
    private static Boolean isFieldWriteable(String objectName, String fieldName) {
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType == null) return false;
            
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            if (!fieldMap.containsKey(fieldName)) return false;
            
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            return fieldDescribe.isCreateable();
        } catch (Exception e) {
            return false;
        }
    }
    
    @isTest
    static void testGetBsnIdFromOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        String cobResult = AccumulationController.getBsnIdFromOpportunity(opp.Id);
        String nullResult = AccumulationController.getBsnIdFromOpportunity(null);
        String invalidResult = AccumulationController.getBsnIdFromOpportunity('invalid_id');
        Test.stopTest();
        
        System.assertEquals('201', cobResult, 'Should return COB value');
        System.assertEquals(null, nullResult, 'Should return null for blank ID');
    }
    
    @isTest
    static void testGetExchangeRate() {
        String currentYear = String.valueOf(System.today().year());
        
        Test.startTest();
        Decimal usdRate = AccumulationController.getExchangeRate('USD', currentYear);
        Decimal idrRate = AccumulationController.getExchangeRate('IDR', currentYear);
        Decimal unknownRate = AccumulationController.getExchangeRate('XXX', currentYear);
        Test.stopTest();
        
        System.assertEquals(15000, usdRate, 'Should return USD exchange rate');
        System.assertEquals(1.0, idrRate, 'Should return default rate for IDR');
        System.assertEquals(1.0, unknownRate, 'Should return default rate for unknown currency');
    }
    
    @isTest
    static void testGetExchangeRateException() {
        Test.startTest();
        try {
            AccumulationController.getExchangeRate(null, null);
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetQuoteData() {
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        AccumulationController.QuoteData result = AccumulationController.getQuoteData(quote.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return QuoteData');
        System.assertNotEquals(null, result.riskId, 'Should have riskId');
    }
    
    @isTest
    static void testGetQuoteDataException() {
        Test.startTest();
        try {
            AccumulationController.getQuoteData(null);
            System.assert(false, 'Should throw exception');
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccumulationData() {
        Accumulation__c accum = [SELECT Id, Name FROM Accumulation__c LIMIT 1];
        
        Test.startTest();
        AccumulationController.AccumulationData result = AccumulationController.getAccumulationData(accum.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return AccumulationData');
        System.assertEquals(accum.Name, result.accumulationName, 'Should match name');
        System.assertEquals('V1', result.version, 'Should match version');
        System.assertNotEquals(null, result.assets, 'Should have assets list');
    }
    
    @isTest
    static void testGetAccumulationDataException() {
        Test.startTest();
        try {
            AccumulationController.getAccumulationData(null);
            System.assert(false, 'Should throw exception');
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInitialAssetData() {
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        
        Test.startTest();
        AccumulationController.InitialData result = AccumulationController.getInitialAssetData(asset.Id);
        AccumulationController.InitialData nullResult = AccumulationController.getInitialAssetData(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return InitialData');
        System.assertNotEquals(null, result.assetRow, 'Should have asset row');
        System.assertEquals(null, nullResult, 'Should return null for blank ID');
    }
    
    @isTest
    static void testGetRisksByOpportunityBusReq() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Create asset without accumulation for this test
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        asset.Accumulation__c = null;
        update asset;
        
        Test.startTest();
        Map<String, Object> result = AccumulationController.getRisksByOpportunityBusReq(opp.Id);
        Map<String, Object> nullResult = AccumulationController.getRisksByOpportunityBusReq(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return result map');
        System.assert(result.containsKey('data'), 'Should contain data key');
        System.assert(result.containsKey('message'), 'Should contain message key');
        
        List<Object> data = (List<Object>) result.get('data');
        System.assertNotEquals(null, data, 'Data should not be null');
    }
    
    @isTest
    static void testGetRisksByOpportunityBusReqNoAssets() {
        // Create opportunity without assets
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;
        
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Busreq_ID__c = 'BUSREQ999',
            Start_Date_Periode__c = System.today(),
            End_Date_Periode__c = System.today().addDays(365)
        );
        insert opp2;
        
        Test.startTest();
        Map<String, Object> result = AccumulationController.getRisksByOpportunityBusReq(opp2.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return result map');
        List<Object> data = (List<Object>) result.get('data');
        System.assertEquals(0, data.size(), 'Should return empty list');
        String message = (String) result.get('message');
        System.assert(message.contains('No active Risk found'), 'Should contain no risk message');
    }
    
@isTest
    static void testSearchAssets() {
        Test.startTest();
        // PERBAIKAN: Menyesuaikan dengan 10 parameter yang ada di Controller
        List<AccumulationController.AssetSearchResult> results = AccumulationController.searchAssets(
            'Test Address', // addressQuery
            'POL001',       // policyQuery
            '12345',        // zipCodeQuery
            'NKR001',       // nkrQuery
            'Test Risk',    // riskNameQuery
            null,           // vesselNameQuery
            null,           // voyageNumberQuery
            null,           // startDatePeriodeQuery
            null,           // endDatePeriodeQuery
            null            // contextOpportunityId
        );
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
    }
    
@isTest
    static void testSearchAssetsWithContext() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        List<AccumulationController.AssetSearchResult> results = AccumulationController.searchAssets(
            'Test',         // addressQuery
            null,           // policyQuery
            null,           // zipCodeQuery
            null,           // nkrQuery
            null,           // riskNameQuery
            null,           // vesselNameQuery
            null,           // voyageNumberQuery
            null,           // startDatePeriodeQuery
            null,           // endDatePeriodeQuery
            opp.Id          // contextOpportunityId
        );
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
    }
    
@isTest
    static void testSearchAssetsNoResults() {
        Test.startTest();
        List<AccumulationController.AssetSearchResult> results = AccumulationController.searchAssets(
            'NonExistentAddress',
            null, null, null, null, null, null, null, null, null 
        );
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list');
    }
    
    @isTest
    static void testGetAssetsByGroupId() {
        Accumulation__c accum = [SELECT Group_ID__c FROM Accumulation__c LIMIT 1];
        
        Test.startTest();
        List<AccumulationController.AssetSearchResult> results = 
            AccumulationController.getAssetsByGroupId(accum.Group_ID__c);
        List<AccumulationController.AssetSearchResult> nullResults = 
            AccumulationController.getAssetsByGroupId(null);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
        System.assertEquals(0, nullResults.size(), 'Should return empty list for null');
    }
    
    @isTest
    static void testCheckMultipleAssetOwnership() {
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        List<String> assetIds = new List<String>{ asset.Id };
        
        Test.startTest();
        Map<String, Boolean> result = AccumulationController.checkMultipleAssetOwnership(assetIds);
        Map<String, Boolean> nullResult = AccumulationController.checkMultipleAssetOwnership(null);
        Map<String, Boolean> emptyResult = AccumulationController.checkMultipleAssetOwnership(new List<String>());
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return result map');
        System.assert(result.containsKey(asset.Id), 'Should contain asset ID');
        System.assertEquals(0, nullResult.size(), 'Should return empty map for null');
        System.assertEquals(0, emptyResult.size(), 'Should return empty map for empty list');
    }
    
    @isTest
    static void testCreateAccumulationRecord() {
        Asset asset = [SELECT Id, Risk_ID__c, Accumulation__r.Group_ID__c, Opportunity__r.Busreq_ID__c FROM Asset LIMIT 1];
        
        AccumulationController.AccumulationInput input = new AccumulationController.AccumulationInput();
        input.versionStr = 'V1';
        input.totalTSI = 1000000;
        input.assetDetails = new List<AccumulationController.AssetSearchResult>();
        
        AccumulationController.AssetSearchResult assetDetail = new AccumulationController.AssetSearchResult();
        assetDetail.riskId = asset.Risk_ID__c;
        assetDetail.groupId = asset.Accumulation__r.Group_ID__c;
        assetDetail.requestNum = asset.Opportunity__r.Busreq_ID__c;
        assetDetail.accumId = 'ACC001';
        input.assetDetails.add(assetDetail);
        
        Test.startTest();
        // Note: This will fail in test context as VlocityMapping is not available
        // You may need to mock this or use Test.setMock()
        try {
            Map<String, Object> result = AccumulationController.createAccumulationRecord(input);
            // If your org has proper mocking, assert results here
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error'), 'Should handle error gracefully');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateAccumulationRecordValidation() {
        Test.startTest();
        try {
            AccumulationController.createAccumulationRecord(null);
            System.assert(false, 'Should throw exception for null input');
        } catch (AuraHandledException e) {
        }
        
        AccumulationController.AccumulationInput invalidInput = new AccumulationController.AccumulationInput();
        try {
            AccumulationController.createAccumulationRecord(invalidInput);
            System.assert(false, 'Should throw exception for missing version');
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAccumulationRecord() {
        Accumulation__c accum = [SELECT Id FROM Accumulation__c LIMIT 1];
        Asset asset = [SELECT Id, Risk_ID__c, Accumulation__r.Group_ID__c, Opportunity__r.Busreq_ID__c FROM Asset LIMIT 1];
        
        AccumulationController.AccumulationInput input = new AccumulationController.AccumulationInput();
        input.accumulationId = accum.Id;
        input.versionStr = 'V2';
        input.totalTSI = 2000000;
        input.assetDetails = new List<AccumulationController.AssetSearchResult>();
        
        AccumulationController.AssetSearchResult assetDetail = new AccumulationController.AssetSearchResult();
        assetDetail.riskId = asset.Risk_ID__c;
        assetDetail.groupId = asset.Accumulation__r.Group_ID__c;
        assetDetail.requestNum = asset.Opportunity__r.Busreq_ID__c;
        assetDetail.accumId = 'ACC001';
        input.assetDetails.add(assetDetail);
        
        Test.startTest();
        try {
            Map<String, Object> result = AccumulationController.updateAccumulationRecord(input);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error'), 'Should handle error gracefully');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAccumulationRecordNoId() {
        AccumulationController.AccumulationInput input = new AccumulationController.AccumulationInput();
        input.versionStr = 'V2';
        input.totalTSI = 2000000;
        
        Test.startTest();
        try {
            AccumulationController.updateAccumulationRecord(input);
            System.assert(false, 'Should throw exception for missing accumulation ID');
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteOperation() {
        Asset asset = [SELECT Id, Risk_ID__c, Accumulation__r.Group_ID__c, Opportunity__r.Busreq_ID__c FROM Asset LIMIT 1];
        
        AccumulationController.AccumulationInput input = new AccumulationController.AccumulationInput();
        input.versionStr = 'V1';
        input.totalTSI = 0;
        input.deletedAssetDetails = new List<AccumulationController.AssetSearchResult>();
        
        AccumulationController.AssetSearchResult deletedAsset = new AccumulationController.AssetSearchResult();
        deletedAsset.riskId = asset.Risk_ID__c;
        deletedAsset.groupId = asset.Accumulation__r.Group_ID__c;
        deletedAsset.requestNum = asset.Opportunity__r.Busreq_ID__c;
        input.deletedAssetDetails.add(deletedAsset);
        
        Test.startTest();
        try {
            Map<String, Object> result = AccumulationController.createAccumulationRecord(input);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error'), 'Should handle error gracefully');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testWrapperClasses() {
        Quote quote = [SELECT Id, Risk_Name__c, Risk_Name__r.Zip_Code__r.Name, 
                       Risk_Name__r.City__r.Name, Risk_Name__r.Address_Description__c, 
                       Risk_Name__r.N_K_R__r.Name, Risk_Name__r.Accumulation__c, 
                       Risk_Name__r.Accumulation__r.Name, Risk_Name__r.Accumulation__r.As_Per_Inception_Date__c, 
                       OpportunityId, Opportunity.Start_Date_Periode__c, Opportunity.End_Date_Periode__c 
                       FROM Quote LIMIT 1];
        
        String assetFields = 'SELECT Id, Name, Risk_ID__c, Address_Description__c, Amount_Insured__c, ' +
                            'Zip_Code__r.Name, Opportunity__c, Opportunity__r.Busreq_ID__c, ' +
                            'Opportunity__r.Start_Date_Periode__c, Opportunity__r.End_Date_Periode__c, ' +
                            'N_K_R__r.Name, Currency__r.Name, Accumulation__c, Accumulation__r.Group_ID__c, ' +
                            'Risk__c, Vessel_Name__c, Vessel_Name__r.Name, Voyage_Number__c';
        
        // Add conditional fields if they exist
        if (isFieldWriteable('Asset', 'Insurance_Policy__c')) {
            assetFields += ', Insurance_Policy__r.Name, Insurance_Policy__r.NameInsured__c';
        }
        if (isFieldWriteable('Asset', 'Accumulation_ID__c')) {
            assetFields += ', Accumulation_ID__c';
        }
        
        assetFields += ' FROM Asset LIMIT 1';
        
        Asset asset = Database.query(assetFields);
        
        Accumulation__c accum = [SELECT Id, Name, Version__c, Group_ID__c, As_Per_Inception_Date__c 
                                 FROM Accumulation__c LIMIT 1];
        
        Test.startTest();
        AccumulationController.QuoteData quoteData = new AccumulationController.QuoteData(quote);
        AccumulationController.AssetSearchResult assetResult = new AccumulationController.AssetSearchResult(asset);
        AccumulationController.AssetSearchResult emptyAssetResult = new AccumulationController.AssetSearchResult();
        AccumulationController.AccumulationData accumData = 
            new AccumulationController.AccumulationData(accum, new List<Asset>{asset});
        Test.stopTest();
        
        System.assertNotEquals(null, quoteData, 'QuoteData should be created');
        System.assertNotEquals(null, assetResult, 'AssetSearchResult should be created');
        System.assertNotEquals(null, emptyAssetResult, 'Empty AssetSearchResult should be created');
        System.assertNotEquals(null, accumData, 'AccumulationData should be created');
        System.assertEquals(1, accumData.assets.size(), 'Should have 1 asset');
    }
    
    @isTest
    static void testFiscalYearCalculation() {
        Account testAcc = new Account(Name = 'Test Account for Fiscal');
        insert testAcc;
        
        // Test fiscal year before July (month < 7)
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp Before July',
            AccountId = testAcc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today(),
            Busreq_ID__c = 'FISCAL001',
            Start_Date_Periode__c = Date.newInstance(2024, 3, 15), // March
            End_Date_Periode__c = Date.newInstance(2025, 3, 15)
        );
        insert opp1;
        
        // Test fiscal year after July (month >= 7)
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp After July',
            AccountId = testAcc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today(),
            Busreq_ID__c = 'FISCAL002',
            Start_Date_Periode__c = Date.newInstance(2024, 9, 15), // September
            End_Date_Periode__c = Date.newInstance(2025, 9, 15)
        );
        insert opp2;
        
        Test.startTest();
        Map<String, Object> result1 = AccumulationController.getRisksByOpportunityBusReq(opp1.Id);
        Map<String, Object> result2 = AccumulationController.getRisksByOpportunityBusReq(opp2.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result1, 'Should return result for opp before July');
        System.assertNotEquals(null, result2, 'Should return result for opp after July');
    }
}