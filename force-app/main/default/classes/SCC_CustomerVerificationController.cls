/**
 * @description SCC_CustomerVerificationController
 */
public without sharing class SCC_CustomerVerificationController {
    
    /**
     * @description Method fetchBankingDataFromAPI
     * @param caseId of type Id
     * @return CustomerBankingInfo
     */
    @AuraEnabled
    public static CustomerBankingInfo fetchBankingDataFromAPI (Id caseId) {
        String phoneNumber = getPhoneNo(caseId);
        String customerType ;
        customerType=[Select Account.SCC_Tipe_Nasabah__c    from case where ID=: caseId limit 1].get(0).Account.SCC_Tipe_Nasabah__C;
        SCC_CustomerVerificationWrapper sc = new SCC_CustomerVerificationWrapper();
        Map<String, String> bodyValueMap = new Map<String, String>();
        if(!String.isEmpty(phoneNumber)){
            bodyValueMap.put('phoneNumber', phoneNumber);
        }else {
            throw new AuraException('Nomor telepon untuk melakukan panggilan API tidak ada !'); //Missing phone number to make an API call
        }
        bodyValueMap.put('personalNumber', '00000000');
        bodyValueMap.put('channelId', 'CHMS');
        
        String body = JSON.serialize(bodyValueMap);
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Customer_Profile_API');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);
        // Check the response status
        if (response.getStatusCode() == 200) {
            sc = SCC_CustomerVerificationWrapper.parse(response.getBody());
            try{
                if(sc != null && sc.statusCode == 200){
                    return parseBanking(sc.data,customerType);
                }else{
                    captureErrorLog(endpointUrl, body, response.getBody());
                    throw new AuraException(response.getBody());
                }
            } catch (Exception e) {
                throw new AuraException(e.getMessage());
            }
        }else{
            captureErrorLog(endpointUrl, body, response.getBody());
            throw new AuraException(response.getBody());
        }
    }
    
    /**
     * @description Method fetchCreditDataFromAPI
     * @param caseId of type Id
     * @param cardNumber of type String
     * @return CustomerCreditInfo
     */
    @AuraEnabled
    public static CustomerCreditInfo  fetchCreditDataFromAPI (Id caseId,String cardNumber) {
        String customerType ;
        customerType=[Select Account.SCC_Tipe_Nasabah__c from case where ID=: caseId limit 1].get(0).Account.SCC_Tipe_Nasabah__c ;
        
        SCC_CardlinkByCardNumberWrapper sc = new SCC_CardlinkByCardNumberWrapper();
        Map<String, String> bodyValueMap = new Map<String, String>();
        
        if(!String.isEmpty(cardNumber)){
            bodyValueMap.put('cardNo', cardNumber);
        }else {
            throw new AuraException('Nomor kartu untuk melakukan panggilan API tidak ada.'); //Missing card number to make an API call
        }
        
        String body = JSON.serialize(bodyValueMap);
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Cardlink_By_Card_Number_API');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);
        // Check the response status
        if (response.getStatusCode() == 200) {
            sc = SCC_CardlinkByCardNumberWrapper.parse(response.getBody());
            if(sc != null ){
                return parseCustomerCredit(sc.response,customerType);
            }else{
                captureErrorLog(endpointUrl, body, response.getBody());
                throw new AuraException(response.getBody());
                
            }
        }else{
            captureErrorLog(endpointUrl, body, response.getBody());
            throw new AuraException(response.getBody());
           
        }
    }
    
    /**
     * @description Method captureErrorLog
     * @param endpointUrl of type String
     * @param apiType of type String
     * @param requestBody of type String
     * @param responseBody of type String
     */
    public static void captureErrorLog(String endpointUrl, String requestBody, String responseBody){
        try {
            List<Error_Log__c> errorLogsToInsert = new List<Error_Log__c>();
            
            Error_Log__c el = new Error_Log__c();
            el.Class_Name__c = SCC_CustomerVerificationController.class.getName();
            el.Endpoint__c = endpointUrl;
            el.API_Type__c  = 'Outbound';
            el.Request_Body__c = requestBody;
            el.Error_Datetime__c = System.now();
            el.User_Run__c = UserInfo.getUserId();
            
            if (!String.isEmpty(responseBody)) {
                Map<String,Object> parsedData =  (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                
                if (parsedData != null) {
                    el.Response_Status__c = parsedData.get('responseMessage') != null ? String.valueOf(parsedData.get('responseMessage')) : null;
                    el.Response_Status_Code__c = parsedData.get('statusCode') != null ? Integer.valueOf(parsedData.get('statusCode')) : null;
                    el.Error_Messages__c = parsedData.get('errors') != null ? String.valueOf(parsedData.get('errors')) : null;
                }
                el.Response_Body__c = responseBody;
            }
            
            errorLogsToInsert.add(el);
            insert errorLogsToInsert;
        } catch (Exception e) {
         
        }
    }
    
    /**
     * @description Method getPhoneNo
     * @param caseId of type String
     * @return Phone NUmber as String
     */
    @TestVisible
    private static String getPhoneNo (Id caseId){
        String caseMobileNo;
        String accountMobileNo;
        
        List<Case> caseList = [SELECT Account.PHONE ,SCC_Cust_Phone1__c FROM Case WHERE ID=: caseId LIMIT 1];
        if (caseList.size()>0) {
            caseMobileNo=caseList.get(0).SCC_Cust_Phone1__c ;
            accountMobileNo=caseList.get(0).Account.PHONE;
            if (String.isNotBlank(caseMobileNo)) {
                return caseMobileNo;
            } else {
                if (String.isNotBlank(accountMobileNo)) {
                    return accountMobileNo;
                }else {
                    return null;
                }
            }
        } else {
    return null;
        }
        
    }
    
    /**
     * @description Method captureErrorLog
     * @param response of type CC_CardlinkByCardNumberWrapper.Response
     * @param customerType of type String
     * @return CustomerCreditInfo
     */
    public static CustomerCreditInfo  parseCustomerCredit (SCC_CardlinkByCardNumberWrapper.Response response ,String customerType){
        CustomerCreditInfo customerCreditInfo =new customerCreditInfo();
        if(response != null){
            if (customerType == 'Non-Individu') {
                system.debug('enter' + response.customerData[0].alamatKantorDepan);
                String verif_PIC_Name = response.customerData[0].namaDepan + response.customerData[0].namaTengah + response.customerData[0].namaBelakang;
                String verif_PIC_Phone = response.customerData[0].nomorHandphoneTerdaftar != null ? response.customerData[0].nomorHandphoneTerdaftar :'';
                String verif_Office_Address = response.customerData[0].alamatKantorDepan != null ? response.customerData[0].alamatKantorDepan : '';
                String verif_Office_Phone = response.customerData[0].nomorTelephoneKantor != null ? response.customerData[0].nomorTelephoneKantor : '';
                String verif_Expired_Date = response.customerData[0].cardHolderData[0].expiredKartu != null ?response.customerData[0].cardHolderData[0].expiredKartu : '';
                customerCreditInfo = new customerCreditInfo(
                customerType,
                verif_PIC_Name ,
                verif_PIC_Phone ,
                verif_Office_Address ,
                verif_Office_Phone ,
                verif_Expired_Date );
            }else{
                String  verif_Customer_Name = response.customerData[0].namaDepan + response.customerData[0].namaTengah + response.customerData[0].namaBelakang;
                String  verif_Mother_Name = response.customerData[0].additionalDataByAcctNumber!=null?response.customerData[0].additionalDataByAcctNumber[0].namaLengkapIbuKandung != null ? response.customerData[0].additionalDataByAcctNumber[0].namaLengkapIbuKandung : '':'';
                String verif_Phone_BRINets = response.customerData[0].nomorHandphoneTerdaftar != null ? response.customerData[0].nomorHandphoneTerdaftar : '';
                String verif_Phone_WBS = response.customerData[0].nomorHandphoneTerdaftar != null ? response.customerData[0].nomorHandphoneTerdaftar : '';
                String verif_NIK = response.customerData[0].nomorNik != null ? response.customerData[0].nomorNik : '';
                String verif_NPWP = response.customerData[0].nomorNpwp != null ? response.customerData[0].nomorNpwp : '';
                String verif_Expired_Date = response.customerData[0].cardHolderData[0].expiredKartu.substring(0,2)+'/'+response.customerData[0].cardHolderData[0].expiredKartu.substring(2,4);
                String verif_Home_Address = response.customerData[0].alamatRumahDepan != null ? response.customerData[0].alamatRumahDepan : '';
                String verif_Email = response.customerData[0].alamatEmail != null ? response.customerData[0].alamatEmail : '';
                String verif_Urgent_Contact = response.customerData[0].namaKerabatTidakSerumah+ '|' + response.customerData[0].nomorTelephoneKerabatTidakSerumah;
                String verif_Credit_Card_Limit = response.customerData[0].cardHolderData[0].limitKartuKredit != null ? response.customerData[0].cardHolderData[0].limitKartuKredit : '';
                verif_Credit_Card_Limit = verif_Credit_Card_Limit.replaceFirst('^0+(?!$)', '');
                customerCreditInfo=new customerCreditInfo (
                'Individu',  verif_Customer_Name ,verif_Mother_Name ,verif_Phone_BRINets ,verif_Phone_WBS ,verif_NIK ,verif_NPWP ,
                verif_Expired_Date ,verif_Home_Address ,verif_Email ,verif_Urgent_Contact , verif_Credit_Card_Limit);
            }
        }
        return customerCreditInfo;
    }
    
    /**
     * @description Method parseBanking
     * @param dataList of type List<SCC_CustomerVerificationWrapper.Data>
     * @param customerType of type String
     * @return CustomerBankingInfo
     */
    public static CustomerBankingInfo  parseBanking(List<SCC_CustomerVerificationWrapper.Data> dataList,String customerType) {
        CustomerBankingInfo customerBankingInfo =new CustomerBankingInfo();
        if(!dataList.isEmpty() && dataList != null){
            if (customerType == 'Non-Individu') {
                String verif_Customer_Name =dataList[0].demografi.namaSesuaiIdentitas;
                String verif_Establish_Date =dataList[0].demografi.tanggalAktaPendirian != null ? dataList[0].demografi.tanggalAktaPendirian :'';
                String verif_Mother_Name =dataList[0].demografi.namaGadisIbuKandung != null ? dataList[0].demografi.namaGadisIbuKandung : '';
                String verif_NPWP =dataList[0].demografi.NPWP != null ? dataList[0].demografi.NPWP : '';
                String verif_Phone_BRINets =dataList[0].demografi.handphone != null ? dataList[0].demografi.handphone : '';
                String verif_Phone=datalist[0].demografi.telepon!=null ?datalist[0].demografi.telepon:'';//Surya 16 July 2024
                String verif_PIC_Name_1  =dataList[0].demografi.nama1 != null ? dataList[0].demografi.nama1 : '';
                String verif_PIC_Name_2  =dataList[0].demografi.nama2 != null ? dataList[0].demografi.nama2 : '';
                String verif_PIC_Name_3  =dataList[0].demografi.nama3 != null ? dataList[0].demografi.nama3 : '';
                String verif_Office_Address  =dataList[0].demografi.alamatKantor != null ? dataList[0].demografi.alamatKantor : '';
                String verif_Position_1 =dataList[0].demografi.jabatan1 == null ? dataList[0].demografi.jabatan1 : '';
                String verif_Position_2 =dataList[0].demografi.jabatan2 != null ? dataList[0].demografi.jabatan2 : '';
                String verif_Position_3 =dataList[0].demografi.jabatan3 != null ? dataList[0].demografi.jabatan3 : '';
                customerBankingInfo=  new CustomerBankingInfo('Non-Individu', verif_Customer_Name ,verif_Establish_Date  ,verif_Mother_Name   , verif_NPWP,verif_Phone_BRINets ,verif_Phone,verif_PIC_Name_1    ,verif_PIC_Name_2    ,verif_PIC_Name_3    ,verif_Office_Address,verif_Position_1  , verif_Position_2    ,verif_Position_3     );
            }else {
                String verif_Customer_Name = dataList[0].demografi.namaSesuaiIdentitas;
                String verif_Birth_of_Date = dataList[0].demografi.tanggalLahir != null ? dataList[0].demografi.tanggalLahir : '';
                String verif_Mother_Name = dataList[0].demografi.namaGadisIbuKandung != null ? dataList[0].demografi.namaGadisIbuKandung : '';
                String verif_Phone_BRINets =dataList[0].demografi.handphone != null ? dataList[0].demografi.handphone : '';
                String verif_Phone_WBS = dataList[0].demografi.handphone != null ? dataList[0].demografi.handphone : '';
                String verif_NIK = dataList[0].demografi.nomorIdentitas != null ? dataList[0].demografi.nomorIdentitas : '';
                SCC_CustomerVerificationWrapper.PortofolioPerbankan portofolioPerbankan = dataList[0].portofolioPerbankan;
                List<SCC_CustomerVerificationWrapper.Simpanan> s =portofolioPerbankan.simpanan ;
                List<String> slist = new List<String>();
                for (Integer i = 0; i < s.size(); i++) {
                    String accounttype = s.get(i).product;
                    slist.add(accounttype);
                }
                String verif_Account_Type = String.join(slist,' ');
                String verif_Open_Account_Office = dataList[0].portofolioPerbankan.simpanan[0].accountNumber != null ? dataList[0].portofolioPerbankan.simpanan[0].accountNumber.substring(0,4) : '';
                String verif_Home_Address = dataList[0].demografi.alamatSesuaiID != null ? dataList[0].demografi.alamatSesuaiID : '';
                String verif_Email = dataList[0].demografi.email != null ? dataList[0].demografi.email : '';
                customerBankingInfo=  new CustomerBankingInfo(
                'Individu',verif_Customer_Name,verif_Birth_of_Date,verif_Mother_Name, verif_Phone_BRINets,verif_Phone_WBS,
                verif_NIK ,verif_Account_Type,verif_Open_Account_Office,verif_Home_Address,verif_Email);
            }
        }
        return customerBankingInfo;
    }
    
    /**
     * @description Wrapper Class CustomerCreditInfo
     */
    public class CustomerCreditInfo{
        @AuraEnabled 
        public String customerType;
        @AuraEnabled 
        public String verif_Customer_Name;
        @AuraEnabled 
        public String verif_Mother_Name;
        @AuraEnabled 
        public String verif_Phone_BRINets;
        @AuraEnabled 
        public String verif_Phone_WBS;
        @AuraEnabled 
        public String verif_NIK;
        @AuraEnabled 
        public String verif_NPWP;
        @AuraEnabled 
        public String verif_Expired_Date;
        @AuraEnabled 
        public String verif_Home_Address;
        @AuraEnabled 
        public String verif_Email;
        @AuraEnabled 
        public String verif_Urgent_Contact;
        @AuraEnabled 
        public String verif_Credit_Card_Limit;
        @AuraEnabled 
        public String verif_PIC_Name;
        @AuraEnabled 
        public String verif_PIC_Phone;
        @AuraEnabled 
        public String verif_Office_Address;
        @AuraEnabled 
        public String verif_Office_Phone;
        
        public CustomerCreditInfo(){}
        
        public CustomerCreditInfo(String customerType, String verif_PIC_Name,String verif_PIC_Phone,
                                  String verif_Office_Address,String verif_Office_Phone, String verif_Expired_Date){
            this.customerType = customerType;
            this.verif_PIC_Name = verif_PIC_Name;
            this.verif_PIC_Phone = verif_PIC_Phone;
            this.verif_Office_Phone = verif_Office_Phone;
            this.verif_Office_Address= verif_Office_Address;//Surya 16 July 2024
            this.verif_Expired_Date = verif_Expired_Date;
        }
        
        public CustomerCreditInfo(String customerType, String verif_Customer_Name,String verif_Mother_Name,String verif_Phone_BRINets,
        String verif_Phone_WBS,String verif_NIK,String verif_NPWP,String verif_Expired_Date,String verif_Home_Address,
        String verif_Email,String verif_Urgent_Contact,String verif_Credit_Card_Limit){
            this.customerType = customerType;
            this.verif_Customer_Name = verif_Customer_Name;
            this.verif_Mother_Name = verif_Mother_Name;
            this.verif_Phone_BRINets = verif_Phone_BRINets;
            this.verif_Phone_WBS = verif_Phone_WBS;
            this.verif_NIK = verif_NIK;
            this.verif_NPWP = verif_NPWP;
            this.verif_Expired_Date = verif_Expired_Date;
            this.verif_Home_Address =verif_Home_Address;
            this.verif_Email = verif_Email;
            this.verif_Urgent_Contact = verif_Urgent_Contact;
            this.verif_Credit_Card_Limit = verif_Credit_Card_Limit;
        }
    }
    
    /**
     * @description Wrapper Class customerBankingInfo
     */
    public class customerBankingInfo{
        @AuraEnabled 
        public String customerType;
        @AuraEnabled 
        public String verif_Customer_Name;
        @AuraEnabled 
        public String verif_Establish_Date;
        @AuraEnabled 
        public String verif_Mother_Name;
        @AuraEnabled 
        public String verif_NPWP;
        @AuraEnabled 
        public String verif_Phone_BRINets;
        @AuraEnabled 
        public String verif_Phone;//Surya 16 July 2024
        @AuraEnabled 
        public String verif_PIC_Name_1;
        @AuraEnabled 
        public String verif_PIC_Name_2;
        @AuraEnabled 
        public String verif_PIC_Name_3;
        @AuraEnabled 
        public String verif_Office_Address;
        @AuraEnabled 
        public String verif_Position_1;
        @AuraEnabled 
        public String verif_Position_2;
        @AuraEnabled 
        public String verif_Position_3;
        @AuraEnabled 
        public String verif_Birth_of_Date;       
        @AuraEnabled 
        public String verif_Phone_WBS;
        @AuraEnabled 
        public String verif_NIK;
        @AuraEnabled 
        public String verif_Account_Type;
        @AuraEnabled 
        public String verif_Open_Account_Office;
        @AuraEnabled 
        public String verif_Home_Address;
        @AuraEnabled 
        public String verif_Email;
        
        public customerBankingInfo(){}
        
        public customerBankingInfo(String customerType, String verif_Customer_Name ,String verif_Establish_Date , String verif_Mother_Name,String verif_NPWP,String verif_Phone_BRINets,
                                   String verif_Phone,String verif_PIC_Name_1,String verif_PIC_Name_2,String verif_PIC_Name_3,String verif_Office_Address, String verif_Position_1,String verif_Position_2,String verif_Position_3){
            this.customerType = customerType;
            this.verif_Customer_Name  = verif_Customer_Name;
            this.verif_Establish_Date = verif_Establish_Date;
            this.verif_Mother_Name = verif_Mother_Name;
            this.verif_NPWP = verif_NPWP;
            this.verif_Phone_BRINets = verif_Phone_BRINets;
            this.verif_Phone = verif_Phone;
            this.verif_PIC_Name_1 = verif_PIC_Name_1;
            this.verif_PIC_Name_2 = verif_PIC_Name_2;
            this.verif_PIC_Name_3  = verif_PIC_Name_3;
            this.verif_Office_Address = verif_Office_Address;
            this.verif_Position_1 = verif_Position_1;
            this.verif_Position_2 = verif_Position_2;
            this.verif_Position_3 = verif_Position_3;
        }
        
        public customerBankingInfo(String customerType, String verif_Customer_Name ,String verif_Birth_of_Date,
                                   String verif_Mother_Name,String verif_Phone_BRINets,String verif_Phone_WBS,
                                   String verif_NIK, String verif_Account_Type,String verif_Open_Account_Office,
                                   String verif_Home_Address,String verif_Email){
            this.customerType= customerType;
            this.verif_Customer_Name = verif_Customer_Name;
            this.verif_Birth_of_Date = verif_Birth_of_Date;
            this.verif_Mother_Name = verif_Mother_Name;
            this.verif_Phone_BRINets = verif_Phone_BRINets;
            this.verif_Phone_WBS = verif_Phone_WBS;
            this.verif_NIK = verif_NIK;
            this.verif_Account_Type = verif_Account_Type;
            this.verif_Open_Account_Office = verif_Open_Account_Office;
            this.verif_Home_Address = verif_Home_Address;
            this.verif_Email = verif_Email;
        }
    }
    
    /**
     * @description Method saveRecord
     * @param caseStr of type String
     * @return Sucess or Failiure Message
     */
    @AuraEnabled
    public static String saveRecord(String caseStr){
        try {
            Case caseObj = (Case)JSON.deserialize(caseStr, Case.class);
            update caseObj;
            return 'success';
        }
        catch (Exception e) {
            return e.getMessage();
        }
    }
}