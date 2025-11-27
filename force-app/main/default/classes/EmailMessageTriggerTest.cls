/**
 * @description      Test class for EmailMessageTrigger. 
 *                   Memvalidasi before insert EmailMessageTriggerHandler.
 * @author           Pepp
 * @date             2025
 * @testCoverage     Test insert Thread_ID__c.
 */
@IsTest
private class EmailMessageTriggerTest {

    /**
     * @description Menguji trigger EmailMessage sebelum dan sesudah insert.
     */
    @IsTest
    static void testTriggerBeforeAndAfterInsert() {

        // Create Account untuk relasi EmailMessage
        Account acc = new Account(Name = 'Trigger Account');
        insert acc;

        // Prepare EmailMessage
        EmailMessage em = new EmailMessage();
        em.Subject = 'Trigger Test Email';
        em.FromAddress = 'trigger@example.com';
        em.ToAddress = 'to@example.com';
        em.TextBody = 'Trigger body text';
        em.RelatedToId = acc.Id;
        em.Incoming = true;

        Test.startTest();
        insert em; 
        Test.stopTest();

        // Query hasil
        EmailMessage insertedEm = [
            SELECT Id, Thread_ID__c, RelatedToId 
            FROM EmailMessage 
            WHERE Id = :em.Id
        ];

        // Assertions
        System.assertNotEquals(null, insertedEm.Thread_ID__c, 'Thread_ID__c harus diisi oleh trigger');
        System.assertEquals(acc.Id, insertedEm.RelatedToId, 'RelatedToId harus tetap sama dengan Account');
    }
}