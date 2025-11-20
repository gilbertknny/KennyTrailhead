public class SCC_GetCustomerDatabyAccCard {
	@AuraEnabled
    public static List<SCC_CustomerDataWrapper> getCustomerDataByAccCard(String accountNumber, String debitNumber) {
        List<SCC_CustomerDataWrapper> customerDataList = new List<SCC_CustomerDataWrapper>();
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Customer_Profile_API');
        HttpRequest request = new HttpRequest();
        HttpResponse response=new HttpResponse();
        try {
            Map<String, String> bodyValueMap = new Map<String, String>();
            if(!String.isEmpty(accountNumber)){
                bodyValueMap.put('acctno', accountNumber);           
            }else if(!String.isEmpty(debitNumber)){
                bodyValueMap.put('cardno', debitNumber);   
            }
            bodyValueMap.put('personalNumber', '00000000');
            bodyValueMap.put('channelId', 'CHMS');

            String body = JSON.serialize(bodyValueMap);

          
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('X-DATAHUB-PORTOFOLIO-ALL', 'true');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetCustomerDataByAccCard'));  
         
            if (response.getStatusCode() == 200) {
                SCC_CustomerProfileWrapper parsedData = SCC_CustomerProfileWrapper.parse(response.getBody());
                if (parsedData != null && parsedData.statusCode == 200) {
                    for (SCC_CustomerProfileWrapper.Data customerData : parsedData.data) {
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
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetCustomerDataByAccCard'));  
            throw new AuraHandledException('Terjadi kesalahan saat melakukan panggilan API: ' + e.getMessage()); //An error occurred while making the API call: 
        }
        return customerDataList;
    }
}