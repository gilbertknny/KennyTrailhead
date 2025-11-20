@isTest
public class SCC_IncidentHistory_UI_Test {
    @testSetup
    static void setupTestData() {
        Incident testIncident = new Incident(
            Subject = 'test subject',
            Nomor_tiket_iRIS__c = 'TEST-001',
            Hold_Justification__c = 'Test Hold',
            Un_Hold_Justification__c = 'Test UnHold',
            Root_Cause2__c = 'Test Root Cause',
            Remark_History__c = 'Test Remark'
        );
        insert testIncident;
    }

    @isTest
    static void testGetIncidentDetail_ValidId() {
        Incident inc = [SELECT Id FROM Incident LIMIT 1];
        
        Test.startTest();
        Incident result = SCC_IncidentHistory_UI.getIncidentDetail(inc.Id);
        Test.stopTest();
        
        System.assertNotEquals(result, null, 'Incident should not be null');
        System.assertEquals(inc.Id, result.Id, 'Incident ID should match');
    }

    @isTest
    static void testGetIncidentDetail_NullId() {
        try {
            SCC_IncidentHistory_UI.getIncidentDetail(null);
            System.assert(false, 'Expected AuraHandledException for null Id');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Incident ID cannot be null or empty'));
        }
    }

    @isTest
    static void testGetIncidentDetail_InvalidId() {
        try {
            SCC_IncidentHistory_UI.getIncidentDetail('INVALID_ID');
            System.assert(false, 'Expected AuraHandledException for invalid Id');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error retrieving Incident'));
        }
    }
}