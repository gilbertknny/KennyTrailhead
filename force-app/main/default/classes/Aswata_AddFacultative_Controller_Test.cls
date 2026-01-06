@isTest(seeAllData=false)
public with sharing class Aswata_AddFacultative_Controller_Test {

    /* =========================
       TEST SETUP (Data Factory)
    ========================= */
    @TestSetup
    static void setupData() {

        // Create base dataset
        Map<String, SObject> data =
            Aswata_TestDataFactory.createStandardDataSet();

        Account acc = (Account) data.get('Account');
        Opportunity opp = (Opportunity) data.get('Opportunity');
		opp.Busreq_ID__c = '1234';
        opp.Start_Date_Periode__c = Date.today();
        opp.End_Date_Periode__c = Date.today();
        update opp;
        
        Opportunity opp2 = Aswata_TestDataFactory.createOpportunity(acc, 'opportunity 2nd Testing');
		opp2.Busreq_ID__c = '1235';
        opp2.Start_Date_Periode__c = Date.today().addDays(1);
        opp2.End_Date_Periode__c = Date.today().addDays(1);
        update opp2;
        
        Facultative_Share__c facShare = Aswata_TestDataFactory.createFacultativeShare('Folder Test');
        // Create Risk Asset (tanpa folder)
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        risk1.Has_Facultative__c = true;
        risk1.Facultative_Owner__c = UserInfo.getUserId();
        update risk1;

        // Create Risk Asset (dengan folder)
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp2, 'Risk 2');
        risk2.Has_Facultative__c = true;
        risk2.Facultative_Folder__c = facShare.Id;
        update risk2;

        // Create Reinsurance Account (for searchAccounts)
        Account reinsurer = Aswata_TestDataFactory.createAccount('Test Reinsurer');
        reinsurer.Type = 'REINSURANCE';
        reinsurer.Insurance_ID__c = 'INS-001';
        update reinsurer;
        
        //Create Coverage for risk//
        ////////////////////////////
        Id standardRtId = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Coverage').getRecordTypeId();
        RecordType rtCovRate = [SELECT Id FROM RecordType WHERE SobjectType = 'Master_Data__c' AND Name = 'Coverage Rate' LIMIT 1];
        RecordType rtAssetCategory = [SELECT Id FROM RecordType WHERE SobjectType = 'Master_Data__c' AND Name = 'Asset Category' LIMIT 1];
        RecordType rtCoverage = [SELECT Id FROM RecordType WHERE SobjectType = 'Master_Data__c' AND Name = 'Coverage' LIMIT 1];
        String testRtId = standardRtId;
        String testCob = '301';
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
        exchangeRatesToInsert.add(new Master_Data__c(
            Name = 'Comprehensive',
            COVERAGE_REF_ID__c = '301100',
            PARENT_COVERAGE_ID__c = '0',
            RecordTypeId = rtCoverage.Id
        ));
        exchangeRatesToInsert.add(new Master_Data__c(
            Name = 'CASCO',
            RecordTypeId = rtAssetCategory.Id
        ));
        if (!exchangeRatesToInsert.isEmpty()) {
            insert exchangeRatesToInsert;
        }
        Master_Data__c mdComprehensive = [SELECT Id FROM Master_Data__c WHERE NAME='Comprehensive' AND RecordTypeId= :rtCoverage.Id];
        Master_Data__c mdCasco = [SELECT Id FROM Master_Data__c WHERE NAME='CASCO' AND RecordTypeId= :rtAssetCategory.Id];
        Master_Data__c masterCoverageAsset = new Master_Data__c(
            Name = 'CASCO',
            COVERAGE_REF_ID__c = '301101',
            Coverage_301__c = mdComprehensive.Id,
            Asset_Category__c = mdCasco.Id,
            RecordTypeId = rtCoverage.Id,
            Section__c = 301
        );
        insert masterCoverageAsset;

        Account insertAcc = Aswata_TestDataFactory.createAccount('Jhon');
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'DummyInsurancePolicy',
            NameInsuredId = insertAcc.Id,
            Status = 'Active',
            EffectiveDate = Date.today(),
            ExpirationDate = Date.today().addYears(1)
        );
        insert policy;

        List<InsurancePolicyCoverage> coverages = new List<InsurancePolicyCoverage>();
        coverages.add(new InsurancePolicyCoverage(
            CoverageName = 'Coverage1',
            Proposed_Fixed_Amount__c=123123,
            InsurancePolicyId = policy.Id,
            Risk_ID__c = risk1.Id
        ));
        coverages.add(new InsurancePolicyCoverage(
            CoverageName = 'Coverage2',
            Proposed_Fixed_Amount__c=123123,
            InsurancePolicyId = policy.Id,
            Risk_ID__c = risk2.Id
        ));
        insert coverages;
    }

    /* =========================
       getRiskList
    ========================= */
    @IsTest
    static void testGetRiskList() {
        Test.startTest();
        List<Asset> risks =
            Aswata_AddFacultative_Controller.getRiskList();
        Test.stopTest();

        System.assertNotEquals(null, risks);
        System.assert(
            risks.size() > 0,
            'Should return risks without facultative folder'
        );
    }

    /* =========================
       getRiskByFolder
    ========================= */
    @IsTest
    static void testGetRiskAssets() {

        Facultative_Share__c folder = [SELECT Id FROM Facultative_Share__c LIMIT 1];

        Test.startTest();
        List<Asset> risks =
            Aswata_AddFacultative_Controller.getRiskByFolder(folder.Id);
        Test.stopTest();

        System.assertNotEquals(null, risks);
        System.assert(
            risks.size() > 0,
            'Should return risks linked to folder'
        );
    }

    /* =========================
       updateSelectedRisks
    ========================= */
    @IsTest
    static void testUpdateSelectedRisks() {

        Facultative_Share__c folder = [SELECT Id FROM Facultative_Share__c LIMIT 1];

        Asset risk = [
            SELECT Id, Facultative_Folder__c
            FROM Asset
            WHERE Facultative_Folder__c = null
            LIMIT 1
        ];

        Test.startTest();
        Aswata_AddFacultative_Controller.updateSelectedRisks(
            new List<Id>{ risk.Id },
            folder.Id
        );
        Test.stopTest();

        Asset updated = [
            SELECT Facultative_Folder__c
            FROM Asset
            WHERE Id = :risk.Id
        ];

        System.assertEquals(
            folder.Id,
            updated.Facultative_Folder__c,
            'Facultative folder should be updated'
        );
    }

    /* =========================
       searchAccounts
    ========================= */
    @IsTest
    static void testSearchAccounts() {

        Test.startTest();
        List<Account> results =
            Aswata_AddFacultative_Controller.searchAccounts('Reinsurer');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assert(
            results.size() > 0,
            'Should return REINSURANCE accounts'
        );
    }

    /* =========================
       updateFacultativeStatus
    ========================= */
    @IsTest
    static void testUpdateFacultativeStatus() {

        Opportunity opp = [
            SELECT Id, Offering_status__c
            FROM Opportunity
            LIMIT 1
        ];

        Test.startTest();
        Aswata_AddFacultative_Controller.updateFacultativeStatus(
            opp.Id,
            'Offering'
        );
        Test.stopTest();

        Opportunity updated = [
            SELECT Offering_status__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(
            'Offering',
            updated.Offering_status__c,
            'Offering status should be updated'
        );
    }

    /* =========================
       Negative test
    ========================= */
    @IsTest
    static void testUpdateFacultativeStatus_MissingParams() {
        Test.startTest();
        try {
            Aswata_AddFacultative_Controller.updateFacultativeStatus(null, null);
            System.assert(false, 'Exception expected');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testValidateCoverage_Valid() {

        List<String> riskIds = new List<String>();

        for (Asset a : [
            SELECT Id FROM Asset WHERE Has_Facultative__c = true LIMIT 1
        ]) {
            riskIds.add(a.Id);
        }

        Test.startTest();
        Boolean result =
            Aswata_AddFacultative_Controller.validateCoverage(riskIds);
        Test.stopTest();

        System.assertEquals(
            true,
            result,
            'Risks with identical coverage should be valid'
        );
    }
    
    @IsTest
    static void testValidateCoverage_Invalid() {

        List<String> riskIds = new List<String>();

        for (Asset a : [
            SELECT Id FROM Asset WHERE Has_Facultative__c = true LIMIT 2
        ]) {
            riskIds.add(a.Id);
        }

        Test.startTest();
        Boolean result =
            Aswata_AddFacultative_Controller.validateCoverage(riskIds);
        Test.stopTest();

        System.assertEquals(
            false,
            result,
            'Risks with identical coverage should be invalid'
        );
    }
}