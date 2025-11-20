public without sharing class SCC_GetCustomerDataByPhone {

    @AuraEnabled
    public static List<SCC_CustomerDataWrapper> getCustomerDataByPhone(String caseId) {
        List<SCC_CustomerDataWrapper> customerDataList = new List<SCC_CustomerDataWrapper>();

        String phoneNumber = getMobileNumber(caseId);
        if(String.isEmpty(phoneNumber)){
            throw new AuraHandledException('Nomor telepon untuk memanggil API tidak ditemukan');
        }  	

        // Fetch the CIF from the Account linked to the Case
        String caseCif = getCaseCif(caseId);
        if (String.isEmpty(caseCif)) {
            throw new AuraHandledException('CIF tidak ditemukan untuk ID Kasus / Case yang diberikan.'); //CIF not found for the provided Case ID.
        }

        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            bodyValueMap.put('phoneNumber', phoneNumber);
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

            if (response.getStatusCode() == 200) {
                SCC_CustomerProfileWrapper parsedData = SCC_CustomerProfileWrapper.parse(response.getBody());
                if (parsedData != null && parsedData.statusCode == 200) {
                    for (SCC_CustomerProfileWrapper.Data customerData : parsedData.data) {
                        // Only process records with matching CIF
                        if (customerData.cifno == caseCif) {
                            if (customerData.portofolioPerbankan != null && customerData.portofolioPerbankan.simpanan != null) {
                                for (SCC_CustomerProfileWrapper.Simpanan simpanan : customerData.portofolioPerbankan.simpanan) {
                                    String statusValue = simpanan.status.equals('1') ? 'Aktif' : 'Tidak Aktif';
                                    simpanan.status = statusValue;
                                    SCC_CustomerDataWrapper wrapper = new SCC_CustomerDataWrapper(
                                        simpanan.accountNumber,
                                        simpanan.cifno,
                                        simpanan.product,
                                        simpanan.productType,
                                        simpanan.status,
                                        simpanan.openAccountDate
                                    );
                                    customerDataList.add(wrapper);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Terjadi kesalahan saat melakukan panggilan API: ' + e.getMessage()); //An error occurred while making the API call: 
        }
        return customerDataList;
    }
    
    private static String getMobileNumber(Id caseId) {
        String mobileNumber = '';
        try {
            if (!Schema.sObjectType.Case.fields.Id.isAccessible() ||
                !Schema.sObjectType.Case.fields.AccountId.isAccessible() ||
                !Schema.sObjectType.Case.fields.SCC_Cust_Phone1__c.isAccessible()) {
                throw new AuraHandledException('Access to Case fields is denied.');
            }
            Case caseRecord = [SELECT Id, AccountId, SCC_Cust_Phone1__c FROM Case WHERE Id = :caseId LIMIT 1];
        
            if (caseRecord != null && !String.isBlank(caseRecord.SCC_Cust_Phone1__c)) {
                // If the Case has a phone number, use it
                mobileNumber = caseRecord.SCC_Cust_Phone1__c;
            } else if (caseRecord != null && caseRecord.AccountId != null) {
                if (!Schema.sObjectType.Account.fields.Phone.isAccessible()) {
                    throw new AuraHandledException('Access to Account fields is denied.');
                }
                // If the Case does not have a phone number, query the Account
                Account acc = [SELECT Id, Phone FROM Account WHERE Id = :caseRecord.AccountId LIMIT 1];
                if (acc != null) {
                    mobileNumber = acc.Phone;
                }
            }
        } catch (Exception e) {
            return e.getMessage();
        }
        return mobileNumber;
    }

    private static String getCaseCif(String caseId) {
        String caseCif = '';
        // Query to get the CIF from the Account linked to the Case
        try {
            if (!Schema.sObjectType.Case.fields.Id.isAccessible() ||
                !Schema.sObjectType.Account.fields.SCC_cifno__c.isAccessible()) {
                throw new AuraHandledException('Access to Case or Account fields is denied.');
            }
            Case caseRecord = [SELECT Account.SCC_cifno__c FROM Case WHERE Id = :caseId LIMIT 1];
            if (caseRecord != null && caseRecord.Account != null) {
                caseCif = caseRecord.Account.SCC_cifno__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Terjadi kesalahan saat mengambil data CIF dari Kasus / Case: ' + e.getMessage()); //An error occurred while fetching CIF from the Case: 
        }
        return caseCif;
    }
}