/** @description
 * Class: SCC_BriLinkCallout
 * Utility class for making callouts to BRILINK APIs.
 * Author: Prateek Khanna
 * Created Date: 2024-05-30
 */
public without sharing class SCC_BriLinkCallout {
     
    /**
     * @description
     * Method: makeCallout
     * Performs a callout to BRILINK API to retrieve profile data
     * based on either TID (Terminal ID) or MID (Merchant ID).
     * @param tid Terminal ID used to query BRILINK profile.
     * @param mid Merchant ID used to query BRILINK profile.
     * @return String representation of BRILINK profile data.
     */
    @AuraEnabled
    
    public static SCC_BriLinkWrapper makeCallout(String tid, String mid) {
      /*  String a='{"BRILINK_PROFILE":[{"TID":"26022362","jenis_jaringan":null,"alamat_agen":"MATAERE,  KEL TOLO KEC KELARA KAB JENEPONTO","jenis_usaha":"999","kode_agen":"10109690","kode_channel":"10109690","kode_merchant":"11061324","kode_uker_pengelola":"4924","limit_transaksi":"100000000","mid":"000001370021","modifikasi_oleh":"mks_signer","nama_agen":"FADILLAH MOTOR","nama_ibu_kandung":null,"nama_lengkap":"FADILLAH MOTOR","nama_merchant":"FADILLAH MOTOR","nomor_kartu_debit":"5221845037178803","nomor_kontak_pab":null,"nomor_ktp":"7304050804780001","nomor_rekening":"492401004559538","nomor_rekening_pelimpahan":"492401004559538","nomor_rekening_pinjaman":"","nomor_siup":"IUMK/019-KELARA/VII/2018","pic_uker":"00143945","region_office_pengelola":"P","sharing_fee":"50.00","status":"1","tanggal_dibuat":"2021-01-27 16:05:34","tanggal_lahir":null,"tanggal_modifikasi":"2021-10-18 15:34:34","telepon":null},{"TID":"26022362","jenis_jaringan":null,"alamat_agen":"MATAERE,  KEL TOLO KEC KELARA KAB JENEPONTO","jenis_usaha":"999","kode_agen":"10109690","kode_channel":"10109690","kode_merchant":"11032289","kode_uker_pengelola":"4924","limit_transaksi":"100000000","mid":"000001370021","modifikasi_oleh":"mks_signer","nama_agen":"FADILLAH MOTOR","nama_ibu_kandung":null,"nama_lengkap":"FADILLAH MOTOR","nomor_rekening_pinjaman":"","nomor_siup":"IUMK/019-KELARA/VII/2018","pic_uker":"00143945"}]}';
        SCC_BriLinkWrapper parsedData = SCC_BriLinkWrapper.parse(a);
        system.debug(parsedData.BRILINK_PROFILE);
        return parseddata;*/
        // Construct the endpoint URL and request body based on the type and value
        String endpoint = '';
        String requestBody = '';
        SCC_BriLinkWrapper EWrap=new SCC_BriLinkWrapper();
        if (tid != null && tid != '') {
                             endpoint = SCC_UtilityClassIntegration.getEndPoint('SCC_inquiryBrilinkProfileByTID') ;

            
            requestBody = '{"tid": "' + tid + '"}';
        } else if (mid != null && mid != '') {
          endpoint = SCC_UtilityClassIntegration.getEndPoint('SCC_inquiryBrilinkProfileByMID') ;

            requestBody = '{"mid": "' + mid + '"}';
        } else {
            // Handle invalid type
           Ewrap.errorMsg='Invalid profile';
           return Ewrap;
        }

        // Make the HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(60000);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);

        HttpResponse response = new Http().send(request);
        SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(Endpoint,'SCC_BRILinkCallout'));
        // Process the response
        if (response.getStatusCode() == 200) {
            // Check if response body is null
            if (response.getBody() == null) {
                Ewrap.errorMsg='Hasil tidak ditemukan';
                return Ewrap;
            }

            // Parse the response using the wrapper class
            SCC_BriLinkWrapper parsedData = SCC_BriLinkWrapper.parse(response.getBody());
            
            // Check if BRILINK_PROFILE array is empty
            if (parsedData == null || parsedData.BRILINK_PROFILE.isEmpty()) {
                Ewrap.errorMsg='Hasil tidak ditemukan';
                return Ewrap;
            }
            else
            {
                parsedData.errorMsg='';
                for(integer i=0;i<parseddata.BRILINK_PROFILE.size();i++)
                {
                    
                    parsedData.BRILINK_PROFILE[i].UniqueId=parsedData.BRILINK_PROFILE[i].kode_merchant==null?parsedData.BRILINK_PROFILE[i].nama_agen+'':parsedData.BRILINK_PROFILE[i].nama_agen+parsedData.BRILINK_PROFILE[i].kode_merchant;
                }
            }
            // Assuming parsedData has a method to get some string representation
            String parsedString = parsedData.toString();
            return parsedData;
        } else {
            Ewrap.errorMsg='Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            return Ewrap;
            // Handle error response
          //  return 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
        }
    }
}