public without sharing class SSC_FetchCustomerProfileInformation {

    @AuraEnabled(cacheable=true)
    public static String fetchDataFromAPI(String accountNumber, String creditCardNumber, String nikNumber, String phoneNumber) {
        system.debug('accountNumber====='+accountNumber);
        system.debug('creditCardNumber====='+creditCardNumber);
        system.debug('nikNumber====='+nikNumber);
        system.debug('phoneNumber====='+phoneNumber);

        String body = '';
        if(!String.isEmpty(accountNumber)){
            Map<String, String> accountValueMap = new Map<String, String>();
            accountValueMap.put('acctno', accountNumber);
            accountValueMap.put('personalNumber', 'SYSTEM');
            accountValueMap.put('channelId', 'CHMS');
            body = JSON.serialize(accountValueMap); // account no = 25444945962602
        }else if(!String.isEmpty(creditCardNumber)){
            Map<String, String> cardValueMap = new Map<String, String>();
            cardValueMap.put('cardNo', creditCardNumber);
            cardValueMap.put('personalNumber', 'SYSTEM');
            cardValueMap.put('channelId', 'CHMS');
            body = JSON.serialize(cardValueMap); //card No = 3821928373856192
        }else if(!String.isEmpty(nikNumber)){
            Map<String, String> nikValueMap = new Map<String, String>();
            nikValueMap.put('idType', 'KT');
            nikValueMap.put('idValue', nikNumber);
            nikValueMap.put('personalNumber', 'SYSTEM');
            nikValueMap.put('channelId', 'CHMS');
            body = JSON.serialize(nikValueMap); //NIK = 3174060404840001
        }else if(!String.isEmpty(phoneNumber)){
            Map<String, String> phoneValueMap = new Map<String, String>();
            phoneValueMap.put('phoneNumber', phoneNumber);
            phoneValueMap.put('personalNumber', 'SYSTEM');
            phoneValueMap.put('channelId', 'CHMS');
            body = JSON.serialize(phoneValueMap); // phone no = 08123456789
        }

        // Define the endpoint URL
        String endpointUrl = 'callout:ClosedDevBRI/gateway/apiDataHub/1.0/customer-profile/profile';

        // Create a new HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        // Set any request headers, parameters, and body as needed
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);

        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);

        String responseString = '';
        // Check the response status
        if (response.getStatusCode() == 200) {
            responseString = parseCustomerProfile(response.getBody());
        } else {
            // Handle error response
            System.debug('Error response: ' + response.getBody());
        }        
        return responseString;
    }


    public static String parseCustomerProfile(String json) {
        SCC_CustomerProfileWrapperClass.Demografi demographicInfo = new SCC_CustomerProfileWrapperClass.Demografi();
        // Call the parse method to deserialize JSON data
        SCC_CustomerProfileWrapperClass parsedData = SCC_CustomerProfileWrapperClass.parse(json);

        // Access the parsed data
        List<SCC_CustomerProfileWrapperClass.Data> dataList = parsedData.data;
        for (SCC_CustomerProfileWrapperClass.Data data : dataList) {
            // Accessing data object
            demographicInfo = data.demografi;
            SCC_CustomerProfileWrapperClass.PortofolioPerbankan bankingPortfolio = data.portofolioPerbankan;
            // Accessing banking portfolios
            List<SCC_CustomerProfileWrapperClass.Simpanan> savings = bankingPortfolio.simpanan;
            // Accessing other portfolio types...
        }
        System.debug('demographicInfo: ' + demographicInfo);
        return demographicInfo.namaSesuaiIdentitas;
    }
}