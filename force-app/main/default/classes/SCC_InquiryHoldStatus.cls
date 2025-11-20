public without sharing class SCC_InquiryHoldStatus {
    @AuraEnabled
    public static SCC_InquiryStatusWrapper getInquiryStatus(String accountNumber) {
        SCC_InquiryStatusWrapper statusWrapper;
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Inquiry_Hold_Status_API');
        HttpRequest request = new HttpRequest();
        HttpResponse response=new HttpResponse();
        try {
            SCC_UuidV4 uuidGenerator = new SCC_UuidV4();
            String externalId = uuidGenerator.generateValue();
            Map<String, String> bodyMap = new Map<String, String>{
                'acctNo' => accountNumber, 
                'externalId' => externalId,
                'channelId' => 'CHMS',
                'holdSeq' => '3',
                'serviceId' => '0002P',
                'tellerId' => '0206051'
            };
            String body = JSON.serialize(bodyMap);
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_InquiryHoldStatus'));
            if (response.getStatusCode() == 200) {
                SCC_InquiryHoldStatusWrapper inquiryHoldStatusWrapper = SCC_InquiryHoldStatusWrapper.parse(response.getBody());
                SCC_InquiryHoldStatusWrapper.InquiryHoldStatus holdStatus = inquiryHoldStatusWrapper.inquiryHoldStatus;
                
                statusWrapper = new SCC_InquiryStatusWrapper(
                    holdStatus.saldoAkhirMutasi,
                    holdStatus.holdType,
                    holdStatus.holdAmt,
                    holdStatus.holdRemark
                );
            } else {
                // Handle non-200 HTTP response codes
                throw new CalloutException('Gagal mengambil status pertanyaan. Status HTTP: ' + response.getStatus()); //Failed to retrieve inquiry status. HTTP Status: 
            }
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_InquiryHoldStatus'));
            throw new AuraHandledException('Terjadi kesalahan saat mengambil status pertanyaan:' + e.getMessage()); //Error retrieving inquiry status: 
        }
        return statusWrapper;
    }
}