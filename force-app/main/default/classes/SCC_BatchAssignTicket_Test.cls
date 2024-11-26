@isTest
private class SCC_BatchAssignTicket_Test {
    @isTest
    static void testBatchAssignTicket() {
        // Setup: create a few Case records with an initial owner
        User originalOwner = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        User newOwner = [SELECT Id FROM User WHERE IsActive = true AND Id != :originalOwner.Id LIMIT 1];
        System.assertNotEquals(null, newOwner, 'New owner user should be found for testing');

        List<Case> casesToAssign = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case c = new Case(
                Status = 'New',
                Subject = 'Test Case ' + i,
                OwnerId = originalOwner.Id
            );
            casesToAssign.add(c);
        }
        insert casesToAssign;

        // Collect Case Ids for the batch process
        List<Id> caseIds = new List<Id>();
        for (Case c : casesToAssign) {
            caseIds.add(c.Id);
        }

        // Verify initial OwnerId
        for (Case c : [SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds]) {
            System.assertEquals(originalOwner.Id, c.OwnerId, 'OwnerId should be the original owner before batch process');
        }

        // Run the batch job
        Test.startTest();
        SCC_BatchAssignTicket batchJob = new SCC_BatchAssignTicket(caseIds, newOwner.Id);
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that OwnerId was updated to the new owner
        List<Case> updatedCases = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds];
        for (Case c : updatedCases) {
            System.assertEquals(newOwner.Id, c.OwnerId, 'OwnerId should be updated to new owner after batch process');
        }
    }
}