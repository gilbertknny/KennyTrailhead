/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 07-02-2025
 * @last modified by  : Christian Vieri
**/
@RestResource(urlMapping='/Conversation/SendFile/*')
global with sharing class SCC_SendFileAPI {

    @HttpPost
    global static void SendFile() {
        String returnJson = '';
        String className = 'SCC_SendFileAPI'; //untuk log
        String url_endpoint = '/Conversation/SendFile/'; //untuk log
        Map<String, SCC_Custom_API_Response_Code__mdt> mapRc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        system.debug('requestAPI: ' + requestApi.requestBody.toString());
        RestResponse respondApi = RestContext.response;
        SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();

        try {
            // Get conversationId from URL
            String conversationId = SCC_MessageInAppAndWeb_Ctrl.getConversationIdFromUrl(requestApi.requestURI);
            if (String.isBlank(conversationId)) {
                throw new CalloutException('Conversation ID is missing from the URL');
            }

            // Retrieve and deserialize the request body
            String reqBody = requestApi?.requestBody?.toString();
            if (String.isBlank(reqBody)) {
                throw new CalloutException('Request body is empty');
            }

            // Parse request data into a map
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(reqBody);

            // Extract necessary fields from request body
            String esDeveloperName = (String) requestBody.get('esDeveloperName');
            String fileName = (String) requestBody.get('fileName');
            String messageId = (String) requestBody.get('messageId');
            String fileId = (String) requestBody.get('fileId');
            String text = (String) requestBody.get('text');
            String inReplyToMessageId = (String) requestBody.get('inReplyToMessageId');
            String firstName = (String) requestBody.get('firstName');
            Boolean isNewMessagingSession = (Boolean) requestBody.get('isNewMessagingSession');
            String language = (String) requestBody.get('language');

            // Decode the base64 encoded file data
            // String fileData = (String) requestBody.get('fileData');
            Blob fileData = EncodingUtil.base64Decode((String) requestBody.get('fileData'));
            system.debug('file Data: ' + fileData);

            // Set up routing attributes
            Map<String, String> routingAttributes = new Map<String, String>();
            routingAttributes.put('_firstName', firstName);

            // Create a Message object
            SCC_MessageInAppAndWeb_Wrapper.MessageForSendFile message = new SCC_MessageInAppAndWeb_Wrapper.MessageForSendFile();
            message.id = messageId;
            message.fileId = fileId;
            message.inReplyToMessageId = inReplyToMessageId;
            message.text = text; 

            // Create the request model for SendFile
            SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile sendFileRequest = new SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile(
                esDeveloperName,
                message,
                // routingAttributes,
                isNewMessagingSession,
                language
            );

            system.debug('ini sendFile Request Body: ' + sendFileRequest);

            // Call the SendFile method
            returnJson = SCC_MessageInAppAndWeb_Ctrl.SendFile(conversationId, sendFileRequest, fileData, fileName);

            // Log success if there is no error
            SCC_MessageInAppAndWeb_Ctrl.InsertErrorLog(null, requestApi, respondApi, returnJson, className, url_endpoint, 'Inbound');
        }
        catch (Exception e) {
            // Handle exceptions and create a custom error response
            String typeName = e.getTypeName().replace('System.', '');
            customResponse.responseMessage = e?.getMessage();

            if (mapRc.containsKey(typeName)) {
                customResponse.responseCode = mapRc.get(typeName).Response_Code__c;
            } else {
                for (SCC_Custom_API_Response_Code__mdt rc : mapRc.values()) {
                    if (customResponse.responseMessage.contains(rc.MasterLabel)) {
                        customResponse.responseCode = rc.Response_Code__c;
                        break;
                    }
                }
            }

            if (String.isBlank(customResponse.responseCode)) {
                customResponse.responseCode = mapRc?.get('General_Error')?.Response_Code__c;
            }
            returnJson = SCC_MessageInAppAndWeb_Ctrl.returnCustomAPI(customResponse);
            SCC_MessageInAppAndWeb_Ctrl.InsertErrorLog(null, requestApi, respondApi, returnJson, className, url_endpoint, 'Inbound');
        }

        // Set the API response
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(returnJson);
        RestContext.response.statusCode = 200;  // Status code for accepted request
    }
}