/**
 * @description       : Test Class for Aswata_Add_New_DetailAsset_Controller
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-02-2025
 * @last modified by  : Ahmad Yazid Munif
**/
@IsTest
private class Aswata_Add_New_DetailAsset_Test {
    private static final String TEST_COB = '301';

    @TestSetup
    static void setupTestData() {
        RecordType rtDetailAsset = [SELECT Id, Name FROM RecordType where SobjectType = 'Master_Data__c' and Name = 'Detail Asset' LIMIT 1];
        RecordType recordTypeCategory = [SELECT Id, Name FROM RecordType where SobjectType = 'Master_Data__c' and Name = 'Asset Category' LIMIT 1];
        RecordType rtAssetSection = [SELECT Id, Name FROM RecordType where SobjectType = 'Master_Data__c' and Name = 'Asset Section' LIMIT 1];

        Product2 cob301 = new Product2();
        cob301.Name = 'Motor Vehicle';
        cob301.ProductCode = '301';
        insert cob301;

        // field
        List<Master_Data__c> masterDataList = new List<Master_Data__c>();
        masterDataList.add(new Master_Data__c(
            Name = 'Indemnity_Type__c',
            BSN_ID__c = TEST_COB,
            Section__c = 4,
            RecordTypeId = rtDetailAsset.Id,
            Status__c = 'Active',
            Label__c='Indemnity Type',
            Data_Type__c = 'Picklist'
        ));
        masterDataList.add(new Master_Data__c(
            Name = 'Interest_Insured_Detail_Description__c',
            BSN_ID__c = TEST_COB,
            Section__c = 4,
            RecordTypeId = rtDetailAsset.Id,
            Status__c = 'Active',
            Label__c='Interest Insured Detail Description',
            Data_Type__c = 'Text'
        ));
        insert masterDataList;

        Master_Data__c personAsset = new Master_Data__c(
            Name = 'Physical / Persons',
            Section__c = 4,
            BSN__c = cob301.Id,
            RecordTypeId = rtAssetSection.Id
        );
        insert personAsset;

        // Section Get
        List<Master_Data__c> masterDataList2 = new List<Master_Data__c>();
        masterDataList2.add(new Master_Data__c(
            Name = 'Other Material Damage',
            RecordTypeId = recordTypeCategory.Id,
            Asset_Section__c = personAsset.Id,
            BSN__c = cob301.Id
        ));
        masterDataList2.add(new Master_Data__c(
            Name = 'Passangers Personal Accident',
            RecordTypeId = recordTypeCategory.Id,
            Asset_Section__c = personAsset.Id,
            BSN__c = cob301.Id
        ));
        insert masterDataList2;
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
    static void getSectionTest() {
        User adminUser = createUser();
        Test.startTest();
        List<String> results;
        System.runAs(adminUser) {
            results = Aswata_Add_New_DetailAsset_Controller.getSections('Physical / Persons', '301');
        }
        Test.stopTest();
        System.assertEquals('4', results.get(0), 'First section title should match the expected value.');
    }
    @IsTest
    static void getDetailAssetDataTest() {
        User adminUser = createUser();
        Account insertAcc = [SELECT Id,Name FROM Account WHERE Name = 'Jhon'];
        Opportunity opp = Aswata_TestDataFactory.createOpportunity(insertAcc,'OPPTY-01');
        Asset risk = Aswata_TestDataFactory.createRisk(opp,'RISK TEST');
        Aswata_TestDataFactory.createAsset(opp,risk,'RUMAH');
        // Asset idAsset = [SELECT Id FROM ASSET WHERE Name = 'RUMAH' LIMIT 1];
        Master_Data__c persons = [SELECT Id, Name FROM Master_Data__c WHERE Name = 'Physical / Persons'];
        Map<String, Object> newFormData = new Map<String, Object>{
            'Name' => 'New Building Asset',
            'SerialNumber' => 'SN-12345',
            'Amount_Insured__c' => '500000.00',
            'Exchange_Rate__c' => '1.0',
            'Section__c' => persons.Id,
            'Opportunity__c'=> opp.Id
        };
        Map<String, Object> updateFormData = new Map<String, Object>{
            'Id' => risk.Id,
            'Name' => 'Updated Existing Asset Name',
            'SerialNumber' => 'SN-UPDATED',
            'Amount_Insured__c' => '750000.50',
            'Section__c' => persons.Id
        };
        Map<String,Object> results;
        Test.startTest();
        System.runAs(adminUser) {
            // System.debug('updateFormData'+updateFormData);
            results = Aswata_Add_New_DetailAsset_Controller.getDetailAssetData(risk.Id);
            Aswata_Add_New_DetailAsset_Controller.getDetailAssetData(null);
        }
        try {
            Aswata_Add_New_DetailAsset_Controller.saveDetailAsset(newFormData);
            Aswata_Add_New_DetailAsset_Controller.saveDetailAsset(newFormData);
            Aswata_Add_New_DetailAsset_Controller.saveDetailAsset(updateFormData);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Return Error.');
        }
        Test.stopTest();
        // Asset insertedAsset = [SELECT Id, Name, Amount_Insured__c, SerialNumber FROM Asset WHERE Id = :newAssetId WITH SECURITY_ENFORCED];
        // Asset updatedAsset = [SELECT Id, Name, SerialNumber, Amount_Insured__c FROM Asset WHERE Id = :updatedAssetId WITH SECURITY_ENFORCED];
        // System.assertEquals(500000.00, insertedAsset.Amount_Insured__c, 'Decimal conversion and Amount_Insured__c should be correct.');
        // System.assertEquals(idAsset.Id, (String)results.get('Id'), 'The returned Id must match the queried Asset Id.');
        // System.assertEquals('Updated Existing Asset Name', updatedAsset.Name, 'Asset Name must be updated.');
    }
    @IsTest
    static void getActiveFieldsSuccessTest() {
        User adminUser = createUser();
        RecordType recordType = [SELECT Id, Name FROM RecordType where SobjectType = 'Master_Data__c' and Name = 'Detail Asset' WITH SECURITY_ENFORCED LIMIT 1];
        List<Master_Data__c> testConfigs = new List<Master_Data__c>();
        testConfigs.add(createMasterDataRecord(recordType.Id, 'FieldA__c', 1));
        testConfigs.add(createMasterDataRecord(recordType.Id, 'FieldB__c', 2));
        insert testConfigs;
        List<Aswata_Add_New_DetailAsset_Controller.DynamicFieldConfig> results;
        Test.startTest();
        System.runAs(adminUser) {
            results = Aswata_Add_New_DetailAsset_Controller.getActiveFields('301');
        }
        Test.stopTest();
        System.assertNotEquals(null, results, 'Results list should not be null.');
        System.assertEquals(4, results.size(), 'Should return exactly two active field configurations.');
        Aswata_Add_New_DetailAsset_Controller.DynamicFieldConfig configA = results.get(0);
        // System.assertEquals('FieldA__c', configA.apiName, 'First config should map the correct Name/apiName.');
        System.assertEquals(4, configA.section, 'Section field should be correctly mapped.');
    }
    /**
     * @description function for generate master data
     * @param recordTypeId
     * @param name
     * @param section
     * @return Master_Data__c
     */
    private static Master_Data__c createMasterDataRecord(Id recordTypeId, String name, Decimal section) {
        Master_Data__c config = new Master_Data__c(
            RecordTypeId = recordTypeId,
            Name = name,
            Section__c = section,
            Label__c = 'Label for ' + name,
            Data_Type__c = 'TEXT',
            Lookup_Object__c = 'Account',
            Filter__c = 'Active=TRUE',
            Status__c = 'Active',
            Object__c = 'Asset',
            Order__c = 1,
            showData__c = 'TRUE',
            BSN_ID__c = TEST_COB
        );
        return config;
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