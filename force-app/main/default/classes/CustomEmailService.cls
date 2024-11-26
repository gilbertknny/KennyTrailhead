global class CustomEmailService implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                                                           Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try {
            // Process the incoming email here
            String subject = email.subject;
            String plainTextBody = email.plainTextBody;
            String htmlBody = email.htmlBody;
            String fromAddress = envelope.fromAddress;
            
            Case c = new Case();
            c.Subject = subject;
            c.Description = plainTextBody;
            insert c;
            
            // Example processing: Log the email details
            System.debug('Received email with subject: ' + subject);
            System.debug('From: ' + fromAddress);
            System.debug('Plain Text Body: ' + plainTextBody);
            System.debug('HTML Body: ' + htmlBody);
            
            // You can add your custom processing logic here
            
            // Set success flag and message
            result.success = true;
            result.message = 'Email berhasil diproses.'; //'Email processed successfully.'
        } catch(Exception e) {
            // If an error occurs during processing, set the success flag to false and log the error message
            result.success = false;
            result.message = 'Terjadi kesalahan saat memproses email: ' + e.getMessage(); //'An error occurred while processing the email: '
            System.debug(result.message);
        }
        return result;
    }
}