/**
 * @description       : Test Class for Aswata_Add_New_CoverageRate
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-12-2025
 * @last modified by  : Ahmad Yazid Munif
**/

@isTest
private class Aswata_Add_New_CoverageRate_Test {

    @testSetup
    static void makeData() {
        Id standardRtId = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Coverage').getRecordTypeId();
        RecordType rtCovRate = [SELECT Id FROM RecordType WHERE SobjectType = 'Master_Data__c' AND Name = 'Coverage Rate' LIMIT 1];

        String testRtId = standardRtId;
        String testCob = '201';
        Decimal testTarifBawah = 0.50;
        Master_Data__c config = new Master_Data__c(
            Name = 'Test Coverage Config',
            RecordTypeId = testRtId,
            BSN_ID__c = testCob,
            PARENT_COVERAGE_ID__c = '115500'
        );
        insert config;

        Master_Data__c coverageRate = new Master_Data__c(
            Name = 'Test Coverage Rate',
            RecordTypeId = rtCovRate.Id,
            Coverage__c = config.Id,
            Tarif_Bawah__c = testTarifBawah,
            PARENT_COVERAGE_ID__c = '115500' ,
            COVERAGE_REF_ID__c = '115500'
        );
        insert coverageRate;
        Master_Data__c excludedConfig = new Master_Data__c(
            Name = 'Excluded Config',
            RecordTypeId = testRtId,
            BSN_ID__c = '301',
            PARENT_COVERAGE_ID__c = '115600',
            COVERAGE_REF_ID__c = '115600'
        );
        insert excludedConfig;
        RecordType rtExRate = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Master_Data__c' AND Name = 'Exchange Rate' LIMIT 1];
        List<Master_Data__c> exchangeRatesToInsert = new List<Master_Data__c>();
        exchangeRatesToInsert.add(new Master_Data__c(
            Name = 'UDR',
            RecordTypeId = rtExRate.Id
        ));
        exchangeRatesToInsert.add(new Master_Data__c(
            Name = 'IDR',
            RecordTypeId = rtExRate.Id
        ));
        if (!exchangeRatesToInsert.isEmpty()) {
            insert exchangeRatesToInsert;
        }
        Account insertAcc = Aswata_TestDataFactory.createAccount('Jhon');
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'DummyInsurancePolicy',
            NameInsuredId = insertAcc.Id,
            Status = 'Active',
            EffectiveDate = Date.today(),
            ExpirationDate = Date.today().addYears(1)
        );
        insert policy;
    }

    @IsTest
    static void testGetCoverageFieldsSuccess() {
        User adminUser = createUser();
        Account insertAcc = [SELECT Id,Name FROM Account WHERE Name = 'Jhon'];
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(insertAcc,'OPPTY-02');
        Asset risk = Aswata_TestDataFactory.createRisk(opp,'RISK TEST AY');
        Asset asset = Aswata_TestDataFactory.createAsset(opp,risk,'RUMAH AY');
        String testRtId = [SELECT Id FROM RecordType WHERE SobjectType = 'Master_Data__c' AND Name = 'Coverage' LIMIT 1].Id;
        String testCob = '201';
        Decimal expectedTarifBawah = 50.0;
        Test.startTest();
        List<Aswata_Coverage_Data_Wrapper.DynamicFieldConfig> results;
        System.runAs(adminUser) {
            results = Aswata_Coverage_Data_Handler.getCoverageFields(testRtId, testCob,risk.Id);
        }
        Test.stopTest();
        System.assertNotEquals(null, results, 'Results list should not be null.');
        System.assertEquals(1, results.size(), 'Only one configuration record should be returned.');
        Aswata_Coverage_Data_Wrapper.DynamicFieldConfig result = results[0];
        // System.assertEquals('115500', result.coverageId, 'The coverage reference ID is incorrect.');
        System.assertEquals('Test Coverage Config', result.coverageName, 'The name is incorrect.');
        System.assertEquals(expectedTarifBawah, result.batasBawah, 'Tarif_Bawah__c was not calculated correctly (Tarif * 100).');
    }

    @IsTest
    static void testGetDeductiblePicklistValuesSuccess() {
        User adminUser = createUser();
        Schema.DescribeFieldResult ddtibleField = InsurancePolicyCoverage.Deductible__c.getDescribe();
        Test.startTest();
        Aswata_Coverage_Data_Wrapper.PicklistWrapper results;
        System.runAs(adminUser) {
            results = Aswata_Coverage_Data_Handler.getDeductiblePicklistValues();
        }
        Test.stopTest();
        System.assertNotEquals(null, results.deductibleOptions, 'Deductible options list should not be null.');
        Integer expectedDeductibleSize = ddtibleField.getPicklistValues().size();
        System.assertEquals(expectedDeductibleSize, results.deductibleOptions.size(), 'Deductible options count does not match the picklist size.');
        if (!results.deductibleOptions.isEmpty()) {
            Map<String, String> firstDeductibleOption = results.deductibleOptions[0];
            Schema.PicklistEntry firstDdtibleEntry = ddtibleField.getPicklistValues()[0];
            System.assert(firstDeductibleOption.containsKey('label'), 'Deductible option map must contain "label" key.');
            System.assertEquals(firstDdtibleEntry.getValue(), firstDeductibleOption.get('value'), 'First deductible value mismatch.');
        }
    }
    @IsTest
    static void testInsertCoverageDetails() {
        User adminUser = createUser();
        Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper = generateData('201101_0','BREAKDOWN_DEDUCTIBLE','Flat');
        List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> wrapperList = new List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>{ wrapper };
        String jsonPayload = JSON.serialize(wrapperList);
        List<String> inputList = new List<String>{ jsonPayload };
        Test.startTest();
        System.runAs(adminUser) {
            Aswata_Add_New_CoverageRate.insertCoverageDetails(inputList);
            Aswata_Coverage_Data_Handler.getExistingCoverage(wrapper.riskId);
        }
        Test.stopTest();
        InsurancePolicy policy = [SELECT Id FROM InsurancePolicy WHERE Name = 'DummyInsurancePolicy' LIMIT 1];
        List<InsurancePolicyCoverage> insertedCoverages = [
            SELECT Id, Name, Coverage_Id__c, InsurancePolicyId,Risk_ID__c
            FROM InsurancePolicyCoverage
            WHERE InsurancePolicyId = :policy.Id
            LIMIT 1
        ];
        System.assert(!insertedCoverages.isEmpty(), 'Error: InsurancePolicyCoverage record was not inserted.');
        System.assertEquals(1, insertedCoverages.size(), 'Error: Should have inserted exactly one coverage record.');
    }
    @IsTest
    static void testInsertCoverageCompositeDetails() {
        User adminUser = createUser();
        Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper = generateData('SINGLE_RATE_ID','COMPOSITE','Flat');
        List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> wrapperList = new List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>{ wrapper };
        String jsonPayload = JSON.serialize(wrapperList);
        List<String> inputList = new List<String>{ jsonPayload };
        Test.startTest();
        System.runAs(adminUser) {
            Aswata_Add_New_CoverageRate.insertCoverageDetails(inputList);
        }
        Test.stopTest();
        InsurancePolicy policy = [SELECT Id FROM InsurancePolicy WHERE Name = 'DummyInsurancePolicy' LIMIT 1];
        List<InsurancePolicyCoverage> insertedCoverages2 = [
            SELECT Id, Name, Coverage_Id__c, InsurancePolicyId,Risk_ID__c
            FROM InsurancePolicyCoverage
            WHERE InsurancePolicyId = :policy.Id
            LIMIT 1
        ];
        System.assert(!insertedCoverages2.isEmpty(), 'Error: InsurancePolicyCoverage record was not inserted.');
        System.assertEquals(1, insertedCoverages2.size(), 'Error: Should have inserted exactly one coverage record.');
    }
    @IsTest
    static void testInsertCoveragePercentage() {
        User adminUser = createUser();
        Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper = generateData('SINGLE_RATE_ID','COMPOSITE','Percentage');
        List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper> wrapperList = new List<Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper>{ wrapper };
        String jsonPayload = JSON.serialize(wrapperList);
        List<String> inputList = new List<String>{ jsonPayload };
        Test.startTest();
        System.runAs(adminUser) {
            Aswata_Add_New_CoverageRate.insertCoverageDetails(inputList);
        }
        Test.stopTest();

        InsurancePolicy policy = [SELECT Id FROM InsurancePolicy WHERE Name = 'DummyInsurancePolicy' LIMIT 1];
        List<InsurancePolicyCoverage> insertedCoverages3 = [
            SELECT Id, Name, Coverage_Id__c, InsurancePolicyId,Risk_ID__c
            FROM InsurancePolicyCoverage
            WHERE InsurancePolicyId = :policy.Id
            LIMIT 1
        ];
        System.assert(!insertedCoverages3.isEmpty(), 'Error: InsurancePolicyCoverage record was not inserted.');
        System.assertEquals(1, insertedCoverages3.size(), 'Error: Should have inserted exactly one coverage record.');
    }
    @IsTest
    static void testWrapperInitializationAndAssignment() {
        Test.startTest();
        Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure config = new Aswata_Coverage_Data_Wrapper.DynamicFieldConfigure();
        config.coverageId = 'COV-001';
        config.coverageName = 'FLEXAS';
        config.batasBawah = 10.5;
        Aswata_Coverage_Data_Wrapper.CoverageRate rate = new Aswata_Coverage_Data_Wrapper.CoverageRate();
        rate.fixedAmount = 50000.00;
        rate.fixedAmount2 = 50000;
        rate.fixedAmount3 = 50000;
        rate.fixedAmount4 = 50000;
        rate.coverageRate = 1.25;
        rate.coverageRate2 = 1.25;
        rate.coverageRate3 = 1.25;
        rate.coverageRate4 = 1.25;
        rate.descriptionRate = 'Testing Rate';

        Test.stopTest();
        System.assertEquals('COV-001', config.coverageId, 'coverageId should be set correctly.');
        System.assertEquals(10.5, config.batasBawah, 'batasBawah should be set correctly.');
    }
    /**
     * @description function for generate data wrapper
     * @param idWrapper just idWrapper from REF ID Coverage
     * @param covSetting BREAKDOWN_DEDUCTIBLE COMPOSITE
     * @param deductibleSetting BREAKDOWN_DEDUCTIBLE COMPOSITE
     * @return Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper
     */
    public static Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper generateData(String idWrapper,String covSetting,String deductibleSetting){
        InsurancePolicy policy = [SELECT Id FROM InsurancePolicy WHERE Name = 'DummyInsurancePolicy' LIMIT 1];
        Account insertAcc = [SELECT Id,Name FROM Account WHERE Name = 'Jhon'];
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(insertAcc,'OPPTY-01');
        Asset risk = Aswata_TestDataFactory.createRisk(opp,'RISK TEST');
        Asset asset = Aswata_TestDataFactory.createAsset(opp,risk,'RUMAH');
        Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper wrapper =new Aswata_Coverage_Data_Wrapper.CoverageDetailWrapper();
        wrapper.id = idWrapper;
        wrapper.policyId = policy.Id;
        wrapper.riskId = asset.Id;
        wrapper.coverageId = '115500';
        wrapper.coverageName = 'FLEXAS';
        wrapper.rowType = 'COMPOSITE';
        wrapper.batasBawah = 2.94;
        wrapper.coverageSetting = covSetting;
        // Sub-Wrapper: Rate
        wrapper.rate.fixedAmount = 3100;
        wrapper.rate.coverageRate = 1;
        // Sub-Wrapper: Deductible
        wrapper.deductible.deductibleAmount = 1;
        // wrapper.deductible.currencyId = 'a1JMS000000Aqmz2AC';
        wrapper.deductible.deductibleSetting = deductibleSetting;
        wrapper.deductible.descriptionDeductible = 'asd';
        // Sub-Wrapper: Rebate
        wrapper.rebate.totalRebate = 10;
        wrapper.rebate.bspValue = 4;
        wrapper.rebate.overridingValue = 3;
        wrapper.rebate.commissionValue = 2;
        wrapper.rebate.discountValue = 1;
        return wrapper;
    }
    /**
     * @description function for createUser
     * @return User return usercreated
     */
    public static User createUser(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'testad',
            Email = 'testadmin' + System.currentTimeMillis() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AdminTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test.admin.' + System.currentTimeMillis() + '@testorg.com' // Unique Username
        );
        insert adminUser;
        return adminUser;
    }
}