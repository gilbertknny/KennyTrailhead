/**
 * @description Test class for EmailMessageTriggerHandler
 * Ensures beforeInsert and afterInsert logic behaves correctly
 * Covers Account, Opportunity, InsurancePolicy, and Incoming Email scenarios
 */
@IsTest
private class EmailMessageTriggerHandlerTest {

    /**
     * @description Utility method to create mock EmailMessage record
     * Note: EmailMessage requires a Parent Case + EmailMessageRelation in real org,
     * but for unit tests, only minimal fields are required for DML insert.
     */
    private static EmailMessage createEmail(Id relatedToId, Boolean incoming) {
        // Parent Case is required for EmailMessage
        Case c = new Case(Subject = 'Test Email Case');
        insert c;

        EmailMessage em = new EmailMessage();
        em.RelatedToId = relatedToId;
        em.Incoming = incoming;
        em.Subject = 'Test Subject';
        em.Status = '3';
        em.FromAddress = 'test@example.com';
        em.ToAddress = 'user@example.com';
        em.ParentId = c.Id;
        return em;
    }

    /**
     * @description Validate beforeInsert updates EmailThreadKey__c on Account
     */
    @IsTest
    static void testBeforeInsert_Account() {
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        Test.startTest();
        EmailMessage em = createEmail(acc.Id, false);
        insert em;
        Test.stopTest();

        Account accAfter = [
            SELECT EmailThreadKey__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertNotEquals(null, accAfter.EmailThreadKey__c,
            'EmailThreadKey__c must be updated');
        System.assertEquals(
            String.valueOf(acc.Id).substring(0, 15),
            accAfter.EmailThreadKey__c,
            'Thread_ID__c should match'
        );
    }

    /**
     * @description Validate beforeInsert updates EmailThreadKey__c on Opportunity
     */
    @IsTest
    static void testBeforeInsert_Opportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Opp Test',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        insert opp;

        Test.startTest();
        EmailMessage em = createEmail(opp.Id, false);
        insert em;
        Test.stopTest();

        Opportunity oppAfter = [
            SELECT EmailThreadKey__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertNotEquals(null, oppAfter.EmailThreadKey__c,
            'EmailThreadKey__c must be updated');
    }

    /**
     * @description Validate beforeInsert updates EmailThreadKey__c on InsurancePolicy
     */
    @IsTest
    static void testBeforeInsert_InsurancePolicy() {
        Account insured = new Account(Name = 'Insured Account');
        insert insured;

        InsurancePolicy pol = new InsurancePolicy(
            Name = 'Policy Test',
            NameInsuredId = insured.Id
        );
        insert pol;

        Test.startTest();
        EmailMessage em = createEmail(pol.Id, false);
        insert em;
        Test.stopTest();

        InsurancePolicy polAfter = [
            SELECT EmailThreadKey__c
            FROM InsurancePolicy
            WHERE Id = :pol.Id
        ];

        System.assertNotEquals(null, polAfter.EmailThreadKey__c);
    }

    /**
     * @description Validate afterInsert updates Thread_ID__c on EmailMessage for incoming email
     */
    @IsTest
    static void testAfterInsert() {
        Account acc = new Account(Name = 'Test Acc 2');
        insert acc;

        Test.startTest();
        EmailMessage em = createEmail(acc.Id, true);
        insert em;
        Test.stopTest();

        EmailMessage emAfter = [
            SELECT Thread_ID__c, Incoming
            FROM EmailMessage
            WHERE Id = :em.Id
        ];

        System.assertEquals(
            String.valueOf(acc.Id).substring(0, 15),
            emAfter.Thread_ID__c,
            'Thread_ID__c should be set correctly'
        );
    }
}