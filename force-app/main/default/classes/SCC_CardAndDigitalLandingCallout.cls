/** 
 * Class: SCC_CardAndDigitalLandingCallout
 * @description This class is for handling various callouts to external APIs related to card and digital landing operations.
 *              This class provides methods to retrieve customer data, transaction details, and other related information
 *              It supports integration with external systems to fetch data based on phone numbers, NIK (Indonesian Identity Number), 
 *              card numbers, and Salesforce Case IDs.
 * Author: Prateek Khanna 
 * Created Date: 2024-05-30
 */

public without sharing class SCC_CardAndDigitalLandingCallout {
    /** @description Method: getCustomerDataByPhone Retrieves customer data based on a phone number using an external API call.
     * @param phoneNumber String representing the phone number.
     * @param caseId Salesforce Case ID.
     * @return List of SCC_CardlinkByPhoneWrapper containing customer data.
     */
    @AuraEnabled
    public static List<SCC_CardlinkByPhoneWrapper> getCustomerDataByPhone(String phoneNumber, String caseId) {
        if (String.isEmpty(phoneNumber)) {
            throw new AuraHandledException('Nomor telepon untuk melakukan panggilan API tidak ada.'); //Missing phone number to make an API call.
        }
        List<SCC_CardlinkByPhoneWrapper> customerDataList = new List<SCC_CardlinkByPhoneWrapper>();
        HttpResponse response=new HttpResponse();
        HttpRequest request = new HttpRequest();
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('phoneNumber', phoneNumber);
            String body = JSON.serialize(bodyValueMap);
            request.setTimeout(60000);
            request.setEndpoint(SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Phone_Number_API'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
           response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                SCC_CardlinkByPhoneNumberWrapper parsedData = SCC_CardlinkByPhoneNumberWrapper.parse(response.getBody());
                
                if (parsedData != null && parsedData.response != null && parsedData.response.customerData != null) {
                    for (SCC_CardlinkByPhoneNumberWrapper.CustomerData customerData : parsedData.response.customerData) {
                        if (customerData.portofolio != null && customerData.portofolio.creditCard != null) {                           
                            for (SCC_CardlinkByPhoneNumberWrapper.CreditCard card : customerData.portofolio.creditCard) {
                                String statusValue = card.status.equals('1') ? 'Active' : 'Inactive';
                                card.status = statusValue;
                                SCC_CardlinkByPhoneWrapper creditCard = new SCC_CardlinkByPhoneWrapper(
                                    card.status,card.productType,card.productDescription,card.product,card.cifno, card.cardNumber,
                                    customerData.namaBelakang,customerData.namaTengah, customerData.namaDepan);
                                customerDataList.add(creditCard);
                            }
                        }
                    }
                }
            }
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Phone_Number_API'),'SCC_CardAndDigitalLandingCallout')); 
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Phone_Number_API'),'SCC_CardAndDigitalLandingCallout')); 
            throw new AuraHandledException('Terjadi kesalahan saat melakukan panggilan API.'); //An error occurred while making the API call.
        }
        return customerDataList;
    }

    /** @description Method: getCaseCif 
     * @param caseId of type Id
     * @return caseCif of type sting
     */
    private static String getCaseCif(String caseId) {
        String caseCif = ''; // Initialize caseCif variable       
        // Query to get the CIF from the Account linked to the Case
        try {
         // Perform the SOQL query to fetch the Case record
            Case caseRecord = [SELECT Account.SCC_cifno__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
            
            // Check if caseRecord and its associated Account are not null
            if (caseRecord != null && caseRecord.Account != null) {
                caseCif = caseRecord.Account.SCC_cifno__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Terjadi kesalahan saat mengambil CIF dari Kasus / Case: ' + e.getMessage()); // An error occurred while fetching CIF from the Case
        }
        
        return caseCif;
    }
    
    /** @description Method: getCustomerDataByNIK Retrieves customer data based on a NIK number using an external API call.
     * @param nikNumber String representing the NIK number.
     * @return List of SCC_CustPersWrapper containing customer data.
     */
    @AuraEnabled
    public static List<SCC_CustPersWrapper> getCustomerDataByNIK(String nikNumber) {
        if (String.isEmpty(nikNumber)) {
            throw new AuraHandledException('Nomor NIK untuk melakukan panggilan API tidak ada.'); //Missing NIK number to make an API call.
        }
        
        List<SCC_CustPersWrapper> customerDataList = new List<SCC_CustPersWrapper>();
        HttpRequest request = new HttpRequest();
        HttpResponse response= new HttpResponse();
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('idNumber', nikNumber);
            
            String body = JSON.serialize(bodyValueMap);
                               
           
            request.setEndpoint(SCC_UtilityClassIntegration.getEndPoint('SCC_Cust_Personal_API'));
            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                SCC_CustPersonalWrapper parsedData = SCC_CustPersonalWrapper.parse(response.getBody());
                
                if (parsedData != null && parsedData.CUSTPERSONAL != null) {
                    for (SCC_CustPersonalWrapper.CUSTPERSONAL custPers : parsedData.CUSTPERSONAL) {
                        SCC_CustPersWrapper custPersonal1 = new SCC_CustPersWrapper(
                            custPers.namaNasabahLengkap, custPers.nik, custPers.tanggalLahir, custPers.nomorAplikasiPengajuan,
                            custPers.tanggalPengajuan, custPers.channelPengajuan, custPers.nomorKartuKredit, custPers.progressPengajuan);
                        customerDataList.add(custPersonal1);
                    }
                }
            }
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_Cust_Personal_API'),'SCC_CardAndDigitalLandingCallout')); 
       
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_Cust_Personal_API'),'SCC_CardAndDigitalLandingCallout')); 
            throw new AuraHandledException('Terjadi kesalahan saat melakukan panggilan API.'); //An error occurred while making the API call.
        }
        return customerDataList;
    }

    /** @description Method: getPCTD Retrieves transaction data associated with a card number using an external API call.
     * @param cardNumber String representing the card number.
     * @return SCC_PCTDWrapper containing transaction data.
     */
    @AuraEnabled
    public static SCC_PCTDWrapper getPCTD(String cardNumber) {
        
        SCC_PCTDWrapper parentWrapper = new SCC_PCTDWrapper();  
        HttpResponse response=new HttpResponse();
        HttpRequest request = new HttpRequest();      
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('cardNumber', cardNumber); 
            request.setTimeout(60000);
            request.setEndpoint(SCC_UtilityClassIntegration.getEndPoint('SCC_PCTD_API'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-DATAHUB-CHANNEL', 'CHMS');
            request.setHeader('X-DATAHUB-USER', 'user');
            request.setBody(JSON.serialize(bodyValueMap));
            Http http = new Http();
            response = http.send(request);         
            if (response.getStatusCode() == 200) {   
                SCC_PCTDWrapper parsedData = SCC_PCTDWrapper.parse(response.getBody());
                if (parsedData != null && parsedData.CPAHF != null) {
                    List<SCC_PCTDWrapper.CPAHF> inquiryData = parsedData.CPAHF;
                    parentWrapper.CPAHF = new List<SCC_PCTDWrapper.CPAHF>(); // Initialize list to hold transaction data
                    for (SCC_PCTDWrapper.CPAHF inquiry : inquiryData) {
                        SCC_PCTDWrapper.CPAHF transactionData = new SCC_PCTDWrapper.CPAHF(); // Create instance to hold transaction data
                        if (inquiry != null) {
                            transactionData.jenisTransaksi = inquiry.jenisTransaksi;
                            transactionData.waktuSisaPenagihanMerchant = inquiry.waktuSisaPenagihanMerchant;
                            transactionData.nominalTransaksiMenggantung = inquiry.nominalTransaksiMenggantung;
                            transactionData.tanggalTransaksiMenggantung = inquiry.tanggalTransaksiMenggantung;
                            transactionData.deskripsiTransaksi = inquiry.deskripsiTransaksi;
                            transactionData.tanggalPostingTagihan = inquiry.tanggalPostingTagihan;
                            transactionData.akumulasiJumlahTransaksi = inquiry.akumulasiJumlahTransaksi;
                            transactionData.refferenceNumber = inquiry.refferenceNumber;
                            transactionData.kodeTransaksi = inquiry.kodeTransaksi;
                            transactionData.tanggalPostingTransaksi = inquiry.tanggalPostingTransaksi;
                            transactionData.approvalCode = inquiry.approvalCode;
                            transactionData.keteranganTransaksi = inquiry.keteranganTransaksi;
                            transactionData.nominalTransaksi = inquiry.nominalTransaksi;
                            transactionData.waktuTransaksi = inquiry.waktuTransaksi;
                            transactionData.tanggalTransaksi = inquiry.tanggalTransaksi;
                            // Add transaction data to the list
                            parentWrapper.CPAHF.add(transactionData);
                        } }}   
                        SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_PCTD_API'),'SCC_CardAndDigitalLandingCallout'));          
                }
            } catch (Exception e) {
                SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_PCTD_API'),'SCC_CardAndDigitalLandingCallout')); 
                throw new AuraHandledException('Terjadi kesalahan selama melakukan panggilan API:' + e.getMessage()); //Error during API call: 
        }
        return parentWrapper;
    }

    /** @description Method: getCardlinkByCardNumber Retrieves customer data based on a card number using an external API call.
     * @param cardNo String representing the card number.
     * @return List of SCC_CardlinkByCardNumberWrapper.CustomerData containing customer data.
     */
    @AuraEnabled
    public static List<SCC_CardlinkByCardNumberWrapper.CustomerData> getCardlinkByCardNumber(String cardNo) {
        List<SCC_CardlinkByCardNumberWrapper.CustomerData> customerDataList = new List<SCC_CardlinkByCardNumberWrapper.CustomerData>();
        HttpRequest request = new HttpRequest();
        HttpResponse response= new HTTPResponse();
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('cardNo', cardNo);
            String body = JSON.serialize(bodyValueMap);
          
            request.setEndpoint(SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Card_Number_API'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
           response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Parse the JSON response into SCC_CardlinkByCardNumberWrapper object
                SCC_CardlinkByCardNumberWrapper wrapper = SCC_CardlinkByCardNumberWrapper.parse(response.getBody());
                if (wrapper != null && wrapper.response != null && wrapper.response.customerData != null) {
                    // Access the response object from the wrapper
                    SCC_CardlinkByCardNumberWrapper.Response responseObj = wrapper.response;
                    // Access customer data from the response
                    customerDataList = responseObj.customerData;                   
                } 
            }
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Card_Number_API'),'SCC_CardAndDigitalLandingCallout'));          
        } catch (Exception e) {   
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Card_Number_API'),'SCC_CardAndDigitalLandingCallout'));                
            throw new AuraHandledException('Terjadi kesalahan saat melakukan panggilan API.'); //An error occurred while making the API call.
        }
        return customerDataList;
    }
}