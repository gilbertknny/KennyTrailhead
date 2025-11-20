/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 22-03-2025
 * @last modified by  : Christian Vieri
**/
public without sharing class scc_SabrinaMilestoneCtrl {

    @AuraEnabled
    public static String getCurrentUserId() {
        return UserInfo.getUserId();
    }

    // public static String getSession() {
    //     Brimo__c sabrinaSettings = Brimo__c.getInstance('Sabrina');
    //     system.debug('acess token: ' + sabrinaSettings.token__c);
    //     return sabrinaSettings.token__c;
    // }

    public static String getSession(String conversationIdentifier){
        MessagingSession ms = [Select Access_Token__c from MessagingSession where conversation.ConversationIdentifier =:conversationIdentifier];
        return ms.Access_Token__c;
    }

    public class APIResponse {
        public Boolean success;
        public String statusTicket;
    }

    // First three methods remain unchanged
    @AuraEnabled(cacheable=true)
    public static Integer getTargetFirstResponseTime(String recordId) {
        try {
            MessagingSession session = [SELECT Target_First_Response_Time__c FROM MessagingSession WHERE Id = :recordId LIMIT 1];
            if (session.Target_First_Response_Time__c != null) {
                return Integer.valueOf(session.Target_First_Response_Time__c); 
            }
            return 10; // Default to 10 minutes if null
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching target response time: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static MessagingSession getSessionDetails(String sessionId) {
        try {
            return [
                SELECT CreatedDate, Estimated_Finish_Time__c, Is_Timer_Stop__c, Waktu_Penyelesaian__c, First_Response_Time__c, Status, Conversation.ConversationIdentifier, MessagingEndUser.Name, OwnerId
                FROM MessagingSession
                WHERE Id = :sessionId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving session: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateTimerStatus(Id recordId, Boolean isStopped, String completionTime, Integer completedTime) {
        MessagingSession session = [SELECT Id, is_Timer_Stop__c, Waktu_Penyelesaian__c, First_Response_Time__c FROM MessagingSession WHERE Id = :recordId];
        session.is_Timer_Stop__c = isStopped;
        session.Waktu_Penyelesaian__c = completionTime;
        session.First_Response_Time__c = completedTime;
        update session;
    }

    private static final String CHANNEL_ID = 'e80d1ff66fb8c438d5n588ef9f66b98d'; 
    private static final String OWNER_ID = '82ab0fd5cfd1e80d1ff97c0cfc9aa9e2'; 
    private static final String MESSAGETYPE = 'text/media';

    @AuraEnabled
    public static APIResponse sendMessage(String ticketNumber, String message, String customerName, String mediaLink) {
        String CREATEDATE = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'GMT');
        
        Map<String, String> payload = new Map<String, String>{
            'ticketNumber' => ticketNumber,
            'channel' => CHANNEL_ID,
            'messageType' => MESSAGETYPE,
            'message' => message,
            'customerName' => customerName,
            'createdDate' => CREATEDATE,
            'owner' => OWNER_ID
        };
        
        if (String.isNotBlank(mediaLink)) {
            payload.put('mediaLink', mediaLink);
        }

        String jsonBody = JSON.serialize(payload);
        
        try {
            SCC_API.WrapperAPI response = SCC_API.getResponseAPI(
                'SabrinaOutgoingMessage',    // metaname
                jsonBody,                     // bodyreq
                null,                         // token
                'scc_SabrinaMilestoneCtrl.sendMessage'  // classname
            );
            
            if (response.res.getStatusCode() == 200) {
                return (APIResponse)JSON.deserialize(response.res.getBody(), APIResponse.class);
            } else {
                system.debug('HTTP Error: ' + response.res.getStatusCode() + ' ' + response.res.getStatus());
                throw new AuraHandledException('HTTP Error: ' + response.res.getStatusCode() + ' ' + response.res.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error sending message: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @future(callout=true)
    public static void closeMessageAsync(List<String> ticketNumbers) {
        for (String ticketNumber : ticketNumbers) {
            Map<String, String> payload = new Map<String, String>{
                'ticketNumber' => ticketNumber,
                'channelType' => 'whatsapp'
            };

            String jsonBody = JSON.serialize(payload);
            
            try {
                SCC_API.WrapperAPI response = SCC_API.getResponseAPI(
                    'SabrinaCloseSession',    // metaname
                    jsonBody,                  // bodyreq
                    null,                      // token
                    'scc_SabrinaMilestoneCtrl.closeMessage'  // classname
                );
                
                if (response.res.getStatusCode() != 200) {
                    System.debug('Error closing session: ' + response.res.getStatus());
                }
            } catch (Exception e) {
                System.debug('Error in closeMessageAsync: ' + e.getMessage());
            }
        }
    }

    @InvocableMethod
    public static void closeMessage(List<String> ticketNumbers) {
        closeMessageAsync(ticketNumbers);
    }

    @AuraEnabled
    public static String getConversationIdentifier(String sessionId) {
        MessagingSession session = [SELECT Conversation.ConversationIdentifier FROM MessagingSession WHERE Id = :sessionId LIMIT 1];
        return session.Conversation?.ConversationIdentifier;
    }

    @AuraEnabled
    public static List<Map<String, String>> fetchAgentMessages(String recordId, String startTimestamp) {
        System.debug('recordId: ' + recordId);
        String conversationIdentifier = getConversationIdentifier(recordId);
        System.debug('Conversation Identifier: ' + conversationIdentifier);
        try {
            String queryDirection = 'FromStart';
            Integer recordLimit = 100;
            
            System.debug('Polling with params - ConversationIdentifier: ' + conversationIdentifier + 
                         ', startTimestamp: ' + startTimestamp + 
                         ' (current GMT time), queryDirection: FromStart, recordLimit: 100');
            
            SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance('baseUrl');
            String baseUrl = eapi.Named_Credential__c;
            // Construct the API endpoint
            String apiEndpoint = baseUrl + '/iamessage/api/v2/conversation/' + conversationIdentifier + '/entries';
            
            // Prepare query parameters
            Map<String, String> queryParams = new Map<String, String>{
                // 'recordLimit' => String.valueOf(recordLimit),
                'direction' => queryDirection,
                'startTimestamp' => startTimestamp
            };
            
            HttpResponse response = makeGetCallout(apiEndpoint, queryParams, conversationIdentifier);
            
            // Process response to extract agent messages with their IDs
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                List<Map<String, String>> agentMessages = new List<Map<String, String>>();
                
                if (responseData.containsKey('conversationEntries')) {
                    List<Object> entries = (List<Object>)responseData.get('conversationEntries');
                    
                    for (Object entryObj : entries) {
                        Map<String, Object> entry = (Map<String, Object>)entryObj;
                        
                        // Check if this is a message entry
                        if (entry.containsKey('entryType') && entry.get('entryType') == 'Message') {
                            Map<String, Object> entryPayload = (Map<String, Object>)entry.get('entryPayload');
                            
                            if (entryPayload != null && entryPayload.containsKey('sender')) {
                                Map<String, Object> sender = (Map<String, Object>)entryPayload.get('sender');
                                
                                // Check if sender is an agent
                                if (sender.containsKey('role') && sender.get('role') == 'Agent') {
                                    // Extract the message text from abstractMessage -> staticContent -> text
                                    if (entryPayload.containsKey('abstractMessage')) {
                                        Map<String, Object> abstractMessage = (Map<String, Object>)entryPayload.get('abstractMessage');
                                        
                                        if (abstractMessage.containsKey('staticContent')) {
                                            Map<String, Object> staticContent = (Map<String, Object>)abstractMessage.get('staticContent');
                                            
                                            if (staticContent.containsKey('text') && staticContent.get('text') != null) {
                                                Map<String, String> messageInfo = new Map<String, String>();
                                                messageInfo.put('id', (String)entryPayload.get('id'));
                                                messageInfo.put('text', (String)staticContent.get('text'));
                                                
                                                // Add timestamp if needed
                                                if (entryPayload.containsKey('transcriptedTimestamp')) {
                                                    messageInfo.put('timestamp', String.valueOf(entryPayload.get('transcriptedTimestamp')));
                                                }
                                                
                                                agentMessages.add(messageInfo);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug('List of agent messages: ' + agentMessages);
                return agentMessages;
            } else {
                System.debug('API Error: ' + response.getStatusCode() + ' ' + response.getBody());
                throw new AuraHandledException('API Error: ' + response.getStatus() + ' ' + response.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Error fetching agent messages: ' + e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException('Error fetching agent messages: ' + e.getMessage());
        }
    }
    
    private static HttpResponse makeGetCallout(String endpoint, Map<String, String> queryParams, String conversationIdentifier) {
        String queryString = '';
        if (queryParams != null && !queryParams.isEmpty()) {
            List<String> params = new List<String>();
            for (String key : queryParams.keySet()) {
                params.add(key + '=' + EncodingUtil.urlEncode(queryParams.get(key), 'UTF-8'));
            }
            queryString = '?' + String.join(params, '&');
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint + queryString);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        String sessionId = getSession(conversationIdentifier);
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        system.debug('userInfo.getSessionId: ' + sessionId);

        
        req.setTimeout(20000);
        
        Http http = new Http();
        return http.send(req);
    }
}