public without sharing class SCC_MachineDataByAddress {
    
	@AuraEnabled(cacheable=true)
    public static List<SCC_MachineDataWrapper> getAddressSuggestions(String address) {
        List<SCC_MachineDataWrapper> addressList = new List<SCC_MachineDataWrapper>();
        try {
            Map<String, String> bodyMap = new Map<String, String>{
                'alamatMesin' => address
            };
            String body = JSON.serialize(bodyMap);
            String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Machine_Data_By_Address_API');
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                // Parse the JSON response using SCC_MachineDataByAddressWrapper
                SCC_MachineDataByAddressWrapper parsedData = SCC_MachineDataByAddressWrapper.parse(response.getBody());
                for(SCC_MachineDataByAddressWrapper.MachineDataByAddress machineData : parsedData.machineDataByAddress) {
                    addressList.add(new SCC_MachineDataWrapper(machineData.tid, machineData.alamatMesin, machineData.kontakId));
                }
            } else {
                throw new CalloutException('Permintaan ke sistem eksternal gagal dengan status: ' + response.getStatus());
            }
        } catch(Exception e) {
            throw new AuraHandledException('Terjadi kesalahan saat mengambil alamat saran.' + e.getMessage());
        }
        return addressList;
    }
}