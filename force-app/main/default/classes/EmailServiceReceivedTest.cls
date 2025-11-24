@isTest
public class EmailServiceReceivedTest {

    // Utility: create Account with thread key
    private static Account createAccountWithThread() {
        Account acc = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com',
            EmailThreadKey__c = 'ABCDE12345ABCDE'
        );
        insert acc;
        return acc;
    }

    // Utility: create InboundEmail object
    private static Messaging.InboundEmail mockEmail(String body, String fromAddr) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Inbound';
        email.fromAddress = fromAddr;
        email.fromName = 'Sender Test';
        email.plainTextBody = body;
        email.htmlBody = '<p>' + body + '</p>';
        email.toAddresses = new String[] {'support@test.com'};
        email.ccAddresses = new String[] {'cc@test.com'};
        return email;
    }

    // Utility: mock envelope
    private static Messaging.InboundEnvelope mockEnv() {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'sender@test.com';
        return env;
    }

    @isTest
    static void testInboundEmail_WithThreadId() {
        // Create linked account
        Account acc = createAccountWithThread();

        // Email with ThreadID matching the account
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

        // Verify email message created
        EmailMessage em = [
            SELECT Id, Subject, FromAddress, ToAddress, TextBody, RelatedToId 
            FROM EmailMessage LIMIT 1
        ];

        System.assertEquals(acc.Id, em.RelatedToId, 'Email RelatedToId must match the Account');
        System.assert(em.TextBody.contains('ThreadID'), 'Text body must contain thread id');

        // Verify ContentVersion created
        List<ContentDocumentLink> cdls = [
            SELECT Id, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :em.Id
        ];
        System.assert(!cdls.isEmpty(), 'Attachment should be linked to EmailMessage');
    }


    @isTest
    static void testInboundEmail_NoThread_CreateAccount() {
        // Email without thread ID → should create new Account
        String body = 'Email without thread';
        Messaging.InboundEmail email = mockEmail(body, 'newuser@test.com');
        Messaging.InboundEnvelope env = mockEnv();

        Test.startTest();
        EmailServiceReceived handler = new EmailServiceReceived();
        Messaging.InboundEmailResult res = handler.handleInboundEmail(email, env);
        Test.stopTest();

        System.assert(res.success, 'Inbound must succeed');

        // Verify auto-created Account
        Account acc = [
            SELECT Id, Email__c 
            FROM Account 
            WHERE Email__c = 'newuser@test.com'
        ];

        System.assertNotEquals(null, acc, 'Account should be auto-created');

        // Verify EmailMessage linked
        EmailMessage em = [
            SELECT Id, RelatedToId 
            FROM EmailMessage 
            WHERE RelatedToId = :acc.Id
            LIMIT 1
        ];

        System.assertEquals(acc.Id, em.RelatedToId, 'Email should be linked to auto-created account');
    }


    @isTest
    static void testEmailMessageTriggerHandler() {
        // Create simple Account
        Account acc = new Account(
            Name = 'Trigger Test',
            Email__c = 'owner@test.com'
        );
        insert acc;

        // Insert email manually to trigger beforeInsert & afterInsert
        EmailMessage em = new EmailMessage(
            Subject = 'Trigger Test',
            FromAddress = 'x@test.com',
            Incoming = true,
            Status = '3',
            RelatedToId = acc.Id,
            TextBody = 'Testing trigger'
        );

        Test.startTest();
        insert em;
        Test.stopTest();

        // Check thread id updated on Account
        acc = [
            SELECT Id, EmailThreadKey__c 
            FROM Account 
            WHERE Id = :acc.Id
        ];

        System.assertNotEquals(null, acc.EmailThreadKey__c, 'Trigger should write Thread ID to Account');
    }
}