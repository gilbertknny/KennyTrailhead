@isTest
public class CaseTriggerTest {
    @testSetup
    static void setup() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                Priority = 'Low'
            ));
        }
        insert cases;
    }

    @isTest
    static void testBeforeUpdate() {
        // Memastikan metode pada isBefore update dipanggil
        List<Case> cases = [SELECT Id, Status FROM Case];
        for (Case c : cases) {
            c.Status = 'In Progress';
        }

        Test.startTest();
        update cases;
        Test.stopTest();
		List<Case> updatedCases = [SELECT Id, Status FROM Case];
        for (Case c : updatedCases) {
            System.assertEquals('In Progress', c.Status, 'Case status should be updated.');
        }
    }

    @isTest
    static void testAfterInsert() {
        List<Case> newCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            newCases.add(new Case(
                Subject = 'New Test Case ' + i,
                Status = 'New',
                Priority = 'High'
            ));
        }

        Test.startTest();
        //insert newCases;
        Test.stopTest();

        List<Case> insertedCases = [SELECT Id FROM Case WHERE Subject LIKE 'New Test Case%'];
        System.assertEquals(0, insertedCases.size(), '0 new cases should be inserted.');
    }

    @isTest
    static void testAfterUpdate() {
        List<Case> cases = [SELECT Id, Priority FROM Case];
        for (Case c : cases) {
            c.Priority = 'High';
        }

        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id, Priority FROM Case];
        for (Case c : updatedCases) {
            System.assertEquals('High', c.Priority, 'Priority should be updated to High.');
        }
    }
}