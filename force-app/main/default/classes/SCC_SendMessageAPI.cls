/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 07-02-2025
 * @last modified by  : Christian Vieri
**/

@RestResource(urlMapping='/Conversation/Send/*')
global with sharing class SCC_SendMessageAPI {

    @HttpPost
    global static void SendMessage() {
        String returnJson = '';
        String className = 'SCC_SendMessageAPI'; //untuk log
        String url_endpoint = '/Conversation/Send/'; //untuk log
        Map<String, SCC_Custom_API_Response_Code__mdt> mapRc = SCC_Custom_API_Response_Code__mdt.getAll();
        RestRequest requestApi = RestContext.request;
        RestResponse respondApi = RestContext.response;
        SCC_MessageInAppAndWeb_Wrapper.ResponseModel customResponse = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();

        try {
            // Ambil conversationId dari URL
            String conversationId = SCC_MessageInAppAndWeb_Ctrl.getConversationIdFromUrl(requestApi.requestURI);
            if (String.isBlank(conversationId)) {
                throw new CalloutException('Conversation ID is missing from the URL');
            }

            // Mengambil body request dari Postman dan mendeserialisasi ke model request
            String reqBody = requestApi?.requestBody?.toString();
            if (String.isBlank(reqBody)) {
                throw new CalloutException('Request body is empty');
            }

            SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage customRequest = (SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage) JSON.deserialize(reqBody, SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage.class);

            // Melakukan callout ke endpoint send message API dengan conversationId dari URL
            returnJson = SCC_MessageInAppAndWeb_Ctrl.SendMessage(customRequest, conversationId);

            // Logging jika sukses
            SCC_MessageInAppAndWeb_Ctrl.InsertErrorLog(null, requestApi, respondApi, returnJson, className, url_endpoint, 'Inbound');
        }
        catch (Exception e) {
            // Tangani exception dan buat custom error response
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

        // Mengatur response API
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(returnJson);
        RestContext.response.statusCode = 200;  // StatusCode untuk accepted
    }
}