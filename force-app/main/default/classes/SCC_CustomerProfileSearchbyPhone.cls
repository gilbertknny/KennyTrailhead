/**
 * @description SCC_CustomerProfileSearchbyPhone
 */
public without sharing class SCC_CustomerProfileSearchbyPhone {
    /**
     * @description Class to return response message.
     */
    public class SCC_CalloutResponse {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String message;
        
        /**
         * @description SCC_CalloutResponse.
         * @param success
         * @param message
         */
        public SCC_CalloutResponse(Boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
    
    
    /**
     * @description initiateCalloutUsingMobileNumber Method to Make Http callout.
     * @param accountId
     * @return SCC_CalloutResponse
     */
    @AuraEnabled
    public static SCC_CalloutResponse initiateCalloutUsingMobileNumber(Id accountId) {
        HttpRequest request = new HttpRequest();
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Customer_Profile_API');
        HttpResponse response=new HttpResponse();
        try {
            String mobileNumber = getMobileNumber(accountId);

            if (String.isBlank(mobileNumber)) {
                return new SCC_CalloutResponse(false, 'Phone Number is incorrect/blank to make an API call');
            }else{
                mobileNumber = removeSpace(mobileNumber);
            }
            
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('phoneNumber', mobileNumber);
            bodyValueMap.put('personalNumber', '00000000');
            bodyValueMap.put('channelId', 'CHMS');
            String body = JSON.serialize(bodyValueMap);
            
           
            request.settimeout(60000);
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointurl,'SCC_CustomerProfileSearchByPhone'));  
            if(response.getStatusCode() == 200){
              SCC_CustomerProfileWrapper parsedData = SCC_CustomerProfileWrapper.parse(response.getBody());
              if(parsedData != null && parsedData.statusCode == 200){
                  List<SCC_CustomerProfileInfo> customerProfiles = parseCustomerProfile(parsedData.data);
                  // Collect all CIF numbers to query in a single SOQL query
                    Set<String> cifNumbers = new Set<String>();
                    for (SCC_CustomerProfileInfo customerProfile : customerProfiles) {
                        cifNumbers.add(customerProfile.cifno);
                    }

                    // Retrieve existing accounts
                    Map<String, Account> existingAccountMap = getExistingAccounts(customerProfiles);
                    
                    for (SCC_CustomerProfileInfo customerProfile : customerProfiles) {
                        SCC_CustomerProfileWrapper.Demografi demographicInfo = customerProfile.demographicInfo;
                        String cifNumber = customerProfile.cifno;
                        if (existingAccountMap.containsKey(cifNumber)) {
                            Account existingAccount = existingAccountMap.get(cifNumber);
                            updateAccount(existingAccount, demographicInfo);
                        } 
                     }
                  return new SCC_CalloutResponse(true, 'Callout and update successful');
                }else{
                    return new SCC_CalloutResponse(false, 'Data tidak ditemukan');
                }
            }else{
                return new SCC_CalloutResponse(false, 'Callout failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointurl,'SCC_CustomerProfileSearchByPhone'));   
            return new SCC_CalloutResponse(false, 'Error: ' + e.getMessage());
        }
    }
    /**
     * @description getExistingAccounts
     * @param customerProfiles
     * @return Map of SCC_cifno__c with Account
     */
    private static Map<String, Account> getExistingAccounts(List<SCC_CustomerProfileInfo> customerProfiles) {
        Set<String> cifNumbers = new Set<String>();
        for (SCC_CustomerProfileInfo customerProfile : customerProfiles) {
            cifNumbers.add(customerProfile.cifno);
        }

        Map<String, Account> existingAccountMap = new Map<String, Account>();
        if (!cifNumbers.isEmpty()) {
            if (Schema.sObjectType.Account.isAccessible()) {
                List<Account> existingAccounts = [SELECT Id, SCC_cifno__c, PersonEmail FROM Account WHERE SCC_cifno__c IN :cifNumbers];
                for (Account acct : existingAccounts) {
                    existingAccountMap.put(acct.SCC_cifno__c, acct);
                }
            } else {
                throw new AuraHandledException('Insufficient permissions to access Account records.');
            }
        }
        return existingAccountMap;
    }   

    /**
     * @description getMobileNumber
     * @param accountId
     * @return mobileNumber from Case or Account
     */
    private static String getMobileNumber(Id accountId) {
        String mobileNumber = '';
        try {
            // Query for the latest Case associated with the AccountId
            if (Schema.sObjectType.Case.fields.SCC_Cust_Phone1__c.isAccessible()) {
                List<Case> cases = [SELECT Id, SCC_Cust_Phone1__c FROM Case WHERE AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];

                if (!cases.isEmpty() && !String.isBlank(cases[0].SCC_Cust_Phone1__c)) {
                    // If there is a Case and it has a phone number, use it
                    mobileNumber = cases[0].SCC_Cust_Phone1__c;
                } else {
                    // Otherwise, query the Account object
                    if (Schema.sObjectType.Account.fields.Phone.isAccessible()) {
                        Account acc = [SELECT Id, Phone, SCC_cifno__c FROM Account WHERE Id = :accountId LIMIT 1];
                        if (acc != null) {
                            mobileNumber = acc.Phone;
                        }
                    } else {
                        throw new AuraHandledException('Insufficient permissions to access Account fields');
                    }
                }
            } else {
                throw new AuraHandledException('Insufficient permissions to access Case fields');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error in getMobileNumber: ' + e.getMessage());
        }
        return mobileNumber;
    }
    
    /**
     * @description parseCustomerProfile
     * @param dataList
     * @return List of SCC_CustomerProfileInfo
     */
    public static List<SCC_CustomerProfileInfo> parseCustomerProfile(List<SCC_CustomerProfileWrapper.Data> dataList) {
        List<SCC_CustomerProfileInfo> customerProfiles = new List<SCC_CustomerProfileInfo>();
        String cifno = '';
        if(!dataList.isEmpty() && dataList != null){
            try {
                for (SCC_CustomerProfileWrapper.Data data : dataList) {
                    SCC_CustomerProfileWrapper.Demografi demographicInfo = data.demografi;
                    cifno = data.cifno;
                    customerProfiles.add(new SCC_CustomerProfileInfo(demographicInfo, cifno));
                }
            } catch (Exception e) {
                throw new AuraHandledException('Exception occurred: ' + e.getMessage());
            }
        }
        return customerProfiles;
    }
    
    /**
     * @description updateAccount
     * @param existingAccount
     * @param demographicInfo
     */
    @TestVisible
    private static void updateAccount(Account existingAccount, SCC_CustomerProfileWrapper.Demografi demographicInfo) {
        
        // Update existing Account record with new information
        if(demographicInfo.tipeNasabah == 'P'){ 
            existingAccount.LastName = demographicInfo.namaSesuaiIdentitas;
            existingAccount.SCC_Tipe_Nasabah__c = 'Individu';
            existingAccount.PersonEmail = validateAndSetEmail(demographicInfo.email);
            existingAccount.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
            existingAccount.RecordTypeId = SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'PersonAccount');
            existingAccount.SCC_TanggalLahir__c = calculateAge(demographicInfo);
        }else{ 
            existingAccount.Name = demographicInfo.namaSesuaiIdentitas;     
            existingAccount.SCC_Tipe_Nasabah__c = 'Non-Individu';
            existingAccount.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
            existingAccount.RecordTypeId = SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'IndustriesBusiness');
        }
        existingAccount.Phone = (demographicInfo.handphone != null || demographicInfo.handphone != 'NULL') ? demographicInfo.handphone : ' ';
        existingAccount.SCC_Jenis_Nasabah__c = (demographicInfo.nasabahPrioritas == null || demographicInfo.nasabahPrioritas == '' || demographicInfo.nasabahPrioritas == 'NULL') ? 'Non-Prioritas' : 'Prioritas';
     //   String address1 = demographicInfo.alamatId1 != null ? demographicInfo.alamatId1 : '';
      //  String address2 = demographicInfo.alamatId2 != null ? demographicInfo.alamatId2 : '';
     //   String address3 = demographicInfo.alamatId3 != null ? demographicInfo.alamatId3 : '';
     //   String address4 = demographicInfo.alamatId4 != null ? demographicInfo.alamatId4 : '';
     //   if(!String.isBlank(address1) || !String.isBlank(address2) || !String.isBlank(address3) || !String.isBlank(address4)){
      //      existingAccount.SCC_Address__c = address1 + ' ' + address2 + ' ' + address3 + ' ' + address4;
     //   }
        //Surya 13 July 2024 Datahub change mapping address from alamatid1-alamatid4 into alamatsesuaiId
          String addressId1=demographicInfo.alamatSesuaiID != null? demographicInfo.alamatsesuaiID:'';
          String addressId2=demographicInfo.alamatSesuaiID2 != null? demographicInfo.alamatSesuaiID2:'';
          if(!String.isBlank(addressId1) || !String.isBlank(addressId2))
          existingAccount.SCC_Address__c =addressId1 +' '+ addressId2;
          //Surya 13 July 2024 end//
        // Check for update permissions on Account object
        if (Schema.sObjectType.Account.isUpdateable()) {
            update existingAccount;
        }
    }
    
    /**
     * @description validateAndSetEmail
     * @param email
     * @return validatedEmail String
     */
    public static string validateAndSetEmail(String email) {        
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern p = Pattern.compile(emailPattern);
        Matcher m = p.matcher(email);
        String validatedEmail = '';
        if (m.matches()) {
            validatedEmail = email;
        }
        return validatedEmail;
    }
    
    /**
     * @description calculateAge
     * @param demographicInfo
     * @return age String
     */
    public static String calculateAge(SCC_CustomerProfileWrapper.Demografi demographicInfo){
        String age = '';
        if(demographicInfo.tanggalLahir != null){
            Date dateOfBirth = Date.valueOf(demographicInfo.tanggalLahir);
            Date birthDate = dateOfBirth.day() <= System.today().day() ? dateOfBirth : dateOfBirth.addMonths(-1);
            Integer years = System.today().year() - birthDate.year();
            age = String.valueOf(years);
        }   
        return age;
    }
    
    /**
     * @description removeSpace
     * @param mobileNumber
     * @return mobileNumber with no space and special characters
     */
    private static String removeSpace(String mobileNumber) {
        return mobileNumber.replaceAll('[^0-9]', '');
    }
}