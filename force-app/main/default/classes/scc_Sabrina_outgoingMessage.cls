/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Christian Vieri
**/
public without sharing class scc_Sabrina_outgoingMessage {
    
    private static final String BASE_URL = 'http://api.close.dev.bri.co.id:5557/gateway/apiSabrina/1.0';
    private static final String CHANNEL_ID = 'e80d1ff66fb8c438d5n588ef9f66b98d'; 
    private static final String OWNER_ID = '82ab0fd5cfd1e80d1ff97c0cfc9aa9e2'; 
    private static final String MESSAGETYPE = 'text/media';

    public class APIResponse {
        public Boolean success;
        public String statusTicket;
    }

    public static APIResponse sendMessage(String ticketNumber, String message, String customerName, String mediaLink) {
        // Waktu saat ini dalam format yang sesuai (YYYY-MM-DDTHH:MM:SS.SSS)
        System.debug('===== Memulai sendMessage =====');
        System.debug('Ticket Number: ' + ticketNumber);
        System.debug('Message: ' + message);
        System.debug('Customer Name: ' + customerName);
        System.debug('Media Link: ' + mediaLink);
        String CREATEDATE = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'GMT'); 

        // Endpoint API
        String endpoint = BASE_URL + '/wbOutgoingMessage';

        // Membuat HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Membuat Payload JSON
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('ticketNumber', ticketNumber);
        payload.put('channel', CHANNEL_ID);
        payload.put('messageType', MESSAGETYPE);
        payload.put('message', message);
        payload.put('customerName', customerName);
        payload.put('createdDate', CREATEDATE);
        payload.put('owner', OWNER_ID);
        
        if (mediaLink != null && mediaLink != '') {
            payload.put('mediaLink', mediaLink);
        }

        // Konversi Map ke JSON String
        String jsonBody = JSON.serialize(payload);
        req.setBody(jsonBody);
        System.debug('===== Request Body =====');
        System.debug(jsonBody);

        // Inisialisasi response API
        APIResponse apiResponse = new APIResponse();
        RestResponse respondApi = new RestResponse();
        respondApi.statusCode = 500; // Default ke 500 jika error terjadi

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Parsing Response JSON
            apiResponse = (APIResponse) JSON.deserialize(res.getBody(), APIResponse.class);
            System.debug('===== Response Status =====');
            System.debug(res.getStatusCode());
            System.debug('===== Response Body =====');
            System.debug(res.getBody());

            // Update status response jika berhasil
            respondApi.statusCode = res.getStatusCode();
        } catch (Exception e) {
            System.debug('Error sending message: ' + e.getMessage());
        } finally {
            // Log ke InsertErrorLog, baik sukses atau gagal
            RestRequest requestApi = new RestRequest();
            requestApi.requestBody = Blob.valueOf(jsonBody);
            requestApi.remoteAddress = UserInfo.getSessionId(); // Simulasi IP
            
            scc_messageInAppAndWeb_Ctrl.InsertErrorLog(null, requestApi, respondApi, jsonBody, 'scc_Sabrina_outgoingMessage', endpoint);
        }

        return apiResponse;
    }
}