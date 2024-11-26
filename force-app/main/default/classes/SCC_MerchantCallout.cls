/** @description
 * Class: SCC_MerchantCallout
 * Contains methods to interact with external APIs and process responses
 *              related to merchant profile and transaction history.
 * Author: Prateek Khanna
 * Created Date: 2024-05-30
 */

public without sharing class SCC_MerchantCallout {
   /** @description
 * Method: formatDate
 * Converts a date string into a formatted date representation.
 * Parameters:
 * @param dateString String representation of the date to format.
 * @return Formatted date string or an error message.
 */
public static String formatDate(String dateString) {
    if (String.isNotBlank(dateString)) {
        try {
            // Parse the date string directly
            Date dt = Date.valueOf(dateString);
            // Format the Date object as needed
            String formattedDate = dt.day() + ' ' + getMonthAbbreviation(dt.month()) + ' ' + dt.year();
            return formattedDate;
        } catch (Exception e) {
            // Handle date parsing errors
            return 'Tanggal tidak valid.';
        }
    }
    return 'Tanggal tidak ada.'; // Return a default value if date string is empty
}

/** @description
 * Helper method to get month abbreviation.
 * Converts a numeric month value into its corresponding three-letter abbreviation.
 * @param month Integer value representing the month (1 for January, 2 for February, ..., 12 for December).
 * @return Three-letter abbreviation of the month (e.g., "Jan" for January).
 *         Returns an empty string if the provided month value is not between 1 and 12.
 */
public static String getMonthAbbreviation(Integer month) {
    String[] monthAbbreviations = new String[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
    if (month >= 1 && month <= 12) {
        return monthAbbreviations[month - 1];
    } else {
        return '';
    }
}
/** @description
     * Method: makeCallout
     * Performs a callout to fetch merchant profile data from an external API 
     * based on either TID (Terminal ID) or MID (Merchant ID).
     * Parameters:
     * @param tid Terminal ID used to query the merchant profile.
     * @param mid Merchant ID used to query the merchant profile.
     * @return String representation of the merchant profile data or an error message.
     */

@AuraEnabled
public static SCC_MerchantProfileByMIDWrapper makeCallout(String tid, String mid) {
    // Construct the endpoint URL and request body based on the type and value
    String endpoint = '';
    String requestBody = '';
    HttpRequest request = new HttpRequest();
    HttpResponse response= new HttpResponse();
    SCC_MerchantProfileByMIDWrapper M=new SCC_MerchantProfileByMIDWrapper();
    if (tid != null && tid != '') {
                 endpoint = SCC_UtilityClassIntegration.getEndPoint('SCC_Merchant_Profile_By_TID_API') ;

        requestBody = '{"tid": "' + tid + '"}';
    } else if (mid != null && mid != '') {
                            endpoint = SCC_UtilityClassIntegration.getEndPoint('SCC_Merchant_Profile_By_MID_API') ;

        requestBody = '{"mid": "' + mid + '"}';
    } else {
        // Handle invalid type
        M.errorMessage='Profile tidak valid';
        return M;
    }

    // Make the HTTP request
    
    request.setEndpoint(endpoint);
    request.settimeout(60000);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('X-DATAHUB-CHANNEL', 'CHMS');
    request.setHeader('X-DATAHUB-USER', 'user');
    request.setBody(requestBody);

    // Log request details


   response = new Http().send(request);
   SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpoint,'SCC_MerchantCallout'));  
    // Process the response
    if (response.getStatusCode() == 200) {
        // Check if response body is null or blank
        if (String.isBlank(response.getBody())) {
            M.errorMessage='Body Respon Kosong atau null';
            return M;
        }

        // Parse the response using the wrapper class
        try {
            SCC_MerchantProfileByMIDWrapper parsedData = SCC_MerchantProfileByMIDWrapper.parse(response.getBody());
            // Process parsedData and return result
            if (parsedData != null && parsedData.MERCHANT_PROFILE != null && !parsedData.MERCHANT_PROFILE.isEmpty()) {
                // Assuming parsedData has a method to get some string representation
            //    String parsedString = parsedData.toString();
             //   return parsedString;
             parsedData.errorMessage='';
             return parsedData;
            } else {
               // return 'Data tidak ditemukan.';
               M.errorMessage='Data tidak ditemukan';
               return M;
            }
        } catch (Exception ex) {
        //    return 'Kesalahan pengurain respon.';
        M.errorMessage='Kesalahan pengurain respon.';
        return M;
        }
    } else {
        // Handle non-200 status code
    //    return 'Kode status Non-200: ' + response.getStatusCode();
    M.errorMessage='Kode status Non-200: ' + response.getStatusCode();
    return M;
    }
}

/** @description
     * Method: getTransactionHistory
     * Retrieves transaction history data from an external API based on MID (Merchant ID)
     *              or MPAN (Merchant Payment Account Number) and transaction date.
     * Parameters:
     * @param midOrMpan MID (Merchant ID) or MPAN (Merchant Payment Account Number) used to query transaction history.
     * @param tidOrStoreId TID (Terminal ID) or Store ID associated with the transactions.
     * @param trxDate Date of the transaction to filter the transaction history.
     * @return SCC_TransactionHistoryWrapper object containing the transaction history data.
     * @throws AuraHandledException if there is an API call failure.
     */
    @AuraEnabled
    public static SCC_TransactionHistoryWrapper getTransactionHistory(String midOrMpan, String tidOrStoreId,String trxDate) {
     
        SCC_TransactionHistoryWrapper parentWrapper = new SCC_TransactionHistoryWrapper();        
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('midOrMpan', midOrMpan); 
            bodyValueMap.put('tidOrStoreId', tidOrStoreId); 
            bodyValueMap.put('trxDate', trxDate);                      
            HttpRequest request = new HttpRequest();
            request.setEndpoint(SCC_UtilityClassIntegration.getEndPoint('SCC_Transaction_History_API'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DATAHUB-CHANNEL', 'CHMS');
            request.setHeader('X-DATAHUB-USER', 'user');
            request.setBody(JSON.serialize(bodyValueMap));
            Http http = new Http();
            HttpResponse response = http.send(request);         
          
            if (response.getStatusCode() == 200) {   
                
    SCC_TransactionHistoryWrapper parsedData = SCC_TransactionHistoryWrapper.parse(response.getBody());

    if (parsedData != null && parsedData.data != null) {
        List<SCC_TransactionHistoryWrapper.Data> inquiryData = parsedData.data;
        parentWrapper.data = new List<SCC_TransactionHistoryWrapper.Data>(); // Initialize list to hold transaction data
        for (SCC_TransactionHistoryWrapper.Data inquiry : inquiryData) {
            SCC_TransactionHistoryWrapper.Data transactionData = new SCC_TransactionHistoryWrapper.Data(); // Create instance to hold transaction data
           if (inquiry != null) {
            transactionData.trxDate = inquiry.trxDate;
            transactionData.trxTime = inquiry.trxTime;
            transactionData.midOrMpan = inquiry.midOrMpan;
            transactionData.tidOrStoreId = inquiry.tidOrStoreId;
            transactionData.appCodeReffNum = inquiry.appCodeReffNum;
            transactionData.jenisTrx = inquiry.jenisTrx;
            transactionData.trxAmount = inquiry.trxAmount;
            transactionData.mti = inquiry.mti;
            transactionData.merchantName = inquiry.merchantName;

            // Add transaction data to the list
            parentWrapper.data.add(transactionData);
           } 
        }
       
    }
                 
}

        } catch (Exception e) {
            throw new AuraHandledException('Kesalahan saat pemanggilan API: ' + e.getMessage());
        }
        
        return parentWrapper;
    }
     /** @description
     * Method: getDetailTransaction
     * Retrieves detailed transaction data from an external API based on MID (Merchant ID)
     *              or MPAN (Merchant Payment Account Number), transaction date, transaction time,
     *              and application code or reference number.
     * Parameters:
     * @param midOrMpan MID (Merchant ID) or MPAN (Merchant Payment Account Number) used to query detailed transaction data.
     * @param tidOrStoreId TID (Terminal ID) or Store ID associated with the transactions.
     * @param trxDate Date of the transaction to filter the detailed transaction data.
     * @param trxTime Time of the transaction to filter the detailed transaction data.
     * @param appCodeOrReffNum Application code or reference number associated with the transaction.
     * @return SCC_DetailTransactionWrapper object containing the detailed transaction data.
     * @throws AuraHandledException if there is an API call failure.
     */
     @AuraEnabled
    public static SCC_DetailTransactionWrapper getDetailTransaction(String midOrMpan, String tidOrStoreId,String trxDate,String trxTime, String appCodeOrReffNum ) {
        
        SCC_DetailTransactionWrapper parentWrapper = new SCC_DetailTransactionWrapper();        
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('midOrMpan', midOrMpan); 
            bodyValueMap.put('tidOrStoreId', tidOrStoreId); 
            bodyValueMap.put('trxDate', trxDate); 
            bodyValueMap.put('trxTime', trxTime); 
            bodyValueMap.put('appCodeOrReffNum', appCodeOrReffNum);  
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(SCC_UtilityClassIntegration.getEndPoint('SCC_Detail_Transaction_API'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DATAHUB-CHANNEL', 'CHMS');
            request.setHeader('X-DATAHUB-USER', 'user');
            request.setBody(JSON.serialize(bodyValueMap));
            
            Http http = new Http();
            
            HttpResponse response = http.send(request);         
            if (response.getStatusCode() == 200) {   
                SCC_DetailTransactionWrapper parsedData = SCC_DetailTransactionWrapper.parse(response.getBody());
                if (parsedData != null && parsedData.data != null) {
                    List<SCC_DetailTransactionWrapper.Data> inquiryData = parsedData.data;
                    parentWrapper.data = new List<SCC_DetailTransactionWrapper.Data>(); // Initialize list to hold transaction data
                    for (SCC_DetailTransactionWrapper.Data inquiry : inquiryData) {
                        SCC_DetailTransactionWrapper.Data transactionData = new SCC_DetailTransactionWrapper.Data(); // Create instance to hold transaction data
                        if (inquiry != null) {
                            transactionData.trxDate = inquiry.trxDate;
                            transactionData.trxTime = inquiry.trxTime;
                            transactionData.midOrMpan = inquiry.midOrMpan;
                            transactionData.tidOrStoreId = inquiry.tidOrStoreId;
                            transactionData.appCodeReffNum = inquiry.appCodeReffNum;
                            transactionData.jenisTrx = inquiry.jenisTrx;
                            transactionData.trxAmount = inquiry.trxAmount;
                            transactionData.mti = inquiry.mti;
                            transactionData.merchantName = inquiry.merchantName;
                            transactionData.noKartuCpan = inquiry.noKartuCpan;
                            transactionData.batchNo = inquiry.batchNo;
                             transactionData.trxStatus = inquiry.trxStatus;
                            transactionData.mdr = inquiry.mdr;
                            transactionData.channelID = inquiry.channelID;
                            transactionData.proccode = inquiry.proccode;
                            transactionData.namaFitur = inquiry.namaFitur;
                            transactionData.localCrossBorder = inquiry.localCrossBorder;
                            transactionData.onUsNotOnUs = inquiry.onUsNotOnUs;
                            transactionData.cardType = inquiry.cardType;
                            transactionData.rc = inquiry.rc;
                            transactionData.status = inquiry.status;
                            transactionData.trxType = inquiry.trxType;
                            transactionData.mti = inquiry.mti;
                            transactionData.traceNum = inquiry.traceNum;
                            transactionData.mcc = inquiry.mcc;
                            transactionData.location = inquiry.location;
                            transactionData.address = inquiry.address;
                            transactionData.acqBank = inquiry.acqBank;
                            transactionData.posEntryMode = inquiry.posEntryMode;
                            transactionData.settleAmount = inquiry.settleAmount;
                            transactionData.settleDate = formatDate(inquiry.settleDate);
                            transactionData.paymentDate = formatDate(inquiry.paymentDate);
                            transactionData.noRekMerchant = inquiry.noRekMerchant;
                            transactionData.paymentRemark = inquiry.paymentRemark;
                            // Add transaction data to the list
                            parentWrapper.data.add(transactionData);
                        } 
                    }
                    
                }
                
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error during API call: ' + e.getMessage());
        }
        
        return parentWrapper;
    }
  
}