/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 11-02-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_QANotificationService {
    
    @InvocableMethod(label='Send QA Notification' description='Send custom notification for QA Response')
    public static void sendNotification(List<NotificationRequest> requests) {
        System.debug('### START sendNotification ###');
        System.debug('Requests received: ' + requests);
        
        if(requests == null || requests.isEmpty()) {
            System.debug('No requests to process');
            return;
        }
        
        for(NotificationRequest req : requests) {
            System.debug('Processing request: ' + req);
            System.debug('Notification Body: ' + req.notificationBody);
            System.debug('Notification Title: ' + req.notificationTitle);
            System.debug('Recipient IDs: ' + req.recipientIds);
            System.debug('QA Response ID: ' + req.qaResponseId);
            
            sendNotificationFuture(
                req.notificationBody,
                req.notificationTitle,
                req.recipientIds,
                req.qaResponseId
            );
        }
        System.debug('### END sendNotification ###');
    }
    
    @future
    private static void sendNotificationFuture(
        String notificationBody,
        String notificationTitle,
        List<String> recipientIds,
        Id qaResponseId
    ) {
        System.debug('### START sendNotificationFuture ###');
        System.debug('Parameters received:');
        System.debug('- Notification Body: ' + notificationBody);
        System.debug('- Notification Title: ' + notificationTitle);
        System.debug('- Recipient IDs: ' + recipientIds);
        System.debug('- QA Response ID: ' + qaResponseId);
        
        try {
            // Get Custom Notification Type
            CustomNotificationType notificationType = [
                SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName = 'Fitur_QA_Notification'
                LIMIT 1
            ];
            System.debug('Found CustomNotificationType: ' + notificationType);
            
            // Get Process Definition
            List<ProcessDefinition> processDefinitions = [
                SELECT Id, DeveloperName
                FROM ProcessDefinition
                WHERE DeveloperName IN ('Approval_Penilaian_QA', 'Approval_Banding_QA')
            ];
            System.debug('Found ProcessDefinitions: ' + processDefinitions);
            
            Set<Id> processDefinitionIds = new Set<Id>();
            for(ProcessDefinition pd : processDefinitions) {
                processDefinitionIds.add(pd.Id);
            }
            System.debug('ProcessDefinition IDs: ' + processDefinitionIds);
            
            // Get Process Instance
            ProcessInstance processInstance = [
                SELECT Id 
                FROM ProcessInstance 
                WHERE ProcessDefinitionId IN :processDefinitionIds
                AND TargetObjectId = :qaResponseId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('Found ProcessInstance: ' + processInstance);
            
            // Get Approval Request
            ProcessInstanceWorkitem approvalRequest = [
                SELECT Id
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstanceId = :processInstance.Id
                LIMIT 1
            ];
            System.debug('Found ApprovalRequest: ' + approvalRequest);
            
            // Create notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            // Set notification content
            notification.setTitle(notificationTitle);
            notification.setBody(notificationBody);
            
            // Set target and recipient
            notification.setTargetId(approvalRequest.Id);
            notification.setNotificationTypeId(notificationType.Id);
            
            // Convert List to Set for send method
            Set<String> recipientSet = new Set<String>(recipientIds);
            System.debug('Recipient Set created: ' + recipientSet);
            
            // Send notification
            notification.send(recipientSet);
            System.debug('Notification sent successfully');
            
        } catch(Exception e) {
            System.debug('ERROR: Exception occurred while sending notification');
            System.debug('Error message: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        System.debug('### END sendNotificationFuture ###');
    }
    
    // Wrapper class for Flow input
    public class NotificationRequest {
        @InvocableVariable(required=true)
        public String notificationBody;
        
        @InvocableVariable(required=true)
        public String notificationTitle;
        
        @InvocableVariable(required=true)
        public List<String> recipientIds;
        
        @InvocableVariable(required=true)
        public Id qaResponseId;
    }
}