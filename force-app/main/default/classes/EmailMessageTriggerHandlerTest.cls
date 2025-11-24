@isTest
private class EmailMessageTriggerHandlerTest {

    // Utility to create required EmailMessageRelation records (mandatory for EmailMessage insert)
    private static EmailMessage createEmail(Id relatedToId, Boolean incoming) {

        // Parent case is required for EmailMessage
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

    @isTest
    static void testBeforeInsert_Account() {

        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        Test.startTest();

        EmailMessage em = createEmail(acc.Id, false);

        insert em;   // Should trigger beforeInsert

        Test.stopTest();

        // Reload Account
        Account accAfter = [SELECT EmailThreadKey__c FROM Account WHERE Id = :acc.Id];

        System.assertNotEquals(null, accAfter.EmailThreadKey__c, 'EmailThreadKey__c must be updated');
        System.assertEquals(
            String.valueOf(acc.Id).substring(0,15),
            accAfter.EmailThreadKey__c,
            'Thread_ID__c should match'
        );
    }

    @isTest
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

        Opportunity oppAfter = [SELECT EmailThreadKey__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(null, oppAfter.EmailThreadKey__c);
    }

@isTest
static void testBeforeInsert_InsurancePolicy() {

    Account insured = new Account(Name = 'Insured Account');
    insert insured;

    InsurancePolicy pol = new InsurancePolicy(
        Name = 'Policy Test',
        NameInsuredId = insured.Id // Required field
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


    @isTest
    static void testAfterInsert() {

        Account acc = new Account(Name = 'Test Acc 2');
        insert acc;

        Test.startTest();

        EmailMessage em = createEmail(acc.Id, true); // incoming = TRUE
        insert em;

        Test.stopTest();

        // Reload email
        EmailMessage emAfter = [
            SELECT Thread_ID__c, Incoming
            FROM EmailMessage
            WHERE Id = :em.Id
        ];

        System.assertEquals(
            String.valueOf(acc.Id).substring(0, 15),
            emAfter.Thread_ID__c,
            'Thread_ID__c should be set'
        );
    }
}