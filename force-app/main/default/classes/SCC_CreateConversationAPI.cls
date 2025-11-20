/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 20-03-2025
 * @last modified by  : Christian Vieri
**/
@RestResource(urlMapping='/Conversation/Create/*')
global without sharing class SCC_CreateConversationAPI {
    @HttpPost
    global static void CreateConversation() {
        String returnJson = '';
        String className = 'SCC_CreateConversationAPI'; // untuk log
        String url_endpoint = '/Conversation/Create/'; // untuk log
        Map<String, SCC_Custom_API_Response_Code__mdt> mapRc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = RestContext.response;
        SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();

        try {
            // Mengambil body request dari Postman dan mendeserialisasi ke model request
            String reqBody = requestApi?.requestBody?.toString();
            SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation customRequest = 
                (SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation) 
                JSON.deserialize(reqBody, SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation.class);
            
            // Ambil parameter chatbot dari request jika ada
            Map<String, Object> reqMap = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
            List<Object> chatbotList = reqMap.containsKey('chatbot') ? (List<Object>) reqMap.get('chatbot') : new List<Object>();

            // Convert array chatbot menjadi string dengan delimiter //
            String chatbotString = '';
            for (Object chatbotItem : chatbotList) {
                if (chatbotItem instanceof Map<String, Object>) {
                    Map<String, Object> chatbotMap = (Map<String, Object>) chatbotItem;
                    String sender = (String) chatbotMap.get('sender');
                    String messageText = (String) chatbotMap.get('messageText');
                    chatbotString += '"sender":"' + sender + '", "messageText":"' + messageText + '" // ';
                }
            }
            // Remove trailing " // " jika ada
            if (chatbotString.endsWith(' // ')) {
                chatbotString = chatbotString.substring(0, chatbotString.length() - 4);
            }

            System.debug('Chatbot String before send to controller: ' + chatbotString);

            // Melakukan callout ke endpoint conversation API
            returnJson = SCC_MessageInAppAndWeb_Ctrl.CreateConversationCallout(customRequest, chatbotString);

            // Logging jika sukses
            SCC_MessageInAppAndWeb_Ctrl.InsertErrorLog(null, requestApi, respondApi, returnJson, className, url_endpoint, 'Inbound');
        } catch (Exception e) {
            // Tangani exception dan buat custom error response
            String typeName = e.getTypeName().replace('System.', '');
            customResponse.responseMessage = e?.getMessage();

            if (mapRc.containsKey(typeName)) {
                customResponse.responseCode = mapRc.get(typeName).Response_Code__c;
            }

            returnJson = SCC_MessageInAppAndWeb_Ctrl.returnCustomAPI(customResponse);
            SCC_MessageInAppAndWeb_Ctrl.InsertErrorLog(null, requestApi, respondApi, returnJson, className, url_endpoint, 'Inbound');
        }

        // Mengatur response API
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(returnJson);
        RestContext.response.statusCode = 200;
    }
}