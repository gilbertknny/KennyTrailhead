@IsTest
public class SCC_Migration_Test {
    /*@TestSetup
    static void setupTestData() {
        // Create necessary test data
        // Create SSC_Call_Type__c records
        List<SSC_Call_Type__c> callTypes = new List<SSC_Call_Type__c>();
            SSC_Call_Type__c callType = new SSC_Call_Type__c(
                Name = '8812',
                SCC_Customer_Segment__c = 'Individu Umum ',  // Field yang diwajibkan oleh validasi
                SSC_Case_Category__c = 'Complaint - Transaction ',    // Field yang diwajibkan oleh validasi
                SSC_Case_Description__c = 'Complaint - Transaction ',       // Field yang diwajibkan oleh validasi
				SSC_Product_L1__c = 'Transaction Banking ',       // Field yang diwajibkan oleh validasi
				SSC_Product_L2__c = 'Transaction Solution ',       // Field yang diwajibkan oleh validasi
                SCC_Level1_Escalation_team__c = 'Team ',
                Active__c = true
            );
            callTypes.add(callType);
        
        insert callTypes;

        // Create Queue records
        List<Group> queueGroups = new List<Group>();
        for (Integer i = 1; i <= 4; i++) {
            Group queue = new Group(
                Name = 'Team ' + i,
                Type = 'Queue'
            );
            queueGroups.add(queue);
        }
        insert queueGroups;

        // Create Case records
        List<Case> cases = new List<Case>();
            Case caseRecord = new Case(
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Migration').getRecordTypeId(),
                Description = 'Test Description',
                SCC_Call_Type__c = callTypes[0].Id,
                SCC_Segment__c = 'Individu Umum ',  // Field yang diwajibkan oleh validasi
                SCC_Resolution_Category__c = 'Transactional/Fraud without Refund ', // Field yang diwajibkan oleh validasi
                SCC_Product_L1__c = 'Savings ',           // Field yang diwajibkan oleh validasi
                SCC_Product_L2__c = 'Tabungan (SA) ',           // Field yang diwajibkan oleh validasi
                SCC_Case_Category__c = 'Complaint - Transaction ',    // Field yang diwajibkan oleh validasi
                SSC_Call_Type_Description__c = 'test '      // Field yang diwajibkan oleh validasi
            );
            cases.add(caseRecord);
        insert cases;
        system.debug(callTypes[0].Name);
    }*/
    
    @IsTest 
    static void testBatchMigration() {
        User u = [SELECT Id FROM User Where isActive = true AND profile.name = 'System Administrator' LIMIT 1];
       	System.runAs(u) {
            Test.startTest();
            String query = 'SELECT Id, SCC_Call_Type__c, RecordTypeId FROM Case';
            SCC_Migration job = new SCC_Migration(query);
            Database.executeBatch(job, 2);
            Test.stopTest();
            
            List<Case> cases = [SELECT Id, OwnerId FROM Case];

            // Verify the results
            /*for (Case c : cases) {
                System.assertNotEquals(null, c.OwnerId, 'OwnerId should be updated');
            }*/
        }
    }
}