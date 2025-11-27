/**
 * @description     Email Service handler for processing inbound emails.
 *                  This class extracts ThreadID, finds related records,
 *                  creates EmailMessage, saves attachments as ContentVersion,
 *                  and logs processing results or errors.
 *
 * @author          Peppp
 * @Date     
 */
global class EmailServiceReceived implements Messaging.InboundEmailHandler {

    /**
     * @description Main entry point for Inbound Email Service.
     *              Handles thread extraction, record resolution, EmailMessage creation,
     *              attachment processing, and error logging.
     */
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email,
        Messaging.InboundEnvelope env
    ) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            // Extract thread identifier from email body
            String threadId = extractThreadId(email.plainTextBody);

            // Identify or create related record based on threadId or email
            Id relatedRecordId = findRelatedRecord(threadId, email);

            // Create EmailMessage record
            EmailMessage em = new EmailMessage();
            em.Subject        = email.subject;
            em.FromAddress    = email.fromAddress;
            em.ToAddress      = (email.toAddresses != null) ? String.join(email.toAddresses, ';') : null;
            em.CcAddress      = (email.ccAddresses != null) ? String.join(email.ccAddresses, ';') : null;
            em.TextBody       = email.plainTextBody;
            em.HtmlBody       = email.htmlBody;
            em.Incoming       = true;
            em.Status         = '3'; 
            em.RelatedToId    = relatedRecordId;
            insert em;

            // Process binary or text attachments
            handleAttachments(email, relatedRecordId, em);

            result.success = true;

            // Log successful processing event
            insertErrorLog(null, email, em);

        } catch (Exception e) {
            result.success = false;

            // Log error event
            insertErrorLog(e, email, null);
        }

        return result;
    }

    /**
     * @description Attempts to find related record using ThreadID,
     *              falling back to searching by email address,
     *              and creates Account if no match is found.
     */
    private Id findRelatedRecord(String threadId, Messaging.InboundEmail email) {
        Id relatedRecordId;

        // Match using ThreadID on Account, InsurancePolicy, Opportunity
        if (threadId != null) {
            List<Account> accByThread = [
                SELECT Id FROM Account WHERE EmailThreadKey__c = :threadId LIMIT 1
            ];
            if (!accByThread.isEmpty()) {
                relatedRecordId = accByThread[0].Id;
            }

            if (relatedRecordId == null) {
                List<InsurancePolicy> polByThread = [
                    SELECT Id FROM InsurancePolicy WHERE EmailThreadKey__c = :threadId LIMIT 1
                ];
                if (!polByThread.isEmpty()) {
                    relatedRecordId = polByThread[0].Id;
                }
            }

            if (relatedRecordId == null) {
                List<Opportunity> oppByThread = [
                    SELECT Id FROM Opportunity WHERE EmailThreadKey__c = :threadId LIMIT 1
                ];
                if (!oppByThread.isEmpty()) {
                    relatedRecordId = oppByThread[0].Id;
                }
            }
        }

        // Fallback: Match by email address
        if (relatedRecordId == null) {
            List<Account> accByEmail = [
                SELECT Id FROM Account
                WHERE Email__c = :email.fromAddress OR PersonEmail = :email.fromAddress
                LIMIT 1
            ];
            if (!accByEmail.isEmpty()) {
                relatedRecordId = accByEmail[0].Id;
            }
        }

        if (relatedRecordId == null) {
            List<InsurancePolicy> polByEmail = [
                SELECT Id FROM InsurancePolicy WHERE Email__c = :email.fromAddress LIMIT 1
            ];
            if (!polByEmail.isEmpty()) {
                relatedRecordId = polByEmail[0].Id;
            }
        }

        if (relatedRecordId == null) {
            List<Opportunity> optyByEmail = [
                SELECT Id FROM Opportunity WHERE Email__c = :email.fromAddress LIMIT 1
            ];
            if (!optyByEmail.isEmpty()) {
                relatedRecordId = optyByEmail[0].Id;
            }
        }

        // If still not found, create Account
        if (relatedRecordId == null) {
            Account newAcc = new Account();
            newAcc.Name     = (email.fromName != null) ? email.fromName : email.fromAddress;
            newAcc.Email__c = email.fromAddress;
            insert newAcc;
            relatedRecordId = newAcc.Id;
        }

        return relatedRecordId;
    }

    /**
     * @description Saves attachments to ContentVersion and links them
     *              to the EmailMessage using ContentDocumentLink.
     */
    private void handleAttachments(
        Messaging.InboundEmail email,
        Id relatedRecordId,
        EmailMessage em
    ) {
        List<ContentVersion> cvsToInsert = new List<ContentVersion>();

        // Handle binary attachments
        if (email.binaryAttachments != null && !email.binaryAttachments.isEmpty()) {
            for (Messaging.Inboundemail.BinaryAttachment bAtt : email.binaryAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.Title = (bAtt.fileName != null) ? bAtt.fileName.left(80) : 'Attachment';
                cv.PathOnClient = '/' + ((bAtt.fileName != null) ? bAtt.fileName : 'Attachment');
                cv.VersionData = bAtt.body;
                cv.FirstPublishLocationId = relatedRecordId;
                cvsToInsert.add(cv);
            }
        }

        // Handle text attachments
        if (email.textAttachments != null && !email.textAttachments.isEmpty()) {
            for (Messaging.Inboundemail.TextAttachment tAtt : email.textAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.Title = (tAtt.fileName != null) ? tAtt.fileName.left(80) : 'Attachment.txt';
                cv.PathOnClient = '/' + ((tAtt.fileName != null) ? tAtt.fileName : 'Attachment.txt');
                cv.VersionData = Blob.valueOf(tAtt.body);
                cv.FirstPublishLocationId = relatedRecordId;
                cvsToInsert.add(cv);
            }
        }

        if (!cvsToInsert.isEmpty()) {
            try {
                insert cvsToInsert;

                // Map ContentVersion to ContentDocument
                Map<Id, Id> versionToDocMap = new Map<Id, Id>();
                for (ContentVersion cv : [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id IN :cvsToInsert
                ]) {
                    versionToDocMap.put(cv.Id, cv.ContentDocumentId);
                }

                // Create CDL linking document to email message
                List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
                for (Id docId : versionToDocMap.values()) {
                    ContentDocumentLink cdlEmail = new ContentDocumentLink();
                    cdlEmail.ContentDocumentId = docId;
                    cdlEmail.LinkedEntityId = em.Id;
                    cdlEmail.ShareType = 'V';
                    cdlEmail.Visibility = 'AllUsers';
                    cdls.add(cdlEmail);
                }

                if (!cdls.isEmpty()) {
                    insert cdls;
                }

            } catch (Exception ex) {
                insertErrorLog(ex, email, em);
            }
        }
    }

    /**
     * @description Extracts ThreadID value from email body using regex.
     */
    private String extractThreadId(String body) {
        if (body == null) {
            return null;
        }
        Pattern p = Pattern.compile('\\[ThreadID:([a-zA-Z0-9]{15})\\]');
        Matcher m = p.matcher(body);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    /**
     * @description Wrapper for structured error logging through APILog.
     *              Creates dummy request/response for uniform logging format.
     */
    private static void insertErrorLog(
        Exception e,
        Messaging.InboundEmail email,
        EmailMessage em
    ) {
        APILog.WrapperError we = new APILog.WrapperError('InboundEmail','EmailServiceReceived');
        we.typeApi    = 'Inbound';
        we.clsName    = 'EmailServiceReceived';
        we.inEndpoint = 'InboundEmailHandler';

        // Request body for logging
        Map<String,Object> reqMap = new Map<String,Object>();
        reqMap.put('from', email.fromAddress);
        reqMap.put('subject', email.subject);
        reqMap.put('to', email.toAddresses);
        reqMap.put('cc', email.ccAddresses);
        reqMap.put('body', email.plainTextBody);
        String reqBody = JSON.serialize(reqMap);

        RestRequest dummyReq = new RestRequest();
        dummyReq.httpMethod = 'POST';
        dummyReq.addHeader('Content-Type','application/json');
        dummyReq.requestBody = Blob.valueOf(reqBody);
        dummyReq.requestURI = 'InboundEmailHandler';

        // Response simulation
        RestResponse dummyRes = new RestResponse();
        if (em != null) {
            dummyRes.statusCode = 200;
            dummyRes.responseBody = Blob.valueOf('EmailMessage Id=' + em.Id);
        } else {
            dummyRes.statusCode = 500;
            dummyRes.responseBody = Blob.valueOf('Failed processing inbound email');
        }

        we.requestApi = dummyReq;
        we.respondApi = dummyRes;

        APILog.insertErrorLog(
            e,
            we,
            (dummyRes.responseBody != null) ? dummyRes.responseBody.toString() : null
        );
    }
}