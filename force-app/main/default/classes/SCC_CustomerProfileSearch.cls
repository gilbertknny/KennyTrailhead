/**
 * @description SCC_CustomerProfileSearch
 */
public without sharing class SCC_CustomerProfileSearch {
    /**
     * @description makeCallout Method to Make Http callout.
     * @param accountNumber
     * @param debitCreditNumber
     * @param idValue
     * @param phoneNumber
     * @param cifNo
     * @return List of SCC_CustomerSearchResult
     */
    @AuraEnabled
    public static List<SCC_CustomerSearchResult> makeCallout(String accountNumber, String debitCreditNumber, String idValue, String phoneNumber, String cifNo) {
        List<SCC_CustomerSearchResult> searchResults = new List<SCC_CustomerSearchResult>();
        try{
            String apiType = 'Outbound';
            Map<String, String> bodyValueMap = new Map<String, String>();
            if(!String.isEmpty(accountNumber)){
                bodyValueMap.put('acctno', accountNumber);           
            }else if(!String.isEmpty(debitCreditNumber)){
                bodyValueMap.put('cardNo', debitCreditNumber);   
            }else if(!String.isEmpty(idValue)){
                bodyValueMap.put('idType', 'KT');
                bodyValueMap.put('idValue', idValue);        
            }else if(!String.isEmpty(phoneNumber)){
                bodyValueMap.put('phoneNumber', phoneNumber);  
            }else if(!String.isEmpty(cifNo)){
                bodyValueMap.put('cifNo', cifNo);  
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
            Http http = new Http();
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                SCC_CustomerProfileWrapper parsedData = SCC_CustomerProfileWrapper.parse(response.getBody());
                if(parsedData != null && parsedData.statusCode == 200){
                    List<SCC_CustomerProfileInfo> customerProfiles = parseCustomerProfile(parsedData.data);
                    // Collect all unique cifNumber values
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
                            // Account exists, update it
                            Account existingAccount = existingAccountMap.get(cifNumber);
                            updateAccount(existingAccount, demographicInfo);
                            searchResults.add(new SCC_CustomerSearchResult(demographicInfo.namaSesuaiIdentitas, existingAccount.Id, demographicInfo.handphone));
                        } else {
                            // Account doesn't exist, create a new one
                            Id accId = createAccount(demographicInfo, cifNumber);
                            searchResults.add(new SCC_CustomerSearchResult(demographicInfo.namaSesuaiIdentitas, accId, demographicInfo.handphone));
                        }
                    }
                }else{
                    captureErrorLog(endpointUrl, apiType, body, response.getBody());
                    return null;
                }
            }else{
                captureErrorLog(endpointUrl, apiType, body, response.getBody());
                return null;
            }
        }catch(Exception e) {
            // Return the exception message in SCC_CustomerSearchResult
            searchResults.add(new SCC_CustomerSearchResult(null, null, null, 'Exception occurred: ' + e.getMessage()));
        }   
        return searchResults;
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
        if (!cifNumbers.isEmpty() && Schema.sObjectType.Account.isAccessible()) {
            List<Account> existingAccounts = [SELECT Id, SCC_cifno__c, PersonEmail FROM Account WHERE SCC_cifno__c IN :cifNumbers];
            for (Account acct : existingAccounts) {
                existingAccountMap.put(acct.SCC_cifno__c, acct);
            }
        }
        return existingAccountMap;
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
               throw new AuraHandledException('Error occurred while capturing error log: ' + e.getMessage());
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
        }else { //demographicInfo.tipeNasabah == 'O'
            existingAccount.Name = demographicInfo.namaSesuaiIdentitas;	    
            existingAccount.SCC_Tipe_Nasabah__c = 'Non-Individu';
            existingAccount.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
            existingAccount.RecordTypeId = SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'IndustriesBusiness');
        }
        existingAccount.Phone = (demographicInfo.handphone != null || demographicInfo.handphone != 'NULL') ? demographicInfo.handphone : ' ';
        existingAccount.SCC_Jenis_Nasabah__c = (demographicInfo.nasabahPrioritas == null || demographicInfo.nasabahPrioritas == '' || demographicInfo.nasabahPrioritas == 'NULL') ? 'Non-Prioritas' : 'Prioritas';
        existingAccount.Provinsi__c = demographicInfo.propinsiSesuaiID != null? demographicInfo.propinsiSesuaiID:'';
        system.debug('cek propinsi existingAccount def: '+ demographicInfo.propinsiSesuaiID);
    //    String address1 = demographicInfo.alamatId1 != null ? demographicInfo.alamatId1 : '';
     //   String address2 = demographicInfo.alamatId2 != null ? demographicInfo.alamatId2 : '';
     //   String address3 = demographicInfo.alamatId3 != null ? demographicInfo.alamatId3 : '';
    //    String address4 = demographicInfo.alamatId4 != null ? demographicInfo.alamatId4 : '';
   //     if(!String.isBlank(address1) || !String.isBlank(address2) || !String.isBlank(address3) || !String.isBlank(address4)){
    //        existingAccount.SCC_Address__c = address1 + ' ' + address2 + ' ' + address3 + ' ' + address4;
   //     }
        //Surya 13 July 2024 Datahub change mapping address from alamatid1-alamatid4 into alamatsesuaiId
        String addressId1=demographicInfo.alamatSesuaiID != null? demographicInfo.alamatsesuaiID:'';
        String addressId2=demographicInfo.alamatSesuaiID2 != null? demographicInfo.alamatSesuaiID2:'';
        if(!String.isBlank(addressId1) || !String.isBlank(addressId2))
        existingAccount.SCC_Address__c =addressId1 +' '+ addressId2;
        //Surya 13 July 2024 end//
        
        // Check for update permissions
        if (Schema.sObjectType.Account.isUpdateable()) {
            update existingAccount;
        }

    }
    
    /**
     * @description createAccount
     * @param demographicInfo
     * @param cifNumber
     * @return Newly Created Account Id
     */
    @TestVisible
    private static Id createAccount(SCC_CustomerProfileWrapper.Demografi demographicInfo, String cifNumber) {
        
        // Create new Account record with demographic information        
        Account newAccount = new Account();
        if(demographicInfo.tipeNasabah == 'P'){
        	newAccount.LastName = demographicInfo.namaSesuaiIdentitas;
            newAccount.SCC_Tipe_Nasabah__c = 'Individu';
            newAccount.PersonEmail = validateAndSetEmail(demographicInfo.email);
            newAccount.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
            newAccount.RecordTypeId = SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'PersonAccount');
            newAccount.SCC_TanggalLahir__c = calculateAge(demographicInfo);
        }else{
            newAccount.Name = demographicInfo.namaSesuaiIdentitas;	    
            newAccount.SCC_Tipe_Nasabah__c = 'Non-Individu';
            newAccount.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
            newAccount.RecordTypeId = SCC_UtilityClassIntegration.getRecordTypeIdByName('Account', 'IndustriesBusiness');
        }
        newAccount.SCC_cifno__c = cifNumber;
        newAccount.Phone = (demographicInfo.handphone != null || demographicInfo.handphone != 'NULL') ? demographicInfo.handphone : ' ';
        newAccount.SCC_Jenis_Nasabah__c = (demographicInfo.nasabahPrioritas == null || demographicInfo.nasabahPrioritas == '' || demographicInfo.nasabahPrioritas == 'NULL') ? 'Non-Prioritas' : 'Prioritas';
        newAccount.Provinsi__c = demographicInfo.propinsiSesuaiID != null? demographicInfo.propinsiSesuaiID:'';
        system.debug('cek propinsi newAccount def: '+ demographicInfo.propinsiSesuaiID);
   //     String address1 = demographicInfo.alamatId1 != null ? demographicInfo.alamatId1 : '';
     //   String address2 = demographicInfo.alamatId2 != null ? demographicInfo.alamatId2 : '';
   //     String address3 = demographicInfo.alamatId3 != null ? demographicInfo.alamatId3 : '';
   //     String address4 = demographicInfo.alamatId4 != null ? demographicInfo.alamatId4 : '';
  //      if(!String.isBlank(address1) || !String.isBlank(address2) || !String.isBlank(address3) || !String.isBlank(address4)){
 //           newAccount.SCC_Address__c = address1 + ' ' + address2 + ' ' + address3 + ' ' + address4;
  //      }
          //Surya 13 July 2024 Datahub change mapping address from alamatid1-alamatid4 into alamatsesuaiId
          String addressId1=demographicInfo.alamatSesuaiID != null? demographicInfo.alamatsesuaiID:'';
          String addressId2=demographicInfo.alamatSesuaiID2 != null? demographicInfo.alamatSesuaiID2:'';
          if(!String.isBlank(addressId1) || !String.isBlank(addressId2))
          newAccount.SCC_Address__c =addressId1 +' '+ addressId2;
          //Surya 13 July 2024 end//
        // Check for create permissions
        if (Schema.sObjectType.Account.isCreateable()) {
            insert newAccount;
        }
        return newAccount.Id;
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
     * @description ScaptureErrorLog
     * @param endpointUrl
     * @param apiType
     * @param requestBody
     * @param responseBody
     */
    public static void captureErrorLog(String endpointUrl, String apiType, String requestBody, String responseBody){
        try {
            List<Error_Log__c> errorLogsToInsert = new List<Error_Log__c>();
            
            Error_Log__c el = new Error_Log__c();
            el.Class_Name__c = SCC_CustomerProfileSearch.class.getName();
            el.Endpoint__c = endpointUrl;
            el.API_Type__c  = apiType;
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
            if (Schema.sObjectType.Error_Log__c.isCreateable()) {
                insert errorLogsToInsert;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error occurred while capturing error log: ' + e.getMessage());
        }
    }
}