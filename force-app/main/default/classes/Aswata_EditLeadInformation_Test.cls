@isTest (seeAllData=false)
public with sharing class Aswata_EditLeadInformation_Test {
       // 🔹 3-parameter reusable assertion helper
    private static void assertField(Object actual, Object expected, String message) {
        System.assertEquals(expected, actual, message);
    }

    @IsTest
    static void testUpdateLeadInformation_Success() {
        // Setup test Lead
        Lead lead = Aswata_TestDataFactory.createLead('John', 'Doe', 'Aswata Company');


        // Prepare JSON input
        Map<String, Object> jsonMap = new Map<String, Object>{
            'id' => lead.Id,
            'accountType' => '0',
            'accountSegment' => 'I',
            'accountSubSegment' => 'Y',
            'pipelineStatus' => 'Direct',
            'businessSegmentation' => 'Retail'
        };
        String jsonString = JSON.serialize(jsonMap);

        Aswata_EditLeadInformation_Controller.JsonInput input = 
            new Aswata_EditLeadInformation_Controller.JsonInput();
        input.jsonString = jsonString;

        // Execute Invocable Method
        Test.startTest();
        Aswata_EditLeadInformation_Controller.updateLeadInformationFromJson(
            new List<Aswata_EditLeadInformation_Controller.JsonInput>{ input }
        );
        Test.stopTest();

        // Verify updates
        Lead updatedLead = [
            SELECT Account_Type__c, Account_Segment__c, Account_Sub_Segment__c,
                   Account_Pipeline_Status__c, Business_Segmentation__c
            FROM Lead
            WHERE Id = :lead.Id
        ];

        assertField(updatedLead.Account_Type__c, '0', 'Account Type mismatch');
        assertField(updatedLead.Account_Segment__c, 'I', 'Account Segment mismatch');
        assertField(updatedLead.Account_Sub_Segment__c, 'Y', 'Account Sub Segment mismatch');
        assertField(updatedLead.Account_Pipeline_Status__c, 'Direct', 'Pipeline Status mismatch');
        assertField(updatedLead.Business_Segmentation__c, 'Retail', 'Business Segmentation mismatch');
    }

    @IsTest
    static void testUpdateLeadInformation_MissingId() {
        // JSON without Id
        Map<String, Object> badJson = new Map<String, Object>{
            'accountType' => 'I'
        };
        String jsonString = JSON.serialize(badJson);

        Aswata_EditLeadInformation_Controller.JsonInput input = 
            new Aswata_EditLeadInformation_Controller.JsonInput();
        input.jsonString = jsonString;

        Test.startTest();
        try {
            Aswata_EditLeadInformation_Controller.updateLeadInformationFromJson(
                new List<Aswata_EditLeadInformation_Controller.JsonInput>{ input }
            );
            System.assert(false, 'Should have thrown an exception for missing Id');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateLeadInformation_InvalidJson() {
        Aswata_EditLeadInformation_Controller.JsonInput input = 
            new Aswata_EditLeadInformation_Controller.JsonInput();
        input.jsonString = '{invalid json}';

        Test.startTest();
        try {
            Aswata_EditLeadInformation_Controller.updateLeadInformationFromJson(
                new List<Aswata_EditLeadInformation_Controller.JsonInput>{ input }
            );
            System.assert(false, 'Should have thrown a JSON parsing error');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateLeadInformation_EmptyInput() {
        Test.startTest();
        try {
            Aswata_EditLeadInformation_Controller.updateLeadInformationFromJson(
                new List<Aswata_EditLeadInformation_Controller.JsonInput>()
            );
            System.assert(false, 'Should have thrown No input received');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }
}