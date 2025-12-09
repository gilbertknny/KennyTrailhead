/**
 * @description     Test class for EmailServiceReceived inbound email handler.
 *                  Covers scenarios:
 *                  - Email with ThreadID (expected to link to Account)
 *                  - Email without ThreadID (auto-create Account)
 *                  - Email trigger logic test (ThreadKey generation)
 *
 * @coverageTarget  EmailServiceReceived
 */
@isTest
public class EmailServiceReceivedTest {

    /**
     * @description Utility: Creates a mock Account with predefined thread key.
     */
    private static Account createAccountWithThread() {
        Account acc = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com',
            EmailThreadKey__c = 'ABCDE12345ABCDE'
        );
        insert acc;
        return acc;
    }

    /**
     * @description Utility: Creates a mock InboundEmail structure.
     */
    private static Messaging.InboundEmail mockEmail(String body, String fromAddr) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject       = 'Test Inbound';
        email.fromAddress   = fromAddr;
        email.fromName      = 'Sender Test';
        email.plainTextBody = body;
        email.htmlBody      = '<p>' + body + '</p>';
        email.toAddresses   = new String[] {'support@test.com'};
        email.ccAddresses   = new String[] {'cc@test.com'};
        return email;
    }

    /**
     * @description Utility: Creates a mock InboundEnvelope.
     */
    private static Messaging.InboundEnvelope mockEnv() {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'sender@test.com';
        return env;
    }

    /**
     * -----------------------------------------------------------------------------
     * @description     Test inbound email that contains a ThreadID.
     *                  Expected result: EmailMessage linked to existing Account,
     *                  attachments saved, CDL created.
     * -----------------------------------------------------------------------------
     */
    @isTest
    static void testInboundEmail_WithThreadId() {
        // Create Account that should be matched via ThreadID
        Account acc = createAccountWithThread();

        // Email containing ThreadID to map to Account
        String body = 'Hello this is test [ThreadID:' + acc.EmailThreadKey__c + ']';
        Messaging.InboundEmail email = mockEmail(body, acc.Email__c);
        Messaging.InboundEnvelope env = mockEnv();

        // Add binary attachment
        Messaging.InboundEmail.BinaryAttachment b = new Messaging.InboundEmail.BinaryAttachment();
        b.fileName = 'test.png';
        b.body = Blob.valueOf('fakeimagecontent');
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] {b};

        Test.startTest();
        EmailServiceReceived handler = new EmailServiceReceived();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        System.assert(res.success, 'Inbound email should succeed');

        // Validate EmailMessage creation
        EmailMessage em = [
            SELECT Id, Subject, FromAddress, ToAddress, TextBody, RelatedToId 
            FROM EmailMessage LIMIT 1
        ];

        System.assertEquals(acc.Id, em.RelatedToId, 'RelatedToId must match the Account');
        System.assert(em.TextBody.contains('ThreadID'), 'Email body must contain ThreadID');

        // Validate ContentDocumentLink creation (attachment linked)
        List<ContentDocumentLink> cdls = [
            SELECT Id, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :em.Id
        ];

        System.assert(!cdls.isEmpty(), 'Attachment should be linked to EmailMessage');
    }

    /**
     * -----------------------------------------------------------------------------
     * @description     Test inbound email without ThreadID.
     *                  Expected: auto-create Account and link EmailMessage to it.
     * -----------------------------------------------------------------------------
     */
    @isTest
    static void testInboundEmail_NoThread_CreateAccount() {
        // Build an email without any ThreadID
        String body = 'Email without thread';
        Messaging.InboundEmail email = mockEmail(body, 'newuser@test.com');
        Messaging.InboundEnvelope env = mockEnv();

        Test.startTest();
        EmailServiceReceived handler = new EmailServiceReceived();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        System.assert(res.success, 'Inbound email should succeed');

        // Validate auto-created Account
        Account acc = [
            SELECT Id, Email__c 
            FROM Account 
            WHERE Email__c = 'newuser@test.com'
            LIMIT 1
        ];

        System.assertNotEquals(null, acc, 'Account must be auto-created');

        // Validate EmailMessage linking
        EmailMessage em = [
            SELECT Id, RelatedToId 
            FROM EmailMessage 
            WHERE RelatedToId = :acc.Id
            LIMIT 1
        ];

        System.assertEquals(acc.Id, em.RelatedToId, 'EmailMessage must be linked to new Account');
    }

    /**
     * -----------------------------------------------------------------------------
     * @description     Test EmailMessage trigger functionality.
     *                  Expected: trigger writes ThreadKey to Account after insert.
     * -----------------------------------------------------------------------------
     */
    @isTest
    static void testEmailMessageTriggerHandler() {
        // Create simple Account for trigger test
        Account acc = new Account(
            Name = 'Trigger Test',
            Email__c = 'owner@test.com'
        );
        insert acc;

        // Create EmailMessage to invoke before/after insert trigger
        EmailMessage em = new EmailMessage(
            Subject     = 'Trigger Test',
            FromAddress = 'x@test.com',
            Incoming    = true,
            Status      = '3',
            RelatedToId = acc.Id,
            TextBody    = 'Testing trigger'
        );

        Test.startTest();
        insert em;
        Test.stopTest();

        // Validate EmailThreadKey written by trigger
        acc = [
            SELECT Id, EmailThreadKey__c 
            FROM Account 
            WHERE Id = :acc.Id
            LIMIT 1
        ];

        System.assertNotEquals(
            null,
            acc.EmailThreadKey__c,
            'Trigger must populate EmailThreadKey on Account'
        );
    }
}