@isTest
public class UpdatePriority_Test {
    @testSetup
    static void setup() {
        // Membuat data SSC_Call_Type__c untuk pengujian
        List<SSC_Call_Type__c> callTypes = new List<SSC_Call_Type__c>();

        // Call Type dengan SCC_Priority__c = true
        callTypes.add(new SSC_Call_Type__c(
            Name = 'Critical Call Type',
            SSC_Case_Description__c= 'test',
            SCC_Priority__c = true
        ));

        // Call Type dengan SCC_Priority__c = false
        callTypes.add(new SSC_Call_Type__c(
            Name = 'Non-Critical Call Type',
            SSC_Case_Description__c= 'test',
            SCC_Priority__c = false
        ));

        insert callTypes;
    }

    @isTest
    static void testUpdatePriorityBeforeInsert() {
        // Mendapatkan data Call Type dari setup
        SSC_Call_Type__c criticalCallType = [SELECT Id FROM SSC_Call_Type__c WHERE SCC_Priority__c = true LIMIT 1];
        SSC_Call_Type__c nonCriticalCallType = [SELECT Id FROM SSC_Call_Type__c WHERE SCC_Priority__c = false LIMIT 1];

        // Membuat data Case untuk pengujian
        List<Case> casesToInsert = new List<Case>();
        casesToInsert.add(new Case(
            SCC_Call_Type__c = criticalCallType.Id,
            Priority = 'Low'
        ));
        casesToInsert.add(new Case(
            SCC_Call_Type__c = nonCriticalCallType.Id,
            Priority = 'Low'
        ));

        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        // Verifikasi bahwa priority berubah sesuai logika trigger
        List<Case> insertedCases = [SELECT Id, Priority, SCC_Call_Type__c FROM Case];
        for (Case c : insertedCases) {
            if (c.SCC_Call_Type__c == criticalCallType.Id) {
                System.assertEquals('High (Urgent/Critical)', c.Priority, 'Priority should be updated to High for critical call type.');
            } else if (c.SCC_Call_Type__c == nonCriticalCallType.Id) {
                System.assertEquals('Low', c.Priority, 'Priority should remain Low for non-critical call type.');
            }
        }
    }

    @isTest
    static void testUpdatePriorityBeforeUpdate() {
        // Mendapatkan data Call Type dari setup
        SSC_Call_Type__c criticalCallType = [SELECT Id FROM SSC_Call_Type__c WHERE SCC_Priority__c = true LIMIT 1];
        SSC_Call_Type__c nonCriticalCallType = [SELECT Id FROM SSC_Call_Type__c WHERE SCC_Priority__c = false LIMIT 1];

        // Membuat dan menyisipkan data Case untuk pengujian
        Case testCase = new Case(
            SCC_Call_Type__c = nonCriticalCallType.Id,
            Priority = 'Low'
        );
        insert testCase;

        // Mengupdate Call Type ke critical
        testCase.SCC_Call_Type__c = criticalCallType.Id;

        Test.startTest();
        update testCase;
        Test.stopTest();

        Case updatedCase = [SELECT Id, Priority, SCC_Call_Type__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('High (Urgent/Critical)', updatedCase.Priority, 'Priority should be updated to High for critical call type.');
    }
}