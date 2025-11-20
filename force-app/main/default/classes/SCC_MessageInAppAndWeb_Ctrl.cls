/**
 * @description       : Class untuk menangani token dan API callouts
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 07-03-2025
**/
public with sharing class SCC_MessageInAppAndWeb_Ctrl {

    //get session
    public static String getSession(){
        return userInfo.getSessionId();
    }

    // Metode untuk mendapatkan access token
    public static String GetAccessToken() {
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();

        String tokenUrl = getFullEndpointUrl('Sabrina_Get_Acess_Token');
        httpRequest.setEndpoint(tokenUrl);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');

        String orgIdValue = System.Label.Sabrina_OrgId;

        Map<String, Object> requestBody = new Map<String, Object>{
            'orgId' => orgIdValue,
            'esDeveloperName' => 'Sabrina',
            'capabilitiesVersion' => '1',
            'platform' => 'Web',
            'context' => new Map<String, Object>{
                'appName' => 'salesApp',
                'clientVersion' => '1.2.3'
            }
        };

        httpRequest.setBody(JSON.serialize(requestBody));

        try {
            HttpResponse response = http.send(httpRequest);
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String accessToken = (String) responseJson.get('accessToken');
                
                return accessToken;
            } else {
                throw new CalloutException('Failed to obtain access token. Status: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            throw new CalloutException(e.getMessage());
        }
    }

    public static String getConversationIdFromUrl(String requestUri) {
        List<String> urlParts = requestUri.split('/');
        if (urlParts.size() > 0) {
            return urlParts[urlParts.size() - 1];  
        }
        return null;
    }

    //Method untuk Create Conversation
    public static String CreateConversationCallout(SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation request, String chatbotConversation) {
        if (request.routingAttributes != null && request.routingAttributes.containsKey('phone')) {
            String phone = request.routingAttributes.get('phone');
            if (String.isNotBlank(phone) && phone.startsWith('62')) {
                request.routingAttributes.put('phone', '0' + phone.substring(2));
            }
        }
    
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        
        String endpointUrl = getFullEndpointUrl('Sabrina_Create_Conversation');
        httpRequest.setEndpoint(endpointUrl);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
    
        String accessToken = GetAccessToken();
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
    
        String requestBody = JSON.serialize(request);
        httpRequest.setBody(requestBody);
    
        try {
            HttpResponse httpResponse = http.send(httpRequest);
    
            if (httpResponse.getStatusCode() == 201) {
                SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
                customResponse.responseCode = '00';  
                customResponse.responseMessage = 'Conversation created successfully with ID: ' + request.conversationId;
                customResponse.conversationId = request.conversationId;
                    
                UpdateAccessToken(accessToken, request.conversationId);
                updateChatbotConv(chatbotConversation, request.conversationId);
                return JSON.serialize(customResponse);
            } else {
                throw new CalloutException('Failed to create conversation. Status: ' + httpResponse.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error during CreateConversationCallout: ' + e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }

    // Metode untuk SendMessage
    public static String SendMessage(SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage request, String conversationId) {
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();

        String domainUrl = getFullEndpointUrl('Sabrina_Send_Message');
        String endpointUrl = domainUrl + conversationId + '/message';
        httpRequest.setEndpoint(endpointUrl);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');

        String accessToken = getATfromMessagingSession(conversationId);
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);

        String requestBody = JSON.serialize(request);
        httpRequest.setBody(requestBody);

        try {
            HttpResponse httpResponse = http.send(httpRequest);

            if (httpResponse.getStatusCode() == 202) {
                SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
                customResponse.responseCode = '00';  
                customResponse.responseMessage = 'Message sent successfully';
                customResponse.conversationId = conversationId;

                Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                List<Object> conversationEntriesList = (List<Object>) responseJson.get('conversationEntries');

                if (conversationEntriesList != null && conversationEntriesList.size() > 0) {
                    customResponse.conversationEntries = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
                    for (Object entry : conversationEntriesList) {
                        Map<String, Object> entryMap = (Map<String, Object>) entry;
                        SCC_MessageInAppAndWeb_Wrapper.ConversationEntry conversationEntry = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
                        conversationEntry.id = (String) entryMap.get('id');
                        conversationEntry.clientTimestamp = (Long) entryMap.get('clientTimestamp');
                        customResponse.conversationEntries.add(conversationEntry);
                    }
                }

                return JSON.serialize(customResponse);
            } else {
                throw new CalloutException('Failed to send message. Status: ' + httpResponse.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error during SendMessage Callout: ' + e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }

    // Metode untuk sendFile 
    public static String SendFile(String conversationId, SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile request, Blob fileData, String fileName) {
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
    
        String domainUrl = getFullEndpointUrl('Sabrina_Send_File');
        String endpointUrl = domainUrl + conversationId + '/file';
        httpRequest.setEndpoint(endpointUrl);
        httpRequest.setMethod('POST');
        
        String accessToken = getATfromMessagingSession(conversationId);
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
        httpRequest.setHeader('Content-Type', SCC_ITSMWebserviceHelper.GetContentType());
    
        String jsonBody = JSON.serialize(request);
        Blob jsonBodyBlob = blob.valueOf(jsonBody);    
        String body = '';
    
        SCC_ITSMWebserviceHelper.WriteFileResult jsonRequest = SCC_ITSMWebserviceHelper.WriteFile('messageEntry', '', 'application/json', jsonBodyBlob);
        SCC_ITSMWebserviceHelper.WriteFileResult jsonFileData = SCC_ITSMWebserviceHelper.WriteFile('fileData', fileName , 'application/octet-stream', fileData);
    
        body += SCC_ITSMWebserviceHelper.WriteBoundary();
        body += jsonRequest.Content;
        body += SCC_ITSMWebserviceHelper.WriteBoundary();
        body += jsonFileData.Content;
        body += SCC_ITSMWebserviceHelper.WriteBoundary(jsonFileData.EndingType);
    
        Blob jsonBlob = EncodingUtil.Base64Decode(body);

        httpRequest.setBodyAsBlob(jsonBlob);
    
        system.debug('req: '+ httpRequest.getBody());
    
        try {
            HttpResponse httpResponse = http.send(httpRequest);
    
            if (httpResponse.getStatusCode() == 202) {
                SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
                customResponse.responseCode = '00';
                customResponse.responseMessage = 'File sent successfully';
                customResponse.conversationId = conversationId;
    
                Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                List<Object> conversationEntriesList = (List<Object>) responseJson.get('conversationEntries');
    
                if (conversationEntriesList != null && conversationEntriesList.size() > 0) {
                    customResponse.conversationEntries = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>();
                    for (Object entry : conversationEntriesList) {
                        Map<String, Object> entryMap = (Map<String, Object>) entry;
                        SCC_MessageInAppAndWeb_Wrapper.ConversationEntry conversationEntry = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry();
                        conversationEntry.id = (String) entryMap.get('id');
                        conversationEntry.clientTimestamp = (Long) entryMap.get('clientTimestamp');
                        customResponse.conversationEntries.add(conversationEntry);
                    }
                }
                return JSON.serialize(customResponse);
            } else {
                throw new CalloutException('Failed to send file. Status: ' + httpResponse.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error during SendFile Callout: ' + e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }
    
    //method untuk get message conversation
    public static String GetMessage(String conversationId) {
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
    
        String BaseUrl = getFullEndpointUrl('Sabrina_Get_Conversation_Entries');
        String endpointUrl = BaseUrl + conversationId + '/entries?recordLimit=1000&queryDirection=FromStart';
        httpRequest.setEndpoint(endpointUrl);
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Content-Type', 'application/json');
    
        String session = getSession();
        httpRequest.setHeader('Authorization', 'Bearer ' + session);
    
        try {
            HttpResponse httpResponse = http.send(httpRequest);
    
            if (httpResponse.getStatusCode() == 200) { 
                SCC_MessageInAppAndWeb_Wrapper.ResponseModelGM customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModelGM();
                customResponse.responseCode = '00';
                customResponse.responseMessage = 'Success Get Message with this conversation Id: ' + conversationId;
                customResponse.conversationId = conversationId;
                
                Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                List<Object> conversationEntriesList = (List<Object>) responseJson.get('conversationEntries');
    
                if (conversationEntriesList != null && conversationEntriesList.size() > 0) {
                    customResponse.conversationEntries = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM>();
                    for (Object entry : conversationEntriesList) {
                        Map<String, Object> entryMap = (Map<String, Object>) entry;
    
                        SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM conversationEntry = new SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM();
                        conversationEntry.clientDuration = (Integer) entryMap.get('clientDuration');
                        conversationEntry.clientTimestamp = (Long) entryMap.get('clientTimestamp');
                        conversationEntry.identifier = (String) entryMap.get('identifier');
                        conversationEntry.messageText = (String) entryMap.get('messageText');
    
                        Map<String, Object> senderMap = (Map<String, Object>) entryMap.get('sender');
                        if (senderMap != null) {
                            SCC_MessageInAppAndWeb_Wrapper.Sender sender = new SCC_MessageInAppAndWeb_Wrapper.Sender();
                            sender.appType = (String) senderMap.get('appType');
                            sender.role = (String) senderMap.get('role');
                            sender.subject = (String) senderMap.get('subject');
                            conversationEntry.sender = sender;
                        }
    
                        conversationEntry.serverReceivedTimestamp = (Long) entryMap.get('serverReceivedTimestamp');
                        
                        customResponse.conversationEntries.add(conversationEntry);
                    }
                }
                String serializedResponse = JSON.serializePretty(customResponse);

                return serializedResponse;
            } else {
                throw new CalloutException('Failed to get conversation entries. Status: ' + httpResponse.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error during GetMessage callout: ' + e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }
             
    //method untuk close Conversation 
    public static String closeConversation(String conversationId){
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        
        String domainUrl = getFullEndpointUrl('Sabrina_Close_Conversation');
        String endpointUrl = domainUrl + conversationId + '?esDeveloperName=Sabrina';
        httpRequest.setEndpoint(endpointUrl);
        httpRequest.setMethod('DELETE');
        httpRequest.setHeader('Content-Type', 'application/json');

        String accessToken = getATfromMessagingSession(conversationId);
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);

        try {
            // Melakukan callout
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 204) {
                SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
                customResponse.responseCode = '00';  
                customResponse.responseMessage = 'This Conversation has been closed';
                customResponse.conversationId = conversationId;
                
                return JSON.serialize(customResponse);
            } else {
                throw new CalloutException('Failed to Close conversation. Status: ' + httpResponse.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error during Close Conversation: ' + e.getMessage());
            throw new CalloutException(e.getMessage());
        }
    }

    // Method untuk memperbarui access token di field access_token pada objek Messaging_Session
    public static void UpdateAccessToken(String accessToken, String conversationId) {
        try {
            Conversation conversationRecord = [SELECT Id FROM Conversation WHERE ConversationIdentifier = :conversationId LIMIT 1];
            
            if (conversationRecord != null) {
                MessagingSession sessionRecord = [SELECT Id, access_token__c FROM MessagingSession WHERE ConversationId = :conversationRecord.Id LIMIT 1];
                sessionRecord.access_token__c = accessToken;
                update sessionRecord;
            } else {
                throw new QueryException('No Conversation record found for the given ConversationIdentifier.');
            }
        } catch (Exception e) {
            System.debug('Error updating access token in Messaging Session: ' + e.getMessage());
            throw new DmlException('Failed to update access token: ' + e.getMessage());
        }
    }

    //Method untuk menambahkan chatbot conversation ke dalam field chatbot_Conversation__c di Messaging Session
    public static void updateChatbotConv(String chat, String conversationId){
        try {
            Conversation conversationRecord = [SELECT Id FROM Conversation WHERE ConversationIdentifier = :conversationId LIMIT 1];
            if (conversationRecord != null) {
                MessagingSession sessionRecord = [SELECT Id, Chatbot_Conversation__c FROM MessagingSession WHERE ConversationId = :conversationRecord.Id LIMIT 1];

                sessionRecord.Chatbot_Conversation__c = chat;
                update sessionRecord;
            } else {
                throw new QueryException('No Conversation record found for the given ConversationIdentifier.');
            }
        } catch (Exception e) {
            System.debug('Error updating access token in Messaging Session: ' + e.getMessage());
            throw new DmlException('Failed to update access token: ' + e.getMessage());
        }
    }

    // Method untuk get Access TOken bedasarkan conversationId
    public static String getATfromMessagingSession (String conversationId) {
        try {
            Conversation conversationRecord = [SELECT Id FROM Conversation WHERE ConversationIdentifier = :conversationId LIMIT 1];
            system.debug('conversationRecord: ' + conversationRecord);
            if (conversationRecord != null) {
                MessagingSession sessionRecord = [SELECT Id, access_token__c FROM MessagingSession WHERE ConversationId = :conversationRecord.Id LIMIT 1];
                String AT = sessionRecord.access_token__c;
                system.debug('acess toket: '+ AT);

                return AT;
            } else {
                throw new QueryException('No Acess Token found for the given ConversationIdentifier.');
            }
        } catch (Exception e){
            System.debug('Error get access token from Messagin Session: ' + e.getMessage());
            throw new DmlException('Failed to get access token: ' + e.getMessage());
        }
    }

    public static String returnCustomAPI(SCC_MessageInAppAndWeb_Wrapper.ResponseModel response) {
        return JSON.serialize(response);
    }

    //function untuk get endpoint dari custom Metadata
    public static String getFullEndpointUrl(String metadataName) {
        SCC_Endpoint_API__mdt urlMdt = SCC_Endpoint_API__mdt.getInstance(metadataName);
        String domain = urlMdt.Named_Credential__c;
        String directoryUrl = urlMdt.Directory__c;
        String fullUrl = domain + directoryUrl;
        
        return fullUrl;
    }

    // public static Boolean checkActiveMessagingSession(String phoneNumber) {
    //     if (String.isBlank(phoneNumber)) {
    //         return false;
    //     }
        
    //     List<MessagingSession> activeSessions = [
    //         SELECT Id, Status, CreatedDate, EndTime 
    //         FROM MessagingSession 
    //         WHERE MessagingEndUser.Phone__c = :phoneNumber 
    //         AND Status = 'Active'
    //         ORDER BY CreatedDate DESC
    //         LIMIT 1
    //     ];
    //     system.debug('activeSession: ' + activeSessions.size() + 'ActiveSessionsny: ' + activeSessions.isempty());
        
    //     // Kembalikan true jika ditemukan minimal 1 session aktif
    //     return !activeSessions.isEmpty();
    // }

    // Method untuk Insert Error Log 
    public static void InsertErrorLog(Exception e, RestRequest requestApi, RestResponse respondApi, String returnJson, String className, String url_endpoint, String typeAPI) {
        ErrorLogRecord.DebugLog log = new ErrorLogRecord.DebugLog();
        log.message = e?.getMessage();
        log.trace = e?.getStackTraceString();
        log.typename = e?.getTypeName();
        log.linenumber = String.valueOf(e?.getLineNumber());
        log.errorcause = String.valueOf(e?.getCause());
        log.classname = className;
        log.header = String.valueOf(requestApi?.headers);
        log.body = requestApi?.requestBody?.toString();
        log.iprequest = requestApi?.remoteAddress;
        log.statusCode = respondApi?.statusCode;
        log.responseBody = returnJson;
        log.urlEndpoint = url_endpoint;
        log.typeApi = typeAPI;
        log.iduser = UserInfo.getUserId();
        ErrorLogRecord.insertErrorAPI(JSON.serialize(log));
    }

}