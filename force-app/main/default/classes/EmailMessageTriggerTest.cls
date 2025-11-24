@IsTest
private class EmailMessageTriggerTest {

    @IsTest
    static void testTriggerBeforeAndAfterInsert() {
        Account acc = new Account(Name = 'Trigger Account');
        insert acc;

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

        EmailMessage insertedEm = [
            SELECT Id, Thread_ID__c, RelatedToId 
            FROM EmailMessage 
            WHERE Id = :em.Id
        ];
        System.assertNotEquals(null, insertedEm.Thread_ID__c, 'Thread_ID__c harus diisi oleh trigger');
        System.assertEquals(acc.Id, insertedEm.RelatedToId);
    }
}