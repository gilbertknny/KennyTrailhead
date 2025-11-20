@isTest
public class CustomEmailService_Test {
    
    @isTest
    static void testHandleInboundEmailSuccess() {
        // Arrange: Create a mock email and envelope
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Test Case Subject';
        email.plainTextBody = 'This is a test email body.';
        email.htmlBody = '<p>This is a test email body.</p>';
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'test@example.com';
        
        // Act: Call the handleInboundEmail method
        CustomEmailService emailService = new CustomEmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, envelope);
        
        // Assert: Verify the Case was created
        List<Case> createdCases = [SELECT Subject, Description FROM Case WHERE Subject = :email.subject];
        System.assert(!createdCases.isEmpty(), 'A Case should have been created.');
        Case createdCase = createdCases[0];
        System.assertEquals(email.subject, createdCase.Subject, 'The Case Subject should match the email subject.');
        System.assertEquals(email.plainTextBody, createdCase.Description, 'The Case Description should match the email body.');
        
        // Assert: Verify the result
        System.assert(result.success, 'The result should indicate success.');
        System.assertEquals('Email berhasil diproses.', result.message, 'The success message should match.');
    }
    
    @isTest
    static void testHandleInboundEmailFailure() {
        // Arrange: Create a mock email and envelope with missing subject to cause an error
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'This is a test email body with no subject.'; // No subject provided
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = null;
        
        // Act: Call the handleInboundEmail method
        CustomEmailService emailService = new CustomEmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, envelope);
        
        // Assert: Verify the result indicates failure
        System.assert(!result.success, 'The result should indicate failure.');
        System.assert(result.message.startsWith('Terjadi kesalahan saat memproses email'),
                      'The failure message should indicate an error occurred.');
    }
}