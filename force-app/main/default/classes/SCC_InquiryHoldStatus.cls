public without sharing class SCC_InquiryHoldStatus {
    @AuraEnabled(cacheable=true)
    public static SCC_InquiryStatusWrapper getInquiryStatus(String accountNumber) {
        SCC_InquiryStatusWrapper statusWrapper;
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
            String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Inquiry_Hold_Status_API');
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                SCC_InquiryHoldStatusWrapper inquiryHoldStatusWrapper = SCC_InquiryHoldStatusWrapper.parse(response.getBody());
                SCC_InquiryHoldStatusWrapper.InquiryHoldStatus holdStatus = inquiryHoldStatusWrapper.inquiryHoldStatus;
                String HoldDate='';
                if(Holdstatus.holddate!=null)
                HoldDate=Holdstatus.holddate.substring(1,3)+'-'+holdstatus.holddate.substring(3,5)+'-'+holdstatus.holddate.substring(5,7);
                if(Holdstatus.saldoAkhirMutasi==null)
                Holdstatus.saldoAkhirMutasi='';
                if(Holdstatus.holdType==null)
                Holdstatus.holdType='';
                if(Holdstatus.holdAmt==null)
                Holdstatus.holdAmt='';
                if(Holdstatus.holdRemark==null)
                Holdstatus.holdRemark='';
                statusWrapper = new SCC_InquiryStatusWrapper(
                    holdStatus.saldoAkhirMutasi,
                    holdStatus.holdType,
                    holdStatus.holdAmt,
                    holdStatus.holdRemark,
                    HoldDate
                );
            } else {
                // Handle non-200 HTTP response codes
                throw new CalloutException('Gagal mengambil status pertanyaan. Status HTTP: ' + response.getStatus()); //Failed to retrieve inquiry status. HTTP Status: 
            }
        } catch (Exception e) {
            throw new AuraHandledException('Terjadi kesalahan saat mengambil status pertanyaan:' + e.getMessage()); //Error retrieving inquiry status: 
        }
        return statusWrapper;
    }
}