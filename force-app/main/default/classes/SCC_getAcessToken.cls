/**
 * @description       : REST API untuk mendapatkan access token dari endpoint eksternal
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 30-10-2024
**/
@RestResource(urlMapping='/getAccessToken/')
global with sharing class SCC_getAcessToken {

    // Method untuk menangani HTTP GET request untuk mengambil access token
    @HttpGet
    global static void GetAccessTokenAPI() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String accessToken = '';

        try {
            // Panggil method dari SCC_MessageInAppAndWeb_Ctrl untuk mendapatkan access token
            accessToken = SCC_MessageInAppAndWeb_Ctrl.GetAccessToken();

            // Set status HTTP 200 OK dan kembalikan token dalam JSON
            response.statusCode = 200;
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"access_token": "' + accessToken + '"}');
        } catch (Exception e) {
            // Jika terjadi kesalahan, set status HTTP 500 dan kembalikan pesan error
            response.statusCode = 500;
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
}