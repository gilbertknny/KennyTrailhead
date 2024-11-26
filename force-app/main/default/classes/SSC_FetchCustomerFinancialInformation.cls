public without sharing class SSC_FetchCustomerFinancialInformation {
    @AuraEnabled
    public static String getCalloutPhoneNo(Id accountid){
        List<Case> caseList =  [Select SCC_Cust_Phone1__c, Account.SCC_cifno__c from Case where accountid=: accountid order by createddate desc limit 1];
        if (caseList.size()>0) {
            String caseMobileNo=caseList.get(0).SCC_Cust_Phone1__c;
            if (String.isNotBlank(caseMobileNo)) {
                return caseMobileNo;
            } else {
                // if there is no mobile number found on the latest case then Mobile Number
                // from the Account shall be used to query to DataHub
                return getAccountMobileNo(accountid);
            }
        } else {
            //If the there is no case linked  then Mobile Number
            // from the Account shall be used to query to DataHub
            return getAccountMobileNo(accountid);
        }
    }
    
    public static String getAccountMobileNo(Id accountid) {
        List<Account> accountList =  [Select phone from account where id=: accountid];
        
        if (String.isNotBlank(accountList.get(0).phone)) {
            return accountList.get(0).phone;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<SCC_CustomerFinancialWrapper.Data> fetchDataFromAPI (String phoneNumber, Id accountId) {
        SCC_CustomerFinancialWrapper parsedData = new SCC_CustomerFinancialWrapper();
        String apiType='Outbound' ;
        Map<String, String> bodyValueMap = new Map<String, String>();
        
        if(!String.isEmpty(phoneNumber)){
            phoneNumber = removeSpace(phoneNumber);
            bodyValueMap.put('phoneNumber', phoneNumber);
        }
        bodyValueMap.put('personalNumber', '00000000');
        bodyValueMap.put('channelId', 'CHMS');
        String body = JSON.serialize(bodyValueMap);
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Customer_Profile_API');
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpointUrl);
        request.setHeader('X-DATAHUB-PORTOFOLIO-ALL', 'true');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);
        // Check the response status
        if (response.getStatusCode() == 200) {
            parsedData = SCC_CustomerFinancialWrapper.parse(response.getBody());
            if(parsedData != null && parsedData.statusCode == 200){
                String accountCIF = getAccountCIF(accountId);
                List<SCC_CustomerFinancialWrapper.Data> matchedData = new List<SCC_CustomerFinancialWrapper.Data>();
                for (SCC_CustomerFinancialWrapper.Data dataItem : parsedData.data) {
                    if (dataItem.cifno == accountCIF) {
                        matchedData.add(dataItem);
                    }
                }
                return matchedData;
            }else{
                captureErrorLog(endpointUrl, apiType, body, response.getBody());
                throw new AuraHandledException(response.getBody());
            }
        }else{
            captureErrorLog(endpointUrl, apiType, body, response.getBody());
            throw new AuraHandledException(response.getBody());
        }
    }
    
    public static String getAccountCIF(Id accountId) {
        List<Account> accountList = [SELECT SCC_cifno__c FROM Account WHERE Id = :accountId];
        if (accountList.size() > 0) {
            return accountList.get(0).SCC_cifno__c;
        } else {
            return null;
        }
    }
    
    public static void captureErrorLog(String endpointUrl, String apiType, String requestBody, String responseBody){
        try {
            List<Error_Log__c> errorLogsToInsert = new List<Error_Log__c>();
            
            Error_Log__c el = new Error_Log__c();
            el.Class_Name__c = SSC_FetchCustomerFinancialInformation.class.getName();
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
            } else {
                System.debug('Response body is empty.');
            }
            
            errorLogsToInsert.add(el);
            insert errorLogsToInsert;
            System.debug('Error log inserted successfully.');
        } catch (Exception e) {
            System.debug('Error occurred while capturing error log: ' + e.getMessage());
        }
    }
    
    private static String removeSpace(String phoneNumber) {
        return phoneNumber.replaceAll('[^0-9]', '');
    }
}