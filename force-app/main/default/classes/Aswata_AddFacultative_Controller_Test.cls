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

        Facultative_Share__c facShare = Aswata_TestDataFactory.createFacultativeShare('Folder Test');
        // Create Risk Asset (tanpa folder)
        Asset risk1 = Aswata_TestDataFactory.createRisk(opp, 'Risk 1');
        risk1.Has_Facultative__c = true;
        risk1.Facultative_Owner__c = UserInfo.getUserId();
        update risk1;

        // Create Risk Asset (dengan folder)
        Asset risk2 = Aswata_TestDataFactory.createRisk(opp, 'Risk 2');
        risk2.Has_Facultative__c = true;
        risk2.Facultative_Folder__c = facShare.Id;
        update risk2;

        // Create Reinsurance Account (for searchAccounts)
        Account reinsurer = Aswata_TestDataFactory.createAccount('Test Reinsurer');
        reinsurer.Type = 'REINSURANCE';
        reinsurer.Insurance_ID__c = 'INS-001';
        update reinsurer;
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
}